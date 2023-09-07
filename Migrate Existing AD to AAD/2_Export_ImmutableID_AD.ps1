<#
    .SYNOPSIS
        Export UPN, SamAccount, ImmutableID, and ProxyAddresses from Active Directory.
    .DESCRIPTION
        This script will export the UPN, SamAccount, ImmutableID, DisplayName and ProxyAddresses from Active Directory.
        The information will be exported to a .csv file.
    .NOTES
        Version:        0.0.1
        Author:         Marc Mylemans
        Creation Date:  30/01/2023
        Purpose/Change: Initial script development
    .EXAMPLE
        .\2_Export_ImmutableID_AD.ps1
#>

#-----------------------------Error Action-------------------------------

$ErrorActionPreference= 'silentlycontinue'

#-----------------------------Variables----------------------------------
$FolderName = "C:\Temp"

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


$reportoutput=@()
$users = Get-ADUser -Filter * -Properties *
$users | Foreach-Object {
 
    $user = $_
    $objectid = $user.ObjectGUID
    $immutableid = [Convert]::ToBase64String([guid]::New($objectid).ToByteArray())

    $SMTP_Addresses = $user.ProxyAddresses
    $SMTP_List = $SMTP_Addresses -join ";" 

    $report = New-Object -TypeName PSObject
    $report | Add-Member -MemberType NoteProperty -Name 'UserPrincipalName' -Value $user.UserPrincipalName
    $report | Add-Member -MemberType NoteProperty -Name 'SamAccountName' -Value $user.samaccountname
    $report | Add-Member -MemberType NoteProperty -Name 'ImmutableID' -Value $immutableid
    $report | Add-Member -MemberType NoteProperty -Name 'E-Mail' -Value $user.mail
    $report | Add-Member -MemberType NoteProperty -Name 'ProxyAddresses' -Value $SMTP_List
    $reportoutput += $report
}
 # Report
$reportoutput | Export-Csv -Path c:\temp\Users_AD.csv -NoTypeInformation -Encoding UTF8
