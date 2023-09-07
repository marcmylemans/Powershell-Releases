<#
    .SYNOPSIS
        
    .DESCRIPTION
     This script will get the total resources from the Hyper-V Host and also the resources used by the Virtual Machines.   
    .NOTES
        Version:        
        Author:         Marc Mylemans      
        Creation Date:  23/02/2023
        Purpose/Change: get Hyper-V resources used
    .EXAMPLE
        .\Get-Hyper-V-Resources.ps1
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


$VMhost = Get-VMHost

$reportoutput=@()
$vms = Get-VM
$vms | Foreach-Object {
 
    $vm = $_
    $report = New-Object -TypeName PSObject
    $report | Add-Member -MemberType NoteProperty -Name 'Name' -Value $vm.Name
    $report | Add-Member -MemberType NoteProperty -Name 'Memory (B)' -Value $vm.MemoryAssigned
    $report | Add-Member -MemberType NoteProperty -Name 'Generation' -Value $vm.Generation
    $report | Add-Member -MemberType NoteProperty -Name 'DisplayName' -Value $vm.displayname
    $reportoutput += $report
}

# Report
$reportoutput | Export-Csv -Path c:\temp\VirtualMachineResourcesUsed.csv -NoTypeInformation -Encoding UTF8