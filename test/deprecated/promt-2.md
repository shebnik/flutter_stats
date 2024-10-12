Develop a nonlinear regression model using normalized transformations, incorporating Mahalanobis distance-based outlier detection with Fisher's F-distribution (α = 0.05). Iteratively remove outliers by discarding the data point with the maximum absolute residual, then re-normalize and refit the linear model until residuals are normally distributed. Next, construct a nonlinear regression model, identify and remove any points outside the prediction intervals, and finalize the model. Throughout the process, ensure proper documentation of each step, including initial data characteristics, normalization methods, number of outliers removed, and final model parameters (b0, b1, b2) and performance metrics R², MMRE, PRED(0.25)

```py
def retrieve_data(filename: str = "3f.csv") -> Tuple[np.ndarray, np.ndarray, np.ndarray]:
    """Load data from CSV file and return X1, X2, and Y arrays."""
    df = pd.read_csv(os.path.join(os.path.dirname(__file__), os.path.join('data', filename)))
    return df["x1"].values.astype(float), df["x2"].values.astype(float), df["y"].values.astype(float)

def main():
    x1, x2, y = retrieve_data()
    Z = np.column_stack((np.log10(x1), np.log10(x2), np.log10(y)))
```

