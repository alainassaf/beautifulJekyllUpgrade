---
layout: post
title: "PowerShell Piping"
date: 2020-02-17
readtime: true
tags: [Piping,ActiveDirectory,Citrix,Learning]
cover-img: 
    - "/assets/img/PowerShell-Piping/2020-02-17-PowerShell-Piping.jpg" : "Pixabay"
---


Piping allows you to select objects and perform multiple actions on those objects all on one line. You use the **Pipeline** Symbol (**\|**) to send the results of one cmdlet to the next one. Let's walk through a scenario using Pipelines.

# Contents

* TOC
{:toc}

# Scenario
I want to get user details for the users who are in an AD group that grants access to a Citrix application.

First, here's the Pipeline we're going to use:

```posh
Get-ADGroupMember 'Citrix-ADGrp-Notepad' | Select-Object samaccountname | ForEach-Object {Get-ADUser $_.samaccountname -Properties *} | Select-Object Givenname,surname,userprincipalname,description | Format-Table -auto | Out-File -FilePath c:\temp\users.txt
```

# Example break down
```posh
Get-ADGroupMember 'Citrix-ADGrp-Notepad'
```
This uses the *activedirectory* PowerShell module - **Get-ADGroupMember** and queries the AD group *Citrix-ADGrp-Notepad* for the members of this group.
```posh
distinguishedName : CN=JLennon,OU=Users,DC=PowerEUCShell,DC=local
name              : JLennon
objectClass       : user
objectGUID        : 61f003c8-1170-4f29-82fd-f23a87090e2e
SamAccountName    : JLennon
SID               : S-1-5-21-61f003c8-1170-4f29-82fd-f23a87090e2e

distinguishedName : CN=PMcCartney,OU=Users,DC=PowerEUCShell,DC=local
name              : PMcCartney
objectClass       : user
objectGUID        : 3c81807a-d2da-4603-98e2-6a6acafa5ba8
SamAccountName    : PMcCartney
SID               : S-1-5-21-3c81807a-d2da-4603-98e2-6a6acafa5ba8
.
.
.
distinguishedName : CN=GHarrison,OU=Users,DC=PowerEUCShell,DC=local
name              : GHarrison
objectClass       : user
objectGUID        : 437ed79e-67b3-46fb-b09e-a975b66e2ab9
SamAccountName    : GHarrison
SID               : S-1-5-21-437ed79e-67b3-46fb-b09e-a975b66e2ab9
```
Sending the results of **Get-ADGroupMember** to **Get-Member**, we can see the type of PowerShell object returned...
```posh
> Get-ADGroupMember 'Citrix-ADGrp-Notepad' | Get-Member


   TypeName: Microsoft.ActiveDirectory.Management.ADPrincipal

Name              MemberType            Definition
----              ----------            ----------
Contains          Method                bool Contains(string propertyName)
Equals            Method                bool Equals(System.Object obj)
GetEnumerator     Method                System.Collections.IDictionaryEnumerator GetEnumerator()
GetHashCode       Method                int GetHashCode()
GetType           Method                type GetType()
ToString          Method                string ToString()
Item              ParameterizedProperty Microsoft.ActiveDirectory.Management.ADPropertyValueCollection Item(string propertyName) {get;}
distinguishedName Property              System.String distinguishedName {get;set;}
name              Property              System.String name {get;}
objectClass       Property              System.String objectClass {get;set;}
objectGUID        Property              System.Nullable`1[[System.Guid, mscorlib, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089]] objectGUID {get;set;}
SamAccountName    Property              System.String SamAccountName {get;set;}
SID               Property              System.Security.Principal.SecurityIdentifier SID {get;set;}
```
## PIPE (|) to Select-Object
```posh
Select-Object samaccountname
```
We use the **Select-Object** cmdlet to just select the SamAccountName from our list of user objects.
```posh
samaccountname            
--------------            
JLennon              
PMcCartney
.
.
.                  
GHarrison                   
```
Sending the results of **Select-Object** to **Get-Member**, we can see the type of PowerShell object returned...
```posh
> Get-ADGroupMember 'Citrix-ADGrp-Notepad' | Select-Object samaccountname | Get-Member


   TypeName: Selected.Microsoft.ActiveDirectory.Management.ADPrincipal

