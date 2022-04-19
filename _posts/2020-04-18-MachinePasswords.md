---
id: 2
title: Machine Passwords
date: 2022-04-16T01:59:36+00:00
author: Jeff Scripter
layout: post
guid: http://www.JPScripter.com/?p=2
permalink: /SECURITY/WINDOWSMACHINEPASS/
categories:
  - Security
---

## Why Try to extracting a machine password?
There were a few interesting things I discovered during this process:

1. The machine password is not as secure as I expected. 

  * Any process running as administrator can extract the password and build our a network credential. 

  * The password is made up of 128 random ASCII characters. This means it is able to be copied and pasted as a string. Contrast this to GMSA accounts that have 120 char binary passwords that can not be copied and pasted.


1. A machine account has far fewer ad permissions than I expected. It seems to not have permission to query AD for other objects or do anything other than manage itself.

1. The LSA security has some interesting quirks that make it weird to get passwords but not hard.

## What is the process for getting the password.

Lucky for you, I wrote a commandlet in powershell that can extract the password:

https://github.com/jpscripter/RunAsImpersonation/blob/main/Commands/Get-MachineCredential.ps1

However, for those more interested in the process:

1. First we have to have a admin powershell process.

1. Then we have to create a duplicate token of our existing authentication token but ensure that it has SeDebugPrivilege process property to access the lsass process. 

1. Next, we copy the system token from the lsass process and use it to impersonate system. 

1. After we have given ourselves system permissions, we can copy the target LSA Secret Registry key (HKLM:\SECURITY\Policy\Secrets\$MACHINE.ACC). This key contains the encrypted password of the machine computer AD account. 

  * We have to do the key copy for some weird behavior I do not totally understand. It just does not decrypt correctly if we try to read the secret directly from the key.

1. After the key is copied, we can proceed to accessing the lsa policy and secret. This is done by creating a few LSA structures including the name of our copied key and and a policy object. 

1. After creating the objects, we can execute the win32 API to open the policy for that key and its stored secret. The stored secret is available decrypted in memory. We just need to read it. 

1. Read the length of the secret and proceed to read the password from memory two bytes at a time. 

1. We use a stringbuilder object to construct the password.

1. Then simply use that password to create a PSCredential object. 
