library(tidyverse)
library(rio)

dd <- rio::import("year_doc_topic.csv") %>% as_data_frame
dd$year <- dd$year+2000

df.docnames <- dd %>%
  select(doc_id, year, doc_name) %>%
  unique %>%
  mutate(doc_name_short = substr(doc_name, 0, 40)) %>%
  select(doc_id, year, doc_name_short, doc_name) %>% 
  arrange(doc_id)

rio::export(df.docnames, 'doc_names.csv')
