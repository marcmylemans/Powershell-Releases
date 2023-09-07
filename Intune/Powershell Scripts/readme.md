# Intune Related PowerShell Scripts


## IntuneEnroll.ps1
Use this script to push the MDM Enrollment GPO registry values + do a GPUPDATE /FORCE.
For Domain joined devices use a Group Policy, only use this for Road warior devices. 

## DeviceEnroller.ps1
This script needs to be run with the 'System' elevation. use ".\psexec.exe -i -s powershell" or run this with N-able Scripts.
This will enforce the enrollment of the device within intune. (Speeds up the process of IntuneEnroll.ps1)