#!/usr/bin/env bash
echo "complete -W \"new build run clean help add generate version\" canoe" >> ~/.bash_completion
source ~/.bash_completion

if [[ -f ~/.zshrc ]]; then
    echo "complete -W \"new build run clean help add generate version\" canoe" >> ~/.zshrc
fi