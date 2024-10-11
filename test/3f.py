import pandas as pd
import numpy as np
from scipy.stats import t
import os
from typing import Tuple, List

def retrieve_data(filename: str = "3f-60-wmc.csv") -> Tuple[np.ndarray, np.ndarray, np.ndarray, np.ndarray]:
    """Load data from CSV file and return X1, X2, X3, and Y arrays."""
    df = pd.read_csv(os.path.join(os.path.dirname(__file__), os.path.join('data', filename)))
    return df["DIT"].values.astype(float), df["CBO"].values.astype(float), df["WMC"].values.astype(float), df["RFC"].values.astype(float)

def normalize_data(x1: np.ndarray, x2: np.ndarray, x3: np.ndarray, y: np.ndarray) -> np.ndarray:
    """Normalize the data."""
    x1[x1 == 0] = 1
    x2[x2 == 0] = 1
    x3[x3 == 0] = 1
    y[y == 0] = 1
    
    return np.column_stack((np.log10(x1), np.log10(x2), np.log10(x3), np.log10(y)))

def calculate_regression_coefficients(Z: np.ndarray) -> Tuple[float, float, float, float]:
    """Calculate regression coefficients."""
    X = Z[:, :-1]
    Y = Z[:, -1]
    X = np.column_stack((np.ones(X.shape[0]), X))
    coffs = np.linalg.inv(X.T @ X) @ X.T @ Y
    
    # Calculate residuals in log space
    Y_hat = X @ coffs
    residuals = Y - Y_hat
    
    # Estimate standard deviation of residuals
    sigma = np.std(residuals, ddof=1)
    
    return coffs[0], coffs[1], coffs[2], coffs[3], residuals, sigma

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
    string = "Outliers found:\n"
    for i in outliers:
        x1 = int(round(10**Z[i, 0]))
        x2 = int(round(10**Z[i, 1]))
        x3 = int(round(10**Z[i, 2]))
        y = int(round(10**Z[i, 3]))
        string += f"DIT: {x1}, CBO: {x2}, WMC: {x3}, RFC: {y}\n"
    print(string)

def remove_outliers_and_create_model(Z: np.ndarray) -> Tuple[np.ndarray, float, float, float, float, np.ndarray, np.ndarray, np.ndarray]:
    """Remove outliers and create a regression model."""
    b0, b1, b2, b3, residuals, sigma = calculate_regression_coefficients(Z)
    Y_hat = b0 + b1 * Z[:, 0] + b2 * Z[:, 1] + b3 * Z[:, 2]
    
    lower_bound, upper_bound = calculate_prediction_interval(Z, Y_hat)
    outliers = identify_outliers(Z, lower_bound, upper_bound)
    
    if outliers:
        print_outliers(Z, outliers)
        Z = np.delete(Z, outliers, axis=0)
        print(f"Removed {len(outliers)} outliers")
    
    return Z, b0, b1, b2, b3, Y_hat, lower_bound, upper_bound

def iterative_outlier_removal_and_modeling(Z: np.ndarray) -> Tuple[np.ndarray, float, float, float, float, np.ndarray, np.ndarray, np.ndarray]:
    """Iteratively remove outliers and create a regression model until no more outliers are found."""
    iteration = 1
    while True:
        print(f"\nStarting iteration {iteration}")
        Z_new, b0, b1, b2, b3, Y_hat, lower_bound, upper_bound = remove_outliers_and_create_model(Z)
        
        if Z_new.shape[0] == Z.shape[0]:
            print("No more outliers found. Stopping iterations.")
            break
        
        Z = Z_new
        iteration += 1
    
    return Z, b0, b1, b2, b3, Y_hat, lower_bound, upper_bound

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

def calculate_residual_statistics(Y: np.ndarray, Y_hat: np.ndarray) -> Tuple[float, float]:
    """Calculate the sample mean and variance of residuals."""
    residuals = Y - Y_hat
    mean_residual = np.mean(residuals)
    variance_residual = np.var(residuals, ddof=1)
    return mean_residual, variance_residual

