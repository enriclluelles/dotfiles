#!/usr/bin/env bash
pushd `dirname "${BASH_SOURCE[0]}"` > /dev/null
CURRENT_DIR=`pwd`
git submodule update --init

PREF_DIR=$HOME/Library/Preferences
for f in vimrc gvimrc
do
  FILEN=$HOME/\.$f
  rm -rf $FILEN
  echo $FILEN
  ln -s $CURRENT_DIR/vim/$f $FILEN
done
for f in *
do
  if [[ -f $f || $f == "bin" || $f == "tmux" || $f == "bash" || $f == "config" ]]
  then
    FILEN=$HOME/\.$f
    rm -rf $FILEN
    echo $FILEN
    ln -s $CURRENT_DIR/$f $FILEN
  fi
done
for f in preferences/*
do
  base_name=${f##*/}
  rm -rf $PREF_DIR/$base_name
  cp $f $PREF_DIR/$base_name
done
