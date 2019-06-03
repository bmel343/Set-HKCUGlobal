Function Set-HKCUGlobal {
	[CmdletBinding()]
	Param (
		[parameter( Mandatory, HelpMessage = "ScriptBlock containing your registry settings using RegPath as HKCU")]
		[ScriptBlock]$ScriptBlock
	)
	begin {
		Write-Host "Calling Begin Block"
		$ProfileList = @()
		$UnloadedHives = @()
		$PatternSID = 'S-1-5-21-\d+-\d+\-\d+\-\d+$'
		Function Write-Log {
		   Param ([string]$logstring)
		   Write-Host $logstring
		}
		Function Get-ProfileList{
			Try {
				Write-Host "Trying to generate array of all system user information"
				$ProfileList += $(Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList\*" `
					| Where-Object {$_.PSChildName -match $PatternSID} `
					| Select @{name="SID";expression={$_.PSChildName}},
							 @{name="UserHive";expression={"$($_.ProfileImagePath)\ntuser.dat"}},
							 @{name="Username";expression={$_.ProfileImagePath -replace '^(.*[\\\/])', ''}})
							 
				#Add Default User to profile list manually so that changes affect new users on this system
				$ProfileList += $([pscustomobject]@{'SID'="DefUser";'UserHive'="C:\Users\Default\NTUSER.DAT";'Username'="Default"})
			} Catch {
				Write-Host "Something went wrong while collecting system user information"
			}
			Write-Host "Successfully found user info.."
			# Get all user SIDs found in HKEY_USERS (ntuder.dat files that are loaded)
			$LoadedHives = gci Registry::HKEY_USERS | ? {$_.PSChildname -match $PatternSID} `
				| Select @{name="SID";expression={$_.PSChildName}} | % {$_.SID}
			# Get all users that are not currently logged in
			$ProfileList | % {if (-not ($LoadedHives -contains $_.SID)){$UnloadedHives += $($_ | % {$_.SID})}}
			Return $ProfileList,$UnloadedHives
		}
		Function Commit-RegistrySettings([Object] $ProfileList,[Object] $UnloadedHives){
			Write-Host "$ProfileList"
			foreach ($Profile in $ProfileList) {
				$RegPath = "Registry::\HKEY_USERS\$($Profile.SID)"
				Write-Host "-----------Start Pass-----------"
				Write-Host "The Current User is : $($Profile.Username)"
				# Load User ntuser.dat if it's not already loaded
				IF ($UnloadedHives -contains $Profile.SID) {
					Write-Host "The registry hive for Current User: $($Profile.Username) is not loaded. Attempting to load..."
					Write-Host "...."
					Try {
						reg load HKU\$($Profile.SID) $($Profile.UserHive) | Out-Null
						Write-Host "Hive loaded succesfully"
					} Catch {
						Write-Host "An unexpected error has occured while attempting to load the registry hive."
						Write-Host "No changes will be made for this user"
					}	
				}
				Write-Host "Creating registy settings for this user..."
				Try {
					Invoke-Command -ScriptBlock $ScriptBlock
				} Catch {
					Write-Host "An error was encountered while creating registry settings for the current user."
					Write-Host "$Error"
				}
				IF ($UnloadedHives -contains $Profile.SID) {
					Write-Host "Trying to unload hive for current user"
					[gc]::collect()
					reg unload HKU\$($Profile.SID)
				}
				Write-Host "-----------End Pass-----------"
			}
		}
    }
	process {
		$ProfileList,$UnloadedHives = Get-ProfileList
		Commit-RegistrySettings $ProfileList $UnloadedHives
	}
}
