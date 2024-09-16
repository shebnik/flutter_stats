import pandas as pd
import numpy as np
from scipy import stats
from scipy.optimize import curve_fit
from scipy.stats import f, normaltest
import os
from typing import Tuple, List

def retrieve_data(filename: str = "flutter_metrics.csv") -> Tuple[np.ndarray, np.ndarray, np.ndarray, np.ndarray]:
    """Load data from CSV file and return X1, X2, X3, and Y arrays."""
    df = pd.read_csv(os.path.join(os.path.dirname(__file__), filename))
    return df["x1"].values.astype(float), df["x2"].values.astype(float), df["x3"].values.astype(float), df["y"].values.astype(float)

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
    return ((n - 4) * n / ((n**2 - 1) * 4)) * mahalanobis_distances

def determine_outliers_mahalanobis(Z: np.ndarray, alpha: float = 0.05) -> List[int]:
    """Determine outliers using Mahalanobis distance."""
    n = Z.shape[0]
    cov_inv = calculate_cov_inv(Z)
    mahalanobis_distances = calculate_mahalanobis_distances(Z, cov_inv)
    test_statistic = calculate_test_statistic(n, mahalanobis_distances)
    
    fisher_f = f.ppf(1 - alpha, 4, n - 4)
    
    outliers = np.where(test_statistic > fisher_f)[0].tolist()
    return outliers

def normalize_data(Z: np.ndarray) -> np.ndarray:
    """Normalize the data using z-score normalization."""
    return (Z - np.mean(Z, axis=0)) / np.std(Z, axis=0)

def linear_regression(X: np.ndarray, Y: np.ndarray) -> Tuple[np.ndarray, np.ndarray]:
    """Perform linear regression and return coefficients and predicted values."""
    X_with_intercept = np.column_stack((np.ones(X.shape[0]), X))
    coeffs = np.linalg.inv(X_with_intercept.T @ X_with_intercept) @ X_with_intercept.T @ Y
    Y_pred = X_with_intercept @ coeffs
    return coeffs, Y_pred

def check_normality(residuals: np.ndarray, alpha: float = 0.05) -> bool:
    """Check if the residuals follow a normal distribution."""
    _, p_value = normaltest(residuals)
    return p_value > alpha

def remove_max_deviation_point(Z: np.ndarray, residuals: np.ndarray) -> np.ndarray:
    """Remove the data point with the maximum absolute residual."""
    max_deviation_index = np.argmax(np.abs(residuals))
    return np.delete(Z, max_deviation_index, axis=0)

def non_linear_regression(X: np.ndarray, Y: np.ndarray) -> Tuple[np.ndarray, np.ndarray]:
    """Perform non-linear regression using a power law model."""
    def power_law(X, a, b, c, d):
        return a * X[:, 0]**b * X[:, 1]**c * X[:, 2]**d
    
    popt, _ = curve_fit(power_law, X, Y, maxfev=10000)
    Y_pred = power_law(X, *popt)
    return popt, Y_pred

def calculate_prediction_interval(Y: np.ndarray, Y_pred: np.ndarray, alpha: float = 0.05) -> Tuple[np.ndarray, np.ndarray]:
    """Calculate prediction interval for non-linear regression."""
    n = len(Y)
    mse = np.sum((Y - Y_pred)**2) / (n - 4)
    se = np.sqrt(mse * (1 + 1/n))
    t_value = stats.t.ppf(1 - alpha/2, n - 4)
    lower = Y_pred - t_value * se
    upper = Y_pred + t_value * se
    return lower, upper

