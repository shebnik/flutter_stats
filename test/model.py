from dataclasses import dataclass
import pandas as pd
import numpy as np
from typing import List, Tuple
import os

@dataclass(frozen=True)
class Project:
    url: str
    cbo: float
    wmc: float
    rfc: float
    noc: float
    zx1: float
    zx2: float
    zy: float
    
def data_path(filename: str) -> str:
    """Return the full path to the data file."""
    return os.path.join(os.path.dirname(__file__), os.path.join('data', filename))

def retrieve_data(filename: str = "train_data.csv") -> List[Project]:
    """Load data from CSV file and return a list of Project objects."""
    df = pd.read_csv(data_path(filename))
    projects = []
    for _, row in df.iterrows():
        project = Project(
            url=row['URL'],
            cbo=row['CBO'],
            wmc=row['WMC'],
            rfc=row['RFC'],
            noc=row['NOC'],
            zx1=row['ZX1'] if 'ZX1' in df.columns else 0.0,
            zx2=row['ZX2'] if 'ZX2' in df.columns else 0.0,
            zy=row['ZY'] if 'ZY' in df.columns else 0.0
        )
        projects.append(project)
    return projects

def normalize_data(projects: List[Project]) -> List[Project]:
    """Normalize the data."""
    normalized_projects = []
    for project in projects:
        cbo = max(project.cbo, 1)
        wmc = max(project.wmc, 1)
        rfc = max(project.rfc, 1)
        noc = max(project.noc, 1)
        
        zx1 = np.log10(cbo / noc)
        zx2 = np.log10(wmc / noc)
        zy = np.log10(rfc / noc)
        
        normalized_projects.append(Project(project.url, project.cbo, project.wmc, project.rfc, project.noc, zx1, zx2, zy))
    
    return normalized_projects
    
def projects_to_array(projects: List[Project]) -> np.ndarray:
    """Convert a list of Project objects to a numpy array."""
    return np.array([[p.zx1, p.zx2, p.zy] for p in projects])

def calculate_regression_coefficients(Z: np.ndarray) -> Tuple[float, float, float]:
    """Calculate regression coefficients."""
    X = Z[:, :-1]
    Y = Z[:, -1]
    X = np.column_stack((np.ones(X.shape[0]), X))
    coffs = np.linalg.inv(X.T @ X) @ X.T @ Y
    return coffs[0], coffs[1], coffs[2]

def calculate_regression_metrics(Y: np.ndarray, Y_hat: np.ndarray) -> Tuple[float, float, float]:
    """Calculate regression model metrics."""
    n = len(Y)
    Y_hat_original = 10**Y_hat
    Y_original = 10**Y
    
    residuals = Y_original - Y_hat_original
    y_mean = np.mean(Y_original)
    
    r_squared = 1 - (np.sum(residuals**2) / np.sum((Y_original - y_mean)**2))
    mmre = np.mean(np.abs(residuals / Y_original))
    pred = np.sum(np.abs(residuals / Y_original) < 0.25) / n
    
    return r_squared, mmre, pred

def build_model(projects: List[Project]) -> Tuple[float, float, float, np.ndarray, np.ndarray]:
    """Build a regression model."""
    Z = projects_to_array(projects)
    b0, b1, b2 = calculate_regression_coefficients(Z)
    Y_hat = b0 + b1 * Z[:, 0] + b2 * Z[:, 1]
    return b0, b1, b2, Y_hat, Z[:, -1]

def calculate_residual_statistics(Y: np.ndarray, Y_hat: np.ndarray) -> Tuple[float, float]:
    """Calculate the sample mean and variance of residuals."""
    residuals = Y - Y_hat
    mean_residual = np.mean(residuals)
    variance_residual = np.var(residuals, ddof=1)
    return mean_residual, variance_residual

def print_results(b0: float, b1: float, b2: float, r_squared: float, mmre: float, pred: float, mean_residual: float, variance_residual: float):
    """Print regression results and residual statistics."""
    print(f"\nModel Results:")
    print(f"Regression Coefficients: b0 = {b0:.4f}, b1 = {b1:.4f}, b2 = {b2:.4f}")
    print(f"Regression Metrics: R^2 = {r_squared:.4f}, MMRE = {mmre:.4f}, PRED = {pred:.4f}")
    print(f"Sample Mean of Residuals: {mean_residual:.6f}")
    print(f"Sample Variance of Residuals: {variance_residual:.6f}")

def test_model(model_coefficients: Tuple[float, float, float], test_file: str = "test_data.csv", sigma: float = 0) -> Tuple[float, float, float]:
    """Test the model on a separate dataset."""
    projects = retrieve_data(test_file)
    if projects[0].zx1 == 0:
        projects = normalize_data(projects)
    
    Z_test = projects_to_array(projects)
    
    b0, b1, b2 = model_coefficients
    Y_test = Z_test[:, -1]
    Y_hat_test = b0 + b1 * Z_test[:, 0] + b2 * Z_test[:, 1] + sigma
    
    r_squared, mmre, pred = calculate_regression_metrics(Y_test, Y_hat_test)
    
    return r_squared, mmre, pred

def main():    
    # Java test
    b0, b1, b2 = -0.054776, 0.672260, 0.441541
    r_squared, mmre, pred = test_model((b0, b1, b2), "100.csv", 0.06538)
    print(f"Test Results for Java: R^2 = {r_squared:.4f}, MMRE = {mmre:.4f}, PRED = {pred:.4f}")
    
    # Kotlin test
    b0, b1, b2 = 0.306892, 0.228584, 1.36206
    r_squared, mmre, pred = test_model((b0, b1, b2), "100.csv", 0.1128)
    print(f"Test Results for Kotlin: R^2 = {r_squared:.4f}, MMRE = {mmre:.4f}, PRED = {pred:.4f}")
    
    # Model test
    b0, b1, b2, Y_hat, Y = build_model(retrieve_data())
    r_squared, mmre, pred = calculate_regression_metrics(Y, Y_hat)
    print_results(b0, b1, b2, r_squared, mmre, pred, *calculate_residual_statistics(Y, Y_hat))
    
    # Test model on a separate dataset
    test_r_squared, test_mmre, test_pred = test_model((b0, b1, b2))
    print(f"Test Results: R^2 = {test_r_squared:.4f}, MMRE = {test_mmre:.4f}, PRED = {test_pred:.4f}")
    
    
if __name__ == "__main__":
    main()