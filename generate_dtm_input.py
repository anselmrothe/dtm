import os
import numpy as np
from nltk.tokenize import RegexpTokenizer
from nltk.stem.wordnet import WordNetLemmatizer
from gensim.corpora import Dictionary
import enchant
enchantdict = enchant.Dict('en_US')

def preprocess(docs,no_below=20,no_above=0.7):
    # input is a an array of docs; each is one string
    tokenizer = RegexpTokenizer(r'\w+')
    for idx in range(len(docs)):
        docs[idx] = docs[idx].lower()  # Convert to lowercase.
        docs[idx] = tokenizer.tokenize(docs[idx])  # Split into words.

    # Remove numbers, but not words that contain numbers.
    docs = [[token for token in doc if not token.isnumeric()] for doc in docs]
    # Remove words that are less than three characters
    docs = [[token for token in doc if len(token) > 2] for doc in docs]

    # Remove short words that are not in the dictionary
    docs = [[token for token in doc if len(token) > 4 or enchantdict.check(token)] for doc in docs]

    # Lemmatize all words in documents.
    lemmatizer = WordNetLemmatizer()
    docs = [[lemmatizer.lemmatize(token) for token in doc] for doc in docs]

    # Delete words based on their frequency in the whole corps
    # Create a dictionary representation of the documents.
    dictionary = Dictionary(docs)
    #set_trace()
    # Filter out words that occur less than 20 documents, or more than 70% of the documents.
    dictionary.filter_extremes(no_below, no_above)

    # According to the filtered dictionary, reconstruct the corpus
    corpus = [dictionary.doc2bow(doc) for doc in docs]

    return corpus, dictionary
    # TODO: linebreaks should be recovered into single word? search for solution first

years = list(range(22, 40))
dirs = ['text_data_new/volume_{}/'.format(y) for y in years]

ndocs = []
docs = []
import codecs


for d in dirs:
    fnames = os.listdir(d)
    # start with 1/10 of the data
    # fnames = [t[1] for t in enumerate(fnames) if t[0] % 10 == 0]
    for fn in fnames:
        with open(d + fn, 'r', encoding='utf-8') as f:
            fstring = ''
            for l in f.readlines():
                if np.mean([c.isalpha() for c in l]) > .7:
                    fstring = fstring + l
            docs.append(fstring)
    ndocs.append(len(fnames))

for i in range(len(docs)):
    docs[i] = docs[i].replace('-\n', '')

# corpus, dictionary = preprocess(docs,no_below=10,no_above=0.5)
corpus, dictionary = preprocess(docs,no_below=36,no_above=0.5)

def doc_to_string(bow):
    s = str(len(bow))
    for w in bow:
        s = "{} {}:{}".format(s, w[0], w[1])
    s = s + '\n'
    return s

corpus_strings = [doc_to_string(c) for c in corpus]

with open('dtm_input-mult.dat', 'w') as f:
    f.writelines(corpus_strings)

ndoc_strings = [str(n) + '\n' for n in ndocs]

with open('dtm_input-seq.dat', 'w') as f:
    f.write(str(len(ndoc_strings)) + '\n')
    f.writelines(ndoc_strings)


for y in [2, 5, 8, 11, 14, 17]:
    sum_to_prev = np.sum(ndocs[:y-1])
    prev = sum_to_prev + ndocs[y-1]
    current = prev + ndocs[y]
    with open('lda_input/prev_'+str(y), 'w') as f:
        f.writelines(corpus_strings[sum_to_prev:prev])
    with open('lda_input/all_'+str(y), 'w') as f:
        f.writelines(corpus_strings[:prev])
    with open('lda_input/test_'+str(y), 'w') as f:
        f.writelines(corpus_strings[prev:current])
