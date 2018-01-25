library(tidyverse)
library(rio)
library(matrixStats)

## TODO: need a function to go from PDF to bag of words

# only to get topic labels ------------------------------------------------
dd <- rio::import("year_doc_topic.csv") %>% as_data_frame
labels <- dd %>% select(topic, topic_label) %>% unique

# script ------------------------------------------------------------------
dd <- rio::import('year_topic_word.csv') %>% as_data_frame
ee <- dd %>% left_join(labels, by = 'topic')
ff <- ee %>% filter(year == 2017)

## for each word count how often it appears in the bag of words from document
## (The procedure below ignores words that don't appear in year_topic_word.csv)
bag <- data_frame(word = c('speaker', 'visual', 'text'), n = c(11, 12, 13))

gg <- ff %>% left_join(bag, by = 'word') %>% as_data_frame
hh <- gg %>%
  rowwise %>%
  mutate(log_freq_n = log(frequency * n)) %>%
  ungroup %>%
  group_by(topic_label) %>%
  summarize(loglik = sum(log_freq_n, na.rm = TRUE),
            loglik = if_else(loglik == 0, -Inf, loglik)) %>% 
  ungroup %>% 
  mutate(loglik = loglik - matrixStats::logSumExp(loglik),
         freq = exp(loglik)) %>%  # normalizing in log space
  select(-loglik)
hh$name <- "test"
hh %>% 
  ggplot(aes(topic_label, freq, fill = name, group = name)) +
  theme(legend.position = 'none') + ylab('') + xlab('') +
  coord_flip() +
  facet_wrap(~name, nrow = 1) +
  geom_bar(stat = 'identity')
