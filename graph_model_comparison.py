import pandas as pd
from ggplot import *

df = pd.read_csv('heldout_summary.csv')
df.columns = [s.strip() for s in df.columns.values]
df['Year'] = df['Year'] + 2000
df['Model'] = df['Model'].replace({'dtm': 'DTM (all years)',
                                   'lda_all': 'LDA (all years)',
                                   'lda_prev': 'LDA (previous year)'})
p = ggplot(aes(x='Year', y='LL', color='Model'), data=df) + geom_line() + ylab('Log Likelihood') + theme_bw()
p.save(filename='modelcomparison.png', width=14)
