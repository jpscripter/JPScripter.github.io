---
id: 1
title: Impersonation Basics
date: 2022-04-16T01:59:36+00:00
author: Jeff Scripter
layout: post
guid: http://www.JPScripter.com/?p=1
permalink: /SECURITY/IMPERSONATION
categories:
  - Security
---
## What is a Impersonation?
Impersonation is a windows feature that temporarily sets an alternate Windows authentication token for a process and thread. This can let you be fluid with what credential a process is using for local or remote actions. 

## Types of tokens
### Primary
Primary tokens are used when to creation processes and are created after a logon event. 

### Impersonation
And impersonation token is used only for setting impersonation and used as alternate authentication for a process/thread. An authentication token can only be created using the DuplicateTokenEX win32 api. 

## Why use Impersonation 
Impersonation can help you get around commands that do not natively have credential options such as SQL. It can also let you use a NetOnly credential and work cross domain with far less hassle. 

# How do I get started working with tokens and Impersonation

Good news! I have a powershell module that I hope simplifies this:

https://github.com/jpscripter/RunAsImpersonation