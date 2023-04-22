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
$ptr = $userStruc.User.Sid.ToInt64()
For ($i = $offset; $I -le $Length ; $I+=1){
    $b1 =  [System.Runtime.InteropServices.marshal]::ReadByte($ptr,$i) 
  
    Write-output  "$i = $b1"
}




$s = @"
using System;
using System.Runtime.InteropServices;
using System.Security.Principal;

namespace LinqTest
{
    public class ClsLookupAccountName
    {
        public const uint SE_GROUP_LOGON_ID = 0xC0000000; // from winnt.h
        public const int TokenGroups = 2; // from TOKEN_INFORMATION_CLASS

        enum TOKEN_INFORMATION_CLASS
        {
            TokenUser = 1,
            TokenGroups,
            TokenPrivileges,
            TokenOwner,
            TokenPrimaryGroup,
            TokenDefaultDacl,
            TokenSource,
            TokenType,
            TokenImpersonationLevel,
            TokenStatistics,
            TokenRestrictedSids,
            TokenSessionId,
            TokenGroupsAndPrivileges,
            TokenSessionReference,
            TokenSandBoxInert,
            TokenAuditPolicy,
            TokenOrigin
        }

        [StructLayout(LayoutKind.Sequential)]
        public struct SID_AND_ATTRIBUTES
        {
            public IntPtr Sid;
            public uint Attributes;
        }

        [StructLayout(LayoutKind.Sequential)]
        public struct TOKEN_GROUPS
        {
            public int GroupCount;
            [MarshalAs(UnmanagedType.ByValArray, SizeConst = 1)]
            public SID_AND_ATTRIBUTES[] Groups;
        };

        [StructLayout(LayoutKind.Sequential)]
        public struct TOKEN_USER
        {
            public int GroupCount;
            [MarshalAs(UnmanagedType.ByValArray, SizeConst = 1)]
            public SID_AND_ATTRIBUTES SID;
        };

        // Using IntPtr for pSID instead of Byte[]
        [DllImport("advapi32", CharSet = CharSet.Auto, SetLastError = true)]
        static extern bool ConvertSidToStringSid(IntPtr pSID, out IntPtr ptrSid);

        [DllImport("kernel32.dll")]
        static extern IntPtr LocalFree(IntPtr hMem);

        [DllImport("advapi32.dll", SetLastError = true)]
        static extern bool GetTokenInformation(
            IntPtr TokenHandle,
            TOKEN_INFORMATION_CLASS TokenInformationClass,
            IntPtr TokenInformation,
            int TokenInformationLength,
            out int ReturnLength);

        public static string GetLogonId(uint info)
        {
            int TokenInfLength = 0;
            // first call gets lenght of TokenInformation
            bool Result = GetTokenInformation(WindowsIdentity.GetCurrent().Token, TOKEN_INFORMATION_CLASS.TokenGroups, IntPtr.Zero, TokenInfLength, out TokenInfLength);
            IntPtr TokenInformation = Marshal.AllocHGlobal(TokenInfLength);
            Result = GetTokenInformation(WindowsIdentity.GetCurrent().Token, info, TokenInformation, TokenInfLength, out TokenInfLength);

            if (!Result)
            {
                Marshal.FreeHGlobal(TokenInformation);
                return string.Empty;
            }

            string retVal = string.Empty;
            TOKEN_GROUPS groups = (TOKEN_GROUPS)Marshal.PtrToStructure(TokenInformation, typeof(TOKEN_GROUPS));
            int sidAndAttrSize = Marshal.SizeOf(new SID_AND_ATTRIBUTES());
            for (int i = 0; i < groups.GroupCount; i++)
            {
                SID_AND_ATTRIBUTES sidAndAttributes = (SID_AND_ATTRIBUTES)Marshal.PtrToStructure(
                    new IntPtr(TokenInformation.ToInt64() + i * sidAndAttrSize + IntPtr.Size), typeof(SID_AND_ATTRIBUTES));
                if ((sidAndAttributes.Attributes & SE_GROUP_LOGON_ID) == SE_GROUP_LOGON_ID)
                {
                    IntPtr pstr = IntPtr.Zero;
                    ConvertSidToStringSid(sidAndAttributes.Sid, out pstr);
                    retVal = Marshal.PtrToStringAuto(pstr);
                    LocalFree(pstr);
                    break;
                }
            }

            Marshal.FreeHGlobal(TokenInformation);
            return retVal;

            }
      }
}
"@

$p = add-type -TypeDefinition $s -PassThru