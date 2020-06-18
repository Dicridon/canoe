#!/usr/bin/env bash
DIR="/usr/local/bin"
BIN="/usr/local/bin/canoe"
DATA="/usr/local/bin/.canoe"

function install_canoe {
    ln -s $(pwd) $DIR/.canoe
    if [[ $? -eq 1 ]]; then
        return 1
    fi
    cp $DIR/.canoe/scripts/canoe.bash $BIN
    if [[ $? -eq 1 ]]; then
        return 1
    fi
    echo "Installation finished"
    echo "To remove canoe, simply remove $BIN and $DATA"
    echo
    echo "try 'canoe help' to see if installation succeeds"
    echo "enjoy working with canoe :)"
}

if [[ -f $BIN ]] || [[ -d $DATA ]]; then
    echo "canoe seems already installed, would you like to overwrite it?"
    echo "Yes[y/Y/yes/Yes], No[n/N/no/No]"
    read option
    case $option in
        y | Y | yes | Yes)
            rm -f $BIN
            rm -r -f $DATA
            install_canoe
            ;;
        *)
            echo "no option is performed"
    esac
else
    install_canoe
fi

