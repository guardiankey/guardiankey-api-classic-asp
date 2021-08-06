# GuardianKey API reference implementation for Classic ASP

GuardianKey is a solution to protect systems against authentication attacks. More information at https://guardiankey.io/ . 

This code is a reference implementation in Classic ASP to integrate with GuardianKey.

Useful information:

- There is an example page: `example.asp`
- Let us know if you have troubles, you can open an issue or send us an e-mail (contact@guardiankey.io)

# Description of the main logic

GuardianKey's endpoint should be requested whenever an access form is submitted. In this case:

- If credentials are valid, request the GK endpoint.
    - If GuardianKey returns `BLOCK`, the system must block the access.
    - Otherwise, the system should allow it.
- If credentials are not valid, request the GK endpoint to register the failed attempt.

GuardianKey may notify the user depending on the authgroup's policy and on the attempt's risk. Check this at https://panel.guardiankey.io (Settings->Policies _and_ Settings->Auth groups->edit->tab Alerts)

# Deploying

1. Copy files below to the respective system's directory.
    - gk.class.asp
    - crypto.class.asp
    - jsonObject.class.asp
2. Make changes on the system's code regarding the login processing. Similar to code in `example.asp`.