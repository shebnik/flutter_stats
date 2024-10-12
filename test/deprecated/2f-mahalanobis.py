import pandas as pd
import numpy as np
from scipy.stats import f
import os
from typing import Tuple, List

def retrieve_data(filename: str = "3f.csv") -> Tuple[np.ndarray, np.ndarray, np.ndarray]:
    """Load data from CSV file and return X1, X2, and Y arrays."""
    df = pd.read_csv(os.path.join(os.path.dirname(__file__), os.path.join('data', filename)))
    return df["x1"].values.astype(float), df["x2"].values.astype(float), df["y"].values.astype(float)

def calculate_cov_inv(Z: np.ndarray) -> np.ndarray:
    """Calculate the inverse of the covariance matrix."""
    n = Z.shape[0]
    Z_centered = Z - np.mean(Z, axis=0)
    cov = (Z_centered.T @ Z_centered) / n
    return np.linalg.inv(cov)

def calculate_mahalanobis_distances(Z: np.ndarray, cov_inv: np.ndarray) -> np.ndarray:
    """Calculate Mahalanobis distances."""
    Z_centered = Z - np.mean(Z, axis=0)
    return np.sum(Z_centered @ cov_inv * Z_centered, axis=1)

def calculate_test_statistic(n: int, mahalanobis_distances: np.ndarray) -> np.ndarray:
    """Calculate the test statistic."""
    return ((n - 3) * n / ((n**2 - 1) * 3)) * mahalanobis_distances

def determine_outliers(Z: np.ndarray, alpha: float = 0.05) -> List[int]:
    """Determine outliers using Mahalanobis distance."""
    n = Z.shape[0]
    cov_inv = calculate_cov_inv(Z)
    mahalanobis_distances = calculate_mahalanobis_distances(Z, cov_inv)
    test_statistic = calculate_test_statistic(n, mahalanobis_distances)
    
    fisher_f = f.ppf(1 - alpha, 3, n - 3)
    
    outliers = np.where(test_statistic > fisher_f)[0].tolist()
    for i in outliers:
        print(f"Outlier detected: x1={10**Z[i,0]:.0f}, x2={10**Z[i,1]:.0f}, y={10**Z[i,2]*1000:.0f}")
    
    return outliers

def calculate_regression_coefficients(Z: np.ndarray) -> Tuple[float, float, float]:
    """Calculate regression coefficients for two factors."""
    X = Z[:, :2]
    Y = Z[:, 2]
    X_with_intercept = np.column_stack((np.ones(X.shape[0]), X))
    coeffs = np.linalg.inv(X_with_intercept.T @ X_with_intercept) @ X_with_intercept.T @ Y
    return coeffs[0], coeffs[1], coeffs[2]

def calculate_regression_metrics(Y: np.ndarray, Y_hat: np.ndarray) -> Tuple[float, float, float]:
    """Calculate regression model metrics."""
    Y_hat_original = 10**Y_hat
    Y_original = 10**Y
    
    residuals = Y_original - Y_hat_original
    y_mean = np.mean(Y_original)
    
    r_squared = 1 - (np.sum(residuals**2) / np.sum((Y_original - y_mean)**2))
    mmre = np.mean(np.abs(residuals / Y_original))
    pred = np.sum(np.abs(residuals / Y_original) < 0.25) / len(Y)
    
    return r_squared, mmre, pred

def remove_outliers_and_create_model(Z: np.ndarray) -> Tuple[np.ndarray, float, float, float, float, float, float, np.ndarray]:
    """Remove outliers and create a regression model."""
    outliers = determine_outliers(Z)
    if outliers:
        Z = np.delete(Z, outliers, axis=0)
    
    b0, b1, b2 = calculate_regression_coefficients(Z)
    Y_hat = b0 + b1 * Z[:, 0] + b2 * Z[:, 1]
    r_squared, mmre, pred = calculate_regression_metrics(Z[:, 2], Y_hat)
    
    residuals = Z[:, 2] - Y_hat
    
    return Z, b0, b1, b2, r_squared, mmre, pred, residuals

def iterative_outlier_removal_and_modeling(Z: np.ndarray) -> Tuple[np.ndarray, float, float, float, float, float, float, np.ndarray]:
    """Iteratively remove outliers and create a regression model until no more outliers are found."""
    iteration = 1
    while True:
        print(f"\nStarting iteration {iteration}")
        Z_new, b0, b1, b2, r_squared, mmre, pred, residuals = remove_outliers_and_create_model(Z)
        print_results(iteration, b0, b1, b2, r_squared, mmre, pred)
        
        if Z_new.shape[0] == Z.shape[0]:
            print("No more outliers found. Stopping iterations.")
            break
        
        Z = Z_new
        iteration += 1
    
    return Z, b0, b1, b2, r_squared, mmre, pred, residuals

def calculate_residual_statistics(residuals: np.ndarray) -> Tuple[float, float]:
    """Calculate the sample mean and variance of residuals."""
    mean_residual = np.mean(residuals)
    variance_residual = np.var(residuals, ddof=1)
    return mean_residual, variance_residual

def print_results(iteration: int, b0: float, b1: float, b2: float, r_squared: float, mmre: float, pred: float):
    """Print regression results."""
    print(f"\nIteration {iteration} Results:")
    print(f"Regression Coefficients: b0 = {b0:.4f}, b1 = {b1:.4f}, b2 = {b2:.4f}")
    print(f"Regression Metrics: R^2 = {r_squared:.4f}, MMRE = {mmre:.4f}, PRED = {pred:.4f}")

def main():
    x1, x2, y = retrieve_data()
    Z = np.column_stack((np.log10(x1), np.log10(x2), np.log10(y)))

    print(f"Initial number of data points: {Z.shape[0]}")
    Z_final, b0, b1, b2, r_squared_final, mmre_final, pred_final, residuals = iterative_outlier_removal_and_modeling(Z)
    print(f"\nFinal number of data points after outlier removal: {Z_final.shape[0]}")
    print("\nFinal Model Results:")
    print_results("Final", b0, b1, b2, r_squared_final, mmre_final, pred_final)
    
    mean_residual, variance_residual = calculate_residual_statistics(residuals)
    print(f"\nResidual Statistics:")
    print(f"Sample Mean of Residuals: {mean_residual:.6f}")
    print(f"Sample Variance of Residuals: {variance_residual:.6f}")

if __name__ == "__main__":
    main()