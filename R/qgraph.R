library(tidyverse)
library(qgraph)
library(rio)

insert_line_break_after_n_characters <- function(x, n, insert_string = "\n") {
  gsub_insert_string <- sprintf("\\1%s", insert_string)
  gsub_n <- sprintf("(.{1,%s})(\\s|$)", n)  # at appropriate places e.g., spaces
  y <- gsub(gsub_n, gsub_insert_string, x)
  if (endsWith(y, "\n")) y <- substr(y, 1, nchar(y)-1)  # remove "\n" at the end (btw, nchar("\n") == 1)
  y
}

# correlation matrix
dd <- rio::import('output/csv/topic_topic_cor.csv') %>% as_data_frame
mm <- dd[,-1] %>% as.matrix
v <- median(mm) / 2
mm[mm < v] <- v  # filter negative correlations
# normalize
mm <- mm - min(mm)  # avoid negative weights for now
diag(mm) <- 0
mm <- mm / max(mm)
mm <- mm * 20  # max line width
mm %>% str

# mm[mm < median(mm)] <- 0
# mm <- mm * 200

labels <- dd$V1
labels <- labels %>% map_chr(insert_line_break_after_n_characters, 12)
  
set.seed(12345)
qgraph(mm, layout = "spring", directed = FALSE, posCol = "darkred", labels = labels,
       title = '', 
       mode = 'direct',  # value = line width
       filetype = "pdf", filename = 'figures/topics_cor')

