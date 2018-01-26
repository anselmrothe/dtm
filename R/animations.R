library(tidyverse)
library(rio)
library(gganimate)  # devtools::install_github("dgrtwo/gganimate")
# also: brew install imagemagick

# https://github.com/dgrtwo/gganimate

# p <- fit %>% 
#   ggplot(aes(year, prob, colour = topic_label, frame = topic_label)) +
#   geom_line() +
#   geom_text_repel(data = fit %>% filter(year == max(year)),
#                   aes(label = topic_label), nudge_x = 45, direction = "both", segment.alpha = .2, size = 3, segment.color = "gray") +
#   geom_vline(xintercept = max(fit$year), colour = "gray") +
#   coord_cartesian(xlim = c(min(fit$year) + 0.75, max(fit$year) + 1.7)) +
#   scale_x_continuous(breaks = years, labels = year_labels) +
#   theme_classic() + theme(legend.position = "none") + xlab("Year") + ylab("Estimated frequency")
# 
# gganimate(p)
# 