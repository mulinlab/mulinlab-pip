# Prepare references for 4Cseqpipe

## Change work directory

Change the work directory to some folder, such as `reference/MP_4Cseq_4Cseqpipe`, then run the following scripts.

## Download reference from the website

```shell
bash 01_download_reference.sh
```

## Prepare the template directory
```shell
bash 02_prepare_template.sh
```

## Prepare the track database

```shell
bash 03_prepare_trackdb.sh
```

## Build restriction site tracks

If you do not know the enzyme restriction site exactly, you can check it on the [ReBase website](http://rebase.neb.com/rebase/rebase.html) in the [IGSuite file](http://rebase.neb.com/rebase/link_bionet).
```shell
# First cutter enzyme: HindIII (AAGCTT)
# Second cutter enzyme: DpnII (GATC)
# This script should be run in the current directory!
cd template
perl 4cseqpipe.pl -build_re_db -first_cutter AAGCTT -second_cutters GATC -trackdb_root ../hg19_trackdb
cd ..
```

## Reference
* [4Cseqpipe](http://compgenomics.weizmann.ac.il/tanay/?page_id=367)