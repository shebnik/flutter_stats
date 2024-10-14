import pandas as pd
import numpy as np
from statsmodels.stats.outliers_influence import variance_inflation_factor
import seaborn as sns
import matplotlib.pyplot as plt
import os

# Read the CSV file
# Assuming the CSV file is named 'metrics.csv'
df = pd.read_csv(
    os.path.join(os.path.dirname(__file__), os.path.join("data", "100.csv"))
)

# Remove the URL column as it's not needed for the analysis
features = ["SLOC", "NOC", "NOM", "DIT", "RFC", "CBO", "WMC"]
df_metrics = df[features]

min_cbo = np.min(df_metrics["CBO"])
max_cbo = np.max(df_metrics["CBO"])

min_wmc = np.min(df_metrics["WMC"])
max_wmc = np.max(df_metrics["WMC"])

min_rfc = np.min(df_metrics["RFC"])
max_rfc = np.max(df_metrics["RFC"])

print(f"Min CBO: {min_cbo}, Max CBO: {max_cbo}")
print(f"Min WMC: {min_wmc}, Max WMC: {max_wmc}")
print(f"Min RFC: {min_rfc}, Max RFC: {max_rfc}")

# Calculate correlation matrix
correlation_matrix = df_metrics.corr()

# Create a heatmap
plt.figure(figsize=(10, 8))
sns.heatmap(correlation_matrix, annot=True, cmap="coolwarm", center=0)
plt.title("Correlation Matrix of Software Metrics")
plt.tight_layout()
plt.savefig(os.path.join(os.path.dirname(__file__), "correlation_heatmap.png"))
plt.close()


# Calculate VIF for each feature
def calculate_vif(df):
    vif_data = pd.DataFrame()
    vif_data["Feature"] = df.columns
    vif_data["VIF"] = [
        variance_inflation_factor(df.values, i) for i in range(df.shape[1])
    ]
    return vif_data.sort_values("VIF", ascending=False)


vif_results = calculate_vif(df_metrics)
print("\nVariance Inflation Factors:")
print(vif_results)

# Print highly correlated pairs
print("\nHighly correlated pairs (|r| > 0.7):")
for i in range(len(features)):
    for j in range(i + 1, len(features)):
        if abs(correlation_matrix.iloc[i, j]) > 0.7:
            print(f"{features[i]} - {features[j]}: {correlation_matrix.iloc[i,j]:.3f}")