Name           MemberType   Definition
----           ----------   ----------
Equals         Method       bool Equals(System.Object obj)
GetHashCode    Method       int GetHashCode()
GetType        Method       type GetType()
ToString       Method       string ToString()
samaccountname NoteProperty string samaccountname=JLennon
```
Notice the TypeName changed from `Microsoft.ActiveDirectory.Management.ADPrincipal` to `Selected.Microsoft.ActiveDirectory.Management.ADPrincipal`
## PIPE (|) to ForEach-Object
```posh
Foreach-Object {Get-ADUser $_.samaccountname -Properties *}
```
We use the **Foreach-Object** cmdlet to perform an action on each object returned from the previous `select-object samaccountname` command. The above command is the equivalent of running **Get-ADUser** on each user. (The $_ is a variable created automatically by PowerShell to store the current pipeline object.)
```posh
#-----------------------------------------------
#EXAMPLE - Running Get-AdUser against each user
#-----------------------------------------------
Get-AdUser JLennon -Properties *
Get-AdUser PMcCartney -Properties *
etc
```
Sending these results to **Get-Member** shows us a new TypeName.
```posh
> Get-ADGroupMember 'Citrix-ADGrp-Notepad' | select-object samaccountname | ForEach-Object {Get-ADUser $_.SamAccountName -properties *} | Get-Member


   TypeName: Microsoft.ActiveDirectory.Management.ADUser

Name                                 MemberType            Definition
----                                 ----------            ----------
Contains                             Method                bool Contains(string propertyName)
Equals                               Method                bool Equals(System.Object obj)
GetEnumerator                        Method                System.Collections.IDictionaryEnumerator GetEnumerator()
GetHashCode                          Method                int GetHashCode()
GetType                              Method                type GetType()
ToString                             Method                string ToString()
Item                                 ParameterizedProperty Microsoft.ActiveDirectory.Management.ADPropertyValueCollection Item(string propertyName) {get;}
AccountExpirationDate                Property              System.DateTime AccountExpirationDate {get;set;}
accountExpires                       Property              System.Int64 accountExpires {get;set;}
AccountLockoutTime                   Property              System.DateTime AccountLockoutTime {get;set;}
AccountNotDelegated                  Property              System.Boolean AccountNotDelegated {get;set;}
AllowReversiblePasswordEncryption    Property              System.Boolean AllowReversiblePasswordEncryption {get;set;}
AuthenticationPolicy                 Property              Microsoft.ActiveDirectory.Management.ADPropertyValueCollection AuthenticationPolicy {get;set;}
AuthenticationPolicySilo             Property              Microsoft.ActiveDirectory.Management.ADPropertyValueCollection AuthenticationPolicySilo {get;set;}
#----------------------------------------------
#Numerous AD User Properties removed for space
#----------------------------------------------
```
## PIPE (|) to Select-Object
```posh
Select-Object Givenname,surname,userprincipalname,description
```
Since we asked for all AD user properties and we only need a few, we use **Select-Object** again to grab the user's first and last name, account, and a description.
```posh
Givenname surname        userprincipalname              description                     
--------- -------        -----------------              -----------                     
John      Lennon         JLennon@PowerEUCShell.org      Singer/Songwriter
Paul      McCartney      PMcCartney@PowerEUCShell.org   Singer/Bassist                
.
.
.
Geroge    Harrison       GHarrison@PowerEUCShell.org    Singer/Guitarist 
```
Sending these results to **Get-Member**...
```posh
> Get-ADGroupMember 'Citrix-ADGrp-Notepad' | Select-Object samaccountname | ForEach-Object {Get-ADUser $_.SamAccountName -properties *} | Select-Object GivenName,SurName,UserPrincipalName,Description | Get-Member


   TypeName: Selected.Microsoft.ActiveDirectory.Management.ADUser

Name              MemberType   Definition
----              ----------   ----------
Equals            Method       bool Equals(System.Object obj)
GetHashCode       Method       int GetHashCode()
GetType           Method       type GetType()
ToString          Method       string ToString()
Description       NoteProperty string Description=WO0000001196844 (Jennifer Petty)
GivenName         NoteProperty string GivenName=Ben
SurName           NoteProperty string SurName=Wagner
UserPrincipalName NoteProperty string UserPrincipalName=JLennon@PowerEUCShell.org
```
The TypeName has changed again. From `Microsoft.ActiveDirectory.Management.ADUser` to `Selected.Microsoft.ActiveDirectory.Management.ADUser`
## PIPE (|) To Format-Table
```posh
Format-Table -auto
```
By default, PowerShell will truncate columns based on the view. To fully display all the data in the columns, we use **Format-Table -Autosize**. This makes PowerShell adjust the column size based on the width of the data.
```posh
# BEFORE FORMAT TABLE
GivenName SurName  UserPrincipalName            Description                       
--------- -------  -----------------            -----------                       
George    Harri... GHarrison@PowerEUCShell.org  Singer/Guitarist           
# AFTER FORMAT TABLE
GivenName SurName   UserPrincipalName            Description
--------- -------   -----------------            -----------
George    Harrison  GHarrison@PowerEUCShell.org  Singer/Guitarist
```
Sending these results to **Get-Member** gives us 2 different TypeNames.
```posh
> Get-ADGroupMember 'Citrix-ADGrp-Notepad' | Select-Object samaccountname | ForEach-Object {Get-ADUser $_.SamAccountName -properties *} | Select-Object GivenName,SurName,UserPrincipalName,Description | Format-Table -Autosize | Get-Member


   TypeName: Microsoft.PowerShell.Commands.Internal.Format.FormatStartData

