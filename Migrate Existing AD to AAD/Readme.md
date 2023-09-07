# Migrate Active Directory to an Existing Azure Directory

If you already have users in your Azure/Office 365 tenant and want to setup AD Connect or Cloud Sync, then you will notice that it can happen that you get duplicate users from your Active Directory environment.

To prevent this from happening you can link the existing immutableid from Active Directory to the user in Azure Directory. it is also important that every proxyaddress (alias e-mail) in Office 365 is present in Active Directory.

## 1. Export all the information from Azure.
First we will have to get an Export from Office 365 for all the information and also as a backup. The following script will create an export of all the Users in Office 365.

```
Export_ImmutableID_AAD.ps1
```

## 2. Export all the information from Active Directory.
The following script will do the same from Active Directory.

```
Export_ImmutableID_AD.ps1
```
## 3. Compare the files for changes
With the following script you can do a compare to both the file to see the differences in each file. With this you can asses what the potential impact for the customer can be.

```
Compare_ImmutableID_AD_AAD.ps1
```

## 4. Set the Immutable ID's in Azure

```
Set_ImmutableID_AAD.ps1
```

## 5. Import the proxyAddresses (and/or other information) in Active Directory 

Proxy Addresses Only
```
Set_ProxyAddresses_AD.ps1
```
Other Attributes (Export from Azure Directory)
```
Set_AD_Attributes.ps1
```

## 6. Verify!!!

Run Step 1, Step 2 and Step 3 again.
Make sure all the information is the same in Active Directory and Azure Directory.

## 7. Setup AD Connect / Cloud Sync

Setup AD Connect or Cloud Sync, do a selective sync based on a Security Group.
Check with the customer for any issues and take proactive actions or add this to the communication to the end users.

## 8. End user communication

End user communication to inform them of the changes and the possible impact on their workflow.
What steps to undertake and who to contact in case of issues.

## 9. Setup AD Connect / Cloud Sync

If everything is in place (100% match between AD and AAD) perform the full synchronisation of AD to AAD.

