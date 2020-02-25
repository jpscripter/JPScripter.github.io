. "$PSScriptRoot\ConvertTo-UniqueSortedList.ps1"
Describe "Create an unique sorted list" {
    Context -Name "Combining, sorting and returning a combined unique list" {
        $list1 = 'a', 'b', 'c', 'd'
        $list2 = 'c', 'b', 'd', 'e'

        It 'Should return a combined, sorted and unique list' {
            $uniqueSortedlist = ConvertTo-UniqueSortedList -Lists $list1, $list2 
            $uniqueSortedlist | Should Be 'a', 'b', 'c', 'd', 'e'
        }

        It 'Should work if the lists are the same.' {
            $uniqueSortedList = ConvertTo-UniqueSortedList -List $list2, $list2
            $uniqueSortedList | Should Be 'b', 'c', 'd', 'e'
        }
    }
    Context -Name 'Combining and sorting using the SortProperty value' {
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
        It 'Should return a combined, sorted and unique list when specifying SortProperty' {
            $expectedList = @( 'a', 'b', 'c', 'd', 'e')
            $uniqueSortedlist = ConvertTo-UniqueSortedList -Lists $list1, $list2 -SortProperty 'Name'
            $uniqueSortedlist | Should Be $expectedList
        }

        It 'Should return a combined, sorted and unique list when specifying a different SortProperty' {
            #this is the same test as above, just showing the flexibility.
            $expectedList = @( '1', '2', '3', '4', '5')
            $uniqueSortedlist = ConvertTo-UniqueSortedList -Lists $list1, $list2 -SortProperty 'Value'
            $uniqueSortedlist | Should Be $expectedList
        }

        It 'Should return null if the SortProperty does not exist.' {
            $uniqueSortedList = ConvertTo-UniqueSortedList -Lists $list1, $list2 -SortProperty "bogus"
            $uniqueSortedList | Should Be $Null
        }
    }
}
