
<#
    .DESCRIPTION
    Assigns users to language-specific security groups based on the language portion of their preferredLanguage attribute in Active Directory.
    .NOTES
        Version:        1.0
        Author:         Marc Mylemans
        Creation Date:  25/10/2024
        Purpose/Change: Initial script development
    .EXAMPLE
        .\Update-UserLanguageGroups.ps1

#>

# Import Active Directory module
Import-Module ActiveDirectory

#-----------------------------Error Action-------------------------------

$ErrorActionPreference= 'silentlycontinue'

#-----------------------------Variables----------------------------------

$DirectoryPath = "C:\temp"
$logFile = "C:\temp\Update-UserLanguageGroups.log"

#Change working Directory
if(!(Test-Path -path $DirectoryPath))  
{  
 New-Item -ItemType directory -Path $DirectoryPath
 Log-Message "Folder path has been created successfully at: " $DirectoryPath    
 }
else 
{ 
Write-Host "The given folder path $DirectoryPath already exists"; 
}
Write-Host "Change working Directory"
Set-Location -Path $DirectoryPath

# Define the security groups corresponding to each language policy
$languageGroups = @{
    "FR" = "User Policy Language FR"
    "EN" = "User Policy Language EN"
    "NL" = "User Policy Language NL"
}

# Define the distinguished names of the security groups using -Identity
$groupDNs = @{
    "FR" = (Get-ADGroup -Identity $languageGroups["FR"]).DistinguishedName
    "EN" = (Get-ADGroup -Identity $languageGroups["EN"]).DistinguishedName
    "NL" = (Get-ADGroup -Identity $languageGroups["NL"]).DistinguishedName
}

# Function to remove user from all language groups
function Remove-FromAllLanguageGroups {
    param (
        [Parameter(Mandatory = $true)]
        [string]$UserDN
    )
    foreach ($groupDN in $groupDNs.Values) {
        Remove-ADGroupMember -Identity $groupDN -Members $UserDN -Confirm:$false
    }
}

# Get all users with the 'preferredLanguage' attribute
$users = Get-ADUser -Filter { preferredLanguage -like "*" } -Properties preferredLanguage, DistinguishedName, SamAccountName

foreach ($user in $users) {
    # Extract the language code from the preferredLanguage attribute (e.g., 'en' from 'en-US')
    $preferredLanguageFull = $user.preferredLanguage
    $preferredLanguageCode = $preferredLanguageFull.Split('-')[0].ToUpper()
    $userDN = $user.DistinguishedName
    $samAccountName = $user.SamAccountName

    if ($languageGroups.ContainsKey($preferredLanguageCode)) {
        $targetGroupDN = $groupDNs[$preferredLanguageCode]
        
        # Add user to the target group if not already a member
        if (-not (Get-ADGroupMember -Identity $targetGroupDN -Recursive | Where-Object { $_.DistinguishedName -eq $userDN })) {
            Add-ADGroupMember -Identity $targetGroupDN -Members $userDN -Confirm:$false
            Log-Message "Added $samAccountName to $($languageGroups[$preferredLanguageCode])"
        }

        # Remove user from other language groups
        foreach ($lang in $languageGroups.Keys) {
            if ($lang -ne $preferredLanguageCode) {
                $otherGroupDN = $groupDNs[$lang]
                Remove-ADGroupMember -Identity $otherGroupDN -Members $userDN -Confirm:$false
                Log-Message "Removed $samAccountName from $($languageGroups[$lang])"
            }
        }
    }
    else {
        # If preferredLanguage is not set correctly, remove from all language groups
        Remove-FromAllLanguageGroups -UserDN $userDN
        Log-Message "Removed $samAccountName from all language groups due to undefined or unsupported preferredLanguage: $preferredLanguageFull"
    }
}

# Function to log messages
function Log-Message {
    param (
        [string]$Message
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$timestamp - $Message" | Out-File -FilePath $logFile -Append
}


