#!/bin/bash
DIR="/usr/local/bin"
echo "ln -s $(pwd) $DIR/.canoe"
ln -s $(pwd) $DIR/.canoe
echo "cp $DIR/.canoe/canoe $DIR"
cp $DIR/.canoe/canoe $DIR
echo "Installation finished"