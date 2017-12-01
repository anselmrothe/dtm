# run this with python 3, can't load this pickle file with python 2
import pickle
import pandas as pd

x = pickle.load(open('output/20topics.p', 'rb'))

# inspect
len(x) # years
len(x[0]) # 5 features:
x[0][0].shape # documents x topics  (proportions)
x[0][1].shape # topics x terms  (proportions)
len(x[0][2]) # length of each document
x[0][3].shape # frequency of each terms
len(x[0][4]) # actual terms list of strings

## make csv with proportion of each topic over time
years = list(range(len(x)))
topics = [1,12,13]

feature = 0  # 0 == documents x topics (proportions)
# for each topic,
# for each year,
# take the mean of the topics proportion across all documents
proportions = {topic: [np.mean(x[year][feature][:,topic-1]) for year in years] for topic in topics}
df = pd.DataFrame.from_dict(proportions)
df.to_csv("proportions.csv", index=False)
# rows = years; columns = topics
