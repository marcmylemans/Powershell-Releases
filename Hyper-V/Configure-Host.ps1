# Function to prevent Server Manager from starting automatically
Function Disable-ServerManagerStartup {
    if ((Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\ServerManager" -Name "DoNotOpenServerManagerAtLogon").DoNotOpenServerManagerAtLogon -ne 1) {
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\ServerManager" -Name "DoNotOpenServerManagerAtLogon" -Value 1
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\ServerManager" -Name "CheckedUnattendLaunchSetting" -Value 0
        Write-Host "Server Manager startup disabled."
    } else {
        Write-Host "Server Manager startup is already disabled."
    }
}

# Function to enable Remote Desktop and configure firewall
Function Enable-RDP {
    if ((Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server" -Name "fDenyTSConnections").fDenyTSConnections -ne 0) {
        Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server" -Name "fDenyTSConnections" -Value 0
        Enable-NetFirewallRule -DisplayGroup "Remote Desktop"
        Write-Host "Remote Desktop enabled."
    } else {
        Write-Host "Remote Desktop is already enabled."
    }
}

# Function to check and configure NIC settings
Function Check-And-Configure-NIC {
    $interfaces = Get-NetIPConfiguration | Where-Object { $_.IPv4DefaultGateway -ne $null }
    $interfaces | ForEach-Object { Write-Host "$($_.InterfaceAlias): $($_.IPv4Address.IPAddress) / $($_.IPv4Address.PrefixLength)" }

    $configureNIC = Read-Host "Do you want to configure a network interface? (y/n)"
    if ($configureNIC -eq 'y') {
        $selectedInterface = Read-Host "Enter the network interface name to configure"
        $useStatic = Read-Host "Do you want to use static IP? (y/n)"
        
        if ($useStatic -eq 'y') {
            $ipAddress = Read-Host "Enter the static IP address"
            $netmask = Read-Host "Enter the subnet mask"
            $gateway = Read-Host "Enter the default gateway"
            $dnsServers = Read-Host "Enter DNS servers (comma-separated)"
            
            New-NetIPAddress -InterfaceAlias $selectedInterface -IPAddress $ipAddress -PrefixLength $netmask -DefaultGateway $gateway
            Set-DnsClientServerAddress -InterfaceAlias $selectedInterface -ServerAddresses ($dnsServers -split ',')
            Write-Host "Static IP configuration applied to $selectedInterface."
        } else {
            Set-DhcpClient -InterfaceAlias $selectedInterface
            Write-Host "$selectedInterface is now set to use DHCP."
        }
    } else {
        Write-Host "No NIC configuration changes made."
    }
}

# Function to enable SNMP
Function Enable-SNMP {
    if (-not (Get-WindowsFeature -Name SNMP-Service).Installed) {
        Install-WindowsFeature SNMP-Service
        Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\SNMP\Parameters\ValidCommunities" -Name "public" -Value 4
        Set-Service -Name "SNMP" -StartupType Automatic
        Start-Service -Name "SNMP"
        Write-Host "SNMP enabled with public community string."
    } else {
        Write-Host "SNMP is already enabled."
    }
}

# Function to disable IE Enhanced Security Configuration
Function Disable-IEESC {
    Param (
        [Parameter(Position=0)]
        [ValidateSet("Admin", "User", "Both")]
        [string]$Target
    )
    
    If ($Target -eq "Admin" -or $Target -eq "Both") {
        if ((Get-ItemProperty -Path "HKLM:\Software\Microsoft\Active Setup\Installed Components\{A509B1A7-37EF-4b3f-8CFC-4F3A74704073}" -Name "IsInstalled").IsInstalled -ne 0) {
            Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A7-37EF-4b3f-8CFC-4F3A74704073}" -Name "IsInstalled" -Value 0
            Stop-Process -Name Explorer -Force
            Write-Host "IE ESC disabled for Administrators."
        } else {
            Write-Host "IE ESC is already disabled for Administrators."
        }
    }
    
    If ($Target -eq "User" -or $Target -eq "Both") {
        if ((Get-ItemProperty -Path "HKLM:\Software\Microsoft\Active Setup\Installed Components\{A509B1A8-37EF-4b3f-8CFC-4F3A74704073}" -Name "IsInstalled").IsInstalled -ne 0) {
            Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A8-37EF-4b3f-8CFC-4F3A74704073}" -Name "IsInstalled" -Value 0
            Stop-Process -Name Explorer -Force
            Write-Host "IE ESC disabled for Users."
        } else {
            Write-Host "IE ESC is already disabled for Users."
        }
    }
}

