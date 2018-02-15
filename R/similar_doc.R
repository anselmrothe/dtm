library(tidyverse)
library(rio)
library(lsa)
library(stringdist)
library(knitr)
library(pbapply)
library(testthat)
library(entropy)

source('R/similar_doc_functions.R')

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


# script ------------------------------------------------------------------

df.docnames <- rio::import('output/csv/doc_names.csv') %>% as_data_frame

dd <- rio::import("output/csv/year_doc_topic.csv") %>% as_data_frame
dd$year <- dd$year+2000

## target paper
similar_docs(docID = 100, dd)

# docIDs <- c(5329)
docIDs <- c(6010, 3674, 5329, 5169, 5913, 6524,
            6812, 6685, 6010, 6298, 6094, 6088, 5427, 5329, 5782, 4885, 
            5169, 4905, 3462, 4270, 3704, 3964, 3755, 3963, 3581, 3494, 3269, 
            3031, 2870, 2799, 2266, 2516, 2155, 2102, 4711)
lines <- docIDs %>% pbapply::pblapply(lines_similar_doc, dd, df.docnames) %>% unlist
readr::write_lines(lines, 'result/similar_doc.txt')
lines <- docIDs %>% pbapply::pblapply(lines_similar_doc, dd, df.docnames, latex = TRUE) %>% unlist
readr::write_lines(lines, 'result/similar_doc_latex.txt')


# debug -------------------------------------------------------------------

alex <- dd %>% filter(doc_id %in% c(5329)) %>% arrange(topic) %>% .$prob
simi <- dd %>% filter(doc_id %in% c(1797)) %>% arrange(topic) %>% .$prob
lsa::cosine(alex, simi)

dd %>% filter(doc_id %in% c(5329, 1797)) %>% 
  ggplot(aes(topic_label, prob, fill = doc_id, group = doc_id)) +
  theme(legend.position = 'none') + ylab('') + xlab('') +
  coord_flip() +
  facet_wrap(~doc_id, nrow = 1) +
  geom_bar(stat = 'identity')


# find doc ids -------------------------------------------------------------

find_doc_id("Asking and evaluating natural language questions", df.docnames)  # 6010
find_doc_id("Causal Status meets Coherence The Explanatory Role of Causal Models in Categorization", df.docnames)  # 3674
find_doc_id("The attentional learning trap and how to avoid it", df.docnames)  # 5329
find_doc_id("The value of approaching bad things", df.docnames)  # 5169
find_doc_id("Evaluating Causal Hypotheses: The Curious Case of Correlated Cues", df.docnames)  # 5913
find_doc_id("The Causal Sampler: A Sampling Approach to Causal Representation, Reasoning, and Learning", df.docnames)  # 6524

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
dput(gureckislab_ids %>% as.numeric)
