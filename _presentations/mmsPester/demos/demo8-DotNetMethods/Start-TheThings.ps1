[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string[]]$GroupNames
)

function Add-UserToList {
    [OutputType('System.Collections.ArrayList')]
    param(
        [Parameter(Mandatory = $true)]
        [AllowEmptyCollection()]
        [System.Collections.ArrayList]$List,

        [Parameter(Mandatory = $true)]
        [string]$User
    )
    $null = $list.Add($user)
}

Import-Module $PSScriptRoot\mmsSortedList -Force

$groupsMembers = @()
foreach ($groupName in $GroupNames) {
    $members = Get-LocalGroupMember -Group $groupName
    $groupsMembers += $members
}
#find unique user names in both groups.
$uniqueNames = ConvertTo-UniqueSortedList -Lists $groupsMembers -SortProperty Name
$arrayListOfUniqueNames = [System.Collections.ArrayList]::new()
foreach ($name in $uniqueNames) {
    $null = $arrayListOfUniqueNames.add($name)
    #Add-UserToList -List $arrayListOfUniqueNames -User $name
}

if ($uniqueNames.Count -gt 0) {
    Start-Something -InputObject $uniqueNames
}

#find duplicate user namess both groups.
$duplicateNames = ConvertTo-DuplicateSortedList -Lists $groupsMembers -SortProperty Name
$arrayListOfDuplicateNames = [System.Collections.ArrayList]::new()
foreach ($name in $duplicateNames) {
    $null = $arrayListOfDuplicateNames.add($name)
    #Add-UserToList -List $arrayListOfDuplicateNames -User $name
}
if ($duplicateNames.Count -gt 0) {
    Start-SomethingElse -InputObject $duplicateNames
}