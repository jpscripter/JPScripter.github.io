Import-Module .\mmsThings -Force
Import-Module .\mmsSortedList -Force
Import-Module c:\source\repos\mmsPester\Pester -Force
Describe 'Working with lists' {
    Context -Name 'Local groups are populated - Using Assert-VerifiableMock' {
        #this is how everyone starts.  This is not great, avoid long mocks.
        Mock Get-LocalGroupMember -MockWith {
            param([string]$Group)
            if ($Group -eq 'group1') {
                return @(
                    @{
                        Name = 'user1';
                    },
                    @{
                        Name = 'user2';
                    }
                )
            }
            if ($Group -eq 'group2') {
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
            }
        } -Verifiable

        Mock -CommandName 'ConvertTo-UniqueSortedList' -MockWith {
            return 'a', 'b', 'c'
        } -Verifiable

        Mock -CommandName 'ConvertTo-DuplicateSortedList' -MockWith {
            return 'a', 'b', 'c'
        } -Verifiable

        Mock -CommandName 'Start-Something' -MockWith {

        } -Verifiable

        Mock -CommandName 'Start-SomethingElse' -MockWith {
            
        } -Verifiable

        It 'Should Start all the things.' {
            . .\Start-TheThings.ps1
            Assert-VerifiableMock
        }

    }

    Context -Name 'Local groups are populated - Using Assert-MockCalled' {
        Mock Get-LocalGroupMember -MockWith {
            param([string]$Group)
            if ($Group -eq 'group1') {
                return @(
                    @{
                        Name = 'user1';
                    },
                    @{
                        Name = 'user2';
                    }
                )
            }
            if ($Group -eq 'group2') {
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
            }
        } -Verifiable

        Mock -CommandName 'ConvertTo-UniqueSortedList' -MockWith {
            return 'a', 'b', 'c'
        } -Verifiable

        Mock -CommandName 'ConvertTo-DuplicateSortedList' -MockWith {
            return 'a', 'b', 'c'
        } -Verifiable

        Mock -CommandName 'Start-Something' -MockWith {

        } -Verifiable

        Mock -CommandName 'Start-SomethingElse' -MockWith {
            
        } -Verifiable
        
        It 'Should Start all the things.' {
            . .\Start-TheThings.ps1
            Assert-MockCalled -CommandName Get-LocalGroupMember -Times 2 -Exactly
            Assert-MockCalled -CommandName ConvertTo-DuplicateSortedList -Times 1 -Exactly
            Assert-MockCalled -CommandName ConvertTo-UniqueSortedList -Times 1 -Exactly
            Assert-MockCalled -CommandName Start-Something -Times 1 -Exactly
            Assert-MockCalled -CommandName Start-SomethingElse -Times 1 -Exactly
        }
    }

    Context -Name 'Both local groups are NOT populated - Using Assert-MockCalled' {
        Mock Get-LocalGroupMember -MockWith {

        } -Verifiable
        #Mocking these provide little to no value.
        #you ensure when you pass in no items you the native function will also return nothing.
        Mock -CommandName 'ConvertTo-UniqueSortedList' -MockWith {
            return @()
        } -Verifiable

        Mock -CommandName 'ConvertTo-DuplicateSortedList' -MockWith {
            return @()
        } -Verifiable
        #>
        Mock -CommandName 'Start-Something' -MockWith {

        } -Verifiable

        Mock -CommandName 'Start-SomethingElse' -MockWith {
            
        } -Verifiable

        It 'Should not start all the things.' {
            . .\Start-TheThings.ps1
            Assert-MockCalled -CommandName Get-LocalGroupMember -Times 2 -Exactly
            #Assert-MockCalled -CommandName ConvertTo-DuplicateSortedList -Times 1 -Exactly
            #Assert-MockCalled -CommandName ConvertTo-UniqueSortedList -Times 1 -Exactly
            Assert-MockCalled -CommandName Start-Something -Times 0 -Exactly
            Assert-MockCalled -CommandName Start-SomethingElse -Times 0 -Exactly
        }
    }

    Context -Name 'One local groups is NOT populated - Using Assert-MockCalled' {
        Mock Get-LocalGroupMember -MockWith { 
            param([string]$Group)
            if ($Group -eq 'group1') {
                return @(
                    @{
                        Name = 'user1';
                    },
                    @{
                        Name = 'user2';
                    }
                )
            }
            if ($Group -eq 'group2') {
                return @(
                   
                )
            }
        } -Verifiable
        
        Mock -CommandName 'Start-Something' -MockWith {

        } -Verifiable

        Mock -CommandName 'Start-SomethingElse' -MockWith {

        } -Verifiable

        It 'Should not start all the things.' {
            . .\Start-TheThings.ps1
            Assert-MockCalled -CommandName Get-LocalGroupMember -Times 2 -Exactly
            Assert-MockCalled -CommandName Start-Something -Times 1 -Exactly
            Assert-MockCalled -CommandName Start-SomethingElse -Times 0 -Exactly
        }
    }
}