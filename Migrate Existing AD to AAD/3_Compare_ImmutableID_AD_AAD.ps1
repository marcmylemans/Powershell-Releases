<#
    .SYNOPSIS
        Compare to CSV files to each other.
    .DESCRIPTION
        This script will compare to -csv's with each other.
    .NOTES
        Version:        0.0.1
        Author:         Marc Mylemans
        Creation Date:  30/01/2023
        Purpose/Change: Initial script development
    .EXAMPLE
        .\3_Compare_ImmutableID_AD_AAD.ps1
#>

#-----------------------------Error Action-------------------------------

$ErrorActionPreference= 'silentlycontinue'

#-----------------------------Variables----------------------------------
$Data_AD = Import-CSV c:\temp\Users_AD.csv -Delimiter ","
$Data_AAD = Import-CSV c:\temp\Users_AAD.csv -Delimiter ","

#-------------------------------------------------------------------------


#Echo "Not Matching UPN: (AD VS AAD)"
Compare-Object -ReferenceObject $Data_AD -DifferenceObject $Data_AAD -Property UserPrincipalName -IncludeEqual -PassThru | Where-Object {$_.SideIndicator -Notlike "=="}

#Echo "Not Matching ImmutableID's: (AD VS AAD)"
Compare-Object -ReferenceObject $Data_AD -DifferenceObject $Data_AAD -Property ImmutableID -IncludeEqual -PassThru | Where-Object {$_.SideIndicator -Notlike "=="}

#Echo "Not Matching ProxyAddresses:(AD VS AAD)"
Compare-Object -ReferenceObject $Data_AD -DifferenceObject $Data_AAD -Property ProxyAddresses -IncludeEqual -PassThru | Where-Object {$_.SideIndicator -Notlike "=="}