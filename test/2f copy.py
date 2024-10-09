import os
import numpy as np
import pandas as pd
from typing import Tuple
from sklearn.linear_model import LinearRegression
from scipy.stats import shapiro, chi2
import statsmodels.api as sm
import matplotlib.pyplot as plt
import seaborn as sns

def retrieve_data(filename: str = "3f.csv") -> Tuple[np.ndarray, np.ndarray, np.ndarray]:
    """
    Load data from a CSV file and return X1, X2, and Y arrays.

    Parameters:
    - filename: str, name of the CSV file located in the 'data' directory.

    Returns:
    - Tuple containing NumPy arrays of x1, x2, and y.
    """
    file_path = os.path.join(os.path.dirname(__file__), 'data', filename)
    df = pd.read_csv(file_path)
    return df["x1"].values.astype(float), df["x2"].values.astype(float), df["y"].values.astype(float)

def perform_normalization(x1: np.ndarray, x2: np.ndarray, y: np.ndarray) -> pd.DataFrame:
    """
    Apply logarithmic normalization to the data.

    Parameters:
    - x1, x2, y: numpy arrays of the original data.

    Returns:
    - DataFrame containing normalized log10(x1), log10(x2), log10(y).
    """
    return pd.DataFrame({
        'log_x1': np.log10(x1),
        'log_x2': np.log10(x2),
        'log_y': np.log10(y)
    })

def fit_linear_model(data: pd.DataFrame) -> sm.OLS:
    """
    Fit a linear regression model using statsmodels.

    Parameters:
    - data: DataFrame containing normalized data.

    Returns:
    - Fitted OLS model.
    """
    X = data[['log_x1', 'log_x2']]
    X = sm.add_constant(X)  # Adds a constant term to the predictor
    y = data['log_y']
    model = sm.OLS(y, X).fit()
    return model

def check_residuals_normality(residuals: np.ndarray, alpha: float = 0.05) -> bool:
    """
    Perform Shapiro-Wilk test for normality on residuals.

    Parameters:
    - residuals: array of residuals from the regression.
    - alpha: significance level.

    Returns:
    - True if residuals are normally distributed, False otherwise.
    """
    stat, p_value = shapiro(residuals)
    print(f"Shapiro-Wilk Test: Statistics={stat:.4f}, p-value={p_value:.4f}")
    return p_value > alpha

def iterative_normalization_and_regression(data: pd.DataFrame) -> sm.OLS:
    """
    Iteratively remove the data point with the maximum absolute residual
    until residuals are normally distributed.

    Parameters:
    - data: DataFrame containing normalized data.

    Returns:
    - Final fitted OLS model with normally distributed residuals.
    """
    iteration = 0
    while True:
        print(f"\nIteration {iteration}:")
        model = fit_linear_model(data)
        residuals = model.resid
        print(model.summary())
        if check_residuals_normality(residuals):
            print("Residuals are normally distributed.")
            break
        # Identify the index with the maximum absolute residual
        max_resid_idx = residuals.abs().idxmax()
        print(f"Removing data point with index {max_resid_idx} having residual {residuals[max_resid_idx]:.4f}")
        data = data.drop(max_resid_idx)
        iteration += 1
        if len(data) < 3:
            raise ValueError("Not enough data points to perform regression.")
    return model

def build_nonlinear_model(model: sm.OLS, original_data: pd.DataFrame, x1: np.ndarray, x2: np.ndarray, y: np.ndarray) -> Tuple[dict, sm.OLS]:
    """
    Build a nonlinear regression model based on the linear model in log space.

    Parameters:
    - model: Fitted OLS model from the normalized data.
    - original_data: DataFrame containing normalized data after outlier removal.
    - x1, x2, y: Original data arrays.

    Returns:
    - Dictionary of nonlinear model coefficients.
    - Fitted OLS model after final regression.
    """
    # Extract coefficients
    params = model.params
    beta0 = params['const']
    beta1 = params['log_x1']
    beta2 = params['log_x2']
    print(f"\nNonlinear Model Coefficients:")
    print(f"a (10^beta0): {10**beta0:.4f}")
    print(f"b (beta1): {beta1:.4f}")
    print(f"c (beta2): {beta2:.4f}")

    coeff = {
        'a': 10**beta0,
        'b': beta1,
        'c': beta2
    }

    # Predict y using the model
    X = original_data[['log_x1', 'log_x2']]
    X = sm.add_constant(X)
    predicted_log_y = model.predict(X)
    predicted_y = 10**predicted_log_y

    # Calculate residuals in original scale
    residuals = y - predicted_y

    # Define prediction interval (e.g., mean ± 2*std)
    std_resid = np.std(residuals)
    print(f"Residuals Standard Deviation: {std_resid:.4f}")
    lower_bound = predicted_y - 2 * std_resid
    upper_bound = predicted_y + 2 * std_resid

    # Identify outliers outside the prediction interval
    outliers = (y < lower_bound) | (y > upper_bound)
    num_outliers = np.sum(outliers)
    print(f"Number of data points outside the prediction interval: {num_outliers}")

    if num_outliers > 0:
        # Remove outliers
        inliers = ~outliers
        refined_data = original_data[inliers].copy()
        print(f"Removing {num_outliers} outliers and refitting the model.")
        # Refit the model without outliers
        final_model = iteratively_refine_model(refined_data)
    else:
        final_model = model

    return coeff, final_model

