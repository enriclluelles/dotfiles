#!/bin/bash

chezmoi init

pushd ~/.local/share/chezmoi
  git remote add origin git@github.com:enriclluelles/factorial-dotfiles.git
  git branch -M main
  git pull origin main
popd

chezmoi apply

source ~/.bashrc
