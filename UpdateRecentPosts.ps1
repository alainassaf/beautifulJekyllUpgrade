[cmdletbinding()]
param(
    $path = ".\_posts\*.md"
)
$path = (Get-ChildItem $path | Sort-Object name -Descending | Select-Object -First 8).fullname
$lineTemplate = '* {0} [**{1}**](/{2}/?utm_source=blog&utm_medium=blog&utm_content=recent)'
$template = @'
---
layout: post
title: "{Title:Powershell: PSGraph, A graph module built on GraphViz}"
date: {Date:2017-01-30}
tags: [{Tags:PowerShell,PSGraph,GraphViz}]
---
'@

$output = foreach ($node in $path) {

    $parsedValues = Get-Content $node -raw | ConvertFrom-String -TemplateContent $template
    $tags = $parsedValues | Where-Object Tags | ForEach-Object { $_.Tags -split ',' } | ForEach-Object { $_.trim() }

    $postInfo = [pscustomobject]@{
        Post  = (Split-Path $node -Leaf).Replace('.md', '')
        Title = $parsedValues | Where-Object Title | ForEach-Object Title
        Tags  = $tags
        Date  = $parsedValues | Where-Object Date | ForEach-Object Date
    }
    $lineTemplate -f $postInfo.Date, $postInfo.Title, $postInfo.Post
}

$output | Set-Content -Path ".\_includes\recent-posts.md"