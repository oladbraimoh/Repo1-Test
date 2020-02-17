*** Settings ***
Documentation   Test suite to check if automation of integration test cases is possible, and what cost of it will be.
Library     Dialogs
Library     OperatingSystem

Suite Setup     Setup

*** Variables ***

*** Test Cases ***
Check if there is a wager request
    ${log}=     Run     grep ${hash} /tmp/gpapi-incoming.log
    Log     ${log}
    Should Contain  ${log}  request=wager   msg=Doesn't contain request=wager

*** Keywords ***
Setup
    ${process_1}=    Run     /home/pbudczak/robot/scripts/tail_gpapi-incoming.sh
    Sleep   1 second   reason=Wait until tailing starts working
    Run     /usr/bin/google-chrome $(/home/pbudczak/robot/scripts/build_url.sh -s 495b091d-73e0-4cbf-8457-95a283910a3b -g 70233 -o 5 -m real -d desktop -c SEK -l en_gb)
    Pause Execution     message=Test execution paused. Press OK when game round finish.
    Run     kill -9 ${process_1}
    ${hash}=    Run     /home/pbudczak/robot/scripts/get_hash_for_sessionid.sh 495b091d-73e0-4cbf-8457-95a283910a3b
    Set Global Variable     ${hash}
