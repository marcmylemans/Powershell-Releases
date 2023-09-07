<#
    .SYNOPSIS
        
    .DESCRIPTION
     This script will create new Virtual Machines based on a sysprepped template VHD.   
    .NOTES
        Version:        
        Author:         Marc Mylemans      
        Creation Date:  23/02/2023
        Purpose/Change: Create multiple Virtual Machines based on a Template.
    .EXAMPLE
        .\New-VM.ps1
#>

#-----------------------------Error Action-------------------------------

$ErrorActionPreference= 'silentlycontinue'

#-----------------------------Variables----------------------------------

$FolderName = "C:\Temp"
$SysVHDPath = "D:\Hyper-V\Virtual Hard Disks\Templates\template_server2019.vhdx"
$_Customer = Read-host('Wich Customer?')
$_VM_Role = Read-host('Give the VM a Role. Ex. DC = Domain Controller, TS = Terminal Server, DB/SQL = Database/SQL Server')
$_TotalVMS = Read-Host('Total number of this vm Ex. srv-dc-01 - srv-dc-02')
$_CPU_Cores = Read-Host('How many Cores to assign? Ex. 2, 4, 6,...')
[int64]$_RAM = 1GB*(Read-Host "How many RAM to assign? Ex. 4, 6, 8,...")
$_VlanID =  Read-Host('Wich Vlan to Assign? Ex. 002')
$VMName = "v" + $_VlanID +"-" + $_Customer +"-ADC" +"-" + $_VM_Role + $_
$VMPath = "D:\Hyper-V\Virtual Machines"
$VHDPath = "D:\Hyper-V\Virtual Hard Disks"

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



Write-Output Creating New VM:


1..$_TotalVMS | ForEach-Object {

# VM Name
$VMName          = "v" + $_VlanID +"-" + $_Customer +"-" + $_VM_Role + $_
# Automatic Start Action (Nothing = 0, Start =1, StartifRunning = 2)
$AutoStartAction = 2
# In second
$AutoStartDelay  = 30
# Automatic Start Action (TurnOff = 0, Save =1, Shutdown = 2)
$AutoStopAction  = 2


###### Hardware Configuration ######
# VM Path


# VM Generation (1 or 2)
$Gen            = 2

# Processor Number
$ProcessorCount = $_CPU_Cores

## Memory (Static = 0 or Dynamic = 1)
$Memory         = 1
# StaticMemory
$StaticMemory   = $_RAM

# DynamicMemory
$StartupMemory  = $_RAM
$MinMemory      = $_RAM
$MaxMemory      = $_RAM


# Rename the VHD copied in VM folder to:
$OsDiskName     = $VMName + "-C"

### Additional virtual drives
#$ExtraDrive  = @()
# Drive 1
#$Drive       = New-Object System.Object
#$Drive       | Add-Member -MemberType NoteProperty -Name Name -Value Data
#$Drive       | Add-Member -MemberType NoteProperty -Name Path -Value $($VHDPath + "\" + $VMName)
#$Drive       | Add-Member -MemberType NoteProperty -Name Size -Value 10GB
#$Drive       | Add-Member -MemberType NoteProperty -Name Type -Value Dynamic
#$ExtraDrive += $Drive

# Drive 2
#$Drive       = New-Object System.Object
#$Drive       | Add-Member -MemberType NoteProperty -Name Name -Value Bin
#$Drive       | Add-Member -MemberType NoteProperty -Name Path -Value $($VHDPath + "\" + $VMName)
#$Drive       | Add-Member -MemberType NoteProperty -Name Size -Value 20GB
#$Drive       | Add-Member -MemberType NoteProperty -Name Type -Value Fixed
#$ExtraDrive += $Drive
# You can copy/delete this below block as you wish to create (or not) and attach several VHDX

### Network Adapters
# Primary Network interface: VMSwitch 
$VMSwitchName = "vSwitch"
$VlanId       = $_VlanID
$VMQ          = $False
$IPSecOffload = $False
$SRIOV        = $False
$MacSpoofing  = $False
$DHCPGuard    = $False
$RouterGuard  = $False
$NicTeaming   = $False

## Additional NICs
$NICs  = @()

# NIC 1
#$NIC   = New-Object System.Object
#$NIC   | Add-Member -MemberType NoteProperty -Name VMSwitch -Value "vSwitch"
#$NIC   | Add-Member -MemberType NoteProperty -Name VLAN -Value 20
#$NIC   | Add-Member -MemberType NoteProperty -Name VMQ -Value $False
#$NIC   | Add-Member -MemberType NoteProperty -Name IPsecOffload -Value $True
#$NIC   | Add-Member -MemberType NoteProperty -Name SRIOV -Value $False
#$NIC   | Add-Member -MemberType NoteProperty -Name MacSpoofing -Value $False
#$NIC   | Add-Member -MemberType NoteProperty -Name DHCPGuard -Value $False
#$NIC   | Add-Member -MemberType NoteProperty -Name RouterGuard -Value $False
#$NIC   | Add-Member -MemberType NoteProperty -Name NICTeaming -Value $False
#$NICs += $NIC

#NIC 2
#$NIC   = New-Object System.Object
#$NIC   | Add-Member -MemberType NoteProperty -Name VMSwitch -Value "LS_VMWorkload"
#$NIC   | Add-Member -MemberType NoteProperty -Name VLAN -Value 20
#$NIC   | Add-Member -MemberType NoteProperty -Name VMQ -Value $False
#$NIC   | Add-Member -MemberType NoteProperty -Name IPsecOffload -Value $True
#$NIC   | Add-Member -MemberType NoteProperty -Name SRIOV -Value $False
#$NIC   | Add-Member -MemberType NoteProperty -Name MacSpoofing -Value $False
#$NIC   | Add-Member -MemberType NoteProperty -Name DHCPGuard -Value $False
#$NIC   | Add-Member -MemberType NoteProperty -Name RouterGuard -Value $False
#$NIC   | Add-Member -MemberType NoteProperty -Name NICTeaming -Value $False
#$NICs += $NIC
# You can copy/delete the above block and set it for additional NIC


######################################################
###           VM Creation and Configuration        ###
######################################################

## Creation of the VM
# Creation without VHD and with a default memory value (will be changed after)
New-VM -Name $VMName `
       -Path $VMPath `
       -NoVHD `
       -Generation $Gen `
       -Version 9.0 `
       -MemoryStartupBytes 1GB `
       -SwitchName $VMSwitchName


if ($AutoStartAction -eq 0){$StartAction = "Nothing"}
Elseif ($AutoStartAction -eq 1){$StartAction = "Start"}
Else{$StartAction = "StartIfRunning"}

if ($AutoStopAction -eq 0){$StopAction = "TurnOff"}
Elseif ($AutoStopAction -eq 1){$StopAction = "Save"}
Else{$StopAction = "Shutdown"}

## Changing the number of processor and the memory
# If Static Memory
if (!$Memory){
    
    Set-VM -Name $VMName `
           -ProcessorCount $ProcessorCount `
           -StaticMemory `
           -MemoryStartupBytes $StaticMemory `
           -AutomaticStartAction $StartAction `
           -AutomaticStartDelay $AutoStartDelay `
           -AutomaticStopAction $StopAction


}
# If Dynamic Memory
Else{
    Set-VM -Name $VMName `
           -ProcessorCount $ProcessorCount `
           -DynamicMemory `
           -MemoryMinimumBytes $MinMemory `
           -MemoryStartupBytes $StartupMemory `
           -MemoryMaximumBytes $MaxMemory `
           -AutomaticStartAction $StartAction `
           -AutomaticStartDelay $AutoStartDelay `
           -AutomaticStopAction $StopAction

}

## Set the primary network adapters
$PrimaryNetAdapter = Get-VM $VMName | Get-VMNetworkAdapter
if ($VlanId -gt 0){$PrimaryNetAdapter | Set-VMNetworkAdapterVLAN -Access -VlanId $VlanId}
else{$PrimaryNetAdapter | Set-VMNetworkAdapterVLAN -untagged}

if ($VMQ){$PrimaryNetAdapter | Set-VMNetworkAdapter -VmqWeight 100}
Else {$PrimaryNetAdapter | Set-VMNetworkAdapter -VmqWeight 0}

if ($IPSecOffload){$PrimaryNetAdapter | Set-VMNetworkAdapter -IPsecOffloadMaximumSecurityAssociation 512}
Else {$PrimaryNetAdapter | Set-VMNetworkAdapter -IPsecOffloadMaximumSecurityAssociation 0}

if ($SRIOV){$PrimaryNetAdapter | Set-VMNetworkAdapter -IovQueuePairsRequested 1 -IovInterruptModeration Default -IovWeight 100}
Else{$PrimaryNetAdapter | Set-VMNetworkAdapter -IovWeight 0}

if ($MacSpoofing){$PrimaryNetAdapter | Set-VMNetworkAdapter -MacAddressSpoofing on}
Else {$PrimaryNetAdapter | Set-VMNetworkAdapter -MacAddressSpoofing off}

if ($DHCPGuard){$PrimaryNetAdapter | Set-VMNetworkAdapter -DHCPGuard on}
Else {$PrimaryNetAdapter | Set-VMNetworkAdapter -DHCPGuard off}

if ($RouterGuard){$PrimaryNetAdapter | Set-VMNetworkAdapter -RouterGuard on}
Else {$PrimaryNetAdapter | Set-VMNetworkAdapter -RouterGuard off}

if ($NicTeaming){$PrimaryNetAdapter | Set-VMNetworkAdapter -AllowTeaming on}
Else {$PrimaryNetAdapter | Set-VMNetworkAdapter -AllowTeaming off}



## VHD(X) OS disk copy
$OsDiskInfo = Get-Item $SysVHDPath
Copy-Item -Path $SysVHDPath -Destination $($VHDPath)
Rename-Item -Path $($VHDPath + "\" + $OsDiskInfo.Name) -NewName $($OsDiskName + $OsDiskInfo.Extension)

# Attach the VHD(x) to the VM
Add-VMHardDiskDrive -VMName $VMName -Path $($VHDPath + "\" + $OsDiskName + $OsDiskInfo.Extension)

$OsVirtualDrive = Get-VMHardDiskDrive -VMName $VMName -ControllerNumber 0
     
# Change the boot order to the VHDX first
Set-VMFirmware -VMName $VMName -FirstBootDevice $OsVirtualDrive

# For additional each Disk in the collection
Foreach ($Disk in $ExtraDrive){
    # if it is dynamic
    if ($Disk.Type -like "Dynamic"){
        New-VHD -Path $($Disk.Path + "\" + $Disk.Name + ".vhdx") `
                -SizeBytes $Disk.Size `
                -Dynamic
    }
    # if it is fixed
    Elseif ($Disk.Type -like "Fixed"){
        New-VHD -Path $($Disk.Path + "\" + $Disk.Name + ".vhdx") `
                -SizeBytes $Disk.Size `
                -Fixed
    }

    # Attach the VHD(x) to the Vm
    Add-VMHardDiskDrive -VMName $VMName `
                        -Path $($Disk.Path + "\" + $Disk.Name + ".vhdx")
}

$i = 2
# foreach additional network adapters
Foreach ($NetAdapter in $NICs){
    # add the NIC
    Add-VMNetworkAdapter -VMName $VMName -SwitchName $NetAdapter.VMSwitch -Name "Network Adapter $i"
    
    $ExtraNic = Get-VM -Name $VMName | Get-VMNetworkAdapter -Name "Network Adapter $i" 
    # Configure the NIC regarding the option
    if ($NetAdapter.VLAN -gt 0){$ExtraNic | Set-VMNetworkAdapterVLAN -Access -VlanId $NetAdapter.VLAN}
    else{$ExtraNic | Set-VMNetworkAdapterVLAN -untagged}

    if ($NetAdapter.VMQ){$ExtraNic | Set-VMNetworkAdapter -VmqWeight 100}
    Else {$ExtraNic | Set-VMNetworkAdapter -VmqWeight 0}

    if ($NetAdapter.IPSecOffload){$ExtraNic | Set-VMNetworkAdapter -IPsecOffloadMaximumSecurityAssociation 512}
    Else {$ExtraNic | Set-VMNetworkAdapter -IPsecOffloadMaximumSecurityAssociation 0}

    if ($NetAdapter.SRIOV){$ExtraNic | Set-VMNetworkAdapter -IovQueuePairsRequested 1 -IovInterruptModeration Default -IovWeight 100}
    Else{$ExtraNic | Set-VMNetworkAdapter -IovWeight 0}

    if ($NetAdapter.MacSpoofing){$ExtraNic | Set-VMNetworkAdapter -MacAddressSpoofing on}
    Else {$ExtraNic | Set-VMNetworkAdapter -MacAddressSpoofing off}

    if ($NetAdapter.DHCPGuard){$ExtraNic | Set-VMNetworkAdapter -DHCPGuard on}
    Else {$ExtraNic | Set-VMNetworkAdapter -DHCPGuard off}

    if ($NetAdapter.RouterGuard){$ExtraNic | Set-VMNetworkAdapter -RouterGuard on}
    Else {$ExtraNic | Set-VMNetworkAdapter -RouterGuard off}

    if ($NetAdapter.NicTeaming){$ExtraNic | Set-VMNetworkAdapter -AllowTeaming on}
    Else {$ExtraNic | Set-VMNetworkAdapter -AllowTeaming off}

    $i++

    
}
#Remove # If cluster
#Add-ClusterVirtualMachineRole -VirtualMachine $VMName
Set-VMProcessor $VMName -CompatibilityForMigrationEnabled $true
Set-VMProcessor $vmname -MaximumCountPerNumaNode $_CPU_Cores
}
