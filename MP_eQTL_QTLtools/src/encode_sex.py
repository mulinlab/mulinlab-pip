import pandas as pd 
import argparse

parser = argparse.ArgumentParser(description='encode gender into binary dummy variable')
parser.add_argument('expression', help='expression matrix')
parser.add_argument('sample_sex', help='sample sex')
parser.add_argument('output', help='output filename')
args = parser.parse_args()

# df = pd.read_csv("inputs/genes.50percent.chr22.expression.bed.gz", sep='\t')
# sex = pd.read_csv("inputs/sample_sex.txt", sep='\t')

df = pd.read_csv(args.expression, sep='\t')
sex = pd.read_csv(args.sample_sex, sep='\t')
samples = list(df.columns[6:])
# print(len(samples))
df_out = sex.T.reset_index(drop=True)
df_out.columns = df_out.iloc[0,:]
df_out = df_out.iloc[1:,:]
df_out = df_out.loc[:,samples]
df_out["SampleID"] = "sex"
df_out = df_out.replace("female" ,2).replace("male", 1)
df_out.to_csv(args.output, index=False, sep='\t', columns=["SampleID"] + list(df_out.columns[:-1]))