import pandas as pd
import numpy as np
from scipy import stats
import os
from typing import Tuple, List

def retrieve_data(filename: str = "2f-den.csv") -> Tuple[np.ndarray, np.ndarray, np.ndarray]:
    """Load data from CSV file and return X1, X2, and Y arrays."""
    df = pd.read_csv(os.path.join(os.path.dirname(__file__), os.path.join('data', filename)))
    x1 = df["x1"].values.astype(float)
    x2 = df["x2"].values.astype(float)
    y = df["y"].values.astype(float)
    if np.mean(y) > 1000:
        y = y / 1000
    return x1, x2, y

def power_model(X: np.ndarray, b0: float, b1: float, b2: float) -> np.ndarray:
    """Calculate the power model: Y = b0 * (X1^b1) * (X2^b2)"""
    return b0 * np.power(X[:, 0], b1) * np.power(X[:, 1], b2)

def calculate_regression_coefficients(X: np.ndarray, Y: np.ndarray) -> Tuple[float, float, float]:
    """Calculate regression coefficients for two-factor power model."""
    log_Y = np.log(Y)
    log_X = np.log(X)
    log_X_with_intercept = np.column_stack((np.ones(X.shape[0]), log_X))
    coeffs = np.linalg.inv(log_X_with_intercept.T @ log_X_with_intercept) @ log_X_with_intercept.T @ log_Y
    return np.exp(coeffs[0]), coeffs[1], coeffs[2]

def calculate_prediction_intervals(X: np.ndarray, Y: np.ndarray, Y_pred: np.ndarray, 
                                   b0: float, b1: float, b2: float, 
                                   alpha: float = 0.05) -> Tuple[np.ndarray, np.ndarray]:
    """Calculate prediction intervals for the power model."""
    n = X.shape[0]
    p = 3  # number of parameters in the model
    
    log_X = np.log(X)
    log_X_with_intercept = np.column_stack((np.ones(n), log_X))
    log_Y = np.log(Y)
    log_Y_pred = np.log(Y_pred)
    
    residuals = log_Y - log_Y_pred
    mse = np.sum(residuals**2) / (n - p)
    
    X_T_X_inv = np.linalg.inv(log_X_with_intercept.T @ log_X_with_intercept)
    
    leverage = np.diagonal(log_X_with_intercept @ X_T_X_inv @ log_X_with_intercept.T)
    
    t_value = stats.t.ppf(1 - alpha/2, n - p)
    
    se_pred = np.sqrt(mse * (1 + leverage))
    margin_of_error = t_value * se_pred
    
    lower_bound = np.exp(log_Y_pred - margin_of_error)
    upper_bound = np.exp(log_Y_pred + margin_of_error)
    
    return lower_bound, upper_bound

def identify_outliers_prediction_interval(Y: np.ndarray, lower_bound: np.ndarray, upper_bound: np.ndarray) -> List[int]:
    """Identify points outside the prediction interval."""
    outliers = np.where((Y < lower_bound) | (Y > upper_bound))[0].tolist()
    for i in outliers:
        print(f"Prediction Interval Outlier detected: y={Y[i]:.2f}, lower bound={lower_bound[i]:.2f}, upper bound={upper_bound[i]:.2f}")
    return outliers

def calculate_cov_inv(Z: np.ndarray) -> np.ndarray:
    """Calculate the inverse of the covariance matrix."""
    n = Z.shape[0]
    Z_centered = Z - np.mean(Z, axis=0)
    cov = (Z_centered.T @ Z_centered) / n
    return np.linalg.inv(cov)

def calculate_mahalanobis_distances(Z: np.ndarray, cov_inv: np.ndarray) -> np.ndarray:
    """Calculate Mahalanobis distances."""
    Z_centered = Z - np.mean(Z, axis=0)
    return np.sqrt(np.sum(Z_centered @ cov_inv * Z_centered, axis=1))

