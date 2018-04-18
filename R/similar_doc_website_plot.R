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

## for document x, create x.json with the top 5 papers
compute_cosine <- function(docID, dd) {
  target_vector <- dd %>% filter(doc_id == docID) %>% .$prob
  dd %>% 
    group_by(doc_id) %>% 
    summarize(docID,
              cosine = lsa::cosine(target_vector, prob))
}

## start with only n papers
# docIDs <- df.docnames[1:5,]$doc_id %>% unique
# docIDs <- df.docnames[1:100,]$doc_id %>% unique
docIDs <- df.docnames$doc_id %>% unique

if (0) {
  if (0) {
    ## takes about 5 minutes (with 7 cores):
    df.cosine <- docIDs %>% pbmcapply::pbmclapply(compute_cosine, dd) %>% bind_rows
    df.cosine %>% rio::export('output/rds/df.cosine.rds')
  }
  df.cosine <- rio::import('output/rds/df.cosine.rds') %>% as_data_frame
  
  ff <- df.cosine %>% 
    select(target = docID,
           source = doc_id,
           value = cosine)
  
  ## cosine(id1, id2) == cosine(id2, id1) -> only keep one
  ## unique combinations:
  n <- length(docIDs)
  mat <- combn(x = n, m = 2) %>% t
  ee <- data_frame(source = mat[,1], target = mat[,2])
  links <- ee %>% left_join(ff, by = c("source", "target"))  # takes several minutes
  links %>% rio::export('output/rds/links.rds')
}
links <- rio::import('output/rds/links.rds')

nrow(links)
nodes <- data_frame(id = docIDs, group = 1)
forceplot <- list(nodes = nodes, 
                  links = links %>% top_n(800, value))
jsonlite::write_json(forceplot, 'docs/data/forceplot.json', pretty = TRUE)