def iteratively_refine_model(data: pd.DataFrame) -> sm.OLS:
    """
    Refine the model by ensuring residuals are normally distributed after
    removing outliers.

    Parameters:
    - data: DataFrame containing data after outlier removal.

    Returns:
    - Final fitted OLS model.
    """
    iteration = 0
    while True:
        print(f"\nRefinement Iteration {iteration}:")
        model = fit_linear_model(data)
        residuals = model.resid
        print(model.summary())
        if check_residuals_normality(residuals):
            print("Residuals are normally distributed after refinement.")
            break
        # Identify the index with the maximum absolute residual
        max_resid_idx = residuals.abs().idxmax()
        print(f"Removing outlier with index {max_resid_idx} having residual {residuals[max_resid_idx]:.4f}")
        data = data.drop(max_resid_idx)
        iteration += 1
        if len(data) < 3:
            raise ValueError("Not enough data points to perform regression after refinement.")
    return model

def plot_residuals(model: sm.OLS, data: pd.DataFrame):
    """
    Plot residuals to visually inspect normality.

    Parameters:
    - model: Fitted OLS model.
    - data: DataFrame containing the data used for fitting.
    """
    residuals = model.resid
    sns.histplot(residuals, kde=True)
    plt.title("Residuals Distribution")
    plt.xlabel("Residuals")
    plt.ylabel("Frequency")
    plt.show()

    # QQ-plot
    sm.qqplot(residuals, line='s')
    plt.title("QQ-Plot of Residuals")
    plt.show()

def calculate_mmre(y_true: np.ndarray, y_pred: np.ndarray) -> float:
    """
    Calculate the Mean Magnitude of Relative Error (MMRE).

    Parameters:
    - y_true: Array of true values
    - y_pred: Array of predicted values

    Returns:
    - MMRE value
    """
    return np.mean(np.abs((y_true - y_pred) / y_true))

def calculate_pred(y_true: np.ndarray, y_pred: np.ndarray, threshold: float = 0.25) -> float:
    """
    Calculate PRED(threshold), the percentage of predictions within threshold of actual values.

    Parameters:
    - y_true: Array of true values
    - y_pred: Array of predicted values
    - threshold: Threshold for acceptable relative error (default 0.25)

    Returns:
    - PRED(threshold) value
    """
    within_threshold = np.sum(np.abs((y_true - y_pred) / y_true) <= threshold)
    return within_threshold / len(y_true)

def evaluate_model(model: sm.OLS, X: pd.DataFrame, y_true: np.ndarray):
    """
    Evaluate the model using various metrics.

    Parameters:
    - model: Fitted OLS model
    - X: Input features
    - y_true: True output values

    Returns:
    - Dictionary containing evaluation metrics
    """
    y_pred = model.predict(X)
    residuals = y_true - y_pred
    
    return {
        'coefficients': model.params.to_dict(),
        'r_squared': model.rsquared,
        'mmre': calculate_mmre(y_true, y_pred),
        'pred_25': calculate_pred(y_true, y_pred),
        'residuals_mean': np.mean(residuals),
        'residuals_variance': np.var(residuals)
    }

