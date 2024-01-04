function Deploy-RemoteDesktopShortcut {
    param(
        [string]$clientName,
        [string]$fullAddress,
        [string]$gatewayHostname,
        [string]$workspaceID,
        [string]$loadBalanceInfo
    )

    # Directory where the RDP file will be stored
    $targetDir = "C:\Program Files\REMOTEAPP"
    New-Item -ItemType Directory -Path $targetDir -Force

    # RDP file content
    $rdpFileContent = @"
redirectclipboard:i:1
redirectprinters:i:1
redirectcomports:i:0
redirectsmartcards:i:1
devicestoredirect:s:*
drivestoredirect:s:*
redirectdrives:i:1
session bpp:i:32
prompt for credentials on client:i:1
server port:i:3389
allow font smoothing:i:1
promptcredentialonce:i:1
videoplaybackmode:i:1
audiocapturemode:i:1
gatewayusagemethod:i:2
gatewayprofileusagemethod:i:1
gatewaycredentialssource:i:0
full address:s:$fullAddress
gatewayhostname:s:$gatewayHostname
workspace id:s:$workspaceID
use redirection server name:i:1
loadbalanceinfo:s:$loadBalanceInfo
use multimon:i:1
alternate full address:s:$fullAddress
signscope:s:Full Address,Alternate Full Address,Use Redirection Server Name,Server Port,GatewayHostname,GatewayUsageMethod,GatewayProfileUsageMethod,GatewayCredentialsSource,PromptCredentialOnce,RedirectDrives,RedirectPrinters,RedirectCOMPorts,RedirectSmartCards,RedirectClipboard,DevicesToRedirect,DrivesToRedirect,LoadBalanceInfo
"@

    # Creating the RDP file
    $rdpFilePath = "$targetDir\$clientName.rdp"
    $rdpFileContent | Out-File $rdpFilePath

    # Creating a desktop shortcut for the RDP file
    $wshShell = New-Object -comObject WScript.Shell
    $shortcut = $wshShell.CreateShortcut("C:\Users\Public\Desktop\$clientName.lnk")
    $shortcut.TargetPath = $rdpFilePath
    $shortcut.Save()
}

