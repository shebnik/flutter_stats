from dataclasses import dataclass
import pandas as pd
import numpy as np
import os
from typing import List, Tuple
from scipy.stats import f, t
import random


@dataclass(frozen=True)
class Project:
    url: str
    x1: float
    x2: float
    y: float
    zx1: float = 0.0
    zx2: float = 0.0
    zy: float = 0.0


def data_path(filename: str) -> str:
    """Return the full path to the data file."""
    return os.path.join(os.path.dirname(__file__), "data", filename)


def retrieve_data(filename: str = "100.csv") -> List[Project]:
    """Load data from CSV file and return a list of Project objects."""
    df = pd.read_csv(data_path(filename))
    projects = [
        Project(
            url=row["URL"],
            x1=row["CBO"] / row["NOC"],
            x2=row["WMC"] / row["NOC"],
            y=row["RFC"] / row["NOC"],
        )
        for _, row in df.iterrows()
    ]
    return projects


def normalize_data(projects: List[Project]) -> List[Project]:
    """Normalize the data using logarithmic scaling."""
    normalized_projects = []
    for project in projects:
        try:
            zx1 = np.log10(project.x1) if project.x1 > 0 else 0.0
            zx2 = np.log10(project.x2) if project.x2 > 0 else 0.0
            zy = np.log10(project.y) if project.y > 0 else 0.0
        except ValueError:
            zx1, zx2, zy = 0.0, 0.0, 0.0

        normalized_projects.append(
            Project(
                url=project.url,
                x1=project.x1,
                x2=project.x2,
                y=project.y,
                zx1=zx1,
                zx2=zx2,
                zy=zy,
            )
        )
    return normalized_projects


def projects_to_array(projects: List[Project]) -> np.ndarray:
    """Convert a list of Project objects to a numpy array."""
    return np.array([[p.zx1, p.zx2, p.zy] for p in projects])


def calculate_cov_inv(Z: np.ndarray) -> np.ndarray:
    """Calculate the inverse of the covariance matrix."""
    try:
        Z_centered = Z - np.mean(Z, axis=0)
        cov = np.cov(Z_centered, rowvar=False)
        return np.linalg.inv(cov)
    except np.linalg.LinAlgError:
        raise ValueError("Covariance matrix is singular and cannot be inverted.")


def calculate_mahalanobis_distances(Z: np.ndarray, cov_inv: np.ndarray) -> np.ndarray:
    """Calculate Mahalanobis distances."""
    Z_centered = Z - np.mean(Z, axis=0)
    left = np.dot(Z_centered, cov_inv)
    mahalanobis = np.sqrt(np.sum(left * Z_centered, axis=1))
    return mahalanobis


def calculate_test_statistic(n: int, mahalanobis_distances: np.ndarray) -> np.ndarray:
    """Calculate the test statistic based on Mahalanobis distances."""
    return ((n - 3) * n / ((n**2 - 1) * 3)) * mahalanobis_distances**2


def determine_outliers_mahalanobis(
    projects: List[Project], alpha: float = 0.05
) -> List[int]:
    """Determine outliers using Mahalanobis distance."""
    Z = projects_to_array(projects)
    n = Z.shape[0]
    cov_inv = calculate_cov_inv(Z)
    mahalanobis_distances = calculate_mahalanobis_distances(Z, cov_inv)
    test_statistic = calculate_test_statistic(n, mahalanobis_distances)

    fisher_f = f.ppf(1 - alpha, 3, n - 3)

    outliers = np.where(test_statistic > fisher_f)[0].tolist()

    return outliers


def calculate_prediction_interval(
    Z: np.ndarray, Y_hat: np.ndarray, alpha: float = 0.05
) -> Tuple[np.ndarray, np.ndarray]:
    """Calculate prediction interval for each data point."""
    X = np.column_stack((np.ones(Z.shape[0]), Z[:, :-1]))
    n, p = X.shape

    residuals = Z[:, -1] - Y_hat
    mse = np.sum(residuals**2) / (n - p)

    leverage = np.diagonal(X @ np.linalg.inv(X.T @ X) @ X.T)
    se = np.sqrt(mse * (1 + leverage))

    t_value = t.ppf(1 - alpha / 2, n - p)
    margin = t_value * se

    lower_bound = Y_hat - margin
    upper_bound = Y_hat + margin

    return lower_bound, upper_bound


def identify_outliers_intervals(
    Z: np.ndarray, lower_bound: np.ndarray, upper_bound: np.ndarray
) -> List[int]:
    """Identify points that fall outside the prediction interval."""
    Y = Z[:, -1]
    outliers = np.where((Y < lower_bound) | (Y > upper_bound))[0].tolist()
    return outliers


