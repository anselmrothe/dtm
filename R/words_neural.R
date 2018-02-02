library(tidyverse)
library(rio)
library(ggrepel)

year_labels <- 2000:2017
year_labels[-seq(1, 18, 4)] <- ""

dd <- rio::import("output/csv/year_topic_word.csv") %>% as_data_frame
dd %>% head
neural <- dd %>% filter(topic == 15)
diff <- neural %>% 
  group_by(word) %>% 
  summarize(diff = frequency[year == 2017] - frequency[year == 2000]) %>% 
  arrange(-diff)
rising <- diff %>% head(10) %>% .$word
falling <- diff %>% tail(10) %>% .$word

# rising or falling trend
ee <- neural %>%
  filter(word %in% c(rising, falling)) %>% 
  rowwise %>% 
  mutate(trend = if_else(word %in% rising, 'rising', 'falling')) %>% 
  ungroup
ee$trend <- factor(ee$trend, levels = c("rising", "falling"))

# ordering for color
ordering <- ee %>% 
  filter(year == max(year)) %>% 
  arrange(-frequency) %>%
  .$word
ee$word <- factor(ee$word, levels = ordering)


# rise <- neural %>% filter(word %in% rising) %>% mutate(trend = 'rising')
# rise$word <- factor(rise$word, levels = rise %>% filter(year == 2017) %>% arrange(-frequency) %>% .$word)
# 
# fall <- neural %>% filter(word %in% falling) %>% mutate(trend = 'falling')
# fall$word <- factor(fall$word, levels = fall %>% filter(year == 2017) %>% arrange(-frequency) %>% .$word)

ee %>%
  ggplot(aes(year, frequency, colour = word)) +
  geom_line() +
  geom_vline(xintercept = max(fit$year), colour = "gray") +
  geom_text_repel(data = ee %>% filter(year == max(year)),
                  aes(label = word), force = 1, nudge_x = 2.5, direction = "y", segment.alpha = .2, size = 3, segment.color = "gray") +
  scale_x_continuous(breaks = years, labels = year_labels) +
  xlab("Year") + ylab("Estimated frequency") +
  theme_classic() +
  theme(legend.position = "none") +
  coord_cartesian(xlim = c(min(fit$year) + 0.75, max(fit$year) + 4)) +
  theme(panel.border = element_rect(fill = NA, colour = 'black')) +
  # facet_wrap(~trend)
  facet_wrap(~trend, ncol = 1, scales = 'free_y')

ggsave("figures/words_neural.pdf", width = 5, height = 7)
