#!/usr/bin/env zsh
if [[ -f ~/.zshrc ]]; then
    echo "complete -W \"new build run clean help add generate version\" canoe" >> ~/.zshrc
    source ~/.zshrc
fi