# https://github.com/RaRe-Technologies/gensim/blob/develop/docs/notebooks/Corpora_and_Vector_Spaces.ipynb

from gensim import corpora

# This is a tiny corpus of nine documents, each consisting of only a single sentence
documents = ["Human machine interface for lab abc computer applications",
            "A survey of user opinion of computer system response time",
            "The EPS user interface management system",
            "System and human system engineering testing of EPS",
            "Relation of user perceived response time to error measurement",
            "The generation of random binary unordered trees",
            "The intersection graph of paths in trees",
            "Graph minors IV Widths of trees and well quasi ordering",
            "Graph minors A survey"]

# remove common words and tokenize
stoplist = set('for a of the and to in'.split())
texts = [[word for word in document.lower().split() if word not in stoplist] for document in documents]

# remove words that appear only once
from collections import defaultdict
frequency = defaultdict(int)
for text in texts:
    for token in text:
        frequency[token] += 1

texts = [[token for token in text if frequency[token] > 1] for text in texts]

from pprint import pprint  # pretty printer
pprint(texts)


## bag of words
import os

TEMP_FOLDER = "strings_to_vectors"

dictionary = corpora.Dictionary(texts)
dictionary.save(os.path.join(TEMP_FOLDER, 'x.dict'))
print(dictionary)

# there are twelve distinct words in the processed corpus, which means each document will be represented by twelve numbers (ie., by a 12-D vector)
print(dictionary.token2id)

# convert tokenized documents to vectors
newdoc = "Human computer interaction"
# The function doc2bow() simply counts the number of occurrences of each distinct word, converts the word to its integer word id and returns the result as a bag-of-words--a sparse vector, in the form of [(word_id, word_count), ...]
newvec = dictionary.doc2bow(newdoc.lower().split())
print(newvec)  # the word "interaction" does not appear in the dictionary and is ignored
# The token_id is 0 for "human" and 2 for "computer"

corpus = [dictionary.doc2bow(text) for text in texts]
corpora.MmCorpus.serialize(os.path.join(TEMP_FOLDER, 'x.mm'), corpus)
for c in corpus:
    print(c)


# Corpus Streaming – One Document at a Time

class MyCorpus(object):
    def __iter__(self):
        for line in open(os.path.join(TEMP_FOLDER, 'mycorpus.txt')):
            # assume there is one document per line, tokens separated by whitespace
            yield dictionary.doc2bow(line.lower().split())
corpusmemoryfriendly = MyCorpus()
for vector in corpusmemoryfriendly:
    print(vector)
