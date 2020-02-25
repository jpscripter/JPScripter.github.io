Import-Module .\mmsThings -Force
Import-Module .\mmsSortedList -Force

function Add-UserToList { }
Describe 'Working with lists' {
    Context -Name 'Testing Start-TheThings' {
        Mock Get-LocalGroupMember -MockWith {
            return @(
                @{
                    Name = 'user1';
                },
                @{
                    Name = 'user2';
                }
            )
        } -Verifiable -ParameterFilter { $Group.Name -eq 'group1' }

        Mock Get-LocalGroupMember -MockWith {
            return @(
                @{
                    Name = 'user1';
                },
                @{
                    Name = 'user3';
                },
                @{
                    Name = 'user4';
                }
            )
        } -Verifiable -ParameterFilter { $Group.Name -eq 'group2' }

        Mock Get-LocalGroupMember -MockWith {
            return @(
                @{
                    Name = 'user5'
                }
            )
        }  -Verifiable -ParameterFilter { $Group.Name -eq 'group3' }

        Mock Get-LocalGroupMember -MockWith {

        }  -Verifiable -ParameterFilter { $Group.Name -eq 'group4' }

        Mock -CommandName 'Start-Something' -MockWith {

        } -Verifiable

        Mock -CommandName 'Start-SomethingElse' -MockWith {

        } -Verifiable

        Mock -CommandName 'Add-UserToList' -MockWith {

        } -Verifiable

        It 'Should Start all the things.' {
            .\Start-TheThings.ps1 -GroupNames 'group1', 'group2'
            Assert-MockCalled -CommandName Get-LocalGroupMember -Times 1 -Exactly -ParameterFilter { $Group.Name -eq 'group1' } -Scope It
            Assert-MockCalled -CommandName Get-LocalGroupMember -Times 1 -Exactly -ParameterFilter { $Group.Name -eq 'group2' } -Scope It
            Assert-MockCalled -CommandName Add-UserToList -Times 5 -Exactly -Scope It
            Assert-MockCalled -CommandName Start-Something -Times 1 -Exactly -Scope It
            Assert-MockCalled -CommandName Start-SomethingElse -Times 1 -Exactly -Scope It
        }

        It 'Should Start-SomethingElse if there are only duplicates.' {
            .\Start-TheThings.ps1 -GroupNames 'group1', 'group1'
            Assert-MockCalled -CommandName Get-LocalGroupMember -Times 2 -Exactly -Scope It
            Assert-MockCalled -CommandName Start-Something -Times 1 -Exactly -Scope It
            Assert-MockCalled -CommandName Start-SomethingElse -Times 1 -Exactly -Scope It
        }
        
        It 'Should not Start-SomethignElse if there are no duplicates.' {
            .\Start-TheThings.ps1 -GroupNames 'group1', 'group3'
            Assert-MockCalled -CommandName Get-LocalGroupMember -Times 2 -Exactly -Scope It
            Assert-MockCalled -CommandName Start-Something -Times 1 -Exactly -Scope It
            Assert-MockCalled -CommandName Start-SomethingElse -Times 0 -Exactly -Scope It
        }

        It 'Should do nothing if there are no members.' {
            .\Start-TheThings.ps1 -GroupNames 'group4', 'group4'
            Assert-MockCalled -CommandName Get-LocalGroupMember -Times 2 -Exactly -Scope It
            Assert-MockCalled -CommandName Start-Something -Times 0 -Exactly -Scope It
            Assert-MockCalled -CommandName Start-SomethingElse -Times 0 -Exactly -Scope It
        }
    }
}