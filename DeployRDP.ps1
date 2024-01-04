$targetdir = "c:\program files\REMOTEAPP"
New-Item -ItemType "directory" -Path $targetdir -Force

### REMOTEAPP

$rdpFile=@"
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
full address:s:NOVA-RDS.NOVA.LOCAL
gatewayhostname:s:connect.remotedesk.be
workspace id:s:NOVA-RDS.NOVA.LOCAL
use redirection server name:i:1
loadbalanceinfo:s:tsv://MS Terminal Services Plugin.1.AXIS
use multimon:i:1
alternate full address:s:NOVA-RDS.NOVA.LOCAL
signscope:s:Full Address,Alternate Full Address,Use Redirection Server Name,Server Port,GatewayHostname,GatewayUsageMethod,GatewayProfileUsageMethod,GatewayCredentialsSource,PromptCredentialOnce,RedirectDrives,RedirectPrinters,RedirectCOMPorts,RedirectSmartCards,RedirectClipboard,DevicesToRedirect,DrivesToRedirect,LoadBalanceInfo
"@

$rdpFile | Out-File "$targetdir\RemoteApp.rdp"
$WshShell = New-Object -comObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut("c:\users\public\Desktop\RemoteApp.lnk")
$Shortcut.TargetPath = "$targetdir\RemoteApp.rdp"
$Shortcut.Save()