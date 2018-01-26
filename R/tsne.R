library(tidyverse)
library(rio)
library(Rtsne)
library(ggrepel)


dd <- rio::import("output/csv/year_doc_topic.csv") %>% as_data_frame
dd$year <- dd$year+2000

# topic labels
labels <- unique(dd$topic_label)  # same ordering as in python


tsne_plot_saved <- function(yearX) {
  x <- dd %>%
    filter(year == yearX) %>%
    select(doc_id, topic, topic_label, prob) %>%
    group_by(doc_id) %>% 
    mutate(my_topic = topic[which.max(prob)]) %>%
    select(-topic) %>% 
    spread(topic_label, prob) %>% 
    ungroup
  x
  set.seed(12345)
  tsne <- Rtsne(as.matrix(x %>% select(-doc_id, -my_topic)), initial_dims = 20, theta = 0, perplexity = 50, check_duplicates = FALSE)
  # plot(tsne$Y, type = "n")
  # text(tsne$Y, labels = x$my_topic, col = x$my_topic)
  
  dd <- tsne$Y %>% 
    as_data_frame %>% 
    cbind(my_topic = x$my_topic) %>%  # assing document to its max prob topic
    group_by(my_topic) %>% 
    rowwise %>% 
    mutate(topic_label = labels[my_topic + 1])
  dd
  
  label_locations <- dd %>% ungroup %>% group_by(topic_label) %>% summarize(V1 = median(V1),
                                                                            V2 = median(V2))
  
  # plot
  dd %>% 
    ggplot(aes(V1, V2, label = my_topic, color = topic_label)) +
    geom_text(size = 3) +
    geom_label_repel(data = label_locations, aes(label = topic_label), segment.alpha = 0) +
    theme_classic() +
    theme(legend.position = "none") +
    ggtitle(yearX) +
    theme(plot.title = element_text(hjust = 0.5))
  
  ggsave(sprintf("figures/tsne/%s.png", yearX), width = 9, height = 9)
}
c(2016:2017) %>% walk(tsne_plot_saved)


# all years ---------------------------------------------------------------

all_years <- function(dd) {
  x <- dd %>%
    select(doc_id, year, topic, topic_label, prob) %>%
    group_by(doc_id) %>% 
    mutate(my_topic = topic[which.max(prob)]) %>%  # assing document to its max prob topic
    select(-topic) %>% 
    spread(topic_label, prob) %>% 
    ungroup
  x
  set.seed(12345)
  # tsne <- Rtsne(as.matrix(x %>% select(-doc_id, -my_topic, -year)), check_duplicates = FALSE, theta = 0)  # takes 12 minutes
  # write_rds(tsne, 'output/rds/tsne_all_years.rds')
  tsne <- load_rds('output/rds/tsne_all_years.rds')
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
  
  label_locations <- tt %>% ungroup %>% group_by(topic_label) %>% summarize(V1 = median(V1),
                                                                            V2 = median(V2))
  # plot
  tt %>% 
    ggplot(aes(V1, V2, label = my_topic, color = topic_label)) +
    geom_text(size = 3) +
    geom_label_repel(data = label_locations, aes(label = topic_label), segment.alpha = 0) +
    theme_classic() +
    theme(legend.position = "none") +
    theme(plot.title = element_text(hjust = 0.5))
  
  ggsave("figures/tsne/all_years.png", width = 9, height = 9)
  
  
  source('R/animations.R')
  
  a <- tt %>% 
    ggplot(aes(V1, V2, label = my_topic, color = topic_label, frame = year)) +
    geom_text(size = 3) +
    # geom_label_repel(data = label_locations, aes(label = topic_label), segment.alpha = 0) +
    theme_classic() +
    theme(legend.position = "none") +
    theme(plot.title = element_text(hjust = 0.5))
  
  gganimate(a, 'figures/tsne/all_years.gif')
  
}



# PCA ---------------------------------------------------------------------
library(ggfortify)

set.seed(12345)
x <- dd %>%
  filter(year == yearX) %>% 
  select(doc_id, topic, topic_label, prob) %>%
  group_by(doc_id) %>% 
  mutate(my_topic = topic[which.max(prob)]) %>%
  select(-topic) %>% 
  spread(topic_label, prob) %>% 
  ungroup
x
pca <- prcomp(as.matrix(x %>% select(-doc_id, -my_topic)) %>% t)
# pca$rotation
dd <- pca$rotation[,1:2] %>% 
  as_data_frame %>% 
  cbind(my_topic = x$my_topic) %>%  # assing document to its max prob topic
  group_by(my_topic) %>% 
  mutate(i = row_number()) %>%
  rowwise %>% 
  mutate(topic_label = labels[my_topic + 1])
dd
label_locations <- dd %>% ungroup %>% group_by(topic_label) %>% summarize(PC1 = median(PC1),
                                                                          PC2 = median(PC2))
dd %>% 
  ggplot(aes(PC1, PC2, label = my_topic, color = topic_label)) +
  geom_text(size = 3) +
  geom_label_repel(data = label_locations, aes(label = topic_label), segment.alpha = 0) +
  theme_classic() +
  theme(legend.position = "none") +
  ggtitle(yearX) +
  theme(plot.title = element_text(hjust = 0.5))
ggsave('figures/tsne/pca_2017.png', width = 8, height = 8)


# based on words ----------------------------------------------------------
library(tidyverse)
library(rio)
library(Rtsne)
library(ggrepel)

dd <- rio::import("output/csv/year_doc_topic.csv") %>% as_data_frame
dd$year <- dd$year+2000
# topic labels
labels <- unique(dd$topic_label)  # same ordering as in python
# give each doc a best topic
doc_year_mytopic <- dd %>%
  group_by(doc_id) %>% 
  mutate(my_topic = topic[which.max(prob)]) %>%
  select(doc_id, year, my_topic) %>%
  ungroup %>% 
  unique

## one document per row, one word per column, word freqency in cells 
ee <- rio::import("output/csv/doc_word_freq.csv") %>% as_data_frame
ff <- ee[-1,]
colnames(ff) <- ee[1,]
ff$doc_id <- ff$doc_id %>% as.integer

## add year and topic_label
gg <- ff %>% 
  left_join(doc_year_mytopic %>% unique, by = c('doc_id')) %>% 
  select(doc_id, year, my_topic, everything())
gg[1:6, 1:6]

yearX <- 2017
hh <- gg %>% filter(year == yearX)

xx <- hh %>% select(-doc_id, -year, -my_topic) %>% as.matrix
set.seed(12345)
tsne <- Rtsne(xx)
tt <- tsne$Y %>% 
  as_data_frame %>%
  cbind(my_topic = hh$my_topic) %>% 
  as_data_frame %>%
  rowwise %>% 
  mutate(topic_label = labels[my_topic + 1])
tt

label_locations <- tt %>% ungroup %>% group_by(topic_label) %>% summarize(V1 = median(V1),
                                                                       V2 = median(V2))
# plot
tt %>% 
  ggplot(aes(V1, V2, label = my_topic, color = topic_label)) +
  geom_text(size = 3) +
  geom_label_repel(data = label_locations, aes(label = topic_label), segment.alpha = 0) +
  theme_classic() +
  theme(legend.position = "none") +
  ggtitle(yearX) +
  theme(plot.title = element_text(hjust = 0.5))

ggsave(sprintf("figures/tsne/tsne_words%s.png", yearX), width = 9, height = 9)
