from dataclasses import dataclass
import pandas as pd
import numpy as np
import os
from typing import List, Tuple
from scipy.stats import f, t, chi2, norm
import random
import pingouin as pg

alpha = 0.05

@dataclass(frozen=True)
class Project:
    url: str
    x1: float
    x2: float
    y: float
    zx1: float = 0.0
    zx2: float = 0.0
    zy: float = 0.0
    ts: float = 0.0


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


def mardia_test(data: np.ndarray, cov: bool = True) -> Tuple[float, float, float, float]:
    """
    https://rdrr.io/cran/MVN/src/R/mvn.R
    https://stats.stackexchange.com/questions/317147/how-to-get-a-single-p-value-from-the-two-p-values-of-a-mardias-multinormality-t
    Mardia's multivariate skewness and kurtosis.
    Calculates the Mardia's multivariate skewness and kurtosis coefficients
    as well as their corresponding statistical test. For large sample size
    the multivariate skewness is asymptotically distributed as a Chi-square
    random variable; here it is corrected for small sample size. However,
    both uncorrected and corrected skewness statistic are presented. Likewise,
    the multivariate kurtosis it is distributed as a unit-normal.

     Syntax: function [Mskekur] = Mskekur(X,c,alpha)

     Inputs:
          X - multivariate data matrix [Size of matrix must be n(data)-by-p(variables)].
          cov - boolean to whether to normalize the covariance matrix by n (c=1[default]) or by n-1 (c~=1)

     Outputs:
          - skewness test statistic
          - kurtosis test statistic
          - significance value for skewness
          - significance value for kurtosis
    """
    n, p = data.shape

    # correct for small sample size
    small: bool = True if n < 20 else False

    if cov:
        S = ((n - 1)/n) * np.cov(data.T)
    else:
        S = np.cov(data.T)

    # calculate mean
    data_mean = data.mean(axis=0)
    # inverse - check if singular matrix
    try:
        iS = np.linalg.inv(S)
    except Exception as e:
        # print for now
        print(e)
        return 0.0, 0.0, 0.0, 0.0
    # squared-Mahalanobis' distances matrix
    D: np.ndarray = (data - data_mean) @ iS @ (data - data_mean).T
    # multivariate skewness coefficient
    g1p: float = np.sum(D**3)/n**2
    # multivariate kurtosis coefficient
    g2p: float = np.trace(D**2)/n
    # small sample correction
    k: float = ((p + 1)*(n + 1)*(n + 3))/(n*(((n + 1)*(p + 1)) - 6))
    # degrees of freedom
    df: float = (p * (p + 1) * (p + 2))/6

    if small:
        # skewness test statistic corrected for small sample: it approximates to a chi-square distribution
        g_skew = (n * g1p * k)/6
    else:
        # skewness test statistic:it approximates to a chi-square distribution
        g_skew = (n * g1p)/6

    # significance value associated to the skewness corrected for small sample
    p_skew: float = 1.0 - chi2.cdf(g_skew, df)

    # kurtosis test statistic: it approximates to a unit-normal distribution
    g_kurt = (g2p - (p*(p + 2)))/(np.sqrt((8 * p * (p + 2))/n))
    # significance value associated to the kurtosis
    p_kurt: float = 2 * (1.0 - norm.cdf(np.abs(g_kurt)))

    return g_skew, g_kurt, p_skew, p_kurt

def mardia_skewness_kurtosis(X):
    """
    Calculate Mardia's multivariate skewness and kurtosis for the dataset X.
    
    Parameters:
        X (np.ndarray): A 2D numpy array where each row represents an observation and each column represents a variable.
    
    Returns:
        tuple: (beta_1_k, beta_2_k) where beta_1_k is the multivariate skewness and beta_2_k is the multivariate kurtosis.
    """
    N, k = X.shape
    mean_vector = np.mean(X, axis=0)
    S = np.cov(X, rowvar=False, bias=True)  # Sample covariance matrix
    
    # Calculate the inverse of the covariance matrix
    S_inv = np.linalg.inv(S)
    
    # Center the data
    centered_data = X - mean_vector
    
    # Calculate multivariate skewness (beta_1_k)
    skewness_sum = 0
    for i in range(N):
        for j in range(N):
            skewness_sum += (centered_data[i].T @ S_inv @ centered_data[j]) ** 3
    beta_1_k = skewness_sum / (N ** 2)
    
    # Calculate multivariate kurtosis (beta_2_k)
    mahalanobis_distances = np.array([centered_data[i].T @ S_inv @ centered_data[i] for i in range(N)])
    beta_2_k = np.mean(mahalanobis_distances ** 2)
    
    return beta_1_k, beta_2_k

