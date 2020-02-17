*** Settings ***
Documentation   Test suite to check if automation of integration test cases is possible, and what cost of it will be.
Library           Selenium2Library
 
*** Variables ***

*** Test Cases ***
Open Browser Test Case
    Open Browser    browser=firefox  alias=newbrowser    ff_profile_dir=/home/pbudczak/.mozilla/firefox/9jcshqhc.default    url=https://ogs-gl-aws-3pp-int-0.nyxaws.net/game/?nogsgameid=70233&device=desktop&accountid=11111&nogsmode=real&nogscurrency=SEK&nogsoperatorid=5&nogslang=&lobbyurl=https://ogs-gcm-eu-dev.nyxop.net/gcm-lobby/launch.html&sessionid=495b091d-73e0-4cbf-8457-95a283910a3b
    Sleep    10s
    Press Key   \\32
    Sleep    10s
    Close Browser

*** Keywords ***

