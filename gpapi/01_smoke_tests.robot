*** Settings ***
Documentation     Test suite to check if automation of integration test cases is possible, and what cost of it will be.
Suite Setup       Suite Setup
Variables         ../resources/variables_sed.py
Resource          ../resources/imports.robot

*** Variables ***
${LANG}           en_gb
${ACCOUNTID}      testuser_ags_3pp
${BETAMOUNT}      5.00
${SESSIONID}      9cde71cf-6dd0-4e29-b22e-3736a8fbbcf3

*** Test Cases ***
Check getaccount request
    When game sends request=getaccount
    Then request=getaccount must contain common parameters and their appropriate values
    And request=getaccount must contain lang parameter
    And request=getaccount lang parameter must match value=${LANG}

Check getaccount request for non-mandatory parameters
    [Tags]    non-critical
    When game sends request=getaccount
    Then request=getaccount doesn't contain any other parameter

Check getbalance request
    When game sends request=getbalance
    Then request=getbalance must contain common parameters and their appropriate values
    And request=getbalance must contain accountid parameter
    And request=getbalance accountid parameter must match value=${ACCOUNTID}

Check getbalance request for non-mandatory parameters
    [Tags]    non-critical
    When game sends request=getbalance
    Then request=getbalance doesn't contain any other parameter

Check wager request
    When game sends request=wager
    Then request=wager must contain common parameters and their appropriate values
    And request=wager must contain accountid parameter
    And request=wager accountid parameter must match value=${ACCOUNTID}
    And request=wager must contain betamount parameter
    And request=wager betamount parameter must match value=${BETAMOUNT}
    And request=wager must contain roundid parameter
    And request=wager roundid parameter must be ${BIGINT}
    And request=wager must contain transactionid parameter
    And request=wager transactionid parameter must be ${BIGINT}

Check wager request for non-mandatory parameters
    [Tags]    non-critical
    When game sends request=wager
    Then request=wager doesn't contain any other parameter

Check result request with gamestatus=completed
    When game sends request=result
    Then request=result must contain common parameters and their appropriate values
    And request=result must contain accountid parameter
    And request=result accountid parameter must match value=${ACCOUNTID}
    And request=result must contain gamestatus parameter
    And request=result gamestatus parameter must match value=completed
    And request=result must contain roundid parameter
    And request=result roundid parameter must be ${BIGINT}
    And request=result must contain transactionid parameter
    And request=result transactionid parameter must be ${BIGINT}
    And request=result must contain wonamount parameter

Check result request for non-mandatory parameters
    [Tags]    non-critical
    When game sends request=result
    Then request=result must contain gamedetails parameter
    And request=result doesn't contain any other parameter

Check dependencies between wager and result requests
    When game sends request=wager
    And game sends request=result
    And request=wager rc parameter must be 0
    And request=result rc parameter must be 0
    Then for request=wager and request=result the roundid must match
    And for request=wager and request=result the transactionid must not match

Check dependencies between result requests with pending and completed gamestatus
    [Tags]    pending_request
    When game sends request=result with gamestatus=pending
    And game sends request=result with gamestatus=completed
    Then request=result with gamestatus=pending must contain wonamount parameter
    And request=result with gamestatus=completed must contain wonamount parameter
    And for request=result with gamestatus=pending the wonamount parameter must match value from Game UI
    And for request=result with gamestatus=completed the wonamount parameter must match value=0.00

Check wonamount for result request with completed gamestatus if there is no result request with pending gamestatus
    When game doesn't send request=result with gamestatus=pending
    And game sends request=result with gamestatus=completed
    Then request=result with gamestatus=completed must contain wonamount parameter
    And for request=result with gamestatus=completed the wonamount parameter must match value from Game UI
