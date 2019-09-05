#!/bin/bash

[ -z $1 ] && (echo "Source directory must be specified!" && exit 1)
[ -d $1 ] || (echo "Source directory must exist!" && exit 1)
[ -z $2 ] && echo "Target directory set to current folder(.)!"

dir_from=$1
dir_to=${2:-"."}

link_recursive () {
  local df=$1
  local dt=$2
  [ -d $dt ] || mkdir $dt
  for fi in $(ls -d $df/*)
  do
    if [ -f $fi ]; then
      ln $fi $dt
    fi
    if [ -d $fi ]; then
      local bn=$(basename $fi)
      local dtt="$dt/$bn"
      link_recursive $fi $dtt
    fi
  done
}

link_recursive $dir_from $dir_to
