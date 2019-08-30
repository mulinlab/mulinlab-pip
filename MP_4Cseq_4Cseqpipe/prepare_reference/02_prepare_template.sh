#!/bin/bash

dot="template"
mkdir $dot

tar -zxf 4cseq_pipe.tgz -C $dot
rm -rf $dot/rawdata/alpha_globin_features.txt
