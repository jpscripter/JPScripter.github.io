[CmdletBinding()]
param(

)

Import-Module $PSScriptRoot\mmsSortedList -Force
$group1Members = Get-LocalGroupMember -Group "group1"
$group2Members = Get-LocalGroupMember -Group "group2"

#find unique user names in both groups.
$uniqueNames = ConvertTo-UniqueSortedList -Lists $group1Members, $group2Members -SortProperty Name
if($uniqueNames.Count -gt 0) {
    Start-Something -InputObject $uniqueNames
}


#find duplicate user namess both groups.
$duplicateNames = ConvertTo-DuplicateSortedList -Lists $group1Members, $group2Members -SortProperty Name
if($duplicateNames.Count -gt 0) {
    Start-SomethingElse -InputObject $duplicateNames
} 


<# setup stuff 
$pwd = ConvertTo-SecureString -String "Password123" -AsPlainText -Force
$user1 = New-LocalUser -Name "user1" -Password $pwd
$user2 = New-LocalUser -Name "user2" -Password $pwd
$user3 = New-LocalUser -Name "user3" -Password $pwd
$user4 = New-LocalUser -Name "user4" -Password $pwd

$group1 = New-LocalGroup -Name "group1"
$group2 = New-LocalGroup -Name "group2"
Add-LocalGroupMember -Group $group1.Name -Member $user1
Add-LocalGroupMember -Group $group1.Name -Member $user2
Add-LocalGroupMember -Group $group2.Name -Member $user1
Add-LocalGroupMember -Group $group2.Name -Member $user3
Add-LocalGroupMember -Group $group2.Name -Member $user4

#cleanup
$user1 = Get-LocalUser -Name "user1"
$user2 = Get-LocalUser -Name "user2"
$user3 = Get-LocalUser -Name "user3"
$user4 = Get-LocalUser -Name "user4"
Remove-LocalUser -InputObject $user1
Remove-LocalUser -InputObject $user2
Remove-LocalUser -InputObject $user3
Remove-LocalUser -InputObject $user4

$group1 = Get-LocalGroup -Name "group1"
$group2 = Get-LocalGroup -Name "group2"
Remove-LocalGroup -InputObject $group1
Remove-LocalGroup -InputObject $group2
#>

