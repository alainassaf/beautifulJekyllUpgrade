---
layout: post
title: "PowerShell: Launching the WEM Console"
subtitle: Open the WEM Console and connect to multiple WEM databases.
date: 2021-02-04
readtime: true
tags: [PowerShell,WEM]
cover-img:
    - "/assets/img/PowerShell-Launching the WEM Console/2021-02-04-Launching the WEM Console.jpg" : "Pixabay"
---

<!--more-->

# Contents

* TOC
{:toc}

# Scenario
**Citrix's Workspace Environment Management (WEM)** tool is my favorite Citrix product to work with. It allows for centralized management of many user-facing settings, it can reduce login times, and improve the performance of your VDA's and applications that run on them. 
You use the WEM Console to manage configuration sets that contain policies, actions, and performance settings. It connects to a WEM Server which reads and writes changes to the WEM database where the Configuration Set is stored.
Connecting to your WEM server is done by clicking *Connect* in the ribbon and typing in an Infrastructure Server name.

[![WEM Console Connection](/assets/img/wem-new-infra-service-connection.png "WEM Console Connection")](https://docs.citrix.com/en-us/workspace-environment-management/current-release/install-and-configure/admin-console.html#create-an-infrastructure-server-connection){:target="_blank"}  

If you manage different WEM environments with separate databases, you must go through this *Connection* dialog each time. I wanted to write a **PowerShell** script that would allow me to launch the console and have it already connected to the envrionment I wanted, and I also wanted a simple way to create desktop shortcuts to open multiple consoles at once.

# It's in the registry
After following a tip from a helpful person on the [**World of EUC**](https://worldofeuc.slack.com/){:target="_blank"} Slack, I found that the WEM console checks the registry for the last server it was connected to in the following key:
`HKCU:\SOFTWARE\VirtuAll Solutions\VirtuAll User Environment Manager\Administration Console\LastBrokerSvcName` and opens the Console connected to that server.
After some testing, I found that this registry key is only read when the console starts up.  All I had to do was find a simple way to verify the server before I opened the WEM Console. Enter the **Test-NetConnection** cmdlet.

# Test-NetConnection
For years I used `test-connection` which was the equivalent of the classic CMD Shell `ping` command. When I discovered `Test-NetConnection`, I never looked back. This cmdlet (introduced in PowerShell 4 and part of the [**NetTCPIP Module**](https://docs.microsoft.com/en-us/powershell/module/nettcpip/?view=win10-ps){:target="_blank"}) is more feature rich and can be used for a variety of network diagnostics. I will not delve deeply into this command as you can find a detailed post about it on the [**Adam the Automator site**](https://adamtheautomator.com/test-netconnection-powershell/){:target="_blank"}

## Test-NetConnection for Parameter validation
As I stated above, I want to validate that the WEM server I'm connecting to is available. We can use `Test-NetConnection` with the servername and get the following result:

![](/assets/img/PowerShell-Launching the WEM Console/testwemserver.gif "Test connection to WEMSERVER")

 One of the great things about `Test-NetConnection` is that it is not just for ICMP pings, you can test any TCP port. The WEM Console uses the TCP port 8284 to communicate with the WEM Server. We can test this port to ensure the WEM Server is available before we try and connect to the console.

![](/assets/img/PowerShell-Launching the WEM Console/testwemserverport.gif "Test TCP 8284 to WEMSERVER")
 
 In order to use `Test-NetConnection` for parameter validation, I need it to return a boolean value. Luckily, we can use the `-Informationlevel` parameter with the `Quiet` value and it will return a boolean result

![](/assets/img/PowerShell-Launching the WEM Console/testwemserverporttrue.gif "Boolean test tcp 8284 to WEMSERVER")

## ValidateScript Example
Here is how I used `Test-NetConnection` to validate the WEMServer was available.
```posh
param (
    [Parameter()]
    [ValidateScript( { Test-NetConnection -ComputerName $_ -Port 8284 -InformationLevel Quiet })]
    [String]$WEMServer
)
```
Now, given a `$WEMServer`, the `Test-NetConnection` cmdlet will ensure that it can communicate on TCP port 8284 and open the console, otherwise the script will end. See below in the *Learning More* section for information on using `ValidateScript` with parameters.

# The open-WemConsole.ps1 script
{% gist b9c59e5a7f5e1658b51119e4a8cf7c0c %}

# Shortcut examples
![](/assets/img/PowerShell-Launching the WEM Console/WEMenv.png "Examples of WEM shortcuts")

Using my new script, I was able to create different shortcuts that point to the WEM databases my team manages. 

![](/assets/img/PowerShell-Launching the WEM Console/WEMSCProp.png "WEM shortcut properties")

In the Target Field, I put `C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe` -Noninteractive -NoProfile -File "open-WemConsole.ps1" -WEMServer "PRODWEMSERVER"`

To connect to other WEM database, you just create another shortcut and change the `-WEMServer` parameter. Since the console only reads the registry when it first opens, it is possible to open multiple consoles at the same time, each connected to another database.

# Conclusion
Since I had mutliple WEM enviornments to manage, I was frustrated by the WEM Console interface that only allowed a connection to one database at a time. To connect to a different environment, I had to look-up a related WEM Server and type that in. Now, with my shortcuts I can connect to any number of environments and compare my configuration sets across all of them. Please leave a comment if you have any questions.

# Learning More
* [**Test-Connection**](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.management/test-connection?view=powershell-5.1){:target="_blank"}
* [**NetTCPIP**](https://docs.microsoft.com/en-us/powershell/module/nettcpip/?view=win10-ps){:target="_blank"}
* [**Test-NetConnection**](https://docs.microsoft.com/en-us/powershell/module/nettcpip/test-netconnection?view=win10-ps){:target="_blank"}
* [**Using The PowerShell Test-NetConnection Cmdlet on Windows**](https://adamtheautomator.com/test-netconnection-powershell/){:target="_blank"}
* [**Validating Parameters with PowerShell ValidateScript**](https://adamtheautomator.com/powershell-validatescript/){:target="_blank"}
* [**Citrix Product Documentation - WEM**](https://docs.citrix.com/en-us/workspace-environment-management/current-release.html){:target="_blank"}
* [**Carl Stalhood - WEM**](https://www.carlstalhood.com/workspace-environment-management){:target="_blank"}
* [**George Spiers - WEM**](https://www.jgspiers.com/citrix-workspace-environment-manager/){:target="_blank"}
* [**James Kindon - WEM**](https://jkindon.com/?s=WEM){:target="_blank"}

# Value for Value  
If you received any value from reading this post, please help by becoming a [**supporter**](https://www.paypal.com/donate?hosted_button_id=73HNLGA2SGLLU){:target="_blank"}.

*Thanks for Reading,*  
*Alain Assaf*