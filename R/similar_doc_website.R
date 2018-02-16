## Create a JSON file with all paper titles

## For each paper, create a JSON file that lists the cosine similarity and the title of the 5 most similar papers

library(tidyverse)
library(purrr)
library(rio)
library(jsonlite)
library(pbapply)

source('R/similar_doc_functions.R')

## IDs and titles of all documents
df.docnames <- rio::import('output/csv/doc_names.csv') %>% as_data_frame

## load topic distributions of all documents
dd <- rio::import("output/csv/year_doc_topic.csv") %>% as_data_frame
dd$year <- dd$year+2000

## for document x, create x.json with the top 5 papers
export_similar_papers_to_json <- function(docID, dd) {
  ee <- similar_docs(docID, dd)
  ff <- ee %>% left_join(df.docnames, by = 'doc_id')
  gg <- ff %>% mutate(Similarity = cosine %>% round(3) %>% as.character, Title = doc_name, Year = year)
  hh <- gg %>% select(Similarity, Title, Year)
  docname <- df.docnames %>% filter(doc_id == docID) %>% .$doc_name
  filename <- sprintf('docs/data/similar_papers/%s.json', docname)
  rio::export(hh, filename)
}
## begin with first 10 docs
docIDs <- df.docnames[1:10,]$doc_id
docIDs %>% pblapply(export_similar_papers_to_json, dd) %>% length

## export docnames to paper_titles.json
paper_titles <- df.docnames %>% filter(doc_id %in% docIDs) %>% .$doc_name
jsonlite::write_json(paper_titles, 'docs/data/paper_titles.json')
