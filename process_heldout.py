import numpy as np


file_names = [
    ('lda_all', 'lda_out/all_{0}_test-lda-lhood.dat'),
    ('lda_prev', 'lda_out/prev_{0}_test-lda-lhood.dat'),
    ('dtm', 'dtm_out/dtm_{0}-heldout_post_{0}.dat')
]

years = [2, 5, 8, 11, 14, 17]

output = ['Model, Year, LL, SE\n']

for modeltype, fname in file_names:
    log_likelihoods = []
    for y in years:
        with open(fname.format(str(y)), 'r') as f:
            lhoods = [float(n) for n in f.readlines()]
            output.append(
                '{}, {:d}, {:f}, {:f}\n'.format(modeltype, y, np.mean(lhoods),
                                              np.std(lhoods)/np.sqrt(len(lhoods)))
                )

with open('heldout_summary.csv', 'w') as f:
    f.writelines(output)
