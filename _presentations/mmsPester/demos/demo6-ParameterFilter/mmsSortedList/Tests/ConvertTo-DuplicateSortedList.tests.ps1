Import-Module ..\mmsSortedList -Force

Describe "Create an unique sorted list" {
    InModuleScope -ModuleName mmsSortedList {
        Context -Name "Combining, sorting and returning a list of duplicates" {
            $list1 = 'a', 'b', 'c', 'd'
            $list2 = 'c', 'b', 'd', 'e'
    
            It 'Should return a combined, sorted and list of only duplicates' {
                $duplicateSortedList = ConvertTo-DuplicateSortedList -Lists $list1, $list2 
                $duplicateSortedList | Should Be 'b', 'c', 'd'
            }
    
            It 'Should return a list if the lists are the same.' {
                $duplicateSortedList = ConvertTo-DuplicateSortedList -List $list2, $list2
                $duplicateSortedList | Should Be @('b', 'c', 'd', 'e')
            }
        }
        Context -Name 'Find duplicates using the SortProperty value' {
            $list1 = @(
                @{Name = 'a'; Value = '1'; },
                @{Name = 'b'; Value = '2'; },
                @{Name = 'c'; Value = '3'; }
            )
            $list2 = @(
                @{Name = 'd'; Value = '4'; },
                @{Name = 'e'; Value = '5'; },
                @{Name = 'a'; Value = '1'; }
            )
            It 'Should return a combined, sorted list of duplicates when specifying SortProperty' {
                $expectedList = @('a')
                $duplicateSortedList = ConvertTo-DuplicateSortedList -Lists $list1, $list2 -SortProperty 'Name'
                $duplicateSortedList | Should Be $expectedList
            }
    
            It 'Should return a combined, sorted list of duplicates when specifying a different SortProperty' {
                #this is the same test as above, just showing the flexibility.
                $expectedList = @( '1')
                $duplicateSortedList = ConvertTo-DuplicateSortedList -Lists $list1, $list2 -SortProperty 'Value'
                $duplicateSortedList | Should Be $expectedList
            }
    
            It 'Should return null if the SortProperty does not exist.' {
                $duplicateSortedList = ConvertTo-DuplicateSortedList -Lists $list1, $list2 -SortProperty "bogus"
                $duplicateSortedList | Should Be $null
            }
        }
    }
}
