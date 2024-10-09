import pandas as pd
import numpy as np
from scipy.stats import t, shapiro, f, chi2
import os
from typing import Tuple, List
from scipy.spatial import distance

def retrieve_data(filename: str = "3f.csv") -> Tuple[np.ndarray, np.ndarray, np.ndarray]:
    """Load data from CSV file and return X1, X2, and Y arrays."""
    df = pd.read_csv(os.path.join(os.path.dirname(__file__), os.path.join('data', filename)))
    return df["x1"].values.astype(float), df["x2"].values.astype(float), df["y"].values.astype(float)

def convert_y(Y: np.ndarray) -> np.ndarray:
    """Convert LOC to KLOC if needed."""
    if np.mean(Y) > 1000:
        return Y / 1000
    return Y

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

def identify_outliers(Z: np.ndarray, lower_bound: np.ndarray, upper_bound: np.ndarray) -> List[int]:
    """Identify points that fall outside the prediction interval."""
    Y = Z[:, -1]
    outliers = np.where((Y < lower_bound) | (Y > upper_bound))[0].tolist()
    return outliers

def print_outliers(Z: np.ndarray, outliers: List[int]):
    """Print the outliers identified."""
    string = "Outliers found: "
    for i in outliers:
        y = 10**Z[i, 2]
        string += f"{int(y):d} "
    print(string)

def shapiro_test(residuals: np.ndarray) -> bool:
    """Perform Shapiro-Wilk test for normality."""
    stat, p_value = shapiro(residuals)
    print(f"Shapiro-Wilk Test: Statistic={stat}, p-value={p_value}")
    return p_value > 0.05  # If p-value > 0.05, we fail to reject the null hypothesis (normality)

def remove_largest_residual(Z: np.ndarray, Y_hat: np.ndarray) -> np.ndarray:
    """Remove the largest residual from the dataset."""
    residuals = np.abs(Z[:, -1] - Y_hat)
    largest_residual_index = np.argmax(residuals)
    print(f"Removing largest residual: Index={largest_residual_index}, Value={residuals[largest_residual_index]}")
    return np.delete(Z, largest_residual_index, axis=0)

def remove_outliers_and_create_model(Z: np.ndarray) -> Tuple[np.ndarray, float, float, float, np.ndarray, np.ndarray, np.ndarray]:
    """Remove outliers and create a regression model."""
    b0, b1, b2 = calculate_regression_coefficients(Z)
    Y_hat = b0 + b1 * Z[:, 0] + b2 * Z[:, 1]
    
    lower_bound, upper_bound = calculate_prediction_interval(Z, Y_hat)
    outliers = identify_outliers(Z, lower_bound, upper_bound)
    
    if outliers:
        print_outliers(Z, outliers)
        Z = np.delete(Z, outliers, axis=0)
        print(f"Removed {len(outliers)} outliers")
    
    return Z, b0, b1, b2, Y_hat, lower_bound, upper_bound

def iterative_outlier_removal_and_modeling(Z: np.ndarray) -> Tuple[np.ndarray, float, float, float, np.ndarray, np.ndarray, np.ndarray]:
    """Iteratively remove outliers and create a regression model until no more outliers are found."""
    iteration = 1
    while True:
        print(f"\nStarting iteration {iteration}")
        Z_new, b0, b1, b2, Y_hat, lower_bound, upper_bound = remove_outliers_and_create_model(Z)
        
        # Recalculate Y_hat based on the new Z_new after outlier removal
        Y_hat = b0 + b1 * Z_new[:, 0] + b2 * Z_new[:, 1]
        
        # Check for normality of residuals
        residuals = Z_new[:, -1] - Y_hat
        if not shapiro_test(residuals):
            Z_new = remove_largest_residual(Z_new, Y_hat)
        
        if Z_new.shape[0] == Z.shape[0]:
            print("No more outliers found and residuals are normal. Stopping iterations.")
            break
        
        Z = Z_new
        iteration += 1
    
    return Z, b0, b1, b2, Y_hat, lower_bound, upper_bound

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
    
def mahalanobis_distance(X: np.ndarray) -> np.ndarray:
    """Calculate the Mahalanobis distance for each observation."""
    mean = np.mean(X, axis=0)
    cov = np.cov(X, rowvar=False)
    inv_cov = np.linalg.inv(cov)
    diff = X - mean
    md = np.sqrt(np.einsum('ij,jk->i', diff, inv_cov.dot(diff.T)))
    return md

def identify_outliers_mahalanobis(Z: np.ndarray, alpha: float = 0.05) -> List[int]:
    """Identify outliers using the Mahalanobis distance."""
    # Calculate Mahalanobis distances
    md = mahalanobis_distance(Z[:, :-1])
    
    # Determine the threshold for outliers
    threshold = chi2.ppf(1 - alpha, df=Z.shape[1] - 1)
    
    # Identify outliers
    outliers = np.where(md > np.sqrt(threshold))[0]
    return outliers.tolist()

def iterative_outlier_removal_mahalanobis(Z: np.ndarray) -> np.ndarray:
    """Iteratively remove outliers based on Mahalanobis distance."""
    while True:
        outliers = identify_outliers_mahalanobis(Z)
        if len(outliers) == 0:
            break
        Z = np.delete(Z, outliers, axis=0)
    return Z

def main():
    x1, x2, y = retrieve_data("2f-den.csv")
    Z = np.column_stack((np.log10(x1), np.log10(x2), np.log10(y)))
    
    b0, b1, b2 = calculate_regression_coefficients(Z)
    print("\nRegression Coefficients:")
    print(f"b0: {b0:.4f}, b1: {b1:.4f}, b2: {b2:.4f}")
    
    mean_residual, variance_residual = calculate_residual_statistics(Z[:, -1], b0 + b1 * Z[:, 0] + b2 * Z[:, 1])
    print(f"Initial Results:")
    print(f"Sample Mean of Residuals: {mean_residual:.6f}")
    print(f"Sample Variance of Residuals: {variance_residual:.6f}")

    print(f"Initial number of data points: {Z.shape[0]}")
    
    Z_final = iterative_outlier_removal_mahalanobis(Z)
    print(f"Final number of data points after Mahalanobis distance outlier removal: {Z_final.shape[0]}")
    
    Z_final, b0, b1, b2, Y_hat, lower_bound, upper_bound = iterative_outlier_removal_and_modeling(Z_final)
    print(f"\nFinal number of data points after outlier removal: {Z_final.shape[0]}")   
    
    r_squared, mmre, pred = calculate_regression_metrics(Z_final[:, -1], Y_hat)
    
    mean_residual, variance_residual = calculate_residual_statistics(Z_final[:, -1], Y_hat)
    
    print_results(b0, b1, b2, r_squared, mmre, pred, mean_residual, variance_residual)

if __name__ == "__main__":
    main()