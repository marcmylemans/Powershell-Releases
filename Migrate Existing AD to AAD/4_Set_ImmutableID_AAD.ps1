<#
    .SYNOPSIS
        Import new Immutable ID in Office 365.
    .DESCRIPTION
        This script will import the new Immutable ID's from a csv file to Office 365.
    .NOTES
        Version:        0.0.1
        Author:         Marc Mylemans
        Creation Date:  30/01/2023
        Purpose/Change: Initial script development
    .EXAMPLE
        .\4_Set_ImmutableID_AAD.ps1
#>

#-----------------------------Error Action-------------------------------

$ErrorActionPreference= 'silentlycontinue'

#-----------------------------Variables----------------------------------
$FolderName = "C:\Temp"
$Data_AD = Import-CSV c:\temp\Users_AD.csv -Delimiter ","
#-------------------------------------------------------------------------

#Check for Existing c:\Temp folder and if needed create the c:\Temp folder

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


Connect-MsolService


foreach ($User in $Data_AD) {
$UPN = $User.UserPrincipalName
$ImmutableID = $user.ImmutableId

set-msoluser -userprincipalname $UPN -ImmutableID $ImmutableID
}