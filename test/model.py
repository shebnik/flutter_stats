from dataclasses import dataclass
import pandas as pd
import numpy as np
from typing import List, Tuple
import os


@dataclass(frozen=True)
class Project:
    url: str
    x1: float
    x2: float
    y: float
    x3: float
    zx1: float = 0.0
    zx2: float = 0.0
    zx3: float = 0.0
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
            url="",
            x1=row["CBO"],
            x2=row["DIT"],
            x3=row["WMC"],
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
        zx3 = np.log10(project.x3)
        zy = np.log10(project.y)

        normalized_projects.append(
            Project(
                url=project.url,
                x1=project.x1,
                x2=project.x2,
                y=project.y,
                x3=project.x3,
                zx1=zx1,
                zx2=zx2,
                zx3=zx3,
                zy=zy,
            )
        )

    return normalized_projects


def calculate_regression_coefficients(
    X: np.ndarray, Y: np.ndarray
) -> Tuple[float, float, float, float]:
    """Calculate regression coefficients."""
    X = np.column_stack((np.ones(X.shape[0]), X))
    coffs = np.linalg.inv(X.T @ X) @ X.T @ Y
    return coffs[0], coffs[1], coffs[2], coffs[3]


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


def calculate_epsilon_std(Y: np.ndarray, Y_hat: np.ndarray) -> float:
    """Calculate the standard deviation of epsilon."""
    residuals = Y - Y_hat
    n = len(residuals)
    epsilon_std = np.sqrt(np.sum(residuals**2) / (n - 4))
    return epsilon_std


def build_model(
    x1, x2, x3, y
) -> Tuple[float, float, float, float, np.ndarray, np.ndarray]:
    """Build a regression model."""
    b0, b1, b2, b3 = calculate_regression_coefficients(np.column_stack((x1, x2, x3)), y)
    Y_hat = b0 + b1 * x1 + b2 * x2 + b3 * x3

    epsilon_std = calculate_epsilon_std(y, Y_hat)
    print(epsilon_std)

    return b0, b1, b2, b3, Y_hat


def print_results(
    b0: float,
    b1: float,
    b2: float,
    b3: float,
    r_squared: float,
    mmre: float,
    pred: float,
):
    """Print regression results and residual statistics."""
    print(f"\nModel Results:")
    print(
        f"Regression Coefficients: b0 = {b0:.4f}, b1 = {b1:.4f}, b2 = {b2:.4f}, b3 = {b3:.4f}"
    )
    print(
        f"Regression Metrics: R^2 = {r_squared:.4f}, MMRE = {mmre:.4f}, PRED = {pred:.4f}"
    )


def test_model(
    model_coefficients: Tuple[float, float, float, float],
    test_file: str = "test_data.csv",
) -> Tuple[float, float, float]:
    """Test the model on a separate dataset."""
    projects = retrieve_data(test_file)
    projects = normalize_data(projects)

    zx1 = np.array([project.zx1 for project in projects])
    zx2 = np.array([project.zx2 for project in projects])
    zx3 = np.array([project.zx3 for project in projects])
    zy = np.array([project.zy for project in projects])

    b0, b1, b2, b3 = model_coefficients
    Y_hat_test = b0 + b1 * zx1 + b2 * zx2 + b3 * zx3

    r_squared, mmre, pred = calculate_regression_metrics(zy, Y_hat_test)

    return r_squared, mmre, pred


def main():
    # Model test
    projects = retrieve_data()
    projects = normalize_data(projects)

    zx1 = np.array([project.zx1 for project in projects])
    zx2 = np.array([project.zx2 for project in projects])
    zx3 = np.array([project.zx3 for project in projects])
    zy = np.array([project.zy for project in projects])

    b0, b1, b2, b3, Y_hat = build_model(zx1, zx2, zx3, zy)

    r_squared, mmre, pred = calculate_regression_metrics(zy, Y_hat)
    print_results(b0, b1, b2, b3, r_squared, mmre, pred)

    # Test model on a separate dataset
    test_r_squared, test_mmre, test_pred = test_model((b0, b1, b2, b3))
    print(
        f"Test Results: R^2 = {test_r_squared:.4f}, MMRE = {test_mmre:.4f}, PRED = {test_pred:.4f}"
    )


if __name__ == "__main__":
    main()
