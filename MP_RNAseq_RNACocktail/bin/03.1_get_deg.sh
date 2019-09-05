#!/bin/bash

perl bin/03.0_get_deg_general.pl $1 $2/RNACocktail_work/diff_hisat2 $2/deg
perl bin/03.0_get_deg_general.pl $1 $2/RNACocktail_work/diff_hisat2_stringtie $2/deg
perl bin/03.0_get_deg_general.pl $1 $2/RNACocktail_work/diff_salmon $2/deg
