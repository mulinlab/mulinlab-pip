#!/bin/bash
mkdir qtltools
cd qtltools
wget -c "https://qtltools.github.io/qtltools/binaries/QTLtools_1.1_Ubuntu16.04_x86_64.tar.gz"
tar xzvf QTLtools_1.1_Ubuntu16.04_x86_64.tar.gz
mv QTLtools_1.1_Ubuntu16.04_x86_64 QTLtools
rm QTLtools_1.1_Ubuntu16.04_x86_64.tar.gz
cd ..
export PATH="$PWD/qtltools:$PATH"
# echo $PATH
# exec /bin/bash

