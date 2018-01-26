# Potential expansions of current work
- sanity check: is our result robust to different number of topics?

- better demonstration of topics: show the papers with highest weights of this topic.

- see if we get results that agree with the previous work (i.e. Cohen Priva & Austerweil paper)

Especially, they could interpret a topic as "Framing topic" and say things like "over time Cognition turned from abstract theorizing to more experimental approaches." This is a small innovation compared to traditional TM analysis.

- study the diversity of the field by measuring topic entropy [see this linguistic paper](http://web.stanford.edu/~jurafsky/hallemnlp08.pdf)

- study how much the year-to-year publication has changed (e.g. is there some years very different from the previous year) by measuring KL-divergence over years. [this paper studying Charles Darwin's reading](https://arxiv.org/pdf/1509.07175.pdf)

# Workflow

- model comparison with static topic model -- alex
- topic popularity change over years; hotest topics in recent years; most changed topic over the years -- anselm
- relations between topics via PCA /tsne -- zhiwei
- what topics are gureckis lab talking about?

## 1. Obtaining CogSci papers
## 2. Preprocessing

```
doc_word_freq.ipynb
- input: dtm_input_data/dtm_input-mult.dat
- output: output/csv/doc_word_freq.csv
```

## 3. Modeling

## 4. Postprocessing

Exporting data from model output

```
pickle_to_csv.ipynb
- input: output/dtm_processed_output.p
- output: output/csv/year_doc_topic.csv
- output: output/csv/topicnames.csv
- output: output/csv/year_topic_word.csv
```


## 5. Analyis



# work log
## Nov 23

- Text reading and cleaning procedure (using the 3 months' news data as testing data). --zhiwei
- Feed the cleaned text into dtm and plot the topic drifting over time. --zhiwei
### TODO

- transform current code from jupyter notebook into .py
- my computer can't even run the full news data -- must parallelize the dtm and put them onto cluster when we deal with real data
- clearning parameters to be adjusted based on real data. current parameters could give weird results (e.g. too many non-informative words. maybe not a big problem with bigger dataset).
- better visualization over temporal change of topics



## Nov 22

- Initial implementation of gensim: transform BoW to DTMcorpus; feed DTMcorpus into ldaseqmodel to get the topic evolution; visualize word composition of topics given a time point -- anselm

## Nov 15 

- Batch downloading - alex

done? output?

- Text to BoW - anselm

output: pdf_clean_text.ipynb

**to-do**: eliminate hyphens at line breaks?

