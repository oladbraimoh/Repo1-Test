*** Settings ***
Documentation   Test suite to check if automation of integration test cases is possible, and what cost of it will be.
Resource    ../../resources/imports.robot

Suite Setup     Setup  Play a game round. When you will receive and error, then click OK.

*** Variables ***
${SESSIONID}    3f7edc9f-f5e8-4e81-865d-f18c56854457

*** Test Cases ***
Send Rollback when Wager RC=1
    When game sends request=wager
    And request=wager rc parameter must be 1
    Then game sends request=rollback
    And for request=wager and request=rollback the sessionid must match
    And for request=wager and request=rollback the accountid must match
    And for request=wager and request=rollback the roundid must match
    And for request=wager and request=rollback the transactionid must match
    And for request=wager betamount and request=rollback rollbackamount the value must match
