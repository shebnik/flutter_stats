import pandas as pd
from statsmodels.stats.outliers_influence import variance_inflation_factor
import os

def analyze_metrics(file_path):
    # Read the CSV file
    df = pd.read_csv(file_path)
    
    # Define features
    features = ['NOC', 'NOM', 'DIT', 'CBO', 'WMC']
    
    # Create a copy of the dataframe with selected features
    df_metrics = df[features].copy()
    
    # Convert relevant columns to float type before division
    df_metrics = df_metrics.astype(float)
    
    # Calculate relative metrics
    for metric in ['CBO', 'WMC', 'DIT', 'NOM']:
        df_metrics[metric] = df_metrics[metric] / df_metrics['NOC']
    
    # Calculate correlation matrix
    correlation_matrix = df_metrics.corr()
    
    # Calculate VIF
    vif_data = pd.DataFrame()
    vif_data["Feature"] = df_metrics.columns
    vif_data["VIF"] = [variance_inflation_factor(df_metrics.values, i) 
                       for i in range(df_metrics.shape[1])]
    vif_results = vif_data.sort_values('VIF', ascending=False)
    
    # Find highly correlated pairs
    high_correlations = []
    for i in range(len(features)):
        for j in range(i+1, len(features)):
            corr = correlation_matrix.iloc[i,j]
            if abs(corr) > 0.7:
                high_correlations.append({
                    'pair': f"{features[i]} - {features[j]}",
                    'correlation': corr
                })
    
    # Calculate descriptive statistics
    metrics_stats = df_metrics.describe()
    
    return {
        'correlation_matrix': correlation_matrix,
        'vif_results': vif_results,
        'high_correlations': high_correlations,
        'metrics_stats': metrics_stats
    }

# Usage
if __name__ == "__main__":
    file_path = os.path.join(os.path.dirname(__file__), 'data', '100.csv')
    results = analyze_metrics(file_path)
    
    # Print results
    print("\nDescriptive Statistics:")
    print(results['metrics_stats'])
    
    print("\nVariance Inflation Factors:")
    print(results['vif_results'])
    
    print("\nHighly correlated pairs (|r| > 0.7):")
    for corr in results['high_correlations']:
        print(f"{corr['pair']}: {corr['correlation']:.3f}")