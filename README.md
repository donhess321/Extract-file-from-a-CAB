# Extract-file-from-a-CAB

I needed a way to check that the downloaded wsusscn2.cab file had been recently released.  This is because the wsusscn2.cab file is sometimes released a few days later than patch Tuesday. 

This function will extract one or multiple files from a CAB file to the desired destination.  There does not seem to be a way to extract from a CAB file natively from Powershell, so I had to use the expand.exe command.  There are strict input validations to make sure that only good input is allowed to make it to the Invoke-Expression command where extraction takes place.  This was written and tested on PS v5.1 but should work on PS v2 as well.

This is a reposting from my Microsoft Technet Gallery.