def remove_outliers_and_create_model(Z: np.ndarray) -> Tuple[np.ndarray, np.ndarray, np.ndarray, float, float, float]:
    """Remove outliers and create a regression model."""
    # Step 1: Remove outliers using Mahalanobis distance
    outliers_mahalanobis = determine_outliers_mahalanobis(Z)
    if outliers_mahalanobis:
        Z = np.delete(Z, outliers_mahalanobis, axis=0)
        print(f"Removed {len(outliers_mahalanobis)} outliers using Mahalanobis distance.")

    # Step 2: Normalize data and perform linear regression
    Z_norm = normalize_data(Z)
    X_norm, Y_norm = Z_norm[:, :3], Z_norm[:, 3]
    
    while True:
        coeffs, Y_pred = linear_regression(X_norm, Y_norm)
        residuals = Y_norm - Y_pred
        
        if check_normality(residuals):
            break
        
        Z_norm = remove_max_deviation_point(Z_norm, residuals)
        X_norm, Y_norm = Z_norm[:, :3], Z_norm[:, 3]
        print("Removed a point with maximum deviation to improve normality of residuals.")

    # Step 3: Perform non-linear regression on original scale data
    X, Y = Z[:, :3], Z[:, 3]
    popt, Y_pred = non_linear_regression(X, Y)
    
    # Step 4: Calculate prediction interval and remove outliers
    lower, upper = calculate_prediction_interval(Y, Y_pred)
    outliers_prediction = np.where((Y < lower) | (Y > upper))[0]
    if len(outliers_prediction) > 0:
        Z = np.delete(Z, outliers_prediction, axis=0)
        print(f"Removed {len(outliers_prediction)} outliers outside the prediction interval.")

    # Recalculate non-linear regression after removing outliers
    X, Y = Z[:, :3], Z[:, 3]
    popt, Y_pred = non_linear_regression(X, Y)

    # Calculate metrics
    Y_original = 10**Y
    Y_pred_original = 10**Y_pred
    residuals = Y_original - Y_pred_original
    r_squared = 1 - (np.sum(residuals**2) / np.sum((Y_original - np.mean(Y_original))**2))
    mmre = np.mean(np.abs(residuals / Y_original))
    pred = np.sum(np.abs(residuals / Y_original) < 0.25) / len(Y)

    return Z, popt, Y_pred, r_squared, mmre, pred

def print_results(iteration: int, popt: np.ndarray, r_squared: float, mmre: float, pred: float):
    """Print regression results."""
    print(f"\nIteration {iteration} Results:")
    print(f"Non-linear Regression Coefficients: a = {popt[0]:.4f}, b = {popt[1]:.4f}, c = {popt[2]:.4f}, d = {popt[3]:.4f}")
    print(f"Regression Metrics: R^2 = {r_squared:.4f}, MMRE = {mmre:.4f}, PRED = {pred:.4f}")

def iterative_outlier_removal_and_modeling(Z: np.ndarray) -> Tuple[np.ndarray, np.ndarray, np.ndarray, float, float, float]:
    """Iteratively remove outliers and create a regression model until no more outliers are found."""
    iteration = 1
    while True:
        print(f"\nStarting iteration {iteration}")
        Z_new, popt, Y_pred, r_squared, mmre, pred = remove_outliers_and_create_model(Z)
        print_results(iteration, popt, r_squared, mmre, pred)
        
        if Z_new.shape[0] == Z.shape[0]:
            print("No more outliers found. Stopping iterations.")
            break
        
        Z = Z_new
        iteration += 1
    
    return Z, popt, Y_pred, r_squared, mmre, pred

def main():
    x1, x2, x3, y = retrieve_data()
    Z = np.column_stack((np.log10(x1), np.log10(x2), np.log10(x3), np.log10(y)))

    print(f"Initial number of data points: {Z.shape[0]}")
    Z_final, popt_final, Y_pred_final, r_squared_final, mmre_final, pred_final = iterative_outlier_removal_and_modeling(Z)
    print(f"\nFinal number of data points after outlier removal: {Z_final.shape[0]}")
    print("\nFinal Model Results:")
    print_results("Final", popt_final, r_squared_final, mmre_final, pred_final)

if __name__ == "__main__":
    main()