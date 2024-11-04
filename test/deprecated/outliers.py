from dataclasses import dataclass
import pandas as pd
import numpy as np
import os
from typing import List, Tuple
from scipy.stats import f
import random

@dataclass(frozen=True)
class Project:
    url: str
    cbo: float
    wmc: float
    rfc: float
    noc: float
    zx1: float = 0.0
    zx2: float = 0.0
    zy: float = 0.0
    
def data_path(filename: str) -> str:
    """Return the full path to the data file."""
    return os.path.join(os.path.dirname(__file__), os.path.join('data', filename))

def retrieve_data(filename: str = "100.csv") -> List[Project]:
    """Load data from CSV file and return a list of Project objects."""
    df = pd.read_csv(data_path(filename))
    return [Project(row['URL'], row['CBO'], row['WMC'], row['RFC'], row['NOC']) 
            for _, row in df.iterrows()]

def normalize_data(projects: List[Project]) -> List[Project]:
    """Normalize the data."""
    normalized_projects = []
    for project in projects:
        cbo = max(project.cbo, 1)
        wmc = max(project.wmc, 1)
        rfc = max(project.rfc, 1)
        noc = max(project.noc, 1)
        
        zx1 = np.log10(cbo / noc)
        zx2 = np.log10(wmc / noc)
        zy = np.log10(rfc / noc)
        
        normalized_projects.append(Project(project.url, project.cbo, project.wmc, project.rfc, project.noc, zx1, zx2, zy))
    
    return normalized_projects

def projects_to_array(projects: List[Project]) -> np.ndarray:
    """Convert a list of Project objects to a numpy array."""
    return np.array([[p.zx1, p.zx2, p.zy] for p in projects])

def calculate_cov_inv(Z: np.ndarray) -> np.ndarray:
    """Calculate the inverse of the covariance matrix."""
    n = Z.shape[0]
    Z_centered = Z - np.mean(Z, axis=0)
    cov = (Z_centered.T @ Z_centered) / n
    return np.linalg.inv(cov)

def calculate_mahalanobis_distances(Z: np.ndarray, cov_inv: np.ndarray) -> np.ndarray:
    """Calculate Mahalanobis distances."""
    Z_centered = Z - np.mean(Z, axis=0)
    return np.sum(Z_centered @ cov_inv * Z_centered, axis=1)

def calculate_test_statistic(n: int, mahalanobis_distances: np.ndarray) -> np.ndarray:
    """Calculate the test statistic."""
    return ((n - 3) * n / ((n**2 - 1) * 3)) * mahalanobis_distances

def determine_outliers(projects: List[Project], alpha: float = 0.05) -> List[int]:
    """Determine outliers using Mahalanobis distance."""
    Z = projects_to_array(projects)
    n = Z.shape[0]
    cov_inv = calculate_cov_inv(Z)
    mahalanobis_distances = calculate_mahalanobis_distances(Z, cov_inv)
    test_statistic = calculate_test_statistic(n, mahalanobis_distances)
    
    fisher_f = f.ppf(1 - alpha, 3, n - 3)
    
    return np.where(test_statistic > fisher_f)[0].tolist()

def remove_outliers(projects: List[Project]) -> List[Project]:
    """Remove outliers"""
    outliers = determine_outliers(projects)
    return [p for i, p in enumerate(projects) if i not in outliers]

def iterative_outlier_removal(projects: List[Project]) -> List[Project]:
    """Iteratively remove outliers until no more outliers are found."""
    iteration = 1
    while True:
        print(f"\nStarting iteration {iteration}")
        new_projects = remove_outliers(projects)
        
        if len(new_projects) == len(projects):
            print("No more outliers found. Stopping iterations.")
            break
        
        removed_projects = [p for p in projects if p not in new_projects]
        for project in removed_projects:
            print(f"Removed project: {project.url}")
        
        projects = new_projects
        iteration += 1
    
    return projects

def calculate_regression_coefficients(Z: np.ndarray) -> Tuple[float, float, float]:
    """Calculate regression coefficients."""
    X = Z[:, :-1]
    Y = Z[:, -1]
    X = np.column_stack((np.ones(X.shape[0]), X))
    coffs = np.linalg.inv(X.T @ X) @ X.T @ Y
    return coffs[0], coffs[1], coffs[2]

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

def split_data(projects: List[Project], train_ratio: float = 0.6) -> Tuple[List[Project], List[Project]]:
    """
    Split the data into training and testing sets, ensuring that the training set
    includes the min and max values, and the testing set covers the remaining range.
    """
    # Sort projects by each metric
    sorted_by_cbo = sorted(projects, key=lambda p: p.cbo)
    sorted_by_wmc = sorted(projects, key=lambda p: p.wmc)
    sorted_by_rfc = sorted(projects, key=lambda p: p.rfc)
    sorted_by_noc = sorted(projects, key=lambda p: p.noc)

    # Get min and max projects for each metric
    min_max_projects = set([
        sorted_by_cbo[0], sorted_by_cbo[-1],
        sorted_by_wmc[0], sorted_by_wmc[-1],
        sorted_by_rfc[0], sorted_by_rfc[-1],
        sorted_by_noc[0], sorted_by_noc[-1]
    ])

    # Remove min and max projects from the main list
    remaining_projects = [p for p in projects if p not in min_max_projects]

    # Shuffle the remaining projects
    random.shuffle(remaining_projects)

    # Calculate the number of additional projects needed for the training set
    n_train = int(len(projects) * train_ratio) - len(min_max_projects)

    # Split the remaining projects
    train_projects = list(min_max_projects) + remaining_projects[:n_train]
    test_projects = remaining_projects[n_train:]

    return train_projects, test_projects

def save_to_csv(projects: List[Project], filename: str):
    """Save the list of projects to a CSV file."""
    df = pd.DataFrame([
        {
            'URL': p.url,
            'CBO': p.cbo,
            'WMC': p.wmc,
            'RFC': p.rfc,
            'NOC': p.noc,
            'ZX1': p.zx1,
            'ZX2': p.zx2,
            'ZY': p.zy
        } for p in projects
    ])
    df.to_csv(data_path(filename), index=False)

def main():
    projects = retrieve_data()
    print(f"Initial number of data points: {len(projects)}")
    
    normalized_projects = normalize_data(projects)
    final_projects = iterative_outlier_removal(normalized_projects)
    
    print(f"\nFinal number of data points after outlier removal: {len(final_projects)}")
    
    Z = projects_to_array(final_projects)
    b0, b1, b2 = calculate_regression_coefficients(Z)
    print(f"\nRegression coefficients: b0 = {b0}, b1 = {b1}, b2 = {b2}")
    
    Y_hat = b0 + b1 * Z[:, 0] + b2 * Z[:, 1]
    r_squared, mmre, pred = calculate_regression_metrics(Z[:, 2], Y_hat)
    print(f"\nRegression model metrics:")
    print(f"R-squared: {r_squared}")
    print(f"MMRE: {mmre}")
    print(f"Pred: {pred}")

    # Split the data into training and testing sets
    # train_projects, test_projects = split_data(final_projects)
    
    # print(f"\nNumber of training data points: {len(train_projects)}")
    # print(f"Number of testing data points: {len(test_projects)}")

    # # Save the training and testing sets to CSV files
    # save_to_csv(train_projects, 'train_data.csv')
    # save_to_csv(test_projects, 'test_data.csv')
    # print("\nData has been split and saved to 'train_data.csv' and 'test_data.csv'")

if __name__ == "__main__":
    main()