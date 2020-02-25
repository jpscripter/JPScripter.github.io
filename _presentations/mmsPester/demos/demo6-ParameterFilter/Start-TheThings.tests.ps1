Import-Module .\mmsThings -Force

Describe 'Working with lists' {
    Context -Name 'Group1 and Group2 are both populated.' {
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
            # Mock adhere to the defined parameter type, not what powershell converted it from.  PowerShell is crazy.
            #} -Verifiable -ParameterFilter {$Group -eq 'group1'; write-host $($group).GetType(); write-host ($($group)| gm)}
        } -Verifiable -ParameterFilter { $Group.Name -eq 'group2' }
        
        Mock -CommandName 'Start-Something' -MockWith {

        } -Verifiable

        Mock -CommandName 'Start-SomethingElse' -MockWith {
            
        } -Verifiable

        It 'Should Start all the things.' {
            . .\Start-TheThings.ps1
            Assert-MockCalled -CommandName Get-LocalGroupMember -Times 1 -Exactly -ParameterFilter { $Group.Name -eq 'group1' }
            Assert-MockCalled -CommandName Get-LocalGroupMember -Times 1 -Exactly -ParameterFilter { $Group.Name -eq 'group2' }
            Assert-VerifiableMock
        }

        It 'Should not Start-SomethingElse if there are no duplicates.' {
            #You would expect this to work, it does not.  This needs to be a different context.
            #Parameter filters take precendence.
            Mock Get-LocalGroupMember -MockWith {
                return @(
                    @{
                        Name = 'user1';
                    },
                    @{
                        Name = 'user2';
                    }
                )
            } -Verifiable
            #look at the debugger and verify
            . .\Start-TheThings.ps1

            Assert-MockCalled -CommandName Get-LocalGroupMember -Times 2 -Scope It
            Assert-MockCalled -CommandName Start-Something -Times 1 -Exactly -Scope It
            Assert-MockCalled -CommandName Start-SomethingElse -Times 0 -Exactly -Scope It
        } -Skip
    }

    Context -Name 'Local groups are populated but have all the same members or no members' {
        Mock Get-LocalGroupMember -MockWith {
            return @(
                @{
                    Name = 'user1';
                },
                @{
                    Name = 'user2';
                }
            )
        } -Verifiable

        Mock -CommandName 'Start-Something' -MockWith {
            
        } -Verifiable

        Mock -CommandName 'Start-SomethingElse' -MockWith {
            
        } -Verifiable
        
        It 'Should Start all the things if the groups are the same.' {
            . .\Start-TheThings.ps1
            Assert-MockCalled -CommandName Get-LocalGroupMember -Times 2 -Exactly #-Scope It
            Assert-MockCalled -CommandName Start-Something -Times 1 -Exactly #-Scope It
            Assert-MockCalled -CommandName Start-SomethingElse -Times 1 -Exactly #-Scope It
        }

        It 'Should do nothing if both groups are empty' {
            #Not using parameter filters, so this works as expected.
            Mock Get-LocalGroupMember -MockWith {
                
            } -Verifiable

            . .\Start-TheThings.ps1

            Assert-MockCalled -CommandName Get-LocalGroupMember -Times 2 -Exactly -Scope It
            Assert-MockCalled -CommandName Start-Something -Times 0 -Exactly -Scope It
            Assert-MockCalled -CommandName Start-SomethingElse -Times 0 -Exactly -Scope It
        } -Skip
    }
}