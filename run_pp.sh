#!/bin/bash

PLAYERIP=$(curl https://ipinfo.io/ip 2> /dev/null)
BETAMOUNT=4.0

GPID=151
GPGAMEID=vs40beowulf
GAMEID=1510002

/usr/local/bin/robot -v PLAYERIP:${PLAYERIP} -v GPID:${GPID} -v GPGAMEID:${GPGAMEID} -v GAMEID:${GAMEID} -v BETAMOUNT:${BETAMOUNT} -e pending_request -n non-critical $@
