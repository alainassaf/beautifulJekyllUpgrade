---
layout: post
title: "PowerShell: Invoke-RestMethod"
date: 2020-04-22
readtime: true
tags: [web,learning,splatting,validateset,hash tables]
cover-img: 
    - "/assets/img/Powershell-Invoke-RestMethod/2020-04-22-Powershell-Invoke-RestMethod.jpg" : "Pixabay"
---

<!--more-->

# Contents

* TOC
{:toc}

# Scenario
I want to write a function that will query an image site and download a picture so I can insert it into a blog post. After watching a local PowerShell User Group presentation on using [**Invoke-RestMethod**](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/invoke-restmethod?view=powershell-7), I decided to give it a try.

# API Parameters
**Invoke-RestMethod** is a PowerShell utility specifically for quering web sites that use Representational State Transfer ([**REST**](https://en.wikipedia.org/wiki/Representational_state_transfer)) web services. It was introduced in PS 3.0 and is present through subsequent versions, including PS 7.0.
In order to use this cmdlet, I needed a web site that provded a RESTful API. I chose [**Pixabay**](https://pixabay.com/) because it has an easy to understand API and provides free and royalty free stock photos and videos. Let us take a look at the API parameters.

| Parameter | Type | Description |
| --------- | ----------- | --------|
| key (required) | String | API Key, provided after you create an account |
| q | String |  A URL encoded search term. If omitted, all images are returned. This value may not exceed 100 characters. |
| lang | String | [Language code](https://en.wikipedia.org/wiki/List_of_ISO_639-1_codes) of the language to be searched in. |
| id | String | Retrieve individual images by ID. |
| image_type |  String | Filter results by image type: "all", "photo", "illustration", or "vector". |
| orientation | String | Image orientation. Can be : "all", "horizontal", or "vertical". |
| category | String | Filter results by category: backgrounds, fashion, nature, science, education, feelings, health, people, religion, places, animals, industry, computer, food, sports, transportation, travel, buildings, business, or music |
| min_width | Integer | Minimum image width. |
| min_height | Integer | Minimum image height. |
| color | String | Filter by color: "grayscale", "transparent", "red", "orange", "yellow", "green", "turquoise", "blue", "lilac", "pink", "white", "gray", "black", "brown" |
| editors_choice | Boolean | Select images that have received an Editor's Choice award. "true" or "false" |
| safesearch | Boolean | A flag indicating that only images suitable for all ages should be returned. "true" or "false" |
| order | String | How the results should be ordered. "popular" or "latest" |
| page | Integer | Returned search results are paginated. This parameter selects the page number. |
| per_page | Integer | Number of results per page. Range 3 - 200 |
| callback | String | JSONP callback function name |
| pretty | Boolean | Indent JSON output. This option should not be used in production. "true" or "false" |

# Function Parameters
Now that I know the API parameters, I can decide what parameters to pass to my function. I need to pass a query for the type of images. I would also like to pick the category, a color (optional), and the API Key that I got when I created an account. Here is my function Param block:
```posh
param (
        [parameter(Position = 0, Mandatory = $True )]   
        [ValidateNotNullOrEmpty()]
        [string]$query,

        [Parameter(Mandatory = $true)]
        [ValidateSet("backgrounds", "fashion", "nature", "science", "education", "feelings", "health", "people", "religion", "places", "animals", "industry", "computer", "food", "sports", "transportation", "travel", "buildings", "business", "music")]
        $category,

        [Parameter(Mandatory = $false)]
        [ValidateSet("grayscale", "transparent", "red", "orange", "yellow", "green", "turquoise", "blue", "lilac", "pink", "white", "gray", "black", "brown")]
        $color,

        #Pixabay apikey
        [parameter(Mandatory = $true)]
        [string]$apikey
    )
```
I made the `$query`, `$category`, and `$apikey` parameters mandatory and the `$color` optional (the API supports sending colors as a comma separated list if you wanted more than one color in your image, but we'll keep it to one for this function). Since Pixabay listed the accepted values for categories and colors, we can make these parameters use a **ValidateSet**. A ValidateSet forces the parameter to come from a specific set of values. If the parameter does not match, then the function will fail.
#### Example
```posh
 function get-color {
    param (
        [parameter()]
        [ValidateSet("blue","red")]
        $color
    )
    write-host $color -BackgroundColor $color
}

PS > get-color -color blue
blue

PS > get-color -color red
red

PS > get-color -color black
get-color : Cannot validate argument on parameter 'color'. The argument "black" does not belong 
to the set "blue,red" specified by the ValidateSet attribute. Supply an argument that is in the 
set and then try the command again.
At line:1 char:18
+ get-color -color black
+                  ~~~~~
    + CategoryInfo          : InvalidData: (:) [get-color], ParameterBindingValidationException
    + FullyQualifiedErrorId : ParameterArgumentValidationError,get-color
```

# Splat Attack
Available since PowerShell 2.0, **splating** is a great way to simplify your scripts. The next part of our function will create splats to send all these variables to the **invoke-restmethod** cmdlet.

```posh
if ($null -ne $color) {
    $Body = @{
        key         = $apikey
        q           = $URLSearch
        category    = $category
        lang        = "en"
        image_type  = "photo"
        orientation = "horizontal"
        safesearch  = $true
    }
} else {
    $Body = @{
        key         = $apikey
        q           = $URLSearch
        category    = $category
        lang        = "en"
        image_type  = "photo"
        orientation = "horizontal"
        safesearch  = $true
        color       = $color
    }
}

$splat = @{
    URI    = "https://pixabay.com/api/"
    Method = "Get"
    Body   = $Body
}
```
The reason I want to use splatting is that both **invoke-restmethod** and the Pixabay API have a lot of parameters. It also makes code easier to read and modify in the future. I am going to first create a `$body` [**Hash Table**](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_hash_tables?view=powershell-7). The `$body` may have the additional `$color` parameter if one is present. We assign the *values* to the *keys* in the *hash table* using the API parameters for the *Keys* and the function parameters for the *Values*. Some of the *Values* are preset based on the API. I am presetting *lang*, *image_type*, *orientation*, and *safesearch*. Once the values of the `$body` are set, I create a `$splat` *hash table* that consists of the *URI* (API URL), the *Method* (the method used for the web request, the most common ones being *get* and *post*), and the *Body* which comes from the `$body` *hash table*.

# Getting Results
Now we can use the the *splats* to query the Pixabay API. We use a *Try/Catch* command to have an error check on the **Invoke-RestMethod**.
```posh
try {
    $pixabay_query = Invoke-RestMethod @splat
} catch {
    Write-Warning "Failed to query Pixabay"
    break
}
```
The rest of the function takes the results, randomly picks from the results (Pixabay returns 20 images as a default) and uses an Invoke-WebRequest to download the image.
```posh
if ($pixabay_query.totalHits -eq 0) {
    Write-Warning "No query results"
    Break
} else {
    $picPath = Split-Path -parent $PSCommandPath
    Write-Verbose "Filepath: [$PSScriptRoot]"
    # Default items per page from pixabay is 20
    $randomHit = Get-Random -Minimum 1 -Maximum 20
    $img = $pixabay_query.hits[$randomHit]
    Invoke-WebRequest -Uri $img.webformatUrl -OutFile $picPath\$picFilename
}   
```

# The entire function...
{% gist 0ba2d8b58163a11410b3159008e3381f %}
# Conclusion
This function worked exactly as I wanted. I used it to retrieve the picture at the top of this post. I hope you have seen something you can use in the future. Please leave a comment if you have any questions.

# Learning More
* [**Getting started with API's with Jonathan Moss - YouTube**](https://youtu.be/ZbpbissNlCs)
* [**Research Triangle Powershell User Group**](https://rtpsug.com/)
* [**Pixabay API Documentation**](https://pixabay.com/api/docs/)
* [**Pixabay**](https://pixabay.com/)
* [**ValidateSet**](https://docs.microsoft.com/en-us/powershell/scripting/developer/cmdlet/validateset-attribute-declaration?view=powershell-7)
* [**Splatting**](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_splatting?view=powershell-7)
* [**Hash Tables**](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_hash_tables?view=powershell-7)

### Value for Value  
If you received any value from reading this post, please help by becoming a [**supporter**](https://www.paypal.com/donate?hosted_button_id=73HNLGA2SGLLU).

*Thanks for Reading,*  
*Alain Assaf*