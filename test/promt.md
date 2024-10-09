1. **Iterative Outlier Detection using Mahalanobis Distance**:
   - **Step 1**: After applying the log transformation, calculate the Mahalanobis distance for each data point.
   - **Step 2**: Identify outliers using test statistics and Fisher F-distribution with alpha 0.05.
   - **Step 3**: Remove the detected outliers, and refit the model on the remaining data.
   - Repeat **Steps 1-3** iteratively until no more outliers are detected.

2. **Linear Regression with Normalized Data and Iterative Residual Checking**:
   - **Fit a linear regression model**: Perform linear regression on the normalized data.
   - **Check normality of residuals** (ε): Test the normality of the residuals using Shapiro-Wilk test.
   - If the residuals are not normally distributed:
     - Identify the data point with the largest absolute deviation from the regression.
     - Remove the point, re-normalize the data, and refit the linear model.
   - Repeat the process iteratively until the residuals are normally distributed.

3. **Build Nonlinear Regression Model and Iteratively Remove Outliers**:
   - **Nonlinear model construction**: Once the residuals of the linear model are normal, build a nonlinear regression model based on the transformed data.
   - **Outlier detection in nonlinear model**: Identify points that fall outside the prediction interval of the nonlinear regression model (e.g., using a 95% confidence interval).
   - **Iterative refinement**: Remove the outliers and refit the nonlinear model.
   - Repeat until no data points fall outside the prediction interval.

4. **Model Evaluation**:
   - **Outlier count**: Print the number of outliers removed during each iterative process (both in the Mahalanobis distance step and after the nonlinear regression).
   - **Metrics to calculate**:
     - Regression coefficients (`b0`, `b1`, `b2`) for the final nonlinear model.
     - Coefficient of determination (R²).
     - Mean Magnitude of Relative Error (MMRE).
     - Prediction accuracy (PRED(0.25)).
     - Sample mean and variance of the residuals.


```py
def retrieve_data(filename: str = "3f.csv") -> Tuple[np.ndarray, np.ndarray, np.ndarray]:
    """Load data from CSV file and return X1, X2, and Y arrays."""
    df = pd.read_csv(os.path.join(os.path.dirname(__file__), os.path.join('data', filename)))
    return df["x1"].values.astype(float), df["x2"].values.astype(float), df["y"].values.astype(float)

def main():
    x1, x2, y = retrieve_data()
    Z = np.column_stack((np.log10(x1), np.log10(x2), np.log10(y)))
```