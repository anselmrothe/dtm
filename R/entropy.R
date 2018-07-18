## did the overall entropy of topic assignments change over time?

library(tidyverse)
library(rio)

# functions ---------------------------------------------------------------

entropy <- function(p) -1*sum(sapply(p,function(x) ifelse(x==0,0,x*log(x,2))))

# script ------------------------------------------------------------------

dd <- rio::import("output/csv/year_doc_topic.csv") %>% as_data_frame
dd$year <- dd$year+2000

ee <- dd %>% 
  group_by(doc_id, doc_name, year) %>% 
  summarize(entropy = entropy(prob))

lm(data = ee, entropy ~ year) %>% summary()
## entropy increases by 0.01 per year (p < 0.001)
ee %>% ggplot(aes(factor(year), entropy)) + geom_boxplot() + xlab('') + theme_classic() + theme(axis.text.x=element_text(angle=-45, hjust=0)) + ggtitle('Entropy increases by 0.01 per year (p < 0.001)')
ggsave("figures/entropy.pdf", width = 5, height = 3)