def print_results(sigma: float, b0: float, b1: float, b2: float, b3: float, r_squared: float, mmre: float, pred: float, mean_residual: float, variance_residual: float):
    """Print regression results and residual statistics."""
    print(f"\nFinal Results:")
    print(f"Regression Coefficients: ε = {sigma:.4f}, b0 = {b0:.4f}, b1 = {b1:.4f}, b2 = {b2:.4f}, b3 = {b3:.4f}")
    print(f"Regression Metrics: R^2 = {r_squared:.4f}, MMRE = {mmre:.4f}, PRED = {pred:.4f}")
    print(f"Residual Statistics:")
    print(f"Sample Mean of Residuals: {mean_residual:.6f}")
    print(f"Sample Variance of Residuals: {variance_residual:.6f}")

def test_model(model_coefficients: Tuple[float, float, float, float], test_file: str = "3f-40-wmc.csv") -> Tuple[float, float, float]:
    """Test the model on a separate dataset."""
    x1, x2, x3, y = retrieve_data(test_file)
    Z_test = normalize_data(x1, x2, x3, y)
    
    b0, b1, b2, b3 = model_coefficients
    Y_test = Z_test[:, -1]
    Y_hat_test = b0 + b1 * Z_test[:, 0] + b2 * Z_test[:, 1] + b3 * Z_test[:, 2]
    
    r_squared, mmre, pred = calculate_regression_metrics(Y_test, Y_hat_test)
    
    return r_squared, mmre, pred

def main():
    x1, x2, x3, y = retrieve_data()
    Z = normalize_data(x1, x2, x3, y)
    print(f"Initial number of data points: {Z.shape[0]}")
    
    b0, b1, b2, b3, residuals, sigma = calculate_regression_coefficients(Z)
    Y_hat = b0 + b1 * Z[:, 0] + b2 * Z[:, 1] + b3 * Z[:, 2]
    r_squared, mmre, pred = calculate_regression_metrics(Z[:, -1], Y_hat)
    print(f"Regression Coefficients: b0 = {b0:.4f}, b1 = {b1:.4f}, b2 = {b2:.4f}, b3 = {b3:.4f}")
    print(f"Regression Metrics: R^2 = {r_squared:.4f}, MMRE = {mmre:.4f}, PRED = {pred:.4f}")

    Z_final, b0, b1, b2, b3, Y_hat, lower_bound, upper_bound = iterative_outlier_removal_and_modeling(Z)
    print(f"\nFinal number of data points after outlier removal: {Z_final.shape[0]}")
    
    r_squared, mmre, pred = calculate_regression_metrics(Z_final[:, -1], Y_hat)
    mean_residual, variance_residual = calculate_residual_statistics(Z_final[:, -1], Y_hat)    
    print_results(sigma, b0, b1, b2, b3, r_squared, mmre, pred, mean_residual, variance_residual)
    
    # Linear Model Y = b0 + b1 * X1 + b2 * X2 + b3 * X3
    print(f"\nLinear Model: Y = {b0:.4f} + {b1:.4f} * X1 + {b2:.4f} * X2 + {b3:.4f} * X3")
    # Nonlinear Model Y = 10^b0 * X1^b1 * X2^b2 * X3^b3
    print(f"Nonlinear Model: Y = 10^{b0:.4f} * X1^{b1:.4f} * X2^{b2:.4f} * X3^{b3:.4f}")
    
    test_r_squared, test_mmre, test_pred = test_model((b0, b1, b2, b3), "3f-40-wmc.csv")
    print(f"\nTest Results 3 factor model: R^2 = {test_r_squared:.4f}, MMRE = {test_mmre:.4f}, PRED = {test_pred:.4f}")
    
    while True:
        dit, cbo, wmc = input("Enter DIT, CBO, and WMC values separated by spaces: ").split()
        dit, cbo, wmc = float(dit), float(cbo), float(wmc)
        rfc = 10**b0 * dit**b1 * cbo**b2 * wmc**b3
        print(f"Predicted RFC: {int(round(rfc))}")

if __name__ == "__main__":
    main()