def mardia_tests(X, alpha=0.005):
    """
    Perform Mardia's test for multivariate skewness and kurtosis.
    
    Parameters:
        X (np.ndarray): A 2D numpy array where each row represents an observation and each column represents a variable.
        alpha (float): Significance level for the hypothesis test (default is 0.005).
    
    Returns:
        dict: Test results with keys 'skewness', 'kurtosis', 'normality' and the test statistics and p-values.
    """
    N, k = X.shape
    beta_1_k, beta_2_k = mardia_skewness_kurtosis(X)
    
    # Test statistic for skewness
    skewness_stat = N / 6 * beta_1_k
    skewness_df = k * (k + 1) * (k + 2) / 6
    skewness_critical_value = chi2.ppf(1 - alpha, df=skewness_df)
    skewness_significant = skewness_stat > skewness_critical_value
    skewness_p_value = 1 - chi2.cdf(skewness_stat, df=skewness_df)
    
    # Test statistic for kurtosis
    expected_kurtosis = k * (k + 2)
    kurtosis_variance = 8 * k * (k + 2) / N
    kurtosis_stat = (beta_2_k - expected_kurtosis) / np.sqrt(kurtosis_variance)
    kurtosis_critical_value = norm.ppf(1 - alpha / 2)  # Two-tailed
    kurtosis_significant = abs(kurtosis_stat) > kurtosis_critical_value
    kurtosis_p_value = 2 * (1 - norm.cdf(abs(kurtosis_stat)))  # two-tailed test
    
    # Determine if the distribution is normal based on skewness and kurtosis tests
    normality = not (skewness_significant or kurtosis_significant)
    
    return {
        "skewness_stat": skewness_stat,
        "skewness_p_value": skewness_p_value,
        "skewness_significant": skewness_significant,
        "skewness_critical_value": skewness_critical_value,
        "kurtosis_stat": kurtosis_stat,
        "kurtosis_p_value": kurtosis_p_value,
        "kurtosis_significant": kurtosis_significant,
        "kurtosis_critical_value": kurtosis_critical_value,
        "normality": normality
    }


def perform_mardia_test(data: np.ndarray):
    g_skew, g_kurt, p_skew, p_kurt = mardia_test(data)
    print(f"\nMardia's test for multivariate normality:")
    print(f"Skewness: {g_skew:.4f} (p-value: {p_skew:.4f})")
    print(f"Kurtosis: {g_kurt:.4f} (p-value: {p_kurt:.4f})")
    p = data.shape[1]
    skewn_crit = chi2.ppf(1 - alpha, p * (p + 1) * (p + 2) / 6)
    kurt_crit = norm.ppf(1 - alpha)
    print(f"Skewness critical value: {skewn_crit:.4f}")
    print(f"Kurtosis critical value: {kurt_crit:.4f}")
    
    if g_skew > skewn_crit or g_kurt > kurt_crit:
        print("Data is not multivariate normal.")
    else:
        print("Data is multivariate normal.")
        
    print(mardia_tests(data))


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
) -> Tuple[List[int], List[Project]]:
    """Determine outliers using Mahalanobis distance."""
    Z = projects_to_array(projects)
    n = Z.shape[0]
    cov_inv = calculate_cov_inv(Z)
    mahalanobis_distances = calculate_mahalanobis_distances(Z, cov_inv)
    test_statistic = calculate_test_statistic(n, mahalanobis_distances)

    fisher_f = f.ppf(1 - alpha, 3, n - 3)
    print(f"Fisher F value for {n} projects = {fisher_f:.4f}")

    outliers = np.where(test_statistic > fisher_f)[0].tolist()

    projects_with_ts = []
    for i, p in enumerate(projects):
        projects_with_ts.append(
            Project(
                url=p.url,
                x1=p.x1,
                x2=p.x2,
                y=p.y,
                zx1=p.zx1,
                zx2=p.zx2,
                zy=p.zy,
                ts=test_statistic[i],
            )
        )

    return outliers, projects_with_ts


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
    outliers_mahalanobis, ts_projects = determine_outliers_mahalanobis(projects)
    for i in outliers_mahalanobis:
        print(
            f"Removed {projects[i].url} project as mahalanobis outlier: zy: {projects[i].zy:.4f} zx1: {projects[i].zx1:.4f} zx2: {projects[i].zx2:.4f} (TS: {ts_projects[i].ts:.4f})"
        )
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
    for i in outliers_intervals:
        print(
            f"Removed {projects[i].url} project as prediction interval outlier: zy: {projects[i].zy:.4f} zx1: {projects[i].zx1:.4f} zx2: {projects[i].zx2:.4f} (Y_hat: {Y_hat[i]:.4f})"
        )

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
    data = np.array([[p.x1, p.x2, p.y] for p in projects])
    perform_mardia_test(data)

    print(f"Initial number of data points: {len(projects)}")

    normalized_projects = normalize_data(projects)
    final_projects = iterative_outlier_removal(normalized_projects)

    print(f"\nFinal number of data points after outlier removal: {len(final_projects)}")

    # Split the data into training and testing sets
    train_projects, test_projects = split_data(final_projects)

    print(f"\nNumber of training data points: {len(train_projects)}")
    print(f"Number of testing data points: {len(test_projects)}")

    # Save the training and testing sets to CSV files
    # save_to_csv(final_projects, "final_projects.csv")
    # save_to_csv(train_projects, "train_data.csv")
    # save_to_csv(test_projects, "test_data.csv")
    # print("\nData has been split and saved to 'train_data.csv' and 'test_data.csv'")


if __name__ == "__main__":
    main()
