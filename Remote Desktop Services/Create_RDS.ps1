<#
    .SYNOPSIS
        Deploy Non Redundant Remote Desktop Services
    .DESCRIPTION
        This script will provision already domain joined servers to a Remote Desktop Service Farm.
    .NOTES
        Version:        0.0.1
        Author:         Marc Mylemans
        Creation Date:  30/01/2023
        Purpose/Change: Initial script development
    .EXAMPLE
        .\Create_RDS.ps1
#>

#-----------------------------Error Action-------------------------------

$ErrorActionPreference= 'silentlycontinue'

#-----------------------------Variables----------------------------------

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

#-------------------------------------------------------------------------

#Import Module
Import-Module RemoteDesktop

#Create RDS Session
New-RDSessionDeployment -ConnectionBroker $RD_Broker `
                        -WebAccessServer $RD_Web `
                        -SessionHost $RD_Host -Verbose
#Add Licensing Server
Add-RDServer -Server $RD_License -Role RDS-LICENSING -ConnectionBroker $RD_Broker
#Set Licensing Server to PerUser Mode
Set-RDLicenseConfiguration -LicenseServer $RD_License -Mode PerUser -ConnectionBroker $RD_Broker
#Add Second RDS Server for Remote_App
Add-RDServer -Server $RD_Host_Remote_App -Role RDS-RD-SERVER -ConnectionBroker $RD_Broker

#Add RDS Collection
#Full RD Host
New-RDSessionCollection –CollectionName $SessionCollection –SessionHost $RD_Host –CollectionDescription “This Collection is for Desktop Sessions” –ConnectionBroker $RD_Broker

#Remote Apps Host
New-RDSessionCollection –CollectionName $RemoteAppCollection –SessionHost $RD_Host_Remote_App –CollectionDescription “This Collection is for RemoteApps” –ConnectionBroker $RD_Broker

#Add Remote App
#Example Wordpad
#New-RDRemoteapp -Alias Wordpad -DisplayName WordPad -FilePath "C:\Program Files\Windows NT\Accessories\wordpad.exe" -ShowInWebAccess 1 -CollectionName $RemoteAppCollection -ConnectionBroker $RD_Broker

Set-RDSessionCollectionConfiguration -CollectionName $SessionCollection -UserGroup $UserGroup_Session
Set-RDSessionCollectionConfiguration -CollectionName $RemoteAppCollection -UserGroup $UserGroup_RemoteApp


Add-RDServer -Server $RD_Web `
             -Role RDS-Gateway `
             -ConnectionBroker $RD_Broker `
             -GatewayExternalFqdn $GatewayExternalFqdn


#Create RD Gateway Split DNS
$dns_resolve = Resolve-DnsName -Name $RD_Web -DnsOnly
Add-DnsServerPrimaryZone -Name $GatewayExternalFqdn -ReplicationScope "Forest" -PassThru
Add-DnsServerResourceRecordA -Name "@" -ZoneName $GatewayExternalFqdn -AllowUpdateAny -IPv4Address $dns_resolve.IPAddress -TimeToLive 01:00:00
