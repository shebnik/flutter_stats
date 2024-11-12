from dataclasses import dataclass
import pandas as pd
import numpy as np
from typing import List, Tuple
import os
from scipy import stats


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


def retrieve_data(filename: str = "train_data.csv") -> List[Project]:
    """Load data from CSV file and return a list of Project objects."""
    df = pd.read_csv(data_path(filename))
    projects = []
    for _, row in df.iterrows():
        project = Project(
            url=row["URL"],
            x1=row["CBO"],
            x2=row["WMC"],
            y=row["RFC"],
        )
        projects.append(project)
    return projects


def normalize_data(projects: List[Project]) -> List[Project]:
    """Normalize the data."""
    normalized_projects = []
    for project in projects:
        zx1 = np.log10(project.x1)
        zx2 = np.log10(project.x2)
        zy = np.log10(project.y)

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


def calculate_covariance_matrix(X: np.ndarray) -> np.ndarray:
    """Calculate the covariance matrix for normalized variables."""
    return np.cov(X.T)


def calculate_mean_vector(X: np.ndarray) -> np.ndarray:
    """Calculate mean values of normalized variables."""
    return np.mean(X, axis=0)


def calculate_zx_plus(X: np.ndarray, mean_vector: np.ndarray) -> np.ndarray:
    """Calculate z_X+ vector for each observation."""
    return X - mean_vector


def calculate_intervals(
    X: np.ndarray,
    Y: np.ndarray,
    Y_hat: np.ndarray,
    b0: float,
    b1: float,
    b2: float,
    alpha: float = 0.05,
) -> Tuple[np.ndarray, np.ndarray, dict]:
    """
    Calculate prediction and confidence intervals.
    Returns prediction intervals, confidence intervals, and intermediate values.
    """
    n = len(Y)
    v = n - 3  # degrees of freedom

    # Calculate intermediate values
    mean_vector = calculate_mean_vector(X)
    cov_matrix = calculate_covariance_matrix(X)
    zx_plus = calculate_zx_plus(X, mean_vector)

    # Calculate residual variance (S_Z_Y^2)
    residuals = Y - Y_hat
    s_zy = np.sqrt(np.sum(residuals**2) / v)

    # Get t-value
    t_value = stats.t.ppf(1 - alpha / 2, v)

    # Calculate intervals for each observation
    pred_intervals = []
    conf_intervals = []

    for i in range(n):
        # Calculate quadratic form (z_X+)^T * S_Z^-1 * z_X+
        quad_form = zx_plus[i] @ np.linalg.inv(cov_matrix) @ zx_plus[i].T

        # Calculate common terms
        common_term = t_value * s_zy

        # Prediction interval
        pred_term = np.sqrt(1 + 1 / n + quad_form)
        pred_lower = 10 ** (Y_hat[i] - common_term * pred_term)
        pred_upper = 10 ** (Y_hat[i] + common_term * pred_term)
        pred_intervals.append((pred_lower, pred_upper))

        # Confidence interval
        conf_term = np.sqrt(1 / n + quad_form)
        conf_lower = 10 ** (Y_hat[i] - common_term * conf_term)
        conf_upper = 10 ** (Y_hat[i] + common_term * conf_term)
        conf_intervals.append((conf_lower, conf_upper))

    # Store intermediate values for output
    intermediate_values = {
        "degrees_of_freedom": v,
        "t_value": t_value,
        "residual_std": s_zy,
        "mean_vector": mean_vector,
        "covariance_matrix": cov_matrix,
    }

    return np.array(pred_intervals), np.array(conf_intervals), intermediate_values


def calculate_regression_coefficients(
    X: np.ndarray, Y: np.ndarray
) -> Tuple[float, float, float]:
    """Calculate regression coefficients."""
    X = np.column_stack((np.ones(X.shape[0]), X))
    coffs = np.linalg.inv(X.T @ X) @ X.T @ Y
    return coffs[0], coffs[1], coffs[2]


def calculate_regression_metrics(
    Y: np.ndarray, Y_hat: np.ndarray
) -> Tuple[float, float, float]:
    """Calculate regression model metrics."""
    n = len(Y)
    Y_hat_original = 10**Y_hat
    Y_original = 10**Y

    residuals = Y_original - Y_hat_original
    y_mean = np.mean(Y_original)

    r_squared = 1 - (np.sum(residuals**2) / np.sum((Y_original - y_mean) ** 2))
    mmre = np.mean(np.abs(residuals / Y_original))
    pred = np.sum(np.abs(residuals / Y_original) < 0.25) / n

    return r_squared, mmre, pred


