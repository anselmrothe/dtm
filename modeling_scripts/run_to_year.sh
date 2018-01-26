#!/bin/bash

/home/ubuntu/dtmfork/dtm/main \
    --ntopics=20  \
    --mode=fit   \
    --initialize_lda=true   \
    --corpus_prefix=dtm_input_data/dtm_input_incl_$1   \
    --initialize_lda_data=dtm_input_data/dtm_input_upto_$1 \
    --skip_dtm=true \
    --outname=dtm_out/lda_upto_$1   \
    --top_chain_var=0.001   \
    --alpha=0.05   \
    --lda_sequence_min_iter=6   \
    --lda_sequence_max_iter=50   \
    --lda_max_em_iter=3 \
    --min_time=0 \
    --heldout_time=$1

/home/ubuntu/dtmfork/dtm/main \
    --ntopics=20 \
    --mode=fit \
    --initialize_lda=false \
    --lda_SS_folder=dtm_out/lda_upto_$1 \
    --corpus_prefix=dtm_input_data/dtm_input_incl_$1 \
    --outname=dtm_out/dtm_upto_$1 \
    --top_chain_var=0.001 \
    --alpha=0.05 \
    --lda_sequence_min_iter=6 \
    --lda_sequence_max_iter=50 \
    --min_time=0 \
    --heldout_time=$1
