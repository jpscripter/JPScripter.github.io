function Get-WMIVolume {
    Get-WmiObject -Class Win32_Volume
}

function Get-WmiProcess {
    param (
        [string]$Name
    )
    Get-WmiObject -Class Win32_Process -Filter "Name = ""$Name"""
}