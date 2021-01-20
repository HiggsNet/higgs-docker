#!/bin/bash
set -ex

source /etc/higgs/env

if [ $# = 0 ]; then
    echo "nothing to do, exit"
    exit 0 
fi

_term() { 
    echo "Caught SIGTERM signal!"
    kill -TERM $(cat /etc/higgs/supervisord.pid)
    /etc/higgs/down.sh
}

trap _term SIGTERM

if [ $1 == "start" ] ;then
    /etc/higgs/pre.sh
    /usr/bin/supervisord -c /etc/higgs/supervisord.conf &
    child=$! 
    wait "$child"
else
    $*
fi
