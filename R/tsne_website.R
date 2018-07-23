## create main tsne plot with plotly for the website
## THIS DOES NOT WORK YET

## most parts copied from tsne.R

library(tidyverse)
library(rio)
library(plotly)
source('~/.plotly_authentication.R')  # only for online stuff

dd <- rio::import("output/csv/year_doc_topic.csv") %>% as_data_frame
dd$year <- dd$year+2000

# topic labels
labels <- unique(dd$topic_label)  # same ordering as in python

x <- dd %>%
  select(doc_id, year, topic, topic_label, prob) %>%
  group_by(doc_id) %>% 
  mutate(my_topic = topic[which.max(prob)]) %>%  # assing document to its max prob topic
  select(-topic) %>% 
  spread(topic_label, prob) %>% 
  ungroup
x

tsne <- read_rds('output/rds/tsne_all_years.rds')
# plot(tsne$Y, type = "n")
# text(tsne$Y, labels = x$my_topic, col = x$my_topic)

tt <- tsne$Y %>% 
  as_data_frame %>% 
  cbind(my_topic = x$my_topic,
        year = x$year) %>%  
  group_by(my_topic) %>% 
  rowwise %>% 
  mutate(topic_label = labels[my_topic + 1])
tt

# ggrepel doesn't work with plotly
p <- tt %>% 
  ggplot(aes(V1, V2, label = my_topic, color = topic_label)) +
  geom_text(size = 3) +
  theme_classic() +
  theme(legend.position = "none") +
  theme(plot.title = element_text(hjust = 0.5))

pl <- ggplotly(p)
api_create(pl, 'dtm_tsne', sharing = 'private')  ## get paid account 
