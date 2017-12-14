library(tidyverse)
library(ggrepel)
library(rio)

dd <- rio::import("year_doc_topic.csv") %>% as_data_frame

dd$year <- dd$year+2000

# year labels for x-axis
years <- 2000:2017
year_labels <- years
year_labels[-seq(1, 18, 4)] <- ""

# topic labels
topic_labels <- unique(dd$topic_label)  # same ordering as in python

# for each year, aggregate topic probability across documents
ee <- dd %>% 
  group_by(year, topic, topic_label) %>%
  summarize(prob = mean(prob)) %>% 
  ungroup

# fit a smooth line for teach topic
fit <- ee %>% group_by(topic_label) %>% do(data_frame(prob = predict(loess(prob ~ year, .)), year = .$year))

# ordering for color
ordering <- fit %>% 
  filter(year == max(year)) %>% 
  arrange(-prob) %>%
  .$topic_label
fit$topic_label <- factor(fit$topic_label, levels = ordering)

# plot
fit %>% 
  ggplot(aes(year, prob, colour = topic_label)) +
  geom_line() +
  geom_text_repel(data = fit %>% filter(year == max(year)),
                   aes(label = topic_label), nudge_x = 45, direction = "both", segment.alpha = .2, size = 3, segment.color = "gray") +
  geom_vline(xintercept = max(fit$year), colour = "gray") +
  coord_cartesian(xlim = c(min(fit$year) + 0.75, max(fit$year) + 1.7)) +
  scale_x_continuous(breaks = years, labels = year_labels) +
  theme_classic() + theme(legend.position = "none") + xlab("Year") + ylab("Estimated frequency")

ggsave("figures/topics.png", width = 9, height = 6)


# tsne --------------------------------------------------------------------

library(Rtsne)
set.seed(12)
x <- dd %>%
  filter(year == 2017) %>% 
  select(-year) %>%
  group_by(doc_id) %>% 
  mutate(my_topic = topic[which.max(prob)]) %>%
  select(-topic) %>% 
  spread(topic_label, prob) %>% 
  ungroup
x
tsne <- Rtsne(as.matrix(x %>% select(-doc_id, -my_topic)))
plot(tsne$Y, type = "n")
text(tsne$Y, labels = x$my_topic, col = x$my_topic)

dd <- tsne$Y %>% 
  as_data_frame %>% 
  cbind(my_topic = x$my_topic) %>%  # assing document to its max prob topic
  group_by(my_topic) %>% 
  mutate(i = row_number()) %>%
  rowwise %>% 
  mutate(topic_label = topic_labels[my_topic + 1])
dd

# plot
dd %>% 
  ggplot(aes(V1, V2, label = my_topic, color = topic_label)) +
  geom_text(size = 3) +
  geom_label_repel(data = dd %>% filter(i == 3), aes(label = topic_label), segment.alpha = 0) +
  theme_classic() +
  theme(legend.position = "none") +
  ggtitle("2017") +
  theme(plot.title = element_text(hjust = 0.5))

ggsave("figures/topics_tsne_2017.png", width = 8, height = 8)


# pca <- prcomp(as.matrix(x %>% select(-my_topic)))
# pca$rotation
# 
# y <- dd %>%
#   filter(year == 2017) %>%
#   select(-year) %>%
#   select(-topic) %>% 
#   spread(doc_id, prob)
# y
# tsne <- Rtsne(as.matrix(y %>% select(-topic_label)), perplexity = 6)
# plot(tsne$Y, col = seq_along(y$topic_label), pch = 19)
