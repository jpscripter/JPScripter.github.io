import-module C:\Repos\RunAsImpersonation
Set-Impersonation -Token (Get-MachineToken)

$c = Get-ConsoleUserToken
#[System.Security.Claims.Claim]::new('groupsid','S-1-5-32-544')
$a = (Get-TokenInfo).claims.where({$PSItem.value -eq 'S-1-5-32-544'})[0]

$c.AddClaim($a)
Invoke-CommandWithToken -Token $c -ShowUI

# not admin :(

$token = [System.Security.Principal.WindowsIdentity]::GetCurrent().Token
[Pinvoke.TOKEN_INFORMATION_CLASS] $TokenInformationClass = [Pinvoke.TOKEN_INFORMATION_CLASS]::TokenGroups

[int]$TokenInfoLength = 0
#always fails the first time but the length gets updated.
$null = [Pinvoke.advapi32]::GetTokenInformation($token,$TokenInformationClass,[System.IntPtr]::Zero, $TokenInfoLength, [ref] $TokenInfoLength)
if ($TokenInfoLength -ne 0){
    $InfoPointer = [System.Runtime.InteropServices.Marshal]::AllocHGlobal($TokenInfoLength)
}else{
    $Lasterr = ([System.ComponentModel.Win32Exception][System.Runtime.InteropServices.Marshal]::GetHRForLastWin32Error()).message
    Write-Error -Message "Failed Get token information size $lasterr"
}
$success = [Pinvoke.advapi32]::GetTokenInformation($token,$TokenInformationClass, $InfoPointer, $TokenInfoLength, [ref] $TokenInfoLength)
if (-not $Success){
    $Lasterr = ([System.ComponentModel.Win32Exception][System.Runtime.InteropServices.Marshal]::GetHRForLastWin32Error()).message
    Write-Error -Message "Failed to retrieve information pointer $lasterr"
}
$InfoPointer
$userStruc = [System.Runtime.InteropServices.Marshal]::PtrToStructure($InfoPointer,[type][Pinvoke.TOKEN_USER])
[IntPtr] $userSid = [IntPtr]::Zero
$Success = [Pinvoke.advapi32]::ConvertSidToStringSid($userStruc.user.Sid.ToInt64(),[ref]$userSid)
if ($userSid -eq [intptr]::Zero){
    $Lasterr = ([System.ComponentModel.Win32Exception][System.Runtime.InteropServices.Marshal]::GetHRForLastWin32Error()).message
    Write-Error -Message "Failed to format sid $lasterr"
}


$offset = 0
$length = 20
$stringBuilder = New-Object System.Text.StringBuilder -ArgumentList $Length
$ptr = $InfoPointer
For ($i = $offset; $I -le $Length ; $I+=1){
    $b1 =  [System.Runtime.InteropServices.marshal]::ReadByte($ptr,$i) 
  
    Write-output  "$i = $b1"
}