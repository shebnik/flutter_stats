import os
import numpy as np
import pandas as pd
from typing import Tuple, List
from scipy.stats import chi2, shapiro, t
from scipy.spatial.distance import mahalanobis
from sklearn.linear_model import LinearRegression
from sklearn.preprocessing import StandardScaler, PolynomialFeatures
from sklearn.metrics import r2_score
import statsmodels.api as sm

def retrieve_data(filename: str = "3f.csv") -> Tuple[np.ndarray, np.ndarray, np.ndarray]:
    """Load data from CSV file and return X1, X2, and Y arrays."""
    df = pd.read_csv(os.path.join(os.path.dirname(__file__), os.path.join('data', filename)))
    return df["x1"].values.astype(float), df["x2"].values.astype(float), df["y"].values.astype(float)

def calculate_mahalanobis_distance(data: np.ndarray) -> np.ndarray:
    """Calculate the Mahalanobis distance for each observation in the dataset."""
    cov_matrix = np.cov(data, rowvar=False)
    inv_cov_matrix = np.linalg.inv(cov_matrix)
    mean_distr = np.mean(data, axis=0)
    distances = np.array([mahalanobis(row, mean_distr, inv_cov_matrix) for row in data])
    return distances

def iterative_outlier_detection_mahalanobis(Z: np.ndarray, alpha: float = 0.05) -> Tuple[np.ndarray, List[int]]:
    """Iteratively remove outliers based on Mahalanobis distance."""
    outliers_indices = []
    data = Z.copy()
    iteration = 1
    while True:
        distances = calculate_mahalanobis_distance(data)
        df = data.shape[1]
        threshold = np.sqrt(chi2.ppf(1 - alpha, df))
        mask = distances > threshold
        current_outliers = np.where(mask)[0]
        if len(current_outliers) == 0:
            print(f"No more outliers detected at iteration {iteration}.")
            break
        # Adjust indices relative to the original data
        original_indices = list(set(range(Z.shape[0])) - set(outliers_indices))
        outliers_to_add = [original_indices[i] for i in current_outliers]
        print(f"Iteration {iteration}: Detected {len(outliers_to_add)} outliers.")
        outliers_indices.extend(outliers_to_add)
        # Remove outliers for next iteration
        data = np.delete(data, current_outliers, axis=0)
        iteration += 1
    # Final cleaned data
    cleaned_data = Z[~np.isin(np.arange(Z.shape[0]), outliers_indices)]
    return cleaned_data, outliers_indices

def iterative_residual_checking(Z: np.ndarray, alpha: float = 0.05) -> Tuple[LinearRegression, np.ndarray, List[int], StandardScaler]:
    """
    Fit linear regression on normalized data and iteratively remove points
    with non-normal residuals.
    """
    scaler = StandardScaler()
    data = scaler.fit_transform(Z)
    X = data[:, :-1]
    y = data[:, -1]
    removed_indices = []
    iteration = 1
    while True:
        model = LinearRegression()
        model.fit(X, y)
        predictions = model.predict(X)
        residuals = y - predictions
        stat, p_value = shapiro(residuals)
        print(f"Iteration {iteration}: Shapiro-Wilk p-value = {p_value}")
        if p_value > alpha:
            print("Residuals are normally distributed.")
            break
        # Identify the point with the largest absolute residual
        worst_idx = np.argmax(np.abs(residuals))
        # Map back to original indices
        original_indices = np.setdiff1d(np.arange(Z.shape[0]), removed_indices)
        removed_point = original_indices[worst_idx]
        print(f"Removing outlier at index {removed_point} with residual {residuals[worst_idx]}")
        removed_indices.append(removed_point)
        # Remove the outlier and normalize again
        Z = np.delete(Z, worst_idx, axis=0)
        data = scaler.fit_transform(Z)
        X = data[:, :-1]
        y = data[:, -1]
        iteration += 1
    final_model = model
    return final_model, data, removed_indices, scaler

