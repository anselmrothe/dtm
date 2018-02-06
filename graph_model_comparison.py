import pandas as pd
from matplotlib import pyplot as plt
import seaborn as sns

df = pd.read_csv('output/heldout_summary.csv')
df.columns = [s.strip() for s in df.columns.values]
df['Year'] = df['Year'] + 2000
df['LL'] = -df['LL']
df = df.pivot_table(columns='Model', index='Year', values='LL').reset_index()
df['diffdtm'] = df['dtm'] - df['lda_all']
df['difflda'] = df['lda_prev'] - df['lda_all']
df = df[['Year', 'diffdtm', 'difflda']]

sns.set_style('ticks')
plt.plot(df['Year'], df['diffdtm'], df['Year'], df['difflda'])
plt.axhline(y=0, xmin=0, xmax=1, color='k')
plt.legend(['DTM (all years)', 'LDA (prev year)', 'LDA (all years)'])
plt.ylabel('$\Delta$ NLL')
plt.xlabel('year')
sns.despine()
plt.tight_layout()
plt.savefig('modelcomparison.png', dpi=200)
