library(tidyverse)
library(rio)

add_topic_label <- function(x) {
  dd <- rio::import("output/csv/year_doc_topic.csv") %>% as_data_frame
  label <- dd %>% select(topic, topic_label) %>% unique  # same ordering as in python
  x %>% left_join(label, by = 'topic')
}

cc <- rio::import("output/csv/year_topic_word.csv") %>% as_data_frame
dd <- add_topic_label(cc)

# 1 -----------------------------------------------------------------------
plot_topic_words <- function(topic_labelX, dd) {
  gg <- dd %>% filter(topic_label == topic_labelX) %>% group_by(word) %>% summarize(freq = mean(frequency)) %>% arrange(-freq) %>% 
    head(10)
  gg$word <- gg$word %>% factor(rev(gg$word))
  gg %>% ggplot(aes(word, freq)) + geom_bar(stat = 'identity') + ylim(0,NA) + coord_flip() + theme_classic() + xlab('') + ylab('') + theme(axis.text.x = element_blank(), axis.ticks.x = element_blank(), axis.line.x = element_blank())
  ggsave(sprintf('figures/words_%s.pdf', topic_labelX), width = 2.5, height = 2.5)
}
plot_topic_words('Probabilistic modeling', dd)
plot_topic_words('Decision making', dd)
plot_topic_words('Educational psychology', dd)
plot_topic_words('Memory', dd)

# 2 -----------------------------------------------------------------------

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

