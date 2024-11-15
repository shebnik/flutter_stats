from dataclasses import dataclass
import pandas as pd
import numpy as np
from typing import List, Tuple
from scipy.stats import t
import os

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


def calculate_epsilon_std(Y: np.ndarray, Y_hat: np.ndarray) -> float:
    """Calculate the standard deviation of epsilon."""
    residuals = Y - Y_hat
    n = len(residuals)
    epsilon_std = np.sqrt(np.sum(residuals**2) / (n - 3))
    return epsilon_std


def build_model(zx1, zx2, zy) -> Tuple[float, float, float, np.ndarray]:
    """Build a regression model."""
    b0, b1, b2 = calculate_regression_coefficients(np.column_stack((zx1, zx2)), zy)

    epsilon_std = calculate_epsilon_std(zy, b0 + b1 * zx1 + b2 * zx2)
    print(f"Standard Deviation of Epsilon: {epsilon_std:.4f}")

    zY_hat = b0 + b1 * zx1 + b2 * zx2

    return b0, b1, b2, zY_hat


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


def calculate_intervals(
    Z: np.ndarray,
    zy: np.ndarray,
    zy_hat: np.ndarray,
    alpha: float = 0.05,
    verbose: bool = False
) -> Tuple[np.ndarray, np.ndarray, np.ndarray, np.ndarray]:
    """
    Calculate prediction and confidence intervals for a regression model with log-transformed data.
    Handles any number of predictor variables.
    
    Parameters
    ----------
    Z : np.ndarray
        2D array of predictor variables (log-transformed), shape (n_samples, n_features)
    zy : np.ndarray
        Actual response variable (log-transformed), shape (n_samples,)
    zy_hat : np.ndarray
        Predicted response variable (log-transformed), shape (n_samples,)
    alpha : float, optional
        Significance level (default: 0.05 for 95% intervals)
    verbose : bool, optional
        If True, prints intermediate calculations (default: False)
    
    Returns
    -------
    Tuple[np.ndarray, np.ndarray, np.ndarray, np.ndarray]
        prediction_lower, prediction_upper, confidence_lower, confidence_upper
        All intervals are transformed back to original scale (not log-transformed)
    
    Notes
    -----
    This function assumes:
    1. All input data is already log-transformed
    2. The model follows standard linear regression assumptions
    3. There are no missing or infinite values in the inputs
    4. Z is properly standardized/scaled if necessary
    
    Examples
    --------
    >>> # For two predictors
    >>> Z = np.column_stack([z1, z2])
    >>> intervals = calculate_intervals(Z, zy, zy_hat)
    
    >>> # For three predictors
    >>> Z = np.column_stack([z1, z2, z3])
    >>> intervals = calculate_intervals(Z, zy, zy_hat)
    """
    # Input validation
    if Z.ndim != 2:
        raise ValueError("Z must be a 2D array of shape (n_samples, n_features)")
    if not all(len(arr) == Z.shape[0] for arr in [zy, zy_hat]):
        raise ValueError("All input arrays must have the same number of samples")
    if not (0 < alpha < 1):
        raise ValueError("Alpha must be between 0 and 1")
    
    N, p = Z.shape  # n_samples, n_features
    nu = N - (p + 1)  # Degrees of freedom (N - number of parameters including intercept)

    if verbose:
        print(f"Number of samples: {N}")
        print(f"Number of features: {p}")
        print(f"Degrees of freedom: {nu}")

    # Calculate t-statistic
    t_stat = t.ppf(1 - alpha / 2, nu)
    if verbose:
        print(f"T-Student statistic: {t_stat:.4f}")

    # Calculate residual standard deviation
    residuals = zy - zy_hat
    szy = np.sqrt(np.sum(residuals**2) / nu)
    if verbose:
        print(f"Residual standard deviation: {szy:.4f}")

    # Calculate means for each predictor
    Z_means = np.mean(Z, axis=0)
    
    # Calculate deviations from means
    Z_centered = Z - Z_means

    # Calculate covariance matrix
    S_Z = Z_centered.T @ Z_centered
    if verbose:
        print("\nCovariance Matrix S_Z:")
        print(S_Z)

    # Invert covariance matrix
    try:
        S_Z_inv = np.linalg.inv(S_Z)
    except np.linalg.LinAlgError:
        raise ValueError("Covariance matrix is singular. Check for multicollinearity in predictors.")

    if verbose:
        print("\nInverse Covariance Matrix S_Z_inv:")
        print(S_Z_inv)

    # Calculate quadratic form for each observation
    # This is equivalent to diag(Z_centered @ S_Z_inv @ Z_centered.T)
    quadratic_form = np.sum(Z_centered @ S_Z_inv * Z_centered, axis=1)
    
    if verbose:
        print("\nQuadratic Form (first few values):")
        print(quadratic_form[:5])

    # Calculate intervals in log scale
    pred_lower = zy_hat - t_stat * szy * np.sqrt(1 + 1/N + quadratic_form)
    pred_upper = zy_hat + t_stat * szy * np.sqrt(1 + 1/N + quadratic_form)
    conf_lower = zy_hat - t_stat * szy * np.sqrt(1/N + quadratic_form)
    conf_upper = zy_hat + t_stat * szy * np.sqrt(1/N + quadratic_form)

    # Transform back to original scale
    return (
        10**pred_lower,
        10**pred_upper,
        10**conf_lower,
        10**conf_upper
    )


def main():
    # Model test
    projects = retrieve_data()
    projects = normalize_data(projects)

    zx1 = np.array([project.zx1 for project in projects])
    zx2 = np.array([project.zx2 for project in projects])
    zy = np.array([project.zy for project in projects])

    b0, b1, b2, zY_hat = build_model(zx1, zx2, zy)

    r_squared, mmre, pred = calculate_regression_metrics(zy, zY_hat)
    print_results(b0, b1, b2, r_squared, mmre, pred)

    # Test model on a separate dataset
    test_r_squared, test_mmre, test_pred = test_model((b0, b1, b2))
    print(
        f"Test Results: R^2 = {test_r_squared:.4f}, MMRE = {test_mmre:.4f}, PRED = {test_pred:.4f}"
    )
    pred_lower, pred_upper, conf_lower, conf_upper = calculate_intervals(
        np.column_stack((zx1, zx2)), zy, zY_hat, alpha=alpha
    )


if __name__ == "__main__":
    main()