Name                                    MemberType Definition
----                                    ---------- ----------
Equals                                  Method     bool Equals(System.Object obj)
GetHashCode                             Method     int GetHashCode()
GetType                                 Method     type GetType()
ToString                                Method     string ToString()
autosizeInfo                            Property   Microsoft.PowerShell.Commands.Internal.Format.AutosizeInfo, System.Management.Automation, Version=3.0.0.0, Culture=neutral, PublicKeyToke... ClassId2e4f51ef21dd47e99d3c952918aff9cd Property   string ClassId2e4f51ef21dd47e99d3c952918aff9cd {get;}
groupingEntry                           Property   Microsoft.PowerShell.Commands.Internal.Format.GroupingEntry, System.Management.Automation, Version=3.0.0.0, Culture=neutral, PublicKeyTok... pageFooterEntry                         Property   Microsoft.PowerShell.Commands.Internal.Format.PageFooterEntry, System.Management.Automation, Version=3.0.0.0, Culture=neutral, PublicKeyT... pageHeaderEntry                         Property   Microsoft.PowerShell.Commands.Internal.Format.PageHeaderEntry, System.Management.Automation, Version=3.0.0.0, Culture=neutral, PublicKeyT... shapeInfo                               Property   Microsoft.PowerShell.Commands.Internal.Format.ShapeInfo, System.Management.Automation, Version=3.0.0.0, Culture=neutral, PublicKeyToken=3...


   TypeName: Microsoft.PowerShell.Commands.Internal.Format.GroupStartData

Name                                    MemberType Definition
----                                    ---------- ----------
Equals                                  Method     bool Equals(System.Object obj)
GetHashCode                             Method     int GetHashCode()
GetType                                 Method     type GetType()
ToString                                Method     string ToString()
ClassId2e4f51ef21dd47e99d3c952918aff9cd Property   string ClassId2e4f51ef21dd47e99d3c952918aff9cd {get;}
groupingEntry                           Property   Microsoft.PowerShell.Commands.Internal.Format.GroupingEntry, System.Management.Automation, Version=3.0.0.0, Culture=neutral, PublicKeyTok... shapeInfo                               Property   Microsoft.PowerShell.Commands.Internal.Format.ShapeInfo, System.Management.Automation, Version=3.0.0.0, Culture=neutral, PublicKeyToken=3...
```
Sending our results, which up to now have been ActiveDirectory objects, through **Format-Table** changed them into new object types that do not have any active directory properties. Typically, this is why you leave the PowerShell format commands till the end of a pipeline so you can still manipulate results as their original object type.
## PIPE (|) To Out-File
```posh
Out-File -FilePath c:\temp\users.txt
```
Finally, we send the formatted table to **Out-File** to generate a text file. We cannot send these results to **Get-Member** because the **Out-File** cmdlet does not generate any output (i.e. no PowerShell objects).
# Conclusion
Hopefully this sheds some light on how to manipulate PowerShell objects using the **Pipeline** and how objects are changed as they move from cmdlet to cmdlet in the **Pipeline**.

## Learning More
### Links
*  [**Understanding PowerShell pipelines**](https://docs.microsoft.com/en-us/powershell/scripting/learn/understanding-the-powershell-pipeline)  
*  [**Understanding the PowerShell Pipeline - Petri**](https://www.petri.com/understanding-the-powershell-pipeline)  
*  [**Pipeline operator - PowerShell - SS64.com**](https://ss64.com/ps/syntax-pipeline.html)

### Cmdlets
*  [**Install the Active Directory PowerShell Module on Windows 10**](https://blogs.technet.microsoft.com/ashleymcglone/2016/02/26/install-the-active-directory-powershell-module-on-windows-10/)
*  [**Get-ADGroupMember**](https://docs.microsoft.com/en-us/powershell/module/addsadministration/get-adgroupmember)
*  [**Get-Member**](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/get-member?view=powershell-5.1)
*  [**Select-Object**](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/select-object?view=powershell-5.1)
*  [**ForEach-Object**](https://docs.microsoft.com/en-us/powershell/module/Microsoft.PowerShell.Core/ForEach-Object?view=powershell-5.1)
*  [**Format-Table**](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/format-table?view=powershell-5.1)
*  [**Out-File**](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/out-file?view=powershell-5.1)