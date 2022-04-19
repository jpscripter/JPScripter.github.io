---
id: 3
title: Powershell Debugging Basics
date: 2022-04-16T01:59:36+00:00
author: Jeff Scripter
layout: post
guid: http://www.JPScripter.com/?p=3
permalink: /POWERSHELL/DEBUGGING1
categories:
  - Powershell
---

## What is Debugging?

Code debugging is just the practice of isolating code to make it easier to find the part of your code causing issues. 

There are several techniques that can be used to make debugging easier:
1) Running code in segments
1) Logging 
1) Write targeted tests
1) Break code into smaller chunks and make cmdlets
1) The Powershell Debugger

#!markdown

## Logging and Tracing

* Start-Transcript - The easiest way to do logging

```powershell

#Transcript example

Start-Transcript -Path "$env:temp\DebugTranscript.log" -force
foreach ($i in 1..3) {
    Write-Output $i
    Write-verbose -message "Verbose $i"
    Write-Debug -Message "Debug $i"
    Write-Warning -Message "Warning $i"
    Write-Error -Message "Error $i" -erroraction Continue

    # Debug and Verbose Have to be enabled to log in transcripts
    $VerbosePreference = 'Continue'
    $DebugPreference = 'Continue'
}
Stop-Transcript
start-process -FilePath (Where.exe notepad)[0] -ArgumentList "$env:temp\DebugTranscript.log"

```

* Set-PSDebug - Great for watching what PowerShell is doing at every step.

```powershell
#Trace with Set-PSDebug

Set-PSDebug -Trace 2 
foreach ($i in 1..3) {
    $i
}
Set-PSDebug -off
```

## Why use a debugger
* It lets you interact with the code while running!
* Shows you the status of variables
* Stop at the commands, lines or Variable updates you want
* Great for troubleshooting intermittent issues 
* Lets you dive into a module context and other hard to reach contexts


## Interactive VS Logging VS Debugging

||Interactive| Setup Time| Module Debugging| 
|-|-|-|-|
|Debugging|Yes|Low|Yes|
|Interactive Session|Yes|?|No|
|Logging|No|Medium|?|
|Unit Tests|No|High|Yes| 

## Different ways to use the debugger
### ISE
* Built in and ready to go
* Hovering over variables shows value
* highlights the step

### VSCode
* Built in but needs some configuration
    1) Attach
    1) Interactive
    1) Launch
* Shows all variables
* List and edit breakpoints

### Commandline
* The most amount of control
* Useful anywhere you can be interactive

    1) Wait-Debugger
    1) Set-PSBreakpoint
    1) Debug-Job
    1) get-pscallstack

## Configuring VSCode

1) Install OmniSharp and other dependencies  
1) Create launch.json file -> Powershell -> Current File

```powershell
#Breakpoint Demo

# Script with logic bug we need to step through
Set-PSBreakpoint -Command 'Import-Module'
#Set-PSBreakpoint -Variable 'Counter'
{
    Set-Location C:\Repos\MMS\PowershellDebugging\
    Import-Module .\Module.psm1

    $Loops = 10
    $BreakPoint = 3
    
    wait-debugger
    :LoopName For ($Counter = 0; $Counter -LT $loops; $Counter++){
        # A logic error 
        If ($Counter = $BreakPoint){
            Break LoopName
        }
        "Sleeping $Counter"
        #Inspect Module
        Start-UDFSleep
    }
}.invoke()
Get-PSBreakpoint| Remove-PSBreakpoint
```

# Tips and Tricks with Debugging

1) Try Catch for finding Intermittent issues
    Try{YourCode}Catch{Wait-Debugger}

1) Conditional Triggers
    Set-PSBreakpoint -Variable counter -Action {If ($Counter -eq 1){Break}}

1) Interactive warning
    Set-PSBreakpoint -Variable 'Counter' -Action {Write-Warning -Message "Counter = $Counter"}
