#!/usr/bin/env bash

OPTIONS="new build run clean help add generate update version dep"
function canoe_exec {
    ruby /usr/local/bin/.canoe/main.rb "$OPTIONS" $@
}

canoe_exec $@
