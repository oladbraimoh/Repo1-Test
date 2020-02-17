#!/bin/bash

PLAYERIP=$(curl https://ipinfo.io/ip 2> /dev/null)
BETAMOUNT=1.00

GPID=196
GPGAMEID=Tombstone
GAMEID=1960001

/usr/local/bin/robot -v PLAYERIP:${PLAYERIP} -v GPID:${GPID} -v GPGAMEID:${GPGAMEID} -v GAMEID:${GAMEID} -v BETAMOUNT:${BETAMOUNT} -e pending_request -n non-critical $@
