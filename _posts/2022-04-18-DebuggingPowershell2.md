---
id: 4
title: Powershell Remote Debugging
date: 2022-04-16T01:59:36+00:00
author: Jeff Scripter
layout: post
guid: http://www.JPScripter.com/?p=4
permalink: /POWERSHELL/DEBUGGING2
categories:
  - Powershell
---

## Remote Debugging
1) Useful when troubleshooting scripts running non-interactively.
1) Can debug on remote system.
1) Can debug processes running under different accounts like system. 

### Key Commands
    1) Get-PSHostProcessInfo
    1) Enter-PSHostProcess
    1) get-Runspace
    1) Debug-Runspace


### Code for your hard to interact with script:
```powershell

# Run this on your target environment
# C:\Repos\Utilities\SysInternals\PSEXEC.exe -s -i cmd
Set-Location C:\Repos\MMS\PowershellDebugging
$FilePath = "C:\RunSpaceData.txt"
Import-Module .\Module.psm1

$RunSpaceData = @{
    Computername = $ENV:COMPUTERNAME
    PID = $PID
    RunSpace = $Host.Runspace.ID
}
Out-File -FilePath $FilePath -InputObject (Convertto-json $RunSpaceData)

#Wait

$Seconds = 300
For ($Counter = 0; $Counter -lt $Seconds; $Counter++){
    Start-UDFSleep 
}
```

### Code to connect to the remote session
```powershell
#Run from your IDE such as the ISE

# Entering The Runspace
whoami.exe
$FilePath = "C:\RunSpaceData.txt"
$Content = Get-Content -Path $FilePath -Raw
$RunSpaceData = ConvertFrom-Json -InputObject $content

If ($RunSpaceData.ComputerName -NE $ENV:COMPUTERNAME){
    $PSSession = Enter-PSSession -ComputerName $RunSpaceData.ComputerName
    Invoke-Command -ScriptBlock {Enter-PSHostProcess -ID $args} -ArgumentList $RunSpaceData.PID -Session $PSSession
    "Debug-Runspace -id $($RunSpaceData.RunSpace)"|clip
}Else{
    $RunSpaceData
    Enter-PSHostProcess -ID $RunSpaceData.PID
    #get-Runspace
    #Get-RunspaceDebug
    "Debug-Runspace -ID $($RunSpaceData.RunSpace)"|clip
}

# ? or h for help
```

## Notes
1) You have to be an admin or the same user to enter the HostProcess 
1) Holds the remote runspace up until you detach
1) Errors Easily. Be patient!
1) Integrated consoles are your friend


## Concerned?
1) You need to have admin access
1) This is hard to automate
1) Timing is super difficult
1) You can disable debugging

``` Powershell
$Host.Runspace.Debugger.SetDebugMode([System.Management.Automation.DebugModes]::None)
```