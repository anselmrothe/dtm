#!/bin/bash

for a in 0.01 0.05 0.1
    do
        /home/ubuntu/lda-c/lda est $a 20 \
                               settings.txt \
                               lda_input/all_17 \
                               random \
                               lda_out/all_alpha${a}

        /home/ubuntu/lda-c/lda inf \
                               settings.txt \
                               lda_out/all_topics${t}_alpha${a}/final \
                               lda_input/test_17 \
                               lda_out/all_topics${t}_alpha${a}_test
    done
