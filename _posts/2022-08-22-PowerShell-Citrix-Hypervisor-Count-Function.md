---
layout: post
title: "Powershell: Citrix Hypervisor Count Function"
date: 2022-08-22
tags: [Citrix,Hypervisor,PowerShell]
readtime: true
cover-img: ["/assets/img/PowerShell-Citrix-Hypervisor-Count-Function/abacus.jpg" : "Pixabay"]
thumbnail-img: /assets/img/PowerShell-Citrix-Hypervisor-Count-Function/abacus.jpg
share-img: /assets/img/PowerShell-Citrix-Hypervisor-Count-Function/abacus.jpg
---

<!--more-->

# Contents

* TOC
{:toc}

# Scenario
I’ve been hesitant to dive into Citrix Hypervisor PowerShell cmdlets, but there’s no rational reason to not do it. Citrix continues to make great strides in expanding and updating PowerShell for its hypervisor, PVS, and XenDesktop. Today, we’ll go over a function that queries an array of Citrix Hypervisor Poolmasters and returns the total VM count on each. The idea behind this function was to stop manually counting VM’s in XenCenter and to understand VM growth and Citrix Hypervisor Pool utilization.

>NOTE: Thanks to [The Scripting Frog](http://thescriptingfrog.blogspot.com/) for getting me most of the way there with this function.

| ![](/assets/img/PowerShell-Citrix-Hypervisor-Count-Function/xenservercount.jpg "The manual count of VM’s") |
|:--:|
|<font size="2">The manual count of VM’s</font>|

# Citrix Hypervisor and PowerShell?
It may seem weird to use PowerShell to perform queries of a Linux-based system, but such is the world we live in. I remember back in my day :smile: Apple was a joke; IBM ruled the PC market and Linux didn’t exist. Of course, I still remember saving BASIC programs to a cassette deck.

| ![](/assets/img/PowerShell-Citrix-Hypervisor-Count-Function/th.png "Trash-80") |
|:--:|
|<font size="2">Trash-80</font>|

The script will prompt for credentials which can be root or any Citrix Hypervisor administrator. Then you connect to each pool master in turn…

{% gist cfdf6bb7a87d0bde3f96b436a126615f %}

The important flags are `-SetDefaultSession` and `-NoWarnNewCertificates`. You must set the default session on each new Citrix Hypervisor connection, otherwise, the script will not know what pool master to query. The `-NoWarnNewCertificates` flag prevents a prompt asking you to accept the new Citrix Hypervisor certificate (you can leave this out if you want this additional warning to let you know you’re connecting to a new Citrix Hypervisor).

Unless you can refer to your XenServers with a DNS name, you can do some quick translation to make your output more readable. I’m using a switch statement to replace the IP address with a Citrix Hypervisor name.

{% gist b8da43bb80ad6487801e38c3c47ac0d5 %}

The rest is just getting all the VM’s (minus snapshots, templates, etc.), counting them and putting the results into a custom PowerShell Object. Finally, you disconnect from each Citrix Hypervisor and go to the next one.

{% gist c72b88ba606331ce2ca72db96a7bcc4e %}

The results…

Citrix Hypervisor | VM Count
--- | ---
XenServerPool1 | 108
XenServerPool2 | 109

# Conculsion
I hope this post encourages you to leverage the PowerShell commands for Citrix Hypervisor. You can find the full function on my [GitHub](https://github.com/alainassaf/functions) page.

# Learning More
* [Citrix Hypervisor Software Development Kit Guide](https://developer-docs.citrix.com/projects/citrix-hypervisor-sdk/en/latest/getting-started/)
* [PowerShell Switch](https://docs.microsoft.com/en-us/powershell/scripting/learn/deep-dives/everything-about-switch?view=powershell-5.1)
* [PowerShell Foreach-object](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/foreach-object?view=powershell-5.1)

### Value for Value
If you received any value from reading this post, please help by becoming a [**supporter**](https://www.paypal.com/donate?hosted_button_id=73HNLGA2SGLLU).

*Thanks for Reading,*
*Alain Assaf*
