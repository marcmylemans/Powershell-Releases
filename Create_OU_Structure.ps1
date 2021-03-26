
<#
    .SYNOPSIS
        Create a organised OU Structure for multi client use.
    .DESCRIPTION
        This script will create a default OU structure from scratch starting with the NETBIOS name of the Active directory.
        You will have the option to enter a different top OU if desired.
        Future revisions will include the option to use a csv file.
    .NOTES
        Version:        1.0
        Author:         Marc Mylemans
        Creation Date:  26/03/2021
        Purpose/Change: Initial script development
    .EXAMPLE
        .\Create_OU_Structure.ps1

#>

#---------------------------------------------------------------------------

$DomainNetbiosName = $env:USERDOMAIN
$ADDomain = (Get-ADDomain)
$RootOUpath = ($ADDomain.DistinguishedName)
$DirectoryPath = "C:\temp"
$ADSyncedTopFolders = ("AD-Synced","Servers")
$ADSyncedFolders = ("Users","Computers","Groups")
$ServersOU = ("RDS","Web","Database","Application")
$SecurityGroupsOU = ("Departments","Printers","Shares","Applications","Computers","Servers")
#---------------------------------------------------------------------------


#Change working Directory

if(!(Test-Path -path $DirectoryPath))  
{  
 New-Item -ItemType directory -Path $DirectoryPath
 Write-Host "Folder path has been created successfully at: " $DirectoryPath    
 }
else 
{ 
Write-Host "The given folder path $DirectoryPath already exists"; 
}



#Create Top level OU with the Domain Netbios Name

NEW-ADOrganizationalUnit $DomainNetbiosName

#Create Second Level OU

#Create AD-Synced OU

foreach ($ADSyncedTopFolder in $ADSyncedTopFolders)
        {
            NEW-ADOrganizationalUnit $ADSyncedTopFolder –path ("OU=" + $DomainNetbiosName + "," + $rootOUpath)
        }

#Create AD-Synced Subfolders

foreach ($ADSyncedFolder in $ADSyncedFolders)
        {
            NEW-ADOrganizationalUnit $ADSyncedFolder –path ("OU=AD-Synced,OU=" + $DomainNetbiosName + "," + $rootOUpath)
        }

#Adjusting the Default save location according to the changes made in the OU structure.
#For this version of the script no variables are used

#Redirect Default User OU to New OU

redirusr ("OU=Users,OU=AD-Synced,OU=" + $DomainNetbiosName + "," + $rootOUpath)

#Redirect Default Computer OU to New OU

redircmp ("OU=Computers,OU=AD-Synced,OU=" + $DomainNetbiosName + "," + $rootOUpath)


NEW-ADOrganizationalUnit "Service Accounts" –path ("OU=Users,OU=AD-Synced,OU=" + $DomainNetbiosName + "," + $rootOUpath)


NEW-ADOrganizationalUnit "Kiosk" –path ("OU=Computers,OU=AD-Synced,OU=" + $DomainNetbiosName + "," + $rootOUpath)


#Create Different Servers Sub OU

foreach ($ServerOU in $ServersOU)
        {
        NEW-ADOrganizationalUnit $ServerOU –path ("OU=Servers,OU=" + $DomainNetbiosName + "," + $rootOUpath)
        }

#Create Different Groups Sub OU
#Create Top Level Groups
NEW-ADOrganizationalUnit "Security" –path ("OU=Groups,OU=AD-Synced,OU=" + $DomainNetbiosName + "," + $rootOUpath)
NEW-ADOrganizationalUnit "Distribution" –path ("OU=Groups,OU=AD-Synced,OU=" + $DomainNetbiosName + "," + $rootOUpath)

#Create Second Level Groups
foreach ($SecurityGroupOU in $SecurityGroupsOU)
        {
        NEW-ADOrganizationalUnit $SecurityGroupOU –path ("OU=Security,OU=Groups,OU=AD-Synced,OU=" + $DomainNetbiosName + "," + $rootOUpath)
        }



#Create Default Security Groups
#Departments

New-ADGroup -Name "SG_Management"  -SamAccountName "SG_Management" -GroupCategory Security -GroupScope Global -DisplayName "Management Department" -Path ("OU=Departments,OU=Security,OU=Groups,OU=AD-Synced,OU=" + $DomainNetbiosName + "," + $rootOUpath) -Description "Members of this group are in the Management Department"

New-ADGroup -Name "SG_Internal-IT" -SamAccountName "SG_Internal-IT" -GroupCategory Security -GroupScope Global -DisplayName "Internal IT Department" -Path ("OU=Departments,OU=Security,OU=Groups,OU=AD-Synced,OU=" + $DomainNetbiosName + "," + $rootOUpath) -Description "Members of this group are in the Internal IT Department"
New-ADGroup -Name "SG_HR" -SamAccountName "SG_HR" -GroupCategory Security -GroupScope Global -DisplayName "HR Department" -Path ("OU=Departments,OU=Security,OU=Groups,OU=AD-Synced,OU=" + $DomainNetbiosName + "," + $rootOUpath) -Description "Members of this group are in the HR Department"
New-ADGroup -Name "SG_Stagiair" -SamAccountName "SG_Stagiair" -GroupCategory Security -GroupScope Global -DisplayName "Stagiair Department" -Path ("OU=Departments,OU=Security,OU=Groups,OU=AD-Synced,OU=" + $DomainNetbiosName + "," + $rootOUpath) -Description "Members of this group are in the Stagiair Department"
New-ADGroup -Name "SG_Interim" -SamAccountName "SG_Interim" -GroupCategory Security -GroupScope Global -DisplayName "Interim Department" -Path ("OU=Departments,OU=Security,OU=Groups,OU=AD-Synced,OU=" + $DomainNetbiosName + "," + $rootOUpath) -Description "Members of this group are in the Interim Department"
New-ADGroup -Name "SG_Developers" -SamAccountName "SG_Developers" -GroupCategory Security -GroupScope Global -DisplayName "Developers Department" -Path ("OU=Departments,OU=Security,OU=Groups,OU=AD-Synced,OU=" + $DomainNetbiosName + "," + $rootOUpath) -Description "Members of this group are in the Developers Department"
New-ADGroup -Name "SG_Accounting" -SamAccountName "SG_Acounting" -GroupCategory Security -GroupScope Global -DisplayName "Accounting Department" -Path ("OU=Departments,OU=Security,OU=Groups,OU=AD-Synced,OU=" + $DomainNetbiosName + "," + $rootOUpath) -Description "Members of this group are in the Accounting Department"
#New-ADGroup -Name "SG_Accounting" -SamAccountName "SG_Acounting" -GroupCategory Security -GroupScope Global -DisplayName "Accounting Department" -Path ("OU=Departments,OU=Security,OU=Groups,OU=AD-Synced,OU=" + $DomainNetbiosName + "," + $rootOUpath) -Description "Members of this group are in the Accounting Department"

#Applications

New-ADGroup -Name "SG_APP_O365_e3" -SamAccountName "SG_APP_O365_e3" -GroupCategory Security -GroupScope Global -DisplayName "Office 365 E3 License" -Path ("OU=Applications,OU=Security,OU=Groups,OU=AD-Synced,OU=" + $DomainNetbiosName + "," + $rootOUpath) -Description "Members of this group have a Office 365 E3 License"
New-ADGroup -Name "SG_APP_O365_e1" -SamAccountName "SG_APP_O365_e1" -GroupCategory Security -GroupScope Global -DisplayName "Office 365 E1 License" -Path ("OU=Applications,OU=Security,OU=Groups,OU=AD-Synced,OU=" + $DomainNetbiosName + "," + $rootOUpath) -Description "Members of this group have a Office 365 E1 License"
New-ADGroup -Name "SG_APP_O365_Business" -SamAccountName "SG_APP_O365_Business" -GroupCategory Security -GroupScope Global -DisplayName "Office 365 Business Premium License" -Path ("OU=Applications,OU=Security,OU=Groups,OU=AD-Synced,OU=" + $DomainNetbiosName + "," + $rootOUpath) -Description "Members of this group have a Office 365 Business Premium License"
New-ADGroup -Name "SG_APP_RDS_Users" -SamAccountName "SG_APP_RDS_Users" -GroupCategory Security -GroupScope Global -DisplayName "RDS Host Users" -Path ("OU=Applications,OU=Security,OU=Groups,OU=AD-Synced,OU=" + $DomainNetbiosName + "," + $rootOUpath) -Description "Members of this group can use RDS sessions"

#Computer Based Security Rights

New-ADGroup -Name "SG_computers-administrator" -SamAccountName "SG_computers-administrator" -GroupCategory Security -GroupScope Global -DisplayName "Computers Local Administrator" -Path ("OU=Computers,OU=Security,OU=Groups,OU=AD-Synced,OU=" + $DomainNetbiosName + "," + $rootOUpath) -Description "Members of this group are Local Administrator on the Computers"
New-ADGroup -Name "SG_web-servers-administrator" -SamAccountName "SG_web-servers-administrator" -GroupCategory Security -GroupScope Global -DisplayName "Web Servers Local Administrator" -Path ("OU=Servers,OU=Security,OU=Groups,OU=AD-Synced,OU=" + $DomainNetbiosName + "," + $rootOUpath) -Description "Members of this group are Local Administrator on the Web Servers"
New-ADGroup -Name "SG_APP_servers-administrator" -SamAccountName "SG_APP_servers-administrator" -GroupCategory Security -GroupScope Global -DisplayName "Application Servers Local Administrator" -Path ("OU=Servers,OU=Security,OU=Groups,OU=AD-Synced,OU=" + $DomainNetbiosName + "," + $rootOUpath) -Description "Members of this group are Local Administrator on the Application Servers"
New-ADGroup -Name "SG_db-servers-administrator" -SamAccountName "SG_db-servers-administrator" -GroupCategory Security -GroupScope Global -DisplayName "Database Servers Local Administrator" -Path ("OU=Servers,OU=Security,OU=Groups,OU=AD-Synced,OU=" + $DomainNetbiosName + "," + $rootOUpath) -Description "Members of this group are Local Administrator on the Database Servers"

