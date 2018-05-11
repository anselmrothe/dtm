library(tidyverse)
library(rio)

dd <- rio::import('output/more_topics.csv') %>% as_data_frame
dd %>% 
  ggplot(aes(`n topics`, LL)) +
  geom_line() +
  ylim(NA, 0)
ggsave('figures/more_topics.png', height = 5, width = 5)
