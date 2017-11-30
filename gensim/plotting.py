# various ways to visualize the output
import matplotlib.pyplot as plt
from gensim import matutils

def temporal_change(ldaseq, whichtopic=0,wordtime=0,npick=5):
    # for topic 0, pick the top 5 words at time 0 and see their frequency evolution
    # TODO: pick random 5 words (top words at different times)

    topicP = ldaseq.topic_chains[whichtopic].e_log_prob
    topicP = np.transpose(topicP)
    wordids = matutils.argsort(topicP[wordtime], npick, reverse=True)

    wfreqs = np.empty((len(time_slice),npick))
    for kt in range(len(time_slice)):
        topic = np.exp(topicP[kt])
        topic = topic/sum(topic)

        wfreqs[kt] = np.array([topic[id_] for id_ in wordids])


    plt.plot(wfreqs,'-+')
    plt.yticks(wfreqs[0],[ldaseq.id2word[id_] for id_ in wordids])
    plt.xticks(np.arange(len(time_slice)))
    plt.title('topic %d'%(whichtopic+1))
    plt.show()
