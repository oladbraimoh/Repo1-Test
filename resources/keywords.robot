*** Settings ***
Library           Dialogs
Library           Selenium2Library
Library           SSHLibrary
Library           RequestsLibrary
Library           String
Library           Collections
Variables         credentials.py

*** Variables ***

*** Keywords ***
Connect To Server
    SSHLibrary.Open Connection    ls3.ps.gameop.net
    SSHLibrary.Login    ${LOGIN}    ${PASSWORD}

Start Logging
    SSHLibrary.Write    ssh -t aws-3pp-int-0-app-0.aws 'tail -f -n 0 /nyx/log/ogs-core/gpapi-incoming.log | grep gpid=${GPID}'
    SSHLibrary.Set Client Configuration    timeout=60s

Resolve URL
    RequestsLibrary.Create Session    3pp    https://ogs-gl-aws-3pp-int-0.nyxaws.net/
    ${resp}=    RequestsLibrary.Get Request    3pp    /game/    params=nogsgameid=${GAMEID}&device=desktop&accountid=11111&nogsmode=real&nogscurrency=${CURRENCY}&nogsoperatorid=${OPID}&nogslang=${LANG}&lobbyurl=https://ogs-gcm-eu-dev.nyxop.net/gcm-lobby/launch.html&sessionid=${SESSIONID}    allow_redirects=True
    Set Suite Variable    ${resp}
    Log    ${resp.url}
    ${GPGAMEID_list}=    String.Get Regexp Matches    ${resp.url}    .*&gameid=([A-Za-z0-9._-]+).*    1
    ${GPGAMEID}=    Collections.Get From List    ${GPGAMEID_list}    0
    Set Suite Variable    ${GPGAMEID}

Open Browser With Game
    Selenium2Library.Open Browser    ${resp.url}    chrome
    ${log}=    SSHLibrary.Read Until Regexp    .*request=result.*currency=${CURRENCY}$
    Sleep    7s
    Set Suite Variable    ${log}

Close Browsers
    Selenium2Library.Close All Browsers

Stop Logging
    SSHLibrary.Execute Command    kill $(ps -ef | grep gpapi-incoming.log | grep -v bash | grep -v grep | awk '{print $2}')

Close Connection To Server
    SSHLibrary.Close All Connections

Suite Setup
    [Arguments]    ${SESSIONID}=495b091d-73e0-4cbf-8457-95a283910a3b
    Connect To Server
    Start Logging
    Resolve URL
    Open Browser With Game
    Close Browsers
    Stop Logging
    Close Connection To Server
    Log    ${log}

request=${Request:\w+} must contain common parameters and their appropriate values
    request=${Request} must contain apiversion parameter
    request=${Request} apiversion parameter must match value=${APIVERSION}
    request=${Request} must contain gpid parameter
    request=${Request} gpid parameter must match value=${GPID}
    request=${Request} must contain gpgameid parameter
    request=${Request} gpgameid parameter must match value=${GPGAMEID}
    request=${Request} must contain opid parameter
    request=${Request} opid parameter must match value=${OPID}
    request=${Request} must contain currency parameter
    request=${Request} currency parameter must match value=${CURRENCY}
    request=${Request} must contain sessionid parameter
    request=${Request} sessionid parameter must match value=${SESSIONID}
    request=${Request} must contain playerip parameter
    request=${Request} must contain device parameter
    request=${Request} device parameter must match value=${DEVICE}

game sends request=${Request:\w+}
    Should Contain    ${log}    request=${Request}    msg=Game did not send Request=${Request}
    ${output}=    Get Lines Containing String    ${log}    request=${Request}
    Set Test Variable    ${${Request}_log}    ${output}

game sends request=${Request:\w+} with ${Parameter}=${expected_value}
    Should Contain    ${log}    request=${Request}    msg=Doesn't contain request=${Request}
    ${output_1}=    Get Lines Containing String    ${log}    request=${Request}
    ${output}=    Get Lines Containing String    ${output_1}    ${Parameter}=${expected_value}
    Should Not Be Empty    ${output}    msg=Game did not send Request=${Request} with ${Parameter}=${expected_value}
    Set Test Variable    ${${Request}_${expected_value}_log}    ${output}

game doesn't send request=${Request:\w+} with ${Parameter}=${expected_value}
    Should Contain    ${log}    request=${Request}    msg=Doesn't contain request=${Request}
    ${output_1}=    Get Lines Containing String    ${log}    request=${Request}
    ${output}    Get Lines Containing String    ${output_1}    ${Parameter}=${expected_value}
    Should Be Empty    ${output}    msg=Game sent Request=${Request} with ${Parameter}=${expected_value}

request=${Request:\w+} must contain ${Parameter}=${expected_value}
    Should Contain    ${${Request}_log}    ${Parameter}=${expected_value}

request=${Request:\w+} with ${Parameter_1}=${expected_value_1:\w+} must contain ${Parameter_2:\w+} parameter
    Should Contain    ${${Request}_${expected_value_1}_log}    ${Parameter_2}

