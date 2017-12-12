library(tidyverse)
library(ggrepel)
library(rio)

dd <- rio::import("year_doc_topic.csv") %>% as_data_frame

dd$year <- dd$year+2000

# year labels for x-axis
years <- 2000:2017
year_labels <- years
year_labels[-seq(1, 18, 4)] <- ""

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