def determine_outliers_mahalanobis(Z: np.ndarray, alpha: float = 0.05) -> List[int]:
    """Determine outliers using Mahalanobis distance."""
    cov_inv = calculate_cov_inv(Z)
    mahalanobis_distances = calculate_mahalanobis_distances(Z, cov_inv)
    chi2_value = stats.chi2.ppf(1 - alpha, df=Z.shape[1])
    
    outliers = np.where(mahalanobis_distances > chi2_value)[0].tolist()
    for i in outliers:
        print(f"Mahalanobis Outlier detected: x1={Z[i,0]:.2f}, x2={Z[i,1]:.2f}, y={Z[i,2]:.2f}")
    
    return outliers

def calculate_regression_metrics(Y: np.ndarray, Y_pred: np.ndarray) -> Tuple[float, float, float]:
    """Calculate regression model metrics."""
    n = len(Y)
    residuals = Y - Y_pred
    y_mean = np.mean(Y)
    
    r_squared = 1 - (np.sum(residuals**2) / np.sum((Y - y_mean)**2))
    mmre = np.mean(np.abs(residuals / Y))
    pred = np.sum(np.abs(residuals / Y) < 0.25) / n
    
    return r_squared, mmre, pred, residuals

def remove_outliers_and_create_model(X: np.ndarray, Y: np.ndarray) -> Tuple[np.ndarray, np.ndarray, float, float, float, float, float, float]:
    """Remove outliers and create a regression model."""
    Z = np.column_stack((X, Y))
    
    b0, b1, b2 = calculate_regression_coefficients(X, Y)
    Y_pred = power_model(X, b0, b1, b2)
    
    # Identify outliers using multiple methods
    lower_bound, upper_bound = calculate_prediction_intervals(X, Y, Y_pred, b0, b1, b2)
    outliers_pi = identify_outliers_prediction_interval(Y, lower_bound, upper_bound)
    outliers_mahalanobis = determine_outliers_mahalanobis(Z)
    
    # Combine all outliers
    outliers = list(set(outliers_pi + outliers_mahalanobis))
    
    if outliers:
        X = np.delete(X, outliers, axis=0)
        Y = np.delete(Y, outliers)
        
        # Recalculate the model after removing outliers
        b0, b1, b2 = calculate_regression_coefficients(X, Y)
        Y_pred = power_model(X, b0, b1, b2)
    
    r_squared, mmre, pred, residuals = calculate_regression_metrics(Y, Y_pred)
    
    return X, Y, b0, b1, b2, r_squared, mmre, pred, residuals

def iterative_outlier_removal_and_modeling(X: np.ndarray, Y: np.ndarray) -> Tuple[np.ndarray, np.ndarray, float, float, float, float, float, float]:
    """Iteratively remove outliers and create a regression model until no more outliers are found."""
    iteration = 1
    while True:
        print(f"\nStarting iteration {iteration}")
        X_new, Y_new, b0, b1, b2, r_squared, mmre, pred, residuals = remove_outliers_and_create_model(X, Y)
        print_results(iteration, b0, b1, b2, r_squared, mmre, pred)
        
        if X_new.shape[0] == X.shape[0]:
            print("No more outliers found. Stopping iterations.")
            break
        
        X, Y = X_new, Y_new
        iteration += 1
    
    return X, Y, b0, b1, b2, r_squared, mmre, pred

def print_results(iteration: int, b0: float, b1: float, b2: float, r_squared: float, mmre: float, pred: float):
    """Print regression results."""
    print(f"\nIteration {iteration} Results:")
    print(f"Regression Coefficients: b0 = {b0:.4f}, b1 = {b1:.4f}, b2 = {b2:.4f}")
    print(f"Regression Metrics: R^2 = {r_squared:.4f}, MMRE = {mmre:.4f}, PRED = {pred:.4f}")

def main():
    x1, x2, y = retrieve_data()
    X = np.column_stack((x1, x2))

    print(f"Initial number of data points: {X.shape[0]}")
    X_final, Y_final, b0, b1, b2, r_squared_final, mmre_final, pred_final = iterative_outlier_removal_and_modeling(X, y)
    print(f"\nFinal number of data points after outlier removal: {X_final.shape[0]}")
    print("\nFinal Model Results:")
    print_results("Final", b0, b1, b2, r_squared_final, mmre_final, pred_final)

if __name__ == "__main__":
    main()