# Topics and Trends in Cognitive Science

This project aims to uncover the trends and topics of the annual Cognitive Science Society conference using dynamic topic modeling.

## Results

Paper: [*Topics and Trends in Cognitive Science (2000-2017)*](doc/cogsci_submission.pdf) - to be published in the *Proceedings of the 40th Annual Conference of the Cognitive Science Society*.

Website: [Find similar papers!](https://anselmrothe.github.io/dtm/)


## Workflow


### 1. Obtaining CogSci papers

Download PDFs from [ Archives of the Cognitive Science Society Conference Proceedings
](http://www.cognitivesciencesociety.org/conference/)

Copy PDFs into `text_data_new/`

### 2. Preprocessing

Process PDFs:

```
generate_dtm_input.py
- input:  PDFs in text_data_new/volume_{}/
- output: dtm_input_data/dtm_input-mult.dat
          dtm_input_data/dtm_input-seq.dat

```

### 3. Modeling

Use our DTM version: [alexanderrich/dtm](https://github.com/alexanderrich/dtm)

Talk to your local High Performance Cluster correspondent how to set everything up.

Run the script `run_all.s`

### 4. Postprocessing

@Alex: How did you create `dtm_processed_output.p`?

Exporting model output into csv tables:

```
pickle_to_csv.ipynb
- input:  output/dtm_processed_output.p
- output: output/csv/year_doc_topic.csv
          output/csv/topicnames.csv
          output/csv/year_topic_word.csv
```

Exporting original data into csv tables:

```
doc_word_freq.ipynb
- input:  dtm_input_data/dtm_input-mult.dat
- output: output/csv/doc_word_freq.csv
```

### 5. Analysis & Figures

See R scripts in the folder `R`. The R scripts save all figures into the folder `figures`.

Due to the exploratory nature of this project there are several scripts and figures that did not make their way into the paper.





