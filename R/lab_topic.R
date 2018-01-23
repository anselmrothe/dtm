library(tidyverse)
library(rio)

f <- function(name) {
  dd <- rio::import(sprintf('result/lab_topic/%s.csv', name))
  dd$name <- name
  dd
}

dd <- c('alex', 'anselm', 'gureckis') %>% map_df(f)
topics <- dd %>% filter(name == 'gureckis') %>% arrange(freq) %>% .$topic
dd$topic <- factor(dd$topic, levels = topics)
dd %>% 
  ggplot(aes(topic, freq, fill = name, group = name)) +
  theme(legend.position = 'none') + ylab('') +
  coord_flip() +
  facet_wrap(~name, nrow = 1) +
  geom_bar(stat = 'identity')
ggsave('figures/lab_topic.png', height = 3.5, width = 9)
