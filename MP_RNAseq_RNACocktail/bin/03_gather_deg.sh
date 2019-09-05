#!/bin/bash

# $1: work folder
bash bin/03.1_get_deg.sh $1 $2
perl bin/03.2_deg_stringtie_count2tpm.pl $2
perl bin/03.3_get_deg_list.pl $2