def iterative_nonlinear_outlier_removal(data: np.ndarray, degree: int = 2, alpha: float = 0.05, max_iterations: int = 100) -> Tuple[LinearRegression, PolynomialFeatures, List[int]]:
    """Iteratively remove outliers using prediction intervals from nonlinear regression."""
    X = data[:, :-1]
    y = data[:, -1]
    poly = PolynomialFeatures(degree=degree)
    outliers = []
    iteration = 1

    while iteration <= max_iterations:
        X_poly = poly.fit_transform(X)
        model = LinearRegression(fit_intercept=False)  # Remove intercept to ensure residuals are centered at zero
        model.fit(X_poly, y)
        
        # Calculate residuals
        predictions = model.predict(X_poly)
        residuals = y - predictions
        
        # Center residuals at zero
        y_centered = y - np.mean(residuals)
        model.fit(X_poly, y_centered)
        predictions = model.predict(X_poly)
        residuals = y_centered - predictions
        
        # Calculate prediction intervals
        mse = np.mean(residuals ** 2)
        n = len(y_centered)
        p = X_poly.shape[1]
        df = n - p
        
        t_value = t.ppf(1 - alpha / 2, df)
        se = np.sqrt(mse * (1 + np.sum(X_poly ** 2, axis=1) / np.sum(X_poly ** 2)))
        lower_bound = predictions - t_value * se
        upper_bound = predictions + t_value * se
        
        # Identify outliers
        mask = (y_centered < lower_bound) | (y_centered > upper_bound)
        current_outliers = np.where(mask)[0]
        
        if len(current_outliers) == 0:
            print(f"No more outliers detected at iteration {iteration}.")
            break
        
        print(f"Iteration {iteration}: Detected {len(current_outliers)} outliers.")
        outliers.extend(current_outliers.tolist())
        
        # Remove outliers for next iteration
        X = np.delete(X, current_outliers, axis=0)
        y = np.delete(y, current_outliers)
        iteration += 1

    if iteration > max_iterations:
        print(f"Reached maximum iterations ({max_iterations}). There might still be outliers.")

    # Final fit on cleaned data
    X_poly = poly.fit_transform(X)
    model = LinearRegression(fit_intercept=False)
    model.fit(X_poly, y - np.mean(y))

    return model, poly, outliers

def calculate_mmre(y_true: np.ndarray, y_pred: np.ndarray) -> float:
    """Calculate Mean Magnitude of Relative Error (MMRE)."""
    return np.mean(np.abs((y_true - y_pred) / y_true)) * 100

def calculate_pred_accuracy(y_true: np.ndarray, y_pred: np.ndarray, tau: float = 0.25) -> float:
    """Calculate Prediction Accuracy PRED(tau)."""
    return np.mean(np.abs(y_true - y_pred) / y_true <= tau) * 100

def model_evaluation(final_model: LinearRegression, poly: PolynomialFeatures, data: np.ndarray, removed_outliers_mahalanobis: List[int], removed_outliers_nonlinear: List[int], scaler: StandardScaler):
    """
    Evaluate the final nonlinear model and print required metrics.
    """
    X = data[:, :-1]
    y = data[:, -1]
    X_poly = poly.transform(X)
    predictions = final_model.predict(X_poly)
    
    r2 = r2_score(y, predictions)
    mmre = calculate_mmre(y, predictions)
    pred_accuracy = calculate_pred_accuracy(y, predictions, tau=0.25)
    residuals = y - predictions
    residual_mean = np.mean(residuals)
    residual_var = np.var(residuals, ddof=1)
    
    # Print results
    print("\n--- Model Evaluation ---")
    print(f"Number of outliers removed using Mahalanobis Distance: {len(removed_outliers_mahalanobis)}")
    print(f"Number of outliers removed after Nonlinear Regression: {len(removed_outliers_nonlinear)}")
    print(f"Regression Coefficients: {final_model.coef_}")
    print(f"Coefficient of Determination (R²): {r2:.4f}")
    print(f"Mean Magnitude of Relative Error (MMRE): {mmre:.2f}%")
    print(f"Prediction Accuracy (PRED(0.25)): {pred_accuracy:.2f}%")
    print(f"Residuals Mean: {residual_mean:.4f}")
    print(f"Residuals Variance: {residual_var:.4f}")

def main():
    # Step 0: Retrieve and transform data
    x1, x2, y = retrieve_data("2f-den.csv")
    Z = np.column_stack((np.log10(x1), np.log10(x2), np.log10(y)))
    
    # Step 1: Iterative Outlier Detection using Mahalanobis Distance
    print("Starting Iterative Outlier Detection using Mahalanobis Distance...")
    Z_cleaned_mahalanobis, outliers_mahalanobis = iterative_outlier_detection_mahalanobis(Z, alpha=0.05)
    
    # Step 2: Linear Regression with Normalized Data and Iterative Residual Checking
    print("\nStarting Linear Regression with Iterative Residual Checking...")
    linear_model, data_normalized, removed_outliers_linear, scaler = iterative_residual_checking(Z_cleaned_mahalanobis, alpha=0.05)
    
    # Step 3: Build Nonlinear Regression Model and Iteratively Remove Outliers
    print("\nStarting Nonlinear Regression with Iterative Outlier Removal...")
    nonlinear_model, poly, outliers_nonlinear = iterative_nonlinear_outlier_removal(data_normalized, degree=2, alpha=0.05)
    
    # Step 4: Model Evaluation
    print("\nEvaluating the Final Model...")
    model_evaluation(nonlinear_model, poly, data_normalized, outliers_mahalanobis, outliers_nonlinear, scaler)
    print(f"\nFinal number of outliers removed: {len(outliers_mahalanobis) + len(outliers_nonlinear)}")

if __name__ == "__main__":
    main()