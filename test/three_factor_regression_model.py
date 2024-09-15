import numpy as np
import pandas as pd
from scipy import stats
import os

class ThreeFactorRegressionModel:
    def __init__(self):
        self.coefficients = None
        self.X = None
        self.y = None
        self.Z_X = None
        self.Z_y = None

    def load_data(self, file_path):
        df = pd.read_csv(file_path)
        self.y = df["Y (Lines of Code)"].values.astype(float)
        self.X = np.column_stack((
            df["X1 (Number of Classes)"].values.astype(float),
            df["X2 (Number of Methods)"].values.astype(float),
            df["X3 (Number of dependencies)"].values.astype(float)
        ))
        self.Z_y = np.log10(self.y)
        self.Z_X = np.log10(self.X)

    def remove_outliers(self):
        n, p = self.Z_X.shape
        Z = np.column_stack((self.Z_X, self.Z_y))
        cov_inv = np.linalg.inv(np.cov(Z.T))
        
        mean_Z = np.mean(Z, axis=0)
        diff = Z - mean_Z
        
        mahalanobis_distances = np.sum(diff @ cov_inv * diff, axis=1)
        test_statistic = ((n - p - 1) * n / ((n**2 - 1) * p)) * mahalanobis_distances
        
        fisher_f = stats.f.ppf(0.95, p + 1, n - p - 1)
        mask = test_statistic <= fisher_f
        
        self.X, self.y = self.X[mask], self.y[mask]
        self.Z_X, self.Z_y = self.Z_X[mask], self.Z_y[mask]

    def fit(self):
        X_with_intercept = np.column_stack((np.ones(len(self.Z_X)), self.Z_X))
        self.coefficients = np.linalg.inv(X_with_intercept.T @ X_with_intercept) @ X_with_intercept.T @ self.Z_y

    def predict(self, X):
        Z_X = np.log10(X)
        Z_X_with_intercept = np.column_stack((np.ones(len(Z_X)), Z_X))
        return 10 ** (Z_X_with_intercept @ self.coefficients)

    def calculate_metrics(self):
        y_pred = self.predict(self.X)
        
        r_squared = 1 - (np.sum((self.y - y_pred)**2) / np.sum((self.y - np.mean(self.y))**2))
        sy = np.sum((self.y - y_pred)**2)
        mmre = np.mean(np.abs((self.y - y_pred) / self.y))
        pred = np.mean(np.abs((self.y - y_pred) / self.y) < 0.25)
        
        return r_squared, sy, mmre, pred

def main():
    model = ThreeFactorRegressionModel()
    model.load_data(os.path.join(os.path.dirname(__file__), "flutter_metrics.csv"))
    
    print("Original data points:", len(model.X))
    model.remove_outliers()
    print("Data points after removing outliers:", len(model.X))
    
    model.fit()
    print("\nRegression Coefficients:")
    print(f"Intercept: {model.coefficients[0]:.4f}")
    print(f"X1 (Number of Classes): {model.coefficients[1]:.4f}")
    print(f"X2 (Number of Methods): {model.coefficients[2]:.4f}")
    print(f"X3 (Number of dependencies): {model.coefficients[3]:.4f}")
    
    r_squared, sy, mmre, pred = model.calculate_metrics()
    print(f"\nRegression Metrics:\nR^2: {r_squared:.4f}\nSy: {sy:.4f}\nMMRE: {mmre:.4f}\nPRED: {pred:.4f}")

if __name__ == "__main__":
    main()