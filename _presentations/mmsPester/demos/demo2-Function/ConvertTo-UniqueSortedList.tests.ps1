. "$PSScriptRoot\ConvertTo-UniqueSortedList.ps1"
Describe "Create an unique sorted list" {
    Context -Name "Combining, sorting and returning a combined unique list" {
        It 'Should return a combined, sorted and unique list' {
            $list1 = 'a', 'b', 'c', 'd'
            $list2 = 'b', 'c', 'd', 'e'

            $uniqueSortedlist = ConvertTo-UniqueSortedList -Lists $list1, $list2 
            $uniqueSortedlist | Should Be 'a', 'b', 'c', 'd', 'e'
        }

        It 'Should return a combined, sorted and unique list when specifying SortProperty' {
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
            $expectedList = @( 'a', 'b', 'c', 'd', 'e')

            $uniqueSortedlist = ConvertTo-UniqueSortedList -Lists $list1, $list2 -SortProperty 'Name' 
            $uniqueSortedlist | Should Be $expectedList
        }
    }
}