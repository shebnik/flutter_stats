import numpy as np
import pandas as pd
from scipy import stats
import os

class RegressionModel:
    def __init__(self):
        self.b0 = None
        self.b1 = None
        self.X = None
        self.y = None
        self.Zx = None
        self.Zy = None

    def load_data(self, file_path):
        df = pd.read_csv(file_path)
        self.X = df["x"].values.astype(float)
        self.y = df["y"].values.astype(float)
        self.Zx = np.log10(self.X)
        self.Zy = np.log10(self.y)

    def remove_outliers(self):
        n = len(self.Zx)
        cov_inv = np.linalg.inv(np.cov(self.Zx, self.Zy))
        
        mean_Zx, mean_Zy = np.mean(self.Zx), np.mean(self.Zy)
        diff = np.column_stack((self.Zx - mean_Zx, self.Zy - mean_Zy))
        
        mahalanobis_distances = np.sum(diff @ cov_inv * diff, axis=1)
        test_statistic = ((n - 2) * n / ((n**2 - 1) * 2)) * mahalanobis_distances
        
        fisher_f = stats.f.ppf(0.95, 2, n - 2)
        mask = test_statistic <= fisher_f
        
        self.X, self.y = self.X[mask], self.y[mask]
        self.Zx, self.Zy = self.Zx[mask], self.Zy[mask]

    def fit(self):
        Zx_mean = np.mean(self.Zx)
        Zy_mean = np.mean(self.Zy)
        
        numerator = np.sum((self.Zx - Zx_mean) * (self.Zy - Zy_mean))
        denominator = np.sum((self.Zx - Zx_mean) ** 2)
        
        self.b1 = numerator / denominator
        self.b0 = Zy_mean - self.b1 * Zx_mean

    def predict(self, X):
        Zx = np.log10(X)
        return 10 ** (self.b0 + self.b1 * Zx)

    def calculate_metrics(self):
        y_pred = self.predict(self.X)
        
        r_squared = 1 - (np.sum((self.y - y_pred)**2) / np.sum((self.y - np.mean(self.y))**2))
        sy = np.sum((self.y - y_pred)**2)
        mmre = np.mean(np.abs((self.y - y_pred) / self.y))
        pred = np.mean(np.abs((self.y - y_pred) / self.y) < 0.25)
        
        return r_squared, sy, mmre, pred

def main():
    model = RegressionModel()
    model.load_data(os.path.join(os.path.dirname(__file__), "data.csv"))
    
    print("Original data points:", len(model.X))
    model.remove_outliers()
    print("Data points after removing outliers:", len(model.X))
    
    model.fit()
    print(f"\nRegression Coefficients:\nb0: {model.b0:.4f}\nb1: {model.b1:.4f}")
    
    r_squared, sy, mmre, pred = model.calculate_metrics()
    print(f"\nRegression Metrics:\nR^2: {r_squared:.4f}\nSy: {sy:.4f}\nMMRE: {mmre:.4f}\nPRED: {pred:.4f}")

if __name__ == "__main__":
    main()
