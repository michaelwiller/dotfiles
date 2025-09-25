# Chezmoi

## General setup

dotfiles in home directory. 

~/bin is added to PATH. 

Default setup looks for a file containing additional ENV to be added

    ~/.bash-local-env*

Configuration is placed in

    ~/.config
  

## Chezmoi quick reference

    init       Pull repository from github (cm init <repo>)
    apply      Apply changes from chezmoi repository to Home
    update     Pull changes
    add        Add a new file to the chezmoi repository
