#!/bin/bash

chezmoi init

pushd ~/.local/share/chezmoi
  git remote add origin git@github.com:enriclluelles/factorial-dotfiles.git
  git branch -M main
  git pull origin main
popd

chezmoi apply

source ~/.bashrc

# Install packer dependencies
nvim --headless -c 'autocmd User PackerComplete quitall' -c 'PackerSync'
nvim --headless -c 'autocmd User PackerComplete quitall' -c 'PackerSync' # Yep, twice
nvim --headless -c 'TSUpdateSync'
