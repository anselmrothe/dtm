#!/bin/bash

# to run this script, install poppler first. On a mac with homebrew, use "brew install poppler"

for v in {22..39}
do
    mkdir text_data_new/volume_$v
    for f in data/volume_$v/pdf/*.pdf
    do
        b=$(basename "$f" .pdf)
        /usr/local/Cellar/poppler/0.62.0/bin/pdftotext "$f" "text_data_new/volume_${v}/${b}.txt";
        echo $f
    done
done
