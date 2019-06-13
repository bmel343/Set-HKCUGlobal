# Set-HKCUGlobal
This spaghetti of a powershell function iterates over the reg hive of all users on a system and creates registry keys within the 'HKCU' hive for that user. This is based off of some script magic I've done in software deployment where I need to configure the behavior of an application through keys that only exist in that user's hive. Annoying that this needs to exist. 

Syntax: 
Works almost identically to the New-ItemProperty cmdlet that you would normally use to create a registry property. The only difference is that you need to drop the 'HKCU:\'. So 
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Office\16.0\Lync" -Name "DisableRicherEditCanSetReadOnly" -Type "String" -Value 1
Becomes:
Set-HKCUGlobal -Path "\Software\Microsoft\Office\16.0\Lync" -Name "DisableRicherEditCanSetReadOnly" -Type "String" -Value 1

ToDo:
Fix logging (I know I shouldn't be using write-log).
