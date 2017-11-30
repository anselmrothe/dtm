def preprocess(docs,no_below=20,no_above=0.7):

# preprocessing the raw document
# procedure based on: https://github.com/RaRe-Technologies/gensim/blob/develop/docs/notebooks/lda_training_tips.ipynb

# example: corpus, dictionary = preprocess(docs,no_below=3,no_above=0.7)
# input: docs is an array of string, each string is an article's all raw texts;
# parameters: no_below deletes words appears in less than 3 documents, or appears in more than 70% documents

from nltk.tokenize import RegexpTokenizer
from nltk.stem.wordnet import WordNetLemmatizer
from gensim.corpora import Dictionary

# dealing w the error: "Resource 'corpora/wordnet.zip/wordnet/' not found"
#import nltk
#nltk.download()


    # input is a an array of docs; each is one string
    tokenizer = RegexpTokenizer(r'\w+')
    for idx in range(len(docs)):
        docs[idx] = docs[idx].lower()  # Convert to lowercase.
        docs[idx] = tokenizer.tokenize(docs[idx])  # Split into words.

    # Remove numbers, but not words that contain numbers.
    docs = [[token for token in doc if not token.isnumeric()] for doc in docs]
    # Remove words that are only one character.
    docs = [[token for token in doc if len(token) > 1] for doc in docs]

    # Lemmatize all words in documents.
    lemmatizer = WordNetLemmatizer()
    docs = [[lemmatizer.lemmatize(token) for token in doc] for doc in docs]

    # Delete words based on their frequency in the whole corps
    # Create a dictionary representation of the documents.
    dictionary = Dictionary(docs)
    set_trace()
    # Filter out words that occur less than N documents, or more than M% of the documents.
    dictionary.filter_extremes(no_below, no_above)

    # According to the filtered dictionary, reconstruct the corpus
    corpus = [dictionary.doc2bow(doc) for doc in docs]

    return corpus, dictionary
    # TODO: linebreaks should be recovered into single word? search for solution first
