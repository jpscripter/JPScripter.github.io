function ConvertTo-DuplicateSortedList {
    <#
    .SYNOPSIS
    Get a sorted list of duplicate values for one or more lists.

    .DESCRIPTION
    This will return a list of duplicate values for one or more lists.
    
    .PARAMETER Lists
    A list of objects you want to sort.

    .PARAMETER SortProperty
    The property of the objects in Lists you wish to sort.  The property should be enumarable.

    .EXAMPLE
    $list1 += 'a','b','c','d'
    $list2 += 'b','c','d','e'
    $list = ConvertTo-DuplicateSortedList -Lists $list1, $list2

    .EXAMPLE
    $list1 = @(
        @{Name = 'a'; Value = '1';}, 
        @{Name = 'b'; Value = '2';},
        @{Name = 'c'; Value = '3';}
    )
    $list2 = @(
        @{Name = 'd'; Value = '4';}, 
        @{Name = 'e'; Value = '5';},
        @{Name = 'a'; Value = '1';}
    )
    $list = ConvertTo-DuplicateSortedList -List $list1, $list2 -SortProperty 'Name'

    .NOTES
    This will only return the sorted unique property values if SortProperty is specified.

    #>
    [OutputType([psobject[]])]
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        #[AllowNull()]
        [psobject[]]$Lists,

        [Parameter(Mandatory = $false)]
        [string]$SortProperty
    )
    $combinedList = @()
    foreach ($list in $lists) {
        foreach ($item in $list) {
            if (![string]::IsNullOrEmpty($SortProperty)) {
                $combinedList += $item.$SortProperty
            }
            else {
                $combinedList += $item
            }
        }
    }
    $counts = @{ }
    foreach ($item in $combinedList) {
        $counts["$item"] += 1
    }
    if ($counts) {
        $duplicates = $counts.keys | Where-Object { $counts[$psitem] -gt 1 } | Sort-Object
        if ($duplicates) {
            return $duplicates
        }
    }
}