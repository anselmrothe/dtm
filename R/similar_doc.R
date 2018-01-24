library(tidyverse)
library(rio)
library(lsa)
library(stringdist)
library(knitr)
library(pbapply)

# intro -------------------------------------------------------------------

# lsa::cosine() calculates a similarity matrix between all column vectors of a
# matrix x. This matrix might be a document-term matrix, so columns would be
# expected to be documents and rows to be terms.

## the cosinus measure between two vectors
vec1 = c( 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0 )
vec2 = c( 0, 0, 1, 1, 1, 1, 1, 0, 1, 0, 0, 0 )
cosine(vec1,vec2)
## the cosine measure for all document vectors of a matrix
vec3 = c( 0, 1, 0, 1, 1, 0, 0, 1, 0, 0, 0, 0 )
matrix = cbind(vec1,vec2, vec3)
cosine(matrix)


# functions ---------------------------------------------------------------

similar_docs <- function(docID, x, n = 6) {
  target_doc_vector <- x[,docID]
  doc_ids <- 1:ncol(x)
  similarity <- numeric(length(doc_ids))
  for (i in doc_ids) {
    similarity[i] <- lsa::cosine(target_doc_vector, x[,i])
  }
  data_frame(docID, doc_id = doc_ids, cosine = similarity) %>% 
    arrange(-cosine) %>% 
    filter(docID != doc_id) %>% 
    head(n) %>% 
    select(-docID, cosine, everything())
}

find_doc_id <- function(docname, df.docnames, n = 1, return_just_id = FALSE) {
  out <- df.docnames %>%
    rowwise %>%
    mutate(stringdist = stringdist(docname, doc_name)) %>% 
    select(stringdist, everything()) %>% 
    arrange(stringdist) %>% 
    head(n)
  if (return_just_id) return(out$doc_id)
  else return(out)
}

lines_similar_doc <- function(docID) {
  dd <- similar_docs(docID, x)
  ee <- dd %>% left_join(df.docnames, by ='doc_id')
  docname <- df.docnames %>% filter(doc_id == docID) %>% .$doc_name
  ff <- ee %>% select(-doc_name_short) %>% knitr::kable()
  lines <- c(docname, ff, '\n\n')
  lines
}


# script ------------------------------------------------------------------

df.docnames <- rio::import('doc_names.csv') %>% as_data_frame

dd <- rio::import("year_doc_topic.csv") %>% as_data_frame
dd$year <- dd$year+2000

x <- dd %>% 
  arrange(doc_id) %>% 
  select(doc_id, topic_label, prob) %>% 
  spread(topic_label, prob) %>% 
  select(-doc_id) %>% 
  as.matrix %>% 
  t
# x[1:6,1:6]
# x %>% str

# ## all papers
# sim <- lsa::cosine(x[,1:10])  # takes long with all papers (sim is a 6920*6920 matrix)

## target paper
similar_docs(docID = 100, x)

docIDs <- c(6010, 5329, 5169, gureckislab_ids)
lines <- docIDs %>% pbapply::pblapply(lines_similar_doc) %>% unlist
readr::write_lines(lines, 'result/similar_doc.txt')



# find doc ids -------------------------------------------------------------

find_doc_id("Asking and evaluating natural language questions", df.docnames)  # 6010
find_doc_id("The attentional learning trap and how to avoid it", df.docnames)  # 5329
find_doc_id("The value of approaching bad things", df.docnames)  # 5169

gureckislab <- c('Information selection in categorization with stimulus uncertainty',
                 'Beliefs about sparsity affect casual experimentation',
                 'Asking and evaluating natural language questions','The distorting effects of deciding to stop sampling',
                 'Desirable difficulties in the development of active inquiry skills',
                 'Active control of study leads to improved recognition memory in children',
                 'Deep Neural Networks Predict Category Typicality Ratings for Images',
                 'the Attentional Learning Trap and How to Avoid it',
                 'Are Biases When Making Causal Interventions Related to Biases in Belief Updating',
                 'Decisions to intervene on causal systems are adaptively selected',
                 'The value of approaching bad things',
                 'A preference for the unpredictable over the informative during self-directed learning',
                 'Workshop: Online Experiments using jsPsych, psiTurk, and Amazon Mechanical Turk',
                 'Informavores: Active information foraging and human cognition',
                 'Does the utility of information influence sampling behavior',
                 'One piece at a time: Learning complex rules through self-directed sampling',
                 'Sparse category labels obstruct generalization of category membership',
                 'One-shot lotteries in the park',
                 'Does category labeling lead to forgetting',
                 "Don't Stop 'Til You Get Enough: Adaptive Information Sampling in a Visuomotor Estimation Task",
                 'Grow your own representations: Computational constructivism',
                 'Category Learning Through Active Sampling',
                 'The Impact of Perceptual Aliasing on Exploration and Learning in a Dynamic Decision Making Task',
                 'Is categorial perception really verbally-mediated perception',
                 'Active Learning Strategies in a Spatial Concept Learning Game',
                 'When Things Get Worse before they Get Better: Regulatory Fit and Average-Reward Learning in a Dynamic Decision-Making Environment',
                 'The emergence of Collective Structure through Individual Interactions',
                 'Modeling category intuitiveness',
                 'The effect of the internal structure of categories on perception')

gureckislab_ids <- gureckislab %>% pbapply::pblapply(find_doc_id, df.docnames, return_just_id = TRUE) %>% unlist