def mahalanobis_distance(x: np.ndarray, data: np.ndarray) -> float:
    """
    Calculate the Mahalanobis distance for a point x from the data.

    Parameters:
    - x: The point to calculate the distance for
    - data: The dataset

    Returns:
    - Mahalanobis distance
    """
    covariance_matrix = np.cov(data, rowvar=False)
    inv_covariance_matrix = np.linalg.inv(covariance_matrix)
    diff = x - np.mean(data, axis=0)
    return np.sqrt(diff.dot(inv_covariance_matrix).dot(diff))

def remove_mahalanobis_outliers(data: pd.DataFrame, threshold: float = 0.975) -> pd.DataFrame:
    """
    Remove outliers based on Mahalanobis distance.

    Parameters:
    - data: DataFrame containing the data
    - threshold: Chi-square distribution threshold (default 0.975 for 97.5% confidence)

    Returns:
    - DataFrame with outliers removed
    """
    X = data[['log_x1', 'log_x2']].values
    y = data['log_y'].values
    
    distances = np.array([mahalanobis_distance(x, X) for x in X])
    df = X.shape[1]  # degrees of freedom (number of variables)
    chi2_value = chi2.ppf(threshold, df)
    
    mask = distances < chi2_value
    return data[mask]

def iterative_mahalanobis_and_regression(data: pd.DataFrame, max_iterations: int = 10) -> Tuple[sm.OLS, pd.DataFrame]:
    """
    Iteratively remove outliers using Mahalanobis distance and perform regression.

    Parameters:
    - data: DataFrame containing the data
    - max_iterations: Maximum number of iterations to perform

    Returns:
    - Tuple of (final fitted OLS model, cleaned DataFrame)
    """
    iteration = 0
    n_samples = len(data)
    
    while iteration < max_iterations:
        print(f"\nMahalanobis Iteration {iteration}:")
        model = fit_linear_model(data)
        print(model.summary())
        
        # Remove outliers
        cleaned_data = remove_mahalanobis_outliers(data)
        
        if len(cleaned_data) == n_samples:
            print("No more outliers detected.")
            break
        
        print(f"Removed {n_samples - len(cleaned_data)} outliers.")
        n_samples = len(cleaned_data)
        data = cleaned_data
        iteration += 1
    
    return model, data


def build_nonlinear_regression_model():
    """
    Main method to build the nonlinear regression model following the specified steps.

    Returns:
    - Dictionary of nonlinear model coefficients.
    - Final fitted OLS model.
    - Evaluation metrics.
    """
    # Step 1: Retrieve and normalize data
    x1, x2, y = retrieve_data()
    normalized_data = perform_normalization(x1, x2, y)
    print("Data normalization complete.")
    
    # Step 2: Iteratively fit linear model ensuring normal residuals
    refined_model, cleaned_data = iterative_mahalanobis_and_regression(normalized_data)
    plot_residuals(refined_model, cleaned_data)

    # Step 3: Iteratively fit linear model ensuring normal residuals
    refined_model = iterative_normalization_and_regression(cleaned_data)
    plot_residuals(refined_model, normalized_data)

    # Step 4: Build nonlinear model and remove prediction interval outliers
    coeff, final_model = build_nonlinear_model(refined_model, normalized_data, x1, x2, y)
    plot_residuals(final_model, normalized_data)

    # Step 5: Evaluate the final model
    X = sm.add_constant(normalized_data[['log_x1', 'log_x2']])
    evaluation_metrics = evaluate_model(final_model, X, normalized_data['log_y'])

    return coeff, final_model, evaluation_metrics

def main():
    """
    Execute the nonlinear regression building process and print evaluation metrics.
    """
    coefficients, model, metrics = build_nonlinear_regression_model()
    print("\nFinal Model Coefficients:")
    print(f"a = {coefficients['a']:.4f}")
    print(f"b = {coefficients['b']:.4f}")
    print(f"c = {coefficients['c']:.4f}")
    print("\nFinal Regression Summary:")
    print(model.summary())
    
    print("\nModel Evaluation Metrics:")
    print(f"Number of Observations: {model.nobs}")
    print(f"Regression Coefficients: {metrics['coefficients']}")
    print(f"R-squared: {metrics['r_squared']:.4f}")
    print(f"MMRE: {metrics['mmre']:.4f}")
    print(f"PRED(0.25): {metrics['pred_25']:.4f}")
    print(f"Residuals Mean: {metrics['residuals_mean']:.4f}")
    print(f"Residuals Variance: {metrics['residuals_variance']:.4f}")

if __name__ == "__main__":
    main()