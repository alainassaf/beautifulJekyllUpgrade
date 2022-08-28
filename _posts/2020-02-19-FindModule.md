---
layout: post
title: "Finding Module/Snapin Install Location"
date: 2020-02-19
readtime: true
tags: [Modules,Snapins,Learning]
cover-img:
    - "/assets/img/FindModule/2020-02-19-FindModule.jpg" : "Pixabay"
---

<!--more-->

# Contents

* TOC
{:toc}

# Scenario
When you have serveral installed Modules and SnapIns, you may have different Modules installed in different locations. This is a simple way to determine where a Module or SnapIn is installed.

## Where’s that Snapin?

You can find the install location of a PowerShell SnapIn by getting all the properties of the Snapin.

```posh
Get-PSSnapin Citrix.Broker.Admin.V2 | select -Property *
                                                                                                         
Name                        : Citrix.Broker.Admin.V2
IsDefault                   : False
ApplicationBase             : C:\Program Files\Citrix\Broker\Snapin\v2\
AssemblyName                : BrokerSnapin, Version=7.15.3000.347, Culture=neutral, PublicKeyToken=a80ce61cfbf8b47a                                              
ModuleName                  : C:\Program Files\Citrix\Broker\Snapin\v2\\BrokerSnapin.dll
PSVersion                   : 2.0
Version                     : 7.15.3000.347
Types                       : {}
Formats                     : {}
Description                 : This PowerShell snap-in contains cmdlets used to manage the Citrix Broker.
Vendor                      : Citrix Systems, Inc.
LogPipelineExecutionDetails : False
```
The **ApplicationBase** is the working directory and the **ModuleName** points to the actual Module (in this case a dll).

## Where’s that Module?

Similarly, you grab all the properties of module to find the location:
```posh
get-module activedirectory | select -Property *

LogPipelineExecutionDetails : False
Name                        : activedirectory
Path                        : C:\WINDOWS\system32\WindowsPowerShell\v1.0\Modules\activedirectory\activedirectory
                              .psd1
ImplementingAssembly        :
Definition                  :
Description                 :
Guid                        : 43c15630-959c-49e4-a977-758c5cc93408
HelpInfoUri                 : https://go.microsoft.com/fwlink/?LinkId=390743
ModuleBase                  : C:\WINDOWS\system32\WindowsPowerShell\v1.0\Modules\activedirectory
PrivateData                 :
Tags                        : {}
ProjectUri                  :
IconUri                     :
LicenseUri                  :
ReleaseNotes                :
RepositorySourceLocation    :
Version                     : 1.0.0.0
ModuleType                  : Manifest
Author                      : Microsoft Corporation
AccessMode                  : ReadWrite
ClrVersion                  : 4.0
CompanyName                 : Microsoft Corporation
Copyright                   : © Microsoft Corporation. All rights reserved.
DotNetFrameworkVersion      :
ExportedFunctions           : {}
Prefix                      :
ExportedCmdlets             : {[Add-ADCentralAccessPolicyMember, Add-ADCentralAccessPolicyMember],
                              [Add-ADComputerServiceAccount, Add-ADComputerServiceAccount],
                              [Add-ADDomainControllerPasswordReplicationPolicy,
                              Add-ADDomainControllerPasswordReplicationPolicy],
                              [Add-ADFineGrainedPasswordPolicySubject,
                              Add-ADFineGrainedPasswordPolicySubject]...}
ExportedCommands            : {[Add-ADCentralAccessPolicyMember, Add-ADCentralAccessPolicyMember],
                              [Add-ADComputerServiceAccount, Add-ADComputerServiceAccount],
                              [Add-ADDomainControllerPasswordReplicationPolicy,
                              Add-ADDomainControllerPasswordReplicationPolicy],
                              [Add-ADFineGrainedPasswordPolicySubject,
                              Add-ADFineGrainedPasswordPolicySubject]...}
FileList                    : {}
CompatiblePSEditions        : {}
ModuleList                  : {}
NestedModules               : {Microsoft.ActiveDirectory.Management}
PowerShellHostName          :
PowerShellHostVersion       :
PowerShellVersion           : 3.0
ProcessorArchitecture       : None
Scripts                     : {}
RequiredAssemblies          : {Microsoft.ActiveDirectory.Management}
RequiredModules             : {}
RootModule                  :
ExportedVariables           : {}
ExportedAliases             : {}
ExportedWorkflows           : {}
ExportedDscResources        : {}
SessionState                : System.Management.Automation.SessionState
OnRemove                    :
ExportedFormatFiles         : {C:\WINDOWS\system32\WindowsPowerShell\v1.0\Modules\activedirectory\ActiveDirector
                              y.Format.ps1xml}
ExportedTypeFiles           : {C:\WINDOWS\system32\WindowsPowerShell\v1.0\Modules\activedirectory\ActiveDirector
                              y.Types.ps1xml}
```
In this case **ModuleBase** is the working directory and the actual module is located in the **Path**.