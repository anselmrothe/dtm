#!/bin/bash

for y in 2 5 8 11 14 17
do
    /home/ubuntu/dtmfork/dtm/main   \
        --ntopics=20  \
        --mode=fit   \
        --initialize_lda=true   \
        --corpus_prefix=dtm_input   \
        --fix_topics=0 \
        --outname=dtm_out/dtm_$y   \
        --top_chain_var=0.001   \
        --alpha=0.05   \
        --lda_sequence_min_iter=6   \
        --lda_sequence_max_iter=200   \
        --lda_max_em_iter=100 \
        --min_time=0 \
        --heldout_time=$y
done