for request=${Request_1:\w+} and request=${Request_2:\w+} the ${Parameter:\w+} must match
    ${value_1_list}=    String.Get Regexp Matches    ${${Request_1}_log}    .*${Parameter}=([A-Za-z0-9._-]+).    1
    ${value_1}=    Collections.Get From List    ${value_1_list}    0
    ${value_2_list}=    String.Get Regexp Matches    ${${Request_2}_log}    .*${Parameter}=([A-Za-z0-9._-]+).    1
    ${value_2}=    Collections.Get From List    ${value_2_list}    0
    Run Keyword And Continue On Failure    Should Be Equal As Strings    ${value_1}    ${value_2}

for request=${Request_1:\w+} ${Parameter_1:\w+} and request=${Request_2:\w+} ${Parameter_2:\w+} the value must match
    ${value_1_list}=    String.Get Regexp Matches    ${${Request_1}_log}    .*${Parameter_1}=([A-Za-z0-9_-]+).*    1
    ${value_1}=    Collections.Get From List    ${value_1_list}    0
    ${value_2_list}=    String.Get Regexp Matches    ${${Request_2}_log}    .*${Parameter_1}=([A-Za-z0-9_-]+).*    1
    ${value_2}=    Collections.Get From List    ${value_2_list}    0
    Run Keyword And Continue On Failure    Should Be Equal As Strings    ${value_1}    ${value_2}

for request=${Request_1:\w+} and request=${Request_2:\w+} the ${Parameter:\w+} must not match
    ${value_1_list}=    String.Get Regexp Matches    ${${Request_1}_log}    .*${Parameter}=([A-Za-z0-9._-]+).*    1
    ${value_1}=    Collections.Get From List    ${value_1_list}    0
    ${value_2_list}=    String.Get Regexp Matches    ${${Request_2}_log}    .*${Parameter}=([A-Za-z0-9._-]+).*    1
    ${value_2}=    Collections.Get From List    ${value_2_list}    0
    Run Keyword And Continue On Failure    Should Not Be Equal    ${value_1}    ${value_2}

request=${Request:\w+} doesn't contain any other parameter
    Comment    ${output}    Run    echo '${${Request}_log}' |
    ${output}=    Remove String Using Regexp    ${${Request}_log}    ${sed_general}    ${sed_${Request}}
    Log    ${output}
    Run Keyword And Continue On Failure    Should Be Empty    ${output}    msg=Additional content found in the request: ${output}

request=${Request:\w+} must contain ${Parameter:\w+} parameter
    Log    ${Parameter} => ${${Request}_log}
    Run Keyword And Continue On Failure    Should Contain    ${${Request}_log}    ${Parameter}    msg=Doesn't contain parameter ${Parameter}

request=${Request:\w+} ${Parameter:\w+} parameter must match value=${expected_value:\w+}
    ${given_value_list}=    String.Get Regexp Matches    ${${Request}_log}    .*${Parameter}=([A-Za-z0-9._*-]+).*    1
    ${given_value}=    Collections.Get From List    ${given_value_list}    0
    Log    ${given_value} == ${expected_value}
    Run Keyword And Continue On Failure    Should Be Equal As Strings    ${given_value}    ${expected_value}    msg=Parameter:${Parameter} value should match

for request=${Request:\w+} with ${Parameter_1}=${expected_value_1:\w+} the ${Parameter_2:\w+} parameter must match value=${expected_value_2}
    ${given_value_list}=    String.Get Regexp Matches    ${${Request}_${expected_value_1}_log}    .*${Parameter_2}=([A-Za-z0-9._-]+).*    1
    ${given_value}=    Collections.Get From List    ${given_value_list}    0
    Log    ${given_value} == ${expected_value_2}
    Run Keyword And Continue On Failure    Should Be Equal As Strings    ${given_value}    ${expected_value_2}    msg=Parameter:${Parameter_2} value should match
    ${given_value_list}=    String.Get Regexp Matches    ${${Request}_${expected_value_1}_log}    .*${Parameter_2}=([A-Za-z0-9._-]+).*    1
    ${given_value}=    Collections.Get From List    ${given_value_list}    0

request=${Request:\w+} ${Parameter:\w+} parameter must match value from Game UI
    ${given_value_list}=    String.Get Regexp Matches    ${${Request}_log}    .*${Parameter}=([A-Za-z0-9._-]+).*    1
    ${given_value}=    Collections.Get From List    ${given_value_list}    0
    Execute Manual Step    Do ${given_value} match the win amount in the Game UI?    default_error=Win Amount from request=result doesn't match win amount from Game UI

for request=${Request:\w+} with ${Parameter_1}=${expected_value_1:\w+} the ${Parameter_2:\w+} parameter must match value from Game UI
    ${given_value_list}=    String.Get Regexp Matches    ${${Request}_${expected_value_1}_log}    .*${Parameter_2}=([A-Za-z0-9._-]+).*    1
    ${given_value}=    Collections.Get From List    ${given_value_list}    0
    Execute Manual Step    Do ${given_value} match the win amount in the Game UI?    default_error=Win Amount from request=result doesn't match win amount from Game UI

request=${Request:\w+} ${Parameter:\w+} parameter must be ${value}
    ${given_value_list}=    String.Get Regexp Matches    ${${Request}_log}    .*${Parameter}=([A-Za-z0-9._-]+).*    1
    ${given_value}=    Collections.Get From List    ${given_value_list}    0
    ${status}    Evaluate    0 <= ${given_value} <= ${value}
    Log    ${status}
    Run Keyword And Continue On Failure    Should Be True    '${status}' == 'True'
