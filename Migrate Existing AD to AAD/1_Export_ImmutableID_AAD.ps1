<#
    .SYNOPSIS
        Export UPN, SamAccount, ImmutableID, DisplayName and ProxyAddresses from Azure AD.
    .DESCRIPTION
        This script will export the UPN, SamAccount, ImmutableID, DisplayName and ProxyAddresses from Azure AD.
        The information will be exported to a .csv file. This file can later be used to populated the information back into Active Directory.
    .NOTES
        Version:        0.0.1
        Author:         Marc Mylemans
        Creation Date:  30/01/2023
        Purpose/Change: Initial script development
    .EXAMPLE
        .\1_Export_ImmutableID_AAD.ps1
#>

#-----------------------------Error Action-------------------------------

$ErrorActionPreference= 'silentlycontinue'

#-----------------------------Variables----------------------------------
$FolderName = "C:\Temp"

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

#Connect to Azure AD

Connect-AzureAD


$reportoutput=@()
$users = Get-AzureADUser -All $true
$users | Foreach-Object {
 
    $user = $_
    $SMTP_Addresses = $user.ProxyAddresses
    $SMTP_List = $SMTP_Addresses -join ";"

    $report = New-Object -TypeName PSObject
    $report | Add-Member -MemberType NoteProperty -Name 'UserPrincipalName' -Value $user.UserPrincipalName
    $report | Add-Member -MemberType NoteProperty -Name 'SamAccountName' -Value $user.samaccountname
    $report | Add-Member -MemberType NoteProperty -Name 'ImmutableID' -Value $user.immutableid
    $report | Add-Member -MemberType NoteProperty -Name 'DisplayName' -Value $user.displayname
    $report | Add-Member -MemberType NoteProperty -Name 'ProxyAddresses' -Value $SMTP_List
    $reportoutput += $report
}
 # Report
$reportoutput | Export-Csv -Path c:\temp\Users_AAD.csv -NoTypeInformation -Encoding UTF8