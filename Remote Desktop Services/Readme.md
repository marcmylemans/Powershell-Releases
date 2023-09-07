# Create a Remote Desktop Environment.

This script can be used to create a Non Redundant Remote Desktop Enironment.

## Adjust the variables


```
$RD_Broker = "dc1.DOMAIN.local"
$RD_Web = "web1.DOMAIN.local"
$GatewayExternalFqdn = "rds.DOMAIN.online"
$RD_Host_Remote_App = "ts2.DOMAIN.local"
$RD_Host = "ts1.DOMAIN.local"
$RD_License = "dc1.DOMAIN.local"
$SessionCollection = "RDS Host"
$RemoteAppCollection = "RDS Remote App"
$UserGroup_Session =@("DOMAIN\grp-app-rds-host","DOMAIN\domain admins")
$UserGroup_RemoteApp =@("DOMAIN\grp-app-rds-host","DOMAIN\domain admins")
```

Run the script:

```
Create_RDS.ps1
```

Import the Certificates with Server Manager