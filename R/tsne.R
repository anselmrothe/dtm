library(tidyverse)
library(rio)
library(Rtsne)
library(ggrepel)


dd <- rio::import("output/csv/year_doc_topic.csv") %>% as_data_frame
dd$year <- dd$year+2000

# topic labels
labels <- unique(dd$topic_label)  # same ordering as in python



tsne_plot_saved <- function(yearX) {
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
  tsne <- Rtsne(as.matrix(x %>% select(-doc_id, -my_topic)))
  # plot(tsne$Y, type = "n")
  # text(tsne$Y, labels = x$my_topic, col = x$my_topic)
  
  dd <- tsne$Y %>% 
    as_data_frame %>% 
    cbind(my_topic = x$my_topic) %>%  # assing document to its max prob topic
    group_by(my_topic) %>% 
    mutate(i = row_number()) %>%
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
