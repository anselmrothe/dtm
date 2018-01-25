library(tidyverse)
library(rio)

add_topic_label <- function(x) {
  dd <- rio::import("output/csv/year_doc_topic.csv") %>% as_data_frame
  label <- dd %>% select(topic, topic_label) %>% unique  # same ordering as in python
  x %>% left_join(label, by = 'topic')
}

cc <- rio::import("output/csv/year_topic_word.csv") %>% as_data_frame
dd <- add_topic_label(cc)
dd

words <- c('rehder', 'murphy', 'gureckis', 'tenenbaum', 'griffith')
ee <- dd %>%
  filter(word %in% words) %>% 
  group_by(word, topic_label) %>% 
  summarize(frequency = sum(frequency)) %>% 
  ungroup
labels_ordered <- ee %>% filter(word == 'gureckis') %>% arrange(frequency) %>% .$topic_label %>% unique
ee$topic_label <- factor(ee$topic_label, levels = labels_ordered)
ee$word <- factor(ee$word, levels = words)
ee %>% 
  ggplot(aes(topic_label, frequency, fill = word, group = word)) +
  theme(legend.position = 'none') + ylab('') + xlab('') +
  coord_flip() +
  facet_wrap(~word, nrow = 1, labeller = label_both) +
  geom_bar(stat = 'identity') +
  ggtitle("Appearance of a word in topics\n(not in vocabulary: griffiths, coenen)")

ggsave("figures/words.pdf", width = 10, height = 4)

