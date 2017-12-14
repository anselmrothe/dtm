#!/bin/bash

for y in 2 5 8 11 14 17
do
    /home/ubuntu/lda-c/lda est 0.1 20 \
         settings.txt \
         lda_input/all_$y \
         random \
         lda_out/all_${y}

    /home/ubuntu/lda-c/lda inf \
         settings.txt \
         lda_out/all_${y}/final \
         lda_input/test_$y \
         lda_out/all_${y}_test

    /home/ubuntu/lda-c/lda est 0.1 20 \
         settings.txt \
         lda_input/prev_$y \
         random \
         lda_out/prev_${y}

    /home/ubuntu/lda-c/lda inf \
         settings.txt \
         lda_out/prev_${y}/final \
         lda_input/test_$y \
         lda_out/prev_${y}_test
done