def calculate_regression_coefficients(
    Z: np.ndarray,
) -> Tuple[float, float, float, float]:
    """Calculate regression coefficients using Ordinary Least Squares."""
    X = Z[:, :-1]
    Y = Z[:, -1]
    X = np.column_stack((np.ones(X.shape[0]), X))
    try:
        coefficients = np.linalg.inv(X.T @ X) @ X.T @ Y
    except np.linalg.LinAlgError:
        raise ValueError(
            "Matrix inversion failed during regression coefficient calculation."
        )
    return tuple(coefficients)


def remove_outliers(projects: List[Project]) -> List[Project]:
    """Remove outliers"""
    outliers_mahalanobis = determine_outliers_mahalanobis(projects)

    # Get the data array for prediction intervals
    Z = projects_to_array(projects)
    b0, b1, b2 = calculate_regression_coefficients(Z)

    # Calculate predicted values without noise first
    Y_hat_initial = b0 + b1 * Z[:, 0] + b2 * Z[:, 1]

    # Calculate residuals (epsilon) as difference between actual and predicted values
    epsilon = Z[:, -1] - Y_hat_initial

    # Calculate final predicted values including residuals
    Y_hat = Y_hat_initial + epsilon

    lower_bound, upper_bound = calculate_prediction_interval(Z, Y_hat)

    # Get outliers using prediction intervals
    outliers_intervals = identify_outliers_intervals(Z, lower_bound, upper_bound)

    # Combine both sets of outliers
    all_outliers = set(outliers_mahalanobis + outliers_intervals)

    # Return projects with outliers removed
    return [p for i, p in enumerate(projects) if i not in all_outliers]


def iterative_outlier_removal(projects: List[Project]) -> List[Project]:
    """Iteratively remove outliers until no more outliers are found."""
    iteration = 1
    while True:
        print(f"\nStarting iteration {iteration}")
        new_projects = remove_outliers(projects)

        if len(new_projects) == len(projects):
            print("No more outliers found. Stopping iterations.")
            break

        removed_projects = [p for p in projects if p not in new_projects]
        for project in removed_projects:
            print(f"Removed project: {project.url}")

        projects = new_projects
        iteration += 1

    return projects


def split_data(
    projects: List[Project], train_ratio: float = 0.6
) -> Tuple[List[Project], List[Project]]:
    """
    Split the data into training and testing sets, ensuring that the training set
    includes the min and max values for each metric, and the testing set covers the remaining range.
    """
    # Sort projects by each metric
    sorted_by_x1 = sorted(projects, key=lambda p: p.x1)
    sorted_by_x2 = sorted(projects, key=lambda p: p.x2)
    sorted_by_y = sorted(projects, key=lambda p: p.y)

    # Get min and max projects for each metric
    min_max_projects = {
        sorted_by_x1[0],
        sorted_by_x1[-1],
        sorted_by_x2[0],
        sorted_by_x2[-1],
        sorted_by_y[0],
        sorted_by_y[-1],
    }

    # Remove min and max projects from the main list
    remaining_projects = [p for p in projects if p not in min_max_projects]

    # Shuffle the remaining projects
    random.shuffle(remaining_projects)

    # Calculate the number of additional projects needed for the training set
    n_train = max(int(len(projects) * train_ratio) - len(min_max_projects), 0)

    # Split the remaining projects
    train_projects = list(min_max_projects) + remaining_projects[:n_train]
    test_projects = remaining_projects[n_train:]

    return train_projects, test_projects


def save_to_csv(projects: List[Project], filename: str):
    """Save the list of projects to a CSV file."""
    df = pd.DataFrame(
        [
            {
                "URL": p.url,
                "RFC": p.y,
                "CBO": p.x1,
                "WMC": p.x2,
            }
            for p in projects
        ]
    )
    path = data_path(filename)
    df.to_csv(path, index=False)


def main():
    projects = retrieve_data()
    print(f"Initial number of data points: {len(projects)}")

    normalized_projects = normalize_data(projects)
    final_projects = iterative_outlier_removal(normalized_projects)

    print(f"\nFinal number of data points after outlier removal: {len(final_projects)}")

    # Split the data into training and testing sets
    train_projects, test_projects = split_data(final_projects)

    print(f"\nNumber of training data points: {len(train_projects)}")
    print(f"Number of testing data points: {len(test_projects)}")

    # Save the training and testing sets to CSV files
    save_to_csv(final_projects, "final_projects.csv")
    save_to_csv(train_projects, "train_data.csv")
    save_to_csv(test_projects, "test_data.csv")
    print("\nData has been split and saved to 'train_data.csv' and 'test_data.csv'")


if __name__ == "__main__":
    main()
