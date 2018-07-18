## the most topic-specific paper
## the most topic-general paper

library(tidyverse)
library(rio)

# functions ---------------------------------------------------------------

entropy <- function(p) -1*sum(sapply(p,function(x) ifelse(x==0,0,x*log(x,2))))

# script ------------------------------------------------------------------

dd <- rio::import("output/csv/year_doc_topic.csv") %>% as_data_frame
dd$year <- dd$year+2000

ee <- dd %>% 
  group_by(doc_id, doc_name, year) %>% 
  summarize(entropy = entropy(prob))

ee %>% filter(entropy %in% c(min(ee$entropy), max(ee$entropy))) %>% arrange(entropy)

dd %>% filter(doc_id == 2952) %>% arrange(-prob) %>% head()
dd %>% filter(doc_id == 3846) %>% arrange(-prob) %>% head()

## 2010: 'Illusions of consistency in quantified assertions' has strong assignemnt to topic 'Reasoning' (it's a Johnson-Laird mental models paper)
## 2012: 'Modelling the IAT Implicit Association Test Reflects Shallow Linguistic Environment and not Deep Personal Attitudes' has the weakest topic profile => most domain general