def print_intermediate_values(intermediate_values: dict):
    """Print intermediate values used in interval calculations."""
    print("\nIntermediate Values:")
    print(f"Degrees of Freedom: {intermediate_values['degrees_of_freedom']}")
    print(f"t-value: {intermediate_values['t_value']:.4f}")
    print(f"Residual Standard Deviation: {intermediate_values['residual_std']:.4f}")
    print("\nMean Vector:")
    print(intermediate_values["mean_vector"])
    print("\nCovariance Matrix:")
    print(intermediate_values["covariance_matrix"])


def print_intervals(
    projects: List[Project],
    pred_intervals: np.ndarray,
    conf_intervals: np.ndarray,
    Y_hat: np.ndarray,
):
    """Print predicted values with their intervals."""
    print("\nPrediction Results:")
    print("URL | Actual | Predicted | Pred Interval | Conf Interval")
    print("-" * 80)

    for i, project in enumerate(projects):
        print(
            f"{project.url} | "
            f"{project.y:>7.2f} | "
            f"{10**Y_hat[i]:>9.2f} | "
            f"({pred_intervals[i][0]:>7.2f}, {pred_intervals[i][1]:>7.2f}) | "
            f"({conf_intervals[i][0]:>7.2f}, {conf_intervals[i][1]:>7.2f})"
        )


def build_model(x1, x2, y) -> Tuple[float, float, float, np.ndarray, float]:
    """Build a regression model."""
    b0, b1, b2 = calculate_regression_coefficients(np.column_stack((x1, x2)), y)
    Y_hat = b0 + b1 * x1 + b2 * x2

    epsilon_std = np.sqrt(np.sum((y - Y_hat) ** 2) / (len(y) - 3))
    print(f"Standard Deviation of Epsilon: {epsilon_std:.4f}")

    return b0, b1, b2, Y_hat, epsilon_std

def print_results(
    b0: float,
    b1: float,
    b2: float,
    r_squared: float,
    mmre: float,
    pred: float,
):
    """Print regression results and residual statistics."""
    print(f"Model Results:")
    print(f"Regression Coefficients: b0 = {b0:.4f}, b1 = {b1:.4f}, b2 = {b2:.4f}")
    print(
        f"Regression Metrics: R^2 = {r_squared:.4f}, MMRE = {mmre:.4f}, PRED = {pred:.4f}"
    )

def test_model(
    model_coefficients: Tuple[float, float, float],
    test_file: str = "test_data.csv",
) -> Tuple[float, float, float]:
    """Test the model on a separate dataset."""
    projects = retrieve_data(test_file)
    projects = normalize_data(projects)

    zx1 = np.array([project.zx1 for project in projects])
    zx2 = np.array([project.zx2 for project in projects])
    zy = np.array([project.zy for project in projects])

    b0, b1, b2 = model_coefficients
    Y_hat_test = b0 + b1 * zx1 + b2 * zx2

    r_squared, mmre, pred = calculate_regression_metrics(zy, Y_hat_test)

    return r_squared, mmre, pred


def main():
    # Load and normalize data
    projects = retrieve_data()
    projects = normalize_data(projects)

    # Prepare data
    X = np.array([(project.zx1, project.zx2) for project in projects])
    Y = np.array([project.zy for project in projects])

    # Build model
    b0, b1, b2, Y_hat, epsilon_std = build_model(X[:, 0], X[:, 1], Y)

    # Calculate metrics
    r_squared, mmre, pred = calculate_regression_metrics(Y, Y_hat)
    print_results(b0, b1, b2, r_squared, mmre, pred)

    # Calculate intervals and get intermediate values
    pred_intervals, conf_intervals, intermediate_values = calculate_intervals(
        X, Y, Y_hat, b0, b1, b2
    )

    # Print detailed results
    print_intermediate_values(intermediate_values)
    print_intervals(projects, pred_intervals, conf_intervals, Y_hat)

    # Test model
    test_r_squared, test_mmre, test_pred = test_model((b0, b1, b2))
    print(
        f"\nTest Results: R^2 = {test_r_squared:.4f}, MMRE = {test_mmre:.4f}, "
        f"PRED = {test_pred:.4f}"
    )


if __name__ == "__main__":
    main()
