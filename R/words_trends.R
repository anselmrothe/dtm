library(tidyverse)
library(rio)
library(broom)
library(ggrepel)

add_topic_label <- function(x) {
  dd <- rio::import("output/csv/year_doc_topic.csv") %>% as_data_frame
  label <- dd %>% select(topic, topic_label) %>% unique  # same ordering as in python
  x %>% left_join(label, by = 'topic')
}

cc <- rio::import("output/csv/year_topic_word.csv") %>% as_data_frame
dd <- add_topic_label(cc)
dd

ee <- dd %>% 
  group_by(topic_label, word) %>% 
  do(fit = lm(frequency ~ year, .))
ff <- ee %>% 
  broom::tidy(fit)
gg <- ff %>% 
  filter(term == 'year') %>% 
  group_by(word) %>% 
  summarize(min = min(estimate),
            max = max(estimate),
            range = max - min) %>% 
  arrange(-range) %>% 
  head(30)

extract_data <- function(i, ff, gg) {
  wordx <- gg$word[i]
  topics <- ff %>% filter(term == 'year', word == wordx) %>% arrange(-estimate) %>% ungroup %>% do(rbind(head(.,1),tail(.,1))) %>% .$topic_label
  dd %>% filter(word == wordx, topic_label %in% topics)
}

hh <- 1:9 %>% map_df(extract_data, ff, gg)
hh$word <- factor(hh$word, levels = unique(hh$word))
hh %>% 
  ggplot(aes(year, frequency, colour = topic_label)) +
  facet_wrap(~word, labeller = label_both, scales = 'free_y') +
  theme(legend.position = "none", panel.background = element_rect(fill = 'white'),
        panel.border = element_rect(fill = NA, colour = 'black'),
        strip.text = element_text(colour = 'black'),
        strip.background = element_rect(fill = 'gray', colour = 'black'),
        axis.ticks.y = element_blank(),
        axis.text.y = element_blank()) + 
  xlab("Year") + ylab("Estimated frequency") +
  geom_line() +
  geom_text_repel(data = hh %>% filter(year == 2010),
                  aes(label = topic_label), point.padding = 2.5, nudge_x = 0, nudge_y = 0.0002, direction = "both", segment.alpha = 0, size = 3)
ggsave("figures/words_trends.pdf", width = 7, height = 7)

