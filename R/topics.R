library(tidyverse)
library(rio)
library(ggrepel)


dd <- rio::import("output/csv/year_doc_topic.csv") %>% as_data_frame
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

## word positions
df.word <- fit %>% 
  group_by(topic_label, trend) %>% 
  summarize(year = 2018) %>% 
  arrange(topic_label)
df.word$prob <- seq(from = max(fit$prob), to = min(fit$prob), length.out = nrow(df.word))

## gray lines to words
df.gray <- fit %>% filter(year == max(year)) %>% bind_rows(df.word)

g <- fit %>% 
  ggplot(aes(year, prob, colour = topic_label, group = topic_label)) +
  geom_line() +
  geom_vline(xintercept = max(fit$year), colour = "gray") +
  geom_line(data = df.gray, colour = 'gray', linetype = 'longdash') +
  geom_text(data = df.word, aes(label = topic_label), hjust = 0, size = 3) +
  scale_x_continuous(breaks = years, labels = year_labels) +
  xlab("Year") + ylab("Estimated frequency") +
  theme_classic() +  
  theme(legend.position = "none")

## single plot
g + coord_cartesian(xlim = c(min(fit$year) + 0.75, max(fit$year) + 7))
ggsave("figures/topics.pdf", width = 9, height = 5)


g <- fit %>%
  ggplot(aes(year, prob, colour = topic_label)) +
  geom_line() +
  geom_vline(xintercept = max(fit$year), colour = "gray") +
  geom_text_repel(data = fit %>% filter(year == max(year)),
                  aes(label = topic_label), force = 1, nudge_x = 8, direction = "y", segment.alpha = .2, size = 3, segment.color = "gray") +
  scale_x_continuous(breaks = years, labels = year_labels) +
  xlab("Year") + ylab("Estimated frequency") +
  theme_classic() +
  theme(legend.position = "none")

## double plot
g + coord_cartesian(xlim = c(min(fit$year) + 0.75, max(fit$year) + 14)) +
  theme(panel.border = element_rect(fill = NA, colour = 'black')) +
  # facet_wrap(~trend)
  facet_wrap(~trend, ncol = 1)
# ggsave("figures/topics-2.pdf", width = 11, height = 3)
ggsave("figures/topics-2.pdf", width = 6, height = 6)



