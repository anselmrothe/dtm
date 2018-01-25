library(tidyverse)
library(rio)
library(ggrepel)


dd <- rio::import("year_doc_topic.csv") %>% as_data_frame
dd$year <- dd$year+2000

# topic labels
labels <- unique(dd$topic_label)  # same ordering as in python



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

# rising or falling trend
fit <- fit %>% 
  group_by(topic_label) %>% 
  mutate(trend = if_else(prob[year==2000] < prob[year==2017], "rising", "falling"))
fit$trend <- factor(fit$trend, levels = c("rising", "falling"))

# plot topics.png
fit %>% 
  ggplot(aes(year, prob, colour = topic_label)) +
  facet_wrap(~trend) +  # enable this line for double plot
  geom_line() +
  geom_vline(xintercept = max(fit$year), colour = "gray") +
  geom_text_repel(data = fit %>% filter(year == max(year)),
                   aes(label = topic_label), force = 2, nudge_x = 2, direction = "y", segment.alpha = .2, size = 3, segment.color = "gray") +
  coord_cartesian(xlim = c(min(fit$year) + 0.75, max(fit$year) + 1.5)) +
  scale_x_continuous(breaks = years, labels = year_labels) +
  xlab("Year") + ylab("Estimated frequency") +
  theme_classic() +  
  theme(panel.border = element_rect(fill = NA, colour = 'black')) +  # enable this line for double plot
  theme(legend.position = "none")

# ggsave("figures/topics.png", width = 9, height = 6)  # single plot
ggsave("figures/topics-2.png", width = 11, height = 5)  # double plot

