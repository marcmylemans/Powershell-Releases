<#
    .SYNOPSIS
        Import User Attributes into Active Directory.
    .DESCRIPTION
        This script will import the User Attributes from a csv file to Active Directory.
    .NOTES
        Version:        0.0.1
        Author:         Marc Mylemans
        Creation Date:  30/01/2023
        Purpose/Change: Initial script development
    .EXAMPLE
        .\5_Set_AD_Attributes.ps1
#>

#-----------------------------Error Action-------------------------------

$ErrorActionPreference= 'silentlycontinue'

#-----------------------------Variables----------------------------------
$FolderName = "C:\Temp"
$Data_AD = Import-CSV "c:\temp\gebruikers_lijst.csv" -Delimiter ","

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



foreach ($User in $Data_AD) {


$UPN = $User.UserPrincipalName
$Firstname = $user.Firstname
$Lastname = $user.LastName
$office = $user.Office
$phone = $user.Phone
$mobile = $user.MobilePhone
$postalcode = $user.Postalcode
#$state = $user.State
$street = $user.Streetaddress
$title = $user.Title
$country = $user.Usagelocation
$city = $user.City
$departement = $user.Department


Write-Output Making changes: $UPN
Get-ADUser -Filter "userPrincipalName -like '*$UPN'" | Set-ADUser -Department $departement -Country $country -City $city -MobilePhone $mobile -OfficePhone $phone -Office $office -PostalCode $postalcode -StreetAddress $street -Title $title -WhatIf
}