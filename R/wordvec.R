library(widyr)  # devtools::install_github("dgrtwo/widyr")
library(tidyverse)
library(tidytext)
library(readtext)

slide_windows <- function(tbl, doc_var, window_size) {
  # https://juliasilge.com/blog/word-vectors-take-two/
  # each word gets a skipgram (window_size words) starting on the first
  # e.g. skipgram 1 starts on word 1, skipgram 2 starts on word 2
  
  each_total <- tbl %>% 
    group_by(!!doc_var) %>% 
    mutate(doc_total = n(),
           each_total = pmin(doc_total, window_size, na.rm = TRUE)) %>%
    pull(each_total)
  
  rle_each <- rle(each_total)
  counts <- rle_each[["lengths"]]
  counts[rle_each$values != window_size] <- 1
  
  # each word get a skipgram window, starting on the first
  # account for documents shorter than window
  id_counts <- rep(rle_each$values, counts)
  window_id <- rep(seq_along(id_counts), id_counts)
  
  
  # within each skipgram, there are window_size many offsets
  indexer <- (seq_along(rle_each[["values"]]) - 1) %>%
    map2(rle_each[["values"]] - 1,
         ~ seq.int(.x, .x + .y)) %>% 
    map2(counts, ~ rep(.x, .y)) %>%
    flatten_int() +
    window_id
  
  tbl[indexer, ] %>%
    bind_cols(data_frame(window_id)) %>%
    group_by(window_id) %>%
    filter(n_distinct(!!doc_var) == 1) %>%
    ungroup
}

clean_string <- function(string){
  # http://www.mjdenny.com/Text_Processing_In_R.html
  # Lowercase
  temp <- tolower(string)
  #' Remove everything that is not a number or letter (may want to keep more 
  #' stuff in your actual analyses). 
  temp <- stringr::str_replace_all(temp,"[^a-zA-Z\\s]", " ")
  # Shrink down to just one white space
  temp <- stringr::str_replace_all(temp,"[\\s]+", " ")
  # Split it
  temp <- stringr::str_split(temp, " ")[[1]]
  # Get rid of trailing "" if necessary
  indexes <- which(temp == "")
  if(length(indexes) > 0){
    temp <- temp[-indexes]
  }
  return(temp)
}

## test case
library(janeaustenr)
d <- data_frame(text = prideprejudice)
d$postID <- 0

## cogsci data
# cogsci_text <- function() {
#   read_cogsci_file <- function(i, filenames){
#     txt <- readtext::readtext(filenames[i])
#     txt$text <- paste(clean_string(txt$text), collapse = " ")
#     txt$postID <- i
#     txt$doc_id <- NULL
#     txt
#   }
#   filenames <- list.files("text_data_new", pattern = '.txt', recursive = TRUE, full.names = TRUE)
#   dd <- seq_along(filenames) %>% pbapply::pblapply(read_cogsci_file, filenames) %>% bind_rows
#   dd
# }
# d <- cogsci_text()  # about 1 minute
# d %>% write_rds('cogsci_text.rds')
d <- read_rds('cogsci_text.rds')

# tidy_pmi <- d %>%
#   unnest_tokens(word, text) %>%
#   add_count(word) %>%
#   filter(n >= 20) %>%
#   select(-n) %>%
#   slide_windows(quo(postID), 8) %>%
#   pairwise_pmi(word, window_id)
# tidy_pmi %>% write_rds("tidy_pmi.rds")  # several minutes
tidy_pmi <- read_rds('tidy_pmi.rds')

# tidy_word_vectors <- tidy_pmi %>%
#   widely_svd(item1, item2, pmi, nv = 256, maxit = 1000)
# tidy_word_vectors %>% write_rds("tidy_word_vectors.rds")
tidy_word_vectors <- read_rds('tidy_word_vectors.rds')

## inspect

nearest_synonyms <- function(df, token) {
  df %>%
    widely(~ . %*% (.[token, ]), sort = TRUE)(item1, dimension, value) %>%
    select(-item2)
}

tidy_word_vectors %>%
  nearest_synonyms("jane")

## token1 - token2 + token 3 = ???

analogy <- function(df, token1, token2, token3) {
  df %>%
    widely(~ . %*% (.[token1, ] - .[token2, ] + .[token3, ]), sort = TRUE)(item1, dimension, value) %>%
    select(-item2)
}

tidy_word_vectors %>%
  analogy("my", "your", "she")

