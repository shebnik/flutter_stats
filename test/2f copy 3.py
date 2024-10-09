import pandas as pd
import numpy as np
from scipy.stats import f, shapiro, t
from scipy.linalg import inv
import os
from typing import Tuple, List

def retrieve_data(filename: str = "3f.csv") -> Tuple[np.ndarray, np.ndarray, np.ndarray]:
    """Load data from CSV file and return X1, X2, and Y arrays."""
    df = pd.read_csv(os.path.join(os.path.dirname(__file__), os.path.join('data', filename)))
    return df["x1"].values.astype(float), df["x2"].values.astype(float), df["y"].values.astype(float)

def convert_y(Y: np.ndarray) -> np.ndarray:
    """Convert LOC to KLOC if needed."""
    if np.mean(Y) > 1000:
        return Y / 1000
    return Y

def normalize_data(X: np.ndarray) -> Tuple[np.ndarray, np.ndarray, np.ndarray]:
    """Normalize the features to have zero mean and unit variance."""
    mean = X.mean(axis=0)
    std = X.std(axis=0, ddof=1)
    X_norm = (X - mean) / std
    return X_norm, mean, std

def calculate_regression_coefficients(Z: np.ndarray) -> Tuple[float, float, float]:
    """Calculate regression coefficients."""
    X = Z[:, :-1]
    Y = Z[:, -1]
    X = np.column_stack((np.ones(X.shape[0]), X))
    coeffs = np.linalg.inv(X.T @ X) @ X.T @ Y
    return coeffs[0], coeffs[1], coeffs[2]

def calculate_prediction_interval(Z: np.ndarray, Y_hat: np.ndarray, alpha: float = 0.05) -> Tuple[np.ndarray, np.ndarray]:
    """Calculate prediction interval for each data point."""
    X = np.column_stack((np.ones(Z.shape[0]), Z[:, :-1]))
    n = Z.shape[0]
    p = X.shape[1]
    
    residuals = Z[:, -1] - Y_hat
    mse = np.sum(residuals**2) / (n - p)
    
    leverage = np.diagonal(X @ np.linalg.inv(X.T @ X) @ X.T)
    se = np.sqrt(mse * (1 + leverage))
    
    t_value = t.ppf(1 - alpha/2, n - p)
    margin = t_value * se
    
    lower_bound = Y_hat - margin
    upper_bound = Y_hat + margin
    
    return lower_bound, upper_bound

def calculate_mahalanobis_distances(Z: np.ndarray) -> np.ndarray:
    """Calculate Mahalanobis distances for each data point."""
    X = Z[:, :-1]
    Y = Z[:, -1]
    data = Z  # Include Y in the Mahalanobis calculation
    mean = np.mean(data, axis=0)
    cov = np.cov(data, rowvar=False)
    cov_inv = inv(cov)
    delta = data - mean
    m_dist_sq = np.einsum('...k,kl,...l->...', delta, cov_inv, delta)
    m_dist = np.sqrt(m_dist_sq)
    return m_dist

def mahalanobis_threshold(p: int, n: int, alpha: float = 0.05) -> float:
    """
    Compute the Mahalanobis distance threshold based on the F-distribution.
    Formula: delta^2 = (p(n-1)/(n-p)) * F_critical
    """
    F_critical = f.ppf(1 - alpha, p, n - p)
    delta_sq_threshold = (p * (n - 1)) / (n - p) * F_critical
    delta_threshold = np.sqrt(delta_sq_threshold)
    return delta_threshold

def identify_outliers_mahalanobis(Z: np.ndarray, alpha: float = 0.05) -> List[int]:
    """Identify outliers based on Mahalanobis distance."""
    n, p = Z.shape
    m_dist = calculate_mahalanobis_distances(Z)
    threshold = mahalanobis_threshold(p, n, alpha)
    outliers = np.where(m_dist > threshold)[0].tolist()
    print(f"Mahalanobis distance threshold: {threshold:.4f}")
    print(f"Number of outliers detected: {len(outliers)}")
    return outliers

def test_normality(residuals: np.ndarray, alpha: float = 0.05) -> bool:
    """Test the normality of residuals using the Shapiro-Wilk test."""
    stat, p_value = shapiro(residuals)
    print(f"Shapiro-Wilk test statistic: {stat:.4f}, p-value: {p_value:.4f}")
    return p_value > alpha

def identify_largest_residual(Z: np.ndarray, Y_hat: np.ndarray) -> int:
    """Identify the index of the data point with the largest absolute residual."""
    residuals = Z[:, -1] - Y_hat
    idx = np.argmax(np.abs(residuals))
    return idx

def remove_data_point(Z: np.ndarray, idx: int, Y_hat: np.ndarray) -> np.ndarray:
    """Remove the data point at the specified index."""
    print(f"Removing data point at index {idx} with residual {Z[idx, -1] - Y_hat[idx]:.4f}")
    return np.delete(Z, idx, axis=0)

