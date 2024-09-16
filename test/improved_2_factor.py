import numpy as np
import pandas as pd
from scipy import stats
import os
from sklearn.preprocessing import StandardScaler

class TwoFactorRegressionModel:
    def __init__(self):
        self.coefficients = None
        self.X = None
        self.y = None
        self.Z_X = None
        self.Z_y = None
        self.scaler = StandardScaler()

    def load_data(self, file_path):
        df = pd.read_csv(file_path)
        self.y = df["Y (Lines of Code)"].values.astype(float)
        self.X = np.column_stack((
            df["X1 (Number of Classes)"].values.astype(float),
            df["X2 (Number of Methods)"].values.astype(float)
        ))
        self.Z_y = np.log10(self.y)
        self.Z_X = np.log10(self.X)

    def remove_outliers(self):
        n, p = self.Z_X.shape
        Z = np.column_stack((self.Z_X, self.Z_y))
        cov_inv = np.linalg.inv(np.cov(Z.T))
        print("Inverse Covariance Matrix:")
        print(cov_inv)
        print()
        
        mean_Z = np.mean(Z, axis=0)
        diff = Z - mean_Z
        
        mahalanobis_distances = np.sum(diff @ cov_inv * diff, axis=1)
        print("Mahalanobis Distances:")
        print(mahalanobis_distances)
        print()
        
        test_statistic = ((n - p - 1) * n / ((n**2 - 1) * p)) * mahalanobis_distances
        print("Test Statistic:")
        print(test_statistic)
        print()
        
        fisher_f = stats.f.ppf(0.95, p + 1, n - p - 1)
        mask = test_statistic <= fisher_f
        
        for i in range(n):
            if test_statistic[i] > fisher_f:
                print(
                    "Removed outlier: y={}, x1={}, x2={}".format(
                        self.y[i], self.X[i, 0], self.X[i, 1]
                    )
                )
        
        self.X, self.y = self.X[mask], self.y[mask]
        self.Z_X, self.Z_y = self.Z_X[mask], self.Z_y[mask]

    def normalize_data(self):
        self.Z_X = self.scaler.fit_transform(self.Z_X)

    def remove_max_deviation_point(self):
        X_with_intercept = np.column_stack((np.ones(len(self.Z_X)), self.Z_X))
        coeffs = np.linalg.inv(X_with_intercept.T @ X_with_intercept) @ X_with_intercept.T @ self.Z_y
        y_pred = X_with_intercept @ coeffs
        residuals = self.Z_y - y_pred
        max_deviation_index = np.argmax(np.abs(residuals))
        
        self.X = np.delete(self.X, max_deviation_index, axis=0)
        self.y = np.delete(self.y, max_deviation_index)
        self.Z_X = np.delete(self.Z_X, max_deviation_index, axis=0)
        self.Z_y = np.delete(self.Z_y, max_deviation_index)

    def check_residuals_normality(self):
        X_with_intercept = np.column_stack((np.ones(len(self.Z_X)), self.Z_X))
        coeffs = np.linalg.inv(X_with_intercept.T @ X_with_intercept) @ X_with_intercept.T @ self.Z_y
        y_pred = X_with_intercept @ coeffs
        residuals = self.Z_y - y_pred
        _, p_value = stats.shapiro(residuals)
        return p_value > 0.05  # Assuming 5% significance level

    def iterative_outlier_removal(self):
        while True:
            self.normalize_data()
            if self.check_residuals_normality():
                break
            self.remove_max_deviation_point()

    def fit(self):
        X_with_intercept = np.column_stack((np.ones(len(self.Z_X)), self.Z_X))
        self.coefficients = np.linalg.inv(X_with_intercept.T @ X_with_intercept) @ X_with_intercept.T @ self.Z_y

    def predict(self, X):
        Z_X = np.log10(X)
        Z_X_normalized = self.scaler.transform(Z_X)
        Z_X_with_intercept = np.column_stack((np.ones(len(Z_X_normalized)), Z_X_normalized))
        return 10 ** (Z_X_with_intercept @ self.coefficients)

    def calculate_metrics(self):
        y_pred = self.predict(self.X)
        
        r_squared = 1 - (np.sum((self.y - y_pred)**2) / np.sum((self.y - np.mean(self.y))**2))
        sy = np.sum((self.y - y_pred)**2)
        mmre = np.mean(np.abs((self.y - y_pred) / self.y))
        pred = np.mean(np.abs((self.y - y_pred) / self.y) < 0.25)
        
        return r_squared, sy, mmre, pred

    def remove_points_outside_prediction_interval(self, confidence=0.95):
        X_with_intercept = np.column_stack((np.ones(len(self.Z_X)), self.Z_X))
        n = len(self.Z_y)
        p = X_with_intercept.shape[1]
        
        y_pred = X_with_intercept @ self.coefficients
        residuals = self.Z_y - y_pred
        mse = np.sum(residuals**2) / (n - p)
        
        t_value = stats.t.ppf((1 + confidence) / 2, n - p)
        
        se = np.sqrt(mse * (1 + np.diag(X_with_intercept @ np.linalg.inv(X_with_intercept.T @ X_with_intercept) @ X_with_intercept.T)))
        margin_of_error = t_value * se
        
        lower_bound = y_pred - margin_of_error
        upper_bound = y_pred + margin_of_error
        
        within_interval = (self.Z_y >= lower_bound) & (self.Z_y <= upper_bound)
        
        self.X = self.X[within_interval]
        self.y = self.y[within_interval]
        self.Z_X = self.Z_X[within_interval]
        self.Z_y = self.Z_y[within_interval]

def main():
    model = TwoFactorRegressionModel()
    model.load_data(os.path.join(os.path.dirname(__file__), "den.csv"))
    
    print("Original data points:", len(model.X))
    
    
    model.remove_outliers()
    print("Data points after outlier removal:", len(model.X))
    
    model.fit()
    
    model.iterative_outlier_removal()
    print("Data points after interactive outlier removal:", len(model.X))
    
    model.fit()
    model.remove_points_outside_prediction_interval()
    print("Data points after removing points outside prediction interval:", len(model.X))
    
    model.fit()  # Fit the model again with the final dataset
    
    print("\nRegression Coefficients:")
    print(f"Intercept: {model.coefficients[0]:.4f}")
    print(f"X1 (Number of Classes): {model.coefficients[1]:.4f}")
    print(f"X2 (Number of Methods): {model.coefficients[2]:.4f}")
    
    r_squared, sy, mmre, pred = model.calculate_metrics()
    print(f"\nRegression Metrics:\nR^2: {r_squared:.4f}\nSy: {sy:.4f}\nMMRE: {mmre:.4f}\nPRED: {pred:.4f}")

if __name__ == "__main__":
    main()