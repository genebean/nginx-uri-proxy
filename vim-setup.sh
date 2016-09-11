#!/bin/bash

if [ ! -d /usr/local/vim ]; then

  mkdir -p /usr/local/vim/autoload /usr/local/vim/bundle
  ln -s /usr/local/vim /root/.vim
  ln -s /usr/local/etc/vimrc /root/.vimrc

  ln -s /usr/local/vim /home/vagrant/.vim
  ln -s /usr/local/etc/vimrc /home/vagrant/.vimrc

  curl -LSso /usr/local/vim/autoload/pathogen.vim https://tpo.pe/pathogen.vim

  echo 'execute pathogen#infect()' > /usr/local/etc/vimrc
  echo 'syntax on' >> /usr/local/etc/vimrc
  echo 'filetype plugin indent on' >> /usr/local/etc/vimrc

  cd /usr/local/vim/bundle
  rm -rf ./*
  git clone git://github.com/rodjek/vim-puppet.git
  git clone git://github.com/godlygeek/tabular.git
  git clone https://github.com/scrooloose/syntastic.git
  git clone https://github.com/SirVer/ultisnips
  git clone https://github.com/Valloric/YouCompleteMe
  git clone https://github.com/honza/vim-snippets


  echo >> /usr/local/etc/vimrc
  echo 'set statusline+=%#warningmsg#' >> /usr/local/etc/vimrc
  echo 'set statusline+=%{SyntasticStatuslineFlag()}' >> /usr/local/etc/vimrc
  echo 'set statusline+=%*' >> /usr/local/etc/vimrc
  echo >> /usr/local/etc/vimrc
  echo 'let g:syntastic_always_populate_loc_list = 1' >> /usr/local/etc/vimrc
  echo 'let g:syntastic_auto_loc_list = 1' >> /usr/local/etc/vimrc
  echo 'let g:syntastic_check_on_open = 1' >> /usr/local/etc/vimrc
  echo 'let g:syntastic_check_on_wq = 0' >> /usr/local/etc/vimrc

  cd /usr/local/vim/bundle/YouCompleteMe
  git submodule update --init --recursive
  ./install.py
  cd ~
fi
