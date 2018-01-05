#!/bin/bash

for t in 10 20 30
do
    for a in 0.01 0.05 0.1
    do
        /home/ubuntu/lda-c/lda est $a $t \
                               settings.txt \
                               lda_input/all_17 \
                               random \
                               lda_out/all_topics${t}

        /home/ubuntu/lda-c/lda inf \
                               settings.txt \
                               lda_out/all_${y}/final \
                               lda_input/test_$y \
                               lda_out/all_topics${y}_test
    done
done