# Function to enable Hyper-V Role without Reboot
Function Enable-HyperV {
    if (-not (Get-WindowsFeature -Name Hyper-V).Installed) {
        Install-WindowsFeature -Name Hyper-V -IncludeManagementTools
        Write-Host "Hyper-V installed. Reboot required for the changes to take effect."
        exit
    } else {
        Write-Host "Hyper-V is already installed."
    }
}

# Function to enable SMB in Windows Firewall
Function Enable-SMB {
    Enable-NetFirewallRule -DisplayGroup "File and Printer Sharing"
    Write-Host "SMB enabled in Windows Firewall."
}

# Function to enable ICMP (Ping) in Windows Firewall
Function Enable-Ping {
    if (-not (Get-NetFirewallRule -Name "Allow ICMPv4-In")) {
        New-NetFirewallRule -Name "Allow ICMPv4-In" -DisplayName "Allow ICMPv4-In" -Protocol ICMPv4 -IcmpType 8 -Direction Inbound -Action Allow -Profile Any
        Write-Host "ICMP (Ping) enabled in Windows Firewall."
    } else {
        Write-Host "ICMP (Ping) is already enabled in Windows Firewall."
    }
}


# Function to set NIC Teaming using Switch Embedded Teaming (SET)
Function Set-NICTeaming {
    $teamName = Read-Host "Enter the name for the NIC Team"

    $existingSwitch = Get-VMSwitchTeam -name $teamName

    if ($existingSwitch) {
        Write-Host "A vSwitch with embedded NIC teaming named '$teamName' already exists."
        return
    }

    $netAdapters = Get-NetAdapter | Where-Object { $_.Status -eq "Up" }
    $netAdapters | ForEach-Object { Write-Host $_.Name }

    $selectedAdapters = Read-Host "Enter the network adapters for NIC Teaming (comma-separated or 'all' for all interfaces)"
    if ($selectedAdapters -eq 'all') {
        $adapters = $netAdapters | ForEach-Object { $_.Name }
    } else {
        $adapters = $selectedAdapters -split ','
    }

    New-VMSwitch -Name $teamName -NetAdapterName $adapters -EnableEmbeddedTeaming $true
    Write-Host "NIC Teaming (SET) created with team name '$teamName' using adapters: $($adapters -join ', ')"
}


# Function to set or get hostname
Function Set-Hostname {
    $currentHostname = $env:COMPUTERNAME
    Write-Host "Current Hostname: $currentHostname"
    $newHostname = Read-Host "Enter a new hostname or press Enter to keep the current hostname"
    if ($newHostname -and $newHostname -ne $currentHostname) {
        Rename-Computer -NewName $newHostname -Force
        Write-Host "Hostname changed to $newHostname. Reboot required for the changes to take effect."
        exit
    } else {
        Write-Host "Hostname remains as $currentHostname."
    }
}

# Function to ensure all network profiles are private
Function Set-NetworkProfilesToPrivate {
    Get-NetConnectionProfile | ForEach-Object {
        if ($_.NetworkCategory -ne 'Private') {
            Set-NetConnectionProfile -InterfaceAlias $_.InterfaceAlias -NetworkCategory Private
            Write-Host "Set network profile for interface '$($_.InterfaceAlias)' to Private."
        } else {
            Write-Host "Network profile for interface '$($_.InterfaceAlias)' is already Private."
        }
    }    
}

# Function to display menu and execute selected functions
Function Display-Menu {
    $menu = @"
1. Disable Server Manager Startup
2. Enable Remote Desktop
3. Set Hostname
4. Check and Configure NIC
5. Enable SNMP
6. Disable IE ESC
7. Enable Hyper-V
8. Enable SMB in Windows Firewall
9. Enable ICMP (Ping) in Windows Firewall
10. Set NIC Teaming
11. Set Network Profiles to Private
12. Run All Functions
0. Exit
"@

    Write-Host $menu
    $selection = Read-Host "Please select an option"

    Switch ($selection) {
        1 { Disable-ServerManagerStartup }
        2 { Enable-RDP }
        3 { Set-Hostname }
        4 { Check-And-Configure-NIC }
        5 { Enable-SNMP }
        6 { Disable-IEESC -Target "Both" }
        7 { Enable-HyperV }
        8 { Enable-SMB }
        9 { Enable-Ping }
        10 { Set-NICTeaming }
        11 { Set-NetworkProfilesToPrivate }
        12 {
            Disable-ServerManagerStartup
            Enable-RDP
            Set-Hostname
            Check-And-Configure-NIC
            Enable-SNMP
            Disable-IEESC -Target "Both"
            Enable-HyperV
            Enable-SMB
            Enable-Ping
            Set-NICTeaming
            Set-NetworkProfilesToPrivate
        }
        0 { exit }
        default { Write-Host "Invalid selection. Please try again." }
    }

    # Show the menu again
    Display-Menu
}

# Start the menu
Display-Menu
