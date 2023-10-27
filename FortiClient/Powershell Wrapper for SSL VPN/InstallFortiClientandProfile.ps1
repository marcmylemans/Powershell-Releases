<#
.Synopsis
Created on:   27/10/2023
Created by:   Marc Mylemans
Filename:     InstallFortiClientandProfile.ps1

Edited on:    27/10/2023
Edited by:    Marc Mylemans

Simple script to install a Forticlient VPN with Powershell. The MSI and powershell files should be in the same directory as the script if creating a Win32app

#### Win32 app Commands ####

Install:
powershell.exe -executionpolicy bypass -file .\InstallFortiClientandProfile.ps1 -parameter

#>

[CmdletBinding()]
Param (
    [Parameter(Mandatory = $True)]
    [String]$Description,
    [Parameter(Mandatory = $True)]
    [String]$Server,
    [Parameter(Mandatory = $True)]
    [String]$sso_enabled,
    [Parameter(Mandatory = $True)]
    [String]$promptusername,
    [Parameter(Mandatory = $True)]
    [String]$promptcertificate,
    [Parameter(Mandatory = $False)]
    [String]$ServerCert
)

#Reset Error catching variable
$Throwbad = $Null

#Run script in 64bit PowerShell to enumerate correct path for pnputil
If ($ENV:PROCESSOR_ARCHITEW6432 -eq "AMD64") {
    Try {
        &"$ENV:WINDIR\SysNative\WindowsPowershell\v1.0\PowerShell.exe" -File $PSCOMMANDPATH -PortName $PortName -PrinterIP $PrinterIP -DriverName $DriverName -PrinterName $PrinterName -INFFile $INFFile
    }
    Catch {
        Write-Error "Failed to start $PSCOMMANDPATH"
        Write-Warning "$($_.Exception.Message)"
        $Throwbad = $True
    }
}

function Write-LogEntry {
    param (
        [parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Value,
        [parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$FileName = "$($Description).log",
        [switch]$Stamp
    )

    #Build Log File appending System Date/Time to output
    $LogFile = Join-Path -Path $env:SystemRoot -ChildPath $("Temp\$FileName")
    $Time = -join @((Get-Date -Format "HH:mm:ss.fff"), " ", (Get-WmiObject -Class Win32_TimeZone | Select-Object -ExpandProperty Bias))
    $Date = (Get-Date -Format "MM-dd-yyyy")

    If ($Stamp) {
        $LogText = "<$($Value)> <time=""$($Time)"" date=""$($Date)"">"
    }
    else {
        $LogText = "$($Value)"   
    }
	
    Try {
        Out-File -InputObject $LogText -Append -NoClobber -Encoding Default -FilePath $LogFile -ErrorAction Stop
    }
    Catch [System.Exception] {
        Write-Warning -Message "Unable to add log entry to $LogFile.log file. Error message at line $($_.InvocationInfo.ScriptLineNumber): $($_.Exception.Message)"
    }
}

Write-LogEntry -Value "##################################"
Write-LogEntry -Stamp -Value "Installation started"
Write-LogEntry -Value "##################################"
Write-LogEntry -Value "Install Forticlient using the following values..."
Write-LogEntry -Value "Description: $Description"
Write-LogEntry -Value "Server: $Server"
Write-LogEntry -Value "SSO enabled: $sso_enabled"
Write-LogEntry -Value "Prompt Username: $promptusername"
Write-LogEntry -Value "Prompt Certificate: $promptcertificate"
Write-LogEntry -Value "ServerCert: $ServerCert"



# Install FortiClient VPN
Start-Process Msiexec.exe -Wait -ArgumentList '/i FortiClientVPN.msi REBOOT=ReallySuppress /qn'
# Install VPN Profiles
if((Test-Path -LiteralPath "HKLM:\SOFTWARE\Fortinet\FortiClient\Sslvpn\Tunnels\$Description") -ne $true) {  New-Item "HKLM:\SOFTWARE\Fortinet\FortiClient\Sslvpn\Tunnels\VPN H2O Group" -force -ea SilentlyContinue };
New-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\Fortinet\FortiClient\Sslvpn\Tunnels\$Description' -Name 'Description' -Value $Description -PropertyType String -Force -ea SilentlyContinue;
New-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\Fortinet\FortiClient\Sslvpn\Tunnels\$Description' -Name 'Server' -Value $Server -PropertyType String -Force -ea SilentlyContinue;
New-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\Fortinet\FortiClient\Sslvpn\Tunnels\$Description' -Name 'sso_enabled' -Value 1 -PropertyType DWord -Force -ea SilentlyContinue;
New-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\Fortinet\FortiClient\Sslvpn\Tunnels\$Description' -Name 'promptusername' -Value 0 -PropertyType DWord -Force -ea SilentlyContinue;
New-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\Fortinet\FortiClient\Sslvpn\Tunnels\$Description' -Name 'promptcertificate' -Value 0 -PropertyType DWord -Force -ea SilentlyContinue;
New-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\Fortinet\FortiClient\Sslvpn\Tunnels\$Description' -Name 'ServerCert' -Value '0' -PropertyType String -Force -ea SilentlyContinue;