## Create a JSON file with data for the d3 plot:
## nodes 
##  - paper title
##  - color id
## links
##  - paper1
##  - paper2
##  - similarity


library(tidyverse)
library(purrr)
library(rio)
library(jsonlite)
library(pbmcapply)
options(mc.cores = (parallel::detectCores() - 1))

source('R/similar_doc_functions.R')

## IDs and titles of all documents
df.docnames <- rio::import('output/csv/doc_names.csv') %>% as_data_frame

## load topic distributions of all documents
dd <- rio::import("output/csv/year_doc_topic.csv") %>% as_data_frame
dd$year <- dd$year+2000

## start with only 4 papers
docIDs <- df.docnames[1:4,]$doc_id

source <- c()
target <- c()
ii <- seq_along(docIDs)
for (i in ii) {
  for (j in ii[i:length(ii)]) {
    source <- c(source, i)
    target <- c(target, j)
  }
}
data_frame(source, target)


dd <- dd %>% filter(doc_id %in% df.docnames$doc_id)



links <- function(docID, dd) {
  ee <- similar_docs(docID, dd)
  ee$cosine <- ee$cosine %>% round(3)
  ee
}
## begin with first 10 docs
# docIDs <- df.docnames[1:10,]$doc_id
## all docs
docIDs <- df.docnames$doc_id
docIDs %>% pbmcapply::pbmclapply(export_similar_papers_to_json, dd) %>% length

## export docnames to paper_titles.json
paper_titles <- df.docnames %>% filter(doc_id %in% docIDs) %>% .$doc_name
jsonlite::write_json(paper_titles, 'docs/data/paper_titles.json')
