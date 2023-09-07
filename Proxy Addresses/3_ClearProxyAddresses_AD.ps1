<#
    .SYNOPSIS
        Clear all ProxyAddresses.
    .DESCRIPTION
        This script will clear all the ProxyAddresses in AD.
    .NOTES
        Version:        0.0.1
        Author:         Marc Mylemans
        Creation Date:  15/05/2023
        Purpose/Change: Initial script development
    .EXAMPLE
        .\3_ClearProxyAddresses_AD.ps1
#>

#-----------------------------Error Action-------------------------------

$ErrorActionPreference= 'silentlycontinue'

#-----------------------------Variables----------------------------------
$FolderName = "C:\Temp"
$Data_AD = Import-CSV c:\temp\Users_AD.csv -Delimiter ","
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

#Clear All UPN's

foreach ($AD_User in $Data_AD) {
$UPN = $AD_User.Userprincipalname
Get-ADUser -Filter "userPrincipalName -like '*$UPN'" -SearchBase $OU | Set-ADUser -clear ProxyAddresses
}