<#
    .SYNOPSIS
        Restore the ProxyAddresses into Active Directory.
    .DESCRIPTION
        This script will import the new ProxyAddresses from a csv file to Active Directory.
    .NOTES
        Version:        0.0.1
        Author:         Marc Mylemans
        Creation Date:  30/01/2023
        Purpose/Change: Initial script development
    .EXAMPLE
        .\5_Set_ProxyAddresses_AD.ps1
#>

#-----------------------------Error Action-------------------------------

$ErrorActionPreference= 'silentlycontinue'

#-----------------------------Variables----------------------------------
$FolderName = "C:\Temp"
$Data_AD = Import-CSV c:\temp\Users_AD.csv -Delimiter ","

#-------------------------------------------------------------------------


#Check for Existing c:\Temp folder and if needed create the c:\Temp folder
$FolderName = "C:\Temp"

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



foreach ($AD_User in $Data_AD) {
$UPN = $AD_User.Userprincipalname
$ProxyAddresses = $AD_User.Proxyaddresses
$emailaddress = $AD_User.emailaddress

Get-ADUser -Filter "userPrincipalName -like '*$UPN'" | Set-ADUser -EmailAddress $emailaddress -replace @{ProxyAddresses=$ProxyAddresses -split ";"}
}