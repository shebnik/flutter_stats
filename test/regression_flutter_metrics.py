import pandas as pd
import numpy as np
from scipy.stats import f, chi2, norm, t
import os
import matplotlib.pyplot as plt


def retrieve_data():
    df = pd.read_csv(os.path.join(os.path.dirname(__file__), "flutter_metrics.csv"))
    y = df["Y (Lines of Code)"].values.astype(float)
    x1 = df["X1 (Number of Classes)"].values.astype(float)
    x2 = df["X2 (Number of Methods)"].values.astype(float)
    x3 = df["X3 (Number of dependencies)"].values.astype(float)
    return y / 1000, x1, x2, x3


def normalize_data(y, x1, x2, x3):
    Zy = np.log10(y)
    Zx1 = np.log10(x1)
    Zx2 = np.log10(x2)
    Zx3 = np.log10(x3)

    # print("Нормалізовані дані (log10)")
    # print(f"Zy: {Zy}")
    # print()
    # print(f"Zx1: {Zx1}")
    # print()
    # print(f"Zx2: {Zx2}")
    # print()
    # print(f"Zx3: {Zx3}")
    # print()

    return Zy, Zx1, Zx2, Zx3


def calculate_cov_inv(Zy, Zx1, Zx2, Zx3):
    cov = np.cov(np.column_stack((Zy, Zx1, Zx2, Zx3)), rowvar=False, bias=True)
    # print("Коваріаційна матриця:")
    # print(cov)
    # print()
    cov_inv = np.linalg.inv(cov)
    return cov_inv


def calculate_mahalanobis_distances(Zy, Zx1, Zx2, Zx3, cov_inv):
    # Calculate the mean of each dimension
    ZyAvg = np.mean(Zy)
    Zx1Avg = np.mean(Zx1)
    Zx2Avg = np.mean(Zx2)
    Zx3Avg = np.mean(Zx3)

    # Calculate the difference from the mean for each dimension
    ZyDiff = Zy - ZyAvg
    Zx1Diff = Zx1 - Zx1Avg
    Zx2Diff = Zx2 - Zx2Avg
    Zx3Diff = Zx3 - Zx3Avg

    # Stack the differences into a matrix
    diff_matrix = np.column_stack((ZyDiff, Zx1Diff, Zx2Diff, Zx3Diff))

    # Calculate Mahalanobis distances
    mahalanobis_distances = np.sum(diff_matrix @ cov_inv * diff_matrix, axis=1)

    return mahalanobis_distances


def calculate_test_statistic(n, mahalanobis_distances):
    test_statistic = np.zeros(n)
    for i in range(n):
        test_statistic[i] = (n - 4) * n / ((n**2 - 1) * 4) * mahalanobis_distances[i]
    return test_statistic


def determine_outliers(y, x1, x2, x3, alpha=0.05):
    n = len(y)
    cov_inv = calculate_cov_inv(y, x1, x2, x3)
    # print("Обернена коваріаційна матриця:")
    # print(cov_inv)
    # print()

    mahalanobis_distances = calculate_mahalanobis_distances(y, x1, x2, x3, cov_inv)
    # print("Махаланобісові відстані:")
    # print(mahalanobis_distances)
    # print()

    test_statistic = calculate_test_statistic(n, mahalanobis_distances)
    # print("Тестова статистика:")
    # print(test_statistic)
    # print()

    fisher_f = f.ppf(1 - alpha, 4, n - 4)
    # print(f"Критичне значення: {fisher_f:.6f}\n")

    indexes = []
    for i in range(n):
        if test_statistic[i] > fisher_f:
            print(
                "Видалено викид: y={}, x1={}, x2={}, x3={}".format(
                    y[i], x1[i], x2[i], x3[i]
                )
            )
            indexes.append(i)
    return indexes


def calculate_regression_coefficients(y, X1, X2, X3):
    n = len(y)
    
    X = np.column_stack((np.ones(n), X1, X2, X3))
    
    X_transpose = np.transpose(X)
    X_transpose_X = np.dot(X_transpose, X)
    X_transpose_X_inv = np.linalg.inv(X_transpose_X)
    X_transpose_y = np.dot(X_transpose, y)
    b = np.dot(X_transpose_X_inv, X_transpose_y)
    
    return b


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


def predict_new_values(coefficients):
    b0, b1, b2, b3 = coefficients
    x1 = float(input("Enter Number of Classes (NOC): "))
    x2 = float(input("Enter Number of Methods (NOM): "))
    x3 = float(input("Enter Number of dependencies: "))

    Zx1 = np.log10(x1)
    Zx2 = np.log10(x2)
    Zx3 = np.log10(x3)

    Zy_hat = b0 + b1 * Zx1 + b2 * Zx2 + b3 * Zx3
    y_hat = 10**Zy_hat
    print(f"Predicted LOC (Lines of Code): {y_hat:.2f}")


if __name__ == "__main__":    
    y, x1, x2, x3 = retrieve_data()
    Zy, Zx1, Zx2, Zx3 = normalize_data(y, x1, x2, x3)

    outliers = determine_outliers(Zy, Zx1, Zx2, Zx3)
    while len(outliers) > 0:
        y = np.delete(y, outliers)
        x1 = np.delete(x1, outliers)
        x2 = np.delete(x2, outliers)
        x3 = np.delete(x3, outliers)
        Zy = np.delete(Zy, outliers)
        Zx1 = np.delete(Zx1, outliers)
        Zx2 = np.delete(Zx2, outliers)
        Zx3 = np.delete(Zx3, outliers)
        outliers = determine_outliers(Zy, Zx1, Zx2, Zx3)
    print("Викидів не виявлено\n")
    
    b0, b1, b2, b3 = calculate_regression_coefficients(Zy, Zx1, Zx2, Zx3)
    print("\nRegression Coefficients:")
    print("b0:", b0)
    print("b1:", b1)
    print("b2:", b2)
    print("b3:", b3)

    # Calculate the predicted values
    Zy_hat = b0 + b1 * Zx1 + b2 * Zx2 + b3 * Zx3
    y_hat = 10**Zy_hat
    print("\nPredicted Values:")
    print(Zy_hat)

    # Calculate regression model metrics
    r_squared, sy, mmre, pred = calculate_regression_metrics(Zy_hat, y)
    print("\nRegression Metrics:")
    print("R^2:", r_squared)
    print("Sy:", sy)
    print("MMRE:", mmre)
    print("PRED:", pred)

    # Predict new values based on user input
    predict_new_values((b0, b1, b2, b3))
