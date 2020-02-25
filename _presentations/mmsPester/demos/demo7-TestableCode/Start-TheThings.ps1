[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string[]]$GroupNames
)

Import-Module $PSScriptRoot\mmsSortedList -Force

$groupsMembers = @()
foreach($groupName in $GroupNames) {
    $members = Get-LocalGroupMember -Group $groupName
    $groupsMembers += $members
}
#find unique user names in both groups.
$uniqueNames = ConvertTo-UniqueSortedList -Lists $groupsMembers -SortProperty Name
if($uniqueNames.Count -gt 0) {
    Start-Something -InputObject $uniqueNames
}

#find duplicate user namess both groups.
$duplicateNames = ConvertTo-DuplicateSortedList -Lists $groupsMembers -SortProperty Name
if($duplicateNames.Count -gt 0) {
    Start-SomethingElse -InputObject $duplicateNames
}