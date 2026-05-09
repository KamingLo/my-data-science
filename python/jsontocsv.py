import pandas as pd

df = pd.read_json('../data/employee-datasets.json'); df.to_csv('file.csv', index=False)