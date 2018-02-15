
similar_docs <- function(docID, dd, n = 6) {
  target_vector <- dd %>% filter(doc_id == docID) %>% .$prob
  dd %>% 
    group_by(doc_id) %>% 
    summarize(docID,
              cosine = lsa::cosine(target_vector, prob)) %>% 
    select(docID, everything()) %>% 
    arrange(-cosine) %>% 
    filter(docID != doc_id) %>% 
    head(n)
}

find_doc_id <- function(docname, df.docnames, n = 1, return_just_id = FALSE) {
  out <- df.docnames %>%
    rowwise %>%
    mutate(stringdist = stringdist(docname, doc_name)) %>% 
    select(stringdist, everything()) %>% 
    arrange(stringdist) %>% 
    head(n)
  if (return_just_id) return(out$doc_id)
  else return(out)
}

lines_similar_doc <- function(docID, dd, df.docnames, latex = FALSE) {
  dd <- similar_docs(docID, dd)
  ee <- dd %>% left_join(df.docnames, by ='doc_id')
  docname <- df.docnames %>% filter(doc_id == docID) %>% .$doc_name
  if (latex) {
    ff <- ee %>% select(-doc_name_short) %>% knitr::kable(format = "latex", booktabs = TRUE, digits = 3)
  } else {
    ff <- ee %>% select(-doc_name_short) %>% knitr::kable()
  }
  lines <- c(docname, ff, '\n\n')
  lines
}