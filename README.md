# Set-HKCUGlobal
This spaghetti of a powershell function iterates over the reg hive of all users on a system and creates registry keys within the 'HKCU' hive for that user. This is based off of some script magic I've done in software deployment where I need to configure the behavior of an application through keys that only exist in that user's hive. Annoying that this needs to exist. 

Syntax: 
Works almost identically to the New-ItemProperty cmdlet that you would normally use to create a registry property. The only difference is that you need to drop the 'HKCU:\'. So 

Set-ItemProperty -Path "HKCU:\Software\Microsoft\Office\16.0\Lync" -Name "DisableRicherEditCanSetReadOnly" -Type "String" -Value 1

Becomes:
```PowerShell
Set-HKCUGlobal -Path "\Software\Microsoft\Office\16.0\Lync" -Name "DisableRicherEditCanSetReadOnly" -Type "String" -Value 1
```
New!: Now supports -Verbose switch for verbose output!
```PowerShell
Set-HKCUGlobal -Path "\Software\Microsoft\Office\16.0\Lync" -Name "DisableRicherEditCanSetReadOnly" -Type "String" -Value 1 -Verbose
```
```PowerShell
.\Set-HKUGlobal.ps1 -Verbose
VERBOSE: Calling Begin Block
VERBOSE: Trying to generate array of all system user information
VERBOSE: Successfully found user info..
VERBOSE:
VERBOSE: -----------Start Pass-----------
VERBOSE: The Current User is : Administrator
VERBOSE: The registry hive for Current User: Administrator is not loaded. Attempting to load...
VERBOSE: ....
VERBOSE: Hive loaded succesfully
VERBOSE: Creating registy settings for this user...
VERBOSE: Key Exists for this user!
VERBOSE: Trying to unload hive for current user
VERBOSE: -----------End Pass-----------
```
