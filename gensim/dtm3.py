
## based on dtm1.py but using some cogsci papers

import logging
from gensim.models import ldaseqmodel
from gensim.corpora import Dictionary, bleicorpus, textcorpus
import numpy
from gensim.matutils import hellinger
import re
import os

def text_to_words(text):
  clean = re.sub('[^A-Za-z0-9 ]+', '', text)
  words = clean.lower().split()
  return(words)

def load_documents(folder):
    files = os.listdir(folder)
    documents = list()
    for file in files:
        if file.endswith(".txt"):
            path = os.path.join(folder, file)
            with open(path, "r") as f:
                text = f.read()
                words = text_to_words(text)
                documents.append(words)
    return(documents)

def run(n, folder, verbose = True):
    # documents is a list of lists, where each nested list has the words from one document
    documents = load_documents(folder)
    len(documents)
    len(documents[0])

    # remove common words
    stoplist = set('for a an of the and or to in from on is are can we'.split())
    documents = [[word for word in document if word not in stoplist] for document in documents]

    # remove words that appear only once
    from collections import defaultdict
    frequency = defaultdict(int)
    for document in documents:
        for word in document:
            frequency[word] += 1
    documents = [[word for word in document if frequency[word] > 1] for document in documents]

    len(documents)
    [len(document) for document in documents]

    # use only the first n words per document
    documents = [document[:n] for document in documents]
    [len(document) for document in documents]

    class DTMcorpus(textcorpus.TextCorpus):
        def get_texts(self):
            return self.input
        def __len__(self):
            return len(self.input)

    corpus = DTMcorpus(documents)

    first_half = len(documents) / 2
    second_half = len(documents) - first_half
    time_slice = [first_half, second_half]  # n documents split into 2 time slices

    if verbose:
        # activate logging
        logger = logging.getLogger()
        logger.setLevel(logging.DEBUG)

    # run
    ldaseq = ldaseqmodel.LdaSeqModel(corpus=corpus, id2word=corpus.dictionary, time_slice=time_slice, num_topics=5)

    # Visualizing dynamic topic models
    from gensim.models.wrappers.dtmmodel import DtmModel
    from gensim.corpora import Dictionary, bleicorpus
    import pyLDAvis

    doc_topic, topic_term, doc_lengths, term_frequency, vocab = ldaseq.dtm_vis(time=0, corpus=corpus)
    vis_dtm = pyLDAvis.prepare(topic_term_dists=topic_term, doc_topic_dists=doc_topic, doc_lengths=doc_lengths, vocab=vocab, term_frequency=term_frequency)

    # For ipython notebook:
    # pyLDAvis.display(vis_dtm)

    # This works best for me (then view dtm.html in a browser)
    with open("dtm3.html", "w") as f:
        pyLDAvis.save_html(vis_dtm, f)

    return("dtm3.html saved.")

# use only the first n words per document
run(n = 100, folder = 'txt-small', verbose = False)
