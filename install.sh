#!/usr/bin/env bash
pushd `dirname "${BASH_SOURCE[0]}"` > /dev/null
CURRENT_DIR=`pwd`
git submodule update --init

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
