import pandas as pd
import matplotlib.pyplot as plt
import numpy as np
from scipy.stats import f
import os


def retrieve_data():
    df = pd.read_csv(os.path.join(os.path.dirname(__file__), os.path.join('data', '3f.csv')))
    X = df["x1"].values.astype(float)
    Y = df["y"].values.astype(float)
    
    Y = Y / 1000
    return X, Y

# Calculates the covariance matrix
def calculate_cov_inv(Zx, Zy):
    n = len(Zx)
    ZxAvg = np.mean(Zx)
    ZyAvg = np.mean(Zy)

    ZxZxAvgDiff = Zx - ZxAvg
    ZyZyAvgDiff = Zy - ZyAvg

    ZxZxAvgDiffSq = ZxZxAvgDiff * ZxZxAvgDiff
    ZyZyAvgDiffSq = ZyZyAvgDiff * ZyZyAvgDiff

    cov = np.zeros((2, 2))
    cov[0][0] = np.sum(ZxZxAvgDiffSq) / n
    cov[0][1] = np.sum(ZxZxAvgDiff * ZyZyAvgDiff) / n
    cov[1][0] = cov[0][1]
    cov[1][1] = np.sum(ZyZyAvgDiffSq) / n
    cov_inv = np.linalg.inv(cov)
    return cov_inv


# Calculates the Mahalanobis distances
def calculate_mahalanobis_distances(Zx, Zy, cov_inv):
    ZxAvg = np.mean(Zx)
    ZyAvg = np.mean(Zy)

    ZxZxAvgDiff = Zx - ZxAvg
    ZyZyAvgDiff = Zy - ZyAvg

    diff_matrix = np.column_stack((ZxZxAvgDiff, ZyZyAvgDiff))
    mahalanobis_distances = np.sum(diff_matrix @ cov_inv * diff_matrix, axis=1)
    return mahalanobis_distances


# Calculates the test statistic
def calculate_test_statistic(n, mahalanobis_distances):
    test_statistic = np.zeros(n)
    for i in range(n):
        test_statistic[i] = ((n - 2) * n / ((n**2 - 1) * 2)) * mahalanobis_distances[i]
    return test_statistic


def determine_outliers(Zx, Zy):
    n = len(Zy)
    # Calculate the covariance matrix
    cov_inv = calculate_cov_inv(Zx, Zy)

    # Calculate Mahalanobis distances
    mahalanobis_distances = calculate_mahalanobis_distances(Zx, Zy, cov_inv)

    # Calculate the test statistic
    test_statistic = calculate_test_statistic(n, mahalanobis_distances)

    # Calculate Fisher's F distribution using FINV(0.05, 2, n-2)
    a = 0.05
    fisher_f = f.ppf(1 - a, 2, n - 2)

    # Determine outliers
    indexes = []
    for i in range(n):
        if test_statistic[i] > fisher_f:
            print(f"Outlier detected: x={10**Zx[i]:.0f}, y={10**Zy[i]*1000:.0f}")
            indexes.append(i)
    return indexes


def calculate_regression_coefficients(Zx, Zy):
    # Calculate the means of Zx and Zy
    Zx_mean = np.mean(Zx)
    Zy_mean = np.mean(Zy)

    # Calculate the regression coefficient b1 (slope)
    numerator = np.sum((Zx - Zx_mean) * (Zy - Zy_mean))
    denominator = np.sum((Zx - Zx_mean) ** 2)
    b1 = numerator / denominator

    # Calculate the regression coefficient b0 (intercept)
    b0 = Zy_mean - b1 * Zx_mean

    return b0, b1

def calculate_regression_metrics(Zy_hat, y):
    n = len(y)
    y_hat = 10**Zy_hat
    y_y_hat_diff_squared = (y - y_hat) ** 2
    y_avg = np.mean(y)
    y_y_avg_diff_squared = (y - y_avg) ** 2
    y_y_hat_diff_y_divided = (y - y_hat) / y

    sy = np.sum(y_y_hat_diff_squared)
    r_squared = 1 - (sy / np.sum(y_y_avg_diff_squared))
    mmre = 1 / n * np.sum(np.abs(y_y_hat_diff_y_divided))
    pred = np.sum(np.abs(y_y_hat_diff_y_divided) < 0.25) / n

    return r_squared, sy, mmre, pred


if __name__ == "__main__":
    x, y = retrieve_data()

    # Normalize the data using log10
    Zx = np.log10(x)
    Zy = np.log10(y)

    # While there are outliers, remove them and recalculate the test statistic
    # outliers = determine_outliers(Zx, Zy)
    # while len(outliers) > 0:
    #     x = np.delete(x, outliers)
    #     y = np.delete(y, outliers)
    #     Zx = np.delete(Zx, outliers)
    #     Zy = np.delete(Zy, outliers)
    #     n = len(Zx)
    #     outliers = determine_outliers(Zx, Zy)

    # Calculate the regression coefficients
    b0, b1 = calculate_regression_coefficients(Zx, Zy)
    print("\nRegression Coefficients:")
    print("b0:", b0)
    print("b1:", b1)

    # Calculate the predicted values
    Zy_hat = b0 + b1 * Zx

    # Calculate regression model metrics
    r_squared, sy, mmre, pred = calculate_regression_metrics(Zy_hat, y)
    print("\nRegression Metrics:")
    print("R^2:", r_squared)
    print("Sy:", sy)
    print("MMRE:", mmre)
    print("PRED:", pred)
