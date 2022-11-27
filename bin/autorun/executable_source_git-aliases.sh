#!/bin/bash
git config --global core.excludesfile ~/.gitignore
git config --global alias.l 'log --tags --oneline --color --graph'
git config --global alias.ll 'log --tags --pretty=fuller --color --graph'
git config --global alias.squash 'merge --squash'
git config --global alias.b 'branch -v -v'
git config --global alias.r 'remote -v -v'
git config --global alias.s 'status'
git config --global alias.last 'log -1 HEAD'
git config --global alias.co 'checkout'
git config --global alias.ls 'ls-tree --full-tree'
git config --global alias.i 'add -i'
git config --global push.default simple
