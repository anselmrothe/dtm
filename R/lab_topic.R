library(tidyverse)
library(rio)

f <- function(name) {
  dd <- rio::import(sprintf('result/lab_topic/%s.csv', name))
  dd$name <- name
  dd
}

dd <- c('alex', 'anselm', 'gureckis', 'm_frank', 'Murphy') %>% map_df(f)
dd <- c('gureckis', 'm_frank') %>% map_df(f)
topics <- dd %>% filter(name == 'gureckis') %>% arrange(prob) %>% .$topic
dd$topic <- factor(dd$topic, levels = topics)
ee <- dd %>% mutate(name = replace(name, name == 'gureckis', 'Gureckis lab'),
                    name = replace(name, name == 'm_frank', 'Frank lab'))
ee %>% 
  ggplot(aes(topic, prob, fill = name, group = name)) +
  theme(legend.position = 'none') + ylab('') + xlab('') +
  coord_flip() +
  facet_wrap(~name, nrow = 1) +
  geom_bar(stat = 'identity')
ggsave('figures/lab_topic.png', height = 3.5, width = 9)
