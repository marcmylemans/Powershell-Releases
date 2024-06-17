# Prevent Server Manager from starting automatically
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\ServerManager" -Name "DoNotOpenServerManagerAtLogon" -Value 1

# Enable Remote Desktop
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server" -Name "fDenyTSConnections" -Value 0
Enable-NetFirewallRule -DisplayGroup "Remote Desktop"

# Get Hostname
$hostname = $env:COMPUTERNAME
Write-Host "Hostname: $hostname"

# Check if NIC is set to DHCP or Static
$interfaces = Get-NetIPConfiguration
foreach ($interface in $interfaces) {
    if ($interface.DhcpEnabled) {
        Write-Host "Interface $($interface.InterfaceAlias) is set to DHCP"
    } else {
        Write-Host "Interface $($interface.InterfaceAlias) is set to Static IP"
    }
}

# Enable SNMP with public community string
Install-WindowsFeature SNMP-Service
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\SNMP\Parameters\ValidCommunities" -Name "public" -Value 4
Set-Service -Name "SNMP" -StartupType Automatic
Start-Service -Name "SNMP"

# Disable IE Enhanced Security Configuration for Administrators and Users
Function Disable-IEESC {
    Param (
        [Parameter(Position=0)]
        [ValidateSet("Admin", "User", "Both")]
        [string]$Target
    )
    
    If ($Target -eq "Admin" -or $Target -eq "Both") {
        Set-ItemProperty -Path "HKLM:\Software\Microsoft\Active Setup\Installed Components\{A55FFB6E-EF5E-4d8a-8055-1E4F3D91336B}" -Name "IsInstalled" -Value 0
        Stop-Process -Name Explorer
    }
    
    If ($Target -eq "User" -or $Target -eq "Both") {
        Set-ItemProperty -Path "HKLM:\Software\Microsoft\Active Setup\Installed Components\{B5B124B8-0F1E-4b56-9D78-CF4F5C4C5E6A}" -Name "IsInstalled" -Value 0
        Stop-Process -Name Explorer
    }
}

Disable-IEESC -Target "Both"

# Set NIC Teaming
Function Set-NICTeaming {
    Param (
        [Parameter(Mandatory=$true)]
        [string]$TeamName,
        [Parameter(Mandatory=$true)]
        [string[]]$Adapters
    )
    
    New-NetLbfoTeam -Name $TeamName -TeamMembers $Adapters -TeamingMode SwitchIndependent -LoadBalancingAlgorithm TransportPorts
}

# Example usage: Set-NICTeaming -TeamName "MyTeam" -Adapters "Ethernet1","Ethernet2"
# Uncomment the line below and set your actual team name and adapters
# Set-NICTeaming -TeamName "MyTeam" -Adapters "Ethernet1","Ethernet2"

# Enable Hyper-V Role without Reboot
Install-WindowsFeature -Name Hyper-V -IncludeManagementTools -NoRestart

# Enable SMB in Windows Firewall
Enable-WindowsOptionalFeature -Online -FeatureName smb1protocol
Enable-WindowsOptionalFeature -Online -FeatureName smb2protocol
Enable-NetFirewallRule -DisplayGroup "File and Printer Sharing"

# Enable ICMP (Ping) in Windows Firewall
New-NetFirewallRule -Name "Allow ICMPv4-In" -Protocol ICMPv4 -IcmpType 8 -Direction Inbound -Action Allow -Profile Any
