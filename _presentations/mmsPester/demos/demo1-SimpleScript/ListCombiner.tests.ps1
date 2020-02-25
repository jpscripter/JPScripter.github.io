#Install-Module -Name Pester -Scope CurrentUser -SkipPublisherCheck
#Remove-Module Pester
#Import-Module c:\source\repos\mmsPester\Pester -Force
Describe "Making a unique list" {
    Context -Name 'Get unique items from 2 static lists' {
        $sortedList = . "$PSScriptRoot\ListCombiner.ps1"
        It 'Should return the unique, combined and sorted list.' {
            $sortedList | Should Be 'a', 'b', 'c', 'd', 'e'
        }
    }
}