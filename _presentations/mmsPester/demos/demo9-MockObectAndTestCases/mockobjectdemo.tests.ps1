. .\mockobjectdemo.ps1
#Import-Module -Name Pester -Version 4.7.2
Describe 'Mock object' {
    Context "Management Object" {
        Mock Get-WmiObject {
            New-MockObject -Type 'System.Management.ManagementObject'
        } -Verifiable -ParameterFilter { $Class -eq 'Win32_Volume' }
        It 'Should return a management object' {
            $volume = Get-WMIVolume
            Assert-MockCalled -CommandName Get-WmiObject
            $volume | Should BeOfType 'System.Management.ManagementObject'
        }

        $testCases = @( @{Name = 'PowerShell.exe' }, @{Name = 'explorer.exe' }, @{Name = 'svchost.exe' })
        It 'Process name <Name> is running.' {
            param ($Name)
            Get-WmiProcess -Name $Name | Should Not Be $null
        } -TestCases $testCases
    }
}