<#
    .SYNOPSIS
        Export UPN, SamAccount, ImmutableID, DisplayName and ProxyAddresses from AD.
    .DESCRIPTION
        This script will export the UPN, SamAccount, ImmutableID, DisplayName and ProxyAddresses from AD.
        The information will be exported to a .csv file. This file can later be used to populated the information back into Active Directory.
    .NOTES
        Version:        0.0.1
        Author:         Marc Mylemans
        Creation Date:  15/05/2023
        Purpose/Change: Initial script development
    .EXAMPLE
        .\1_Export_ProxyAddresses_AD.ps1
#>

#-----------------------------Error Action-------------------------------

$ErrorActionPreference= 'silentlycontinue'

#-----------------------------Variables----------------------------------
$FolderName = "C:\Temp"
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

#CreateBackup CSV
$reportoutput=@()
$users = Get-ADUser -Filter * -SearchBase $OU -Properties *
$users | Foreach-Object {

$user = $_
$objectid = $user.ObjectGUID
$immutableid = [Convert]::ToBase64String([guid]::New($objectid).ToByteArray())

$SMTP_Addresses = $user.ProxyAddresses
$SMTP_List = $SMTP_Addresses -join ";"

$report = New-Object -TypeName PSObject
$report | Add-Member -MemberType NoteProperty -Name 'UserPrincipalName' -Value $user.UserPrincipalName
$report | Add-Member -MemberType NoteProperty -Name 'DisplayName' -Value $user.displayName
$report | Add-Member -MemberType NoteProperty -Name 'Firstname' -Value $user.givenName
$report | Add-Member -MemberType NoteProperty -Name 'LastName' -Value $user.sn
$report | Add-Member -MemberType NoteProperty -Name 'JobTitle' -Value $user.title
$report | Add-Member -MemberType NoteProperty -Name 'MobilePhone' -Value $user.mobile
$report | Add-Member -MemberType NoteProperty -Name 'Phone' -Value $user.telephoneNumber
$report | Add-Member -MemberType NoteProperty -Name 'Office' -Value $user.physicalDeliveryOfficeName
$report | Add-Member -MemberType NoteProperty -Name 'Company' -Value $user.Company
$report | Add-Member -MemberType NoteProperty -Name 'emailaddress' -Value $user.emailaddress
$report | Add-Member -MemberType NoteProperty -Name 'SamAccountName' -Value $user.samaccountname
$report | Add-Member -MemberType NoteProperty -Name 'ImmutableID' -Value $immutableid
$report | Add-Member -MemberType NoteProperty -Name 'ProxyAddresses' -Value $SMTP_List
$reportoutput += $report
}
# Report
$reportoutput | Export-Csv -Path c:\temp\Users_AD.csv -NoTypeInformation -Encoding UTF8