def print_outliers(Z: np.ndarray, outliers: List[int]):
    """Print the outliers identified."""
    if not outliers:
        print("No outliers detected.")
        return
    string = "Outliers detected at indices: "
    string += " ".join(map(str, outliers))
    print(string)

def calculate_regression_metrics(Y: np.ndarray, Y_hat: np.ndarray) -> Tuple[float, float, float]:
    """Calculate regression model metrics."""
    n = len(Y)
    Y_hat_original = 10**Y_hat * 1000
    Y_original = 10**Y * 1000
    
    residuals = Y_original - Y_hat_original
    y_mean = np.mean(Y_original)
    
    r_squared = 1 - (np.sum(residuals**2) / np.sum((Y_original - y_mean)**2))
    mmre = np.mean(np.abs(residuals / Y_original))
    pred = np.sum(np.abs(residuals / Y_original) < 0.25) / n
    
    return r_squared, mmre, pred

def calculate_residual_statistics(Y: np.ndarray, Y_hat: np.ndarray) -> Tuple[float, float]:
    """Calculate the sample mean and variance of residuals."""
    residuals = Y - Y_hat
    mean_residual = np.mean(residuals)
    variance_residual = np.var(residuals, ddof=1)
    return mean_residual, variance_residual

def print_results(b0: float, b1: float, b2: float, r_squared: float, mmre: float, pred: float, mean_residual: float, variance_residual: float):
    """Print regression results and residual statistics."""
    print(f"\nFinal Results:")
    print(f"Regression Coefficients: b0 = {b0:.4f}, b1 = {b1:.4f}, b2 = {b2:.4f}")
    print(f"Regression Metrics: R^2 = {r_squared:.4f}, MMRE = {mmre:.4f}, PRED = {pred:.4f}")
    print(f"Residual Statistics:")
    print(f"Sample Mean of Residuals: {mean_residual:.6f}")
    print(f"Sample Variance of Residuals: {variance_residual:.6f}")

def main():
    # Load and preprocess data
    x1, x2, y = retrieve_data()
    y = convert_y(y)
    Z = np.column_stack((np.log10(x1), np.log10(x2), np.log10(y)))
    
    # Normalize the data
    Z_normalized, mean_Z, std_Z = normalize_data(Z)
    
    
    print(f"Initial number of data points: {Z_normalized.shape[0]}")
    iteration = 1
    while True:
        print(f"\nStarting iteration {iteration}")
        
        # Calculate regression coefficients
        b0, b1, b2 = calculate_regression_coefficients(Z_normalized)
        Y_hat = b0 + b1 * Z_normalized[:, 0] + b2 * Z_normalized[:, 1]
        
        # Calculate residuals
        residuals = Z_normalized[:, -1] - Y_hat
        
        # Compute Mahalanobis distance and identify outliers
        outliers = identify_outliers_mahalanobis(Z_normalized, alpha=0.05)
        print_outliers(Z_normalized, outliers)
        
        if outliers:
            # Identify the outlier with the largest absolute residual
            largest_residual_idx = identify_largest_residual(Z_normalized, Y_hat)
            # Remove this data point
            Z_normalized = remove_data_point(Z_normalized, largest_residual_idx, Y_hat)
            print(f"Removed 1 data point. New dataset size: {Z_normalized.shape[0]}")
            # Re-normalize the data after removal
            Z_normalized, mean_Z, std_Z = normalize_data(Z_normalized)
            iteration += 1
            continue
        
        # If no outliers, test for normality of residuals
        normal = test_normality(residuals, alpha=0.05)
        if normal:
            print("Residuals are normally distributed. Stopping iterations.")
            break
        else:
            print("Residuals are not normally distributed. Removing data point with largest residual.")
            # Remove the data point with the largest absolute residual
            largest_residual_idx = identify_largest_residual(Z_normalized, Y_hat)
            Z_normalized = remove_data_point(Z_normalized, largest_residual_idx, Y_hat)
            print(f"Removed 1 data point. New dataset size: {Z_normalized.shape[0]}")
            # Re-normalize the data after removal
            Z_normalized, mean_Z, std_Z = normalize_data(Z_normalized)
            iteration += 1
    
    print(f"\nFinal number of data points after outlier removal: {Z_normalized.shape[0]}")
    
    # Final regression coefficients
    b0, b1, b2 = calculate_regression_coefficients(Z_normalized)
    Y_hat = b0 + b1 * Z_normalized[:, 0] + b2 * Z_normalized[:, 1]
    
    # Calculate regression metrics
    r_squared, mmre, pred = calculate_regression_metrics(Z_normalized[:, -1], Y_hat)
    
    # Calculate residual statistics
    mean_residual, variance_residual = calculate_residual_statistics(Z_normalized[:, -1], Y_hat)
    
    # Print the final results
    print_results(b0, b1, b2, r_squared, mmre, pred, mean_residual, variance_residual)

if __name__ == "__main__":
    main()