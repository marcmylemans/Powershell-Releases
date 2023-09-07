<#
    .SYNOPSIS
        Add new ProxyAddresses in AD.
    .DESCRIPTION
        This script will replace all the current ProxyAddresses from AD and replace them with lowercase smtp.
        The new proxyaddres will be added as the new Primary ProxyAddres(Uppercase SMTP)..
    .NOTES
        Version:        0.0.1
        Author:         Marc Mylemans
        Creation Date:  15/05/2023
        Purpose/Change: Initial script development
    .EXAMPLE
        .\2_NewPrimaryProxy_AD.ps1
#>

#-----------------------------Error Action-------------------------------

$ErrorActionPreference= 'silentlycontinue'

#-----------------------------Variables----------------------------------
$FolderName = "C:\Temp"
$Data_AD = Import-CSV c:\temp\Users_AD.csv -Delimiter ","
$NEW_UPN = Import-CSV c:\temp\Users_AD_NewUPN.csv -Delimiter ","
$OU = ""
#-------------------------------------------------------------------------

if([System.IO.Directory]::Exists($FolderName))
{
    Write-Host "Folder Exists"
    Get-ChildItem -Path $FolderName | Where-Object {$_.CreationTime -gt (Get-Date).Date}   
}
else
{
    Write-Host "Folder Doesn't Exists"
    
    #PowerShell Create directory if not exists
    New-Item $FolderName -ItemType Directory
}

#Replace all proxyAddresses and add as an alias (lowercase smtp:)

foreach ($AD_User in $Data_AD) {
$UPN = $AD_User.Userprincipalname
$ProxyAddresses = $AD_User.Proxyaddresses
$aliasproxy = $ProxyAddresses.ToLower()
Get-ADUser -Filter "userPrincipalName -like '*$UPN'" -SearchBase $OU | Set-ADUser -replace @{ProxyAddresses=$aliasproxy -split ";"}
}

#Add the new Primary UPN (Uppercase SMTP:)

foreach ($NEW_UPN_User in $NEW_UPN) {
$UPN = $NEW_UPN_User.Userprincipalname
$ProxyAddresses = $NEW_UPN_User.Proxyaddresses
$New_emailaddress = $NEW_UPN_User.new_emailaddress
Get-ADUser -Filter "userPrincipalName -like '*$UPN'" -SearchBase $OU | Set-ADUser -EmailAddress $New_emailaddress -add @{ProxyAddresses=$ProxyAddresses -split ";"}
}





