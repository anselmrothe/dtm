# Workflow

- model comparison with static topic model -- alex
- topic popularity change over years; hotest topics in recent years; most changed topic over the years -- anselm
- relations between topics via PCA /tsne -- zhiwei

# work log:
# Nov 23

- Text reading and cleaning procedure (using the 3 months' news data as testing data). --zhiwei
- Feed the cleaned text into dtm and plot the topic drifting over time. --zhiwei
## TODO

- transform current code from jupyter notebook into .py
- my computer can't even run the full news data -- must parallelize the dtm and put them onto cluster when we deal with real data
- clearning parameters to be adjusted based on real data. current parameters could give weird results (e.g. too many non-informative words. maybe not a big problem with bigger dataset).
- better visualization over temporal change of topics



# Nov 22

- Initial implementation of gensim: transform BoW to DTMcorpus; feed DTMcorpus into ldaseqmodel to get the topic evolution; visualize word composition of topics given a time point -- anselm

# Nov 15 

- Batch downloading - alex

done? output?

- Text to BoW - anselm

output: pdf_clean_text.ipynb

**to-do**: eliminate hyphens at line breaks?

