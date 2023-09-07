# New Primary Domain/Mailbox
With these scripts you have to provide 2 csv files.
The 1st csv file you will create with the script in step 1. (Users_AD.csv)
The second csv file (Users_AD_NewUPN.csv) you can create by making a copy of the first csv file (Users_AD.csv)
In the second csv file replace all the existing proxy addresses with the new primary proxyaddress, do not include the existing proxy addreses in this file.
Example: SMTP:firstname.lastname@newdomain.com
Also include an extra collum (with excel for example) that has the header "new_emailaddress" and include the new primary mailbox.
Example: firstname.lastname@newdomain.com

## 1. Export all the information from Active Directory.
First make an export from the current setup. Dupplicate this file and keep the original export somewhere safe. You can use this file in step 3 and 4 to Revert the changes and go 100% back to the original settings.

```
1_Export_ProxyAddresses_AD.ps1
```

## 2. 
After you complete step 1 and also prepare the Users_AD_NewUPN.csv file. Make sure both files are located under "c:\temp".
The next script will 'replace' all the current proxyadresses in lowercase.
In the next phase it will 'add' the nex primary proxyaddress and change the E-mail attribute in Active directory.

```
2_NewPrimaryProxy_AD.ps1
```

Now you have some time before AD Connect will sync the changes. Rename the old Users_AD.csv to Users_AD.bak.
Run the Export_proxyAddresses_AD.ps1 script again to see if everything looks ok after the changes.

If everything looks OK then you can start a deltasync or wait for AD Connect to sync the changes.

## 3. Clear the change to restart step 2 or prepare for step 4
In case of emergency you can allways use the following script to clear everything and start over with step 2 after you make the changes needed.
```
3_ClearProxyAddresses_AD.ps1
```

## 4. Restore the original configuration / Roll back the changes.
For this you will need the original Users_AD.csv.
With this script you can restore the original settings in AD.

```
4_Restore_ProxyAddresses_AD.ps1
```

