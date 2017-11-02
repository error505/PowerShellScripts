#########################################################
# This PowerShell takes all IIS Application pools and set timeout 
# Version: 1.0 
# Date: 01-Nov-2017
# Author: Igor Iric
#########################################################

Import-Module WebAdministration

$getIISPools = Get-ChildItem iis:\apppools

foreach ($IIS_Pool in $getIISPools)
{ 
$IIS_poolname = $IIS_Pool.Name

Set-ItemProperty IIS:\AppPools\$IIS_poolname -name processModel -value @{idletimeout="1"}
Set-ItemProperty IIS:\AppPools\$IIS_poolname -name processModel -value @{idletimeoutaction="Suspend"}
set-ItemProperty IIS:\AppPools\$IIS_poolname -Name Recycling.periodicRestart -Value @{time="0"} 
set-ItemProperty IIS:\AppPools\$IIS_poolname -Name Recycling.periodicRestart.schedule -Value @{value="01:00:00"} 
Set-ItemProperty IIS:\AppPools\$IIS_poolname -name Recycling -value @{logEventOnRecycle="Time, Requests, Schedule, Memory, IsapiUnhealthy, OnDemand, ConfigChange, PrivateMemory"} 

Write-Host "Updated $IIS_poolname settings" 
}