[cmdletbinding()]
param()

Import-Module -Name /opt/microsoft/powershell/7/Modules/Postarr/postarr.psm1 -ErrorAction Stop -Verbose:$false

## Plex token
$plextoken = $env:plextoken
$tmdbapi_v4 = $env:tmdbapi
$plexURL = $env:plexurl
$4kmovielibrary = $env:4klibraryname

## Plex URL
$url = "$($plexURL)/library/sections?X-Plex-Token=$plextoken"

Write-Output "Using URL: $url"
Write-Output "Using Plex Base URL: $plexURL"

## Get the results of the library
$results = Invoke-RestMethod -Uri $url -Method Get -SkipCertificateCheck

## Get the 4K movie library
$4kmovie = $results.MediaContainer.Directory | Where-Object { $PSItem.Title -eq $4kmovielibrary }

## Get all the 4K movies
Write-Output "Using the following library: $plexURL/library/sections/$($4kmovie.key)/all?X-Plex-Token=$plextoken"

$4kmovieplex = Invoke-RestMethod -uri ("$plexURL/library/sections/$($4kmovie.key)/all?X-Plex-Token=$plextoken").replace('"','') -SkipCertificateCheck |
Select-Object -ExpandProperty MediaContainer | Select-object -ExpandProperty Video

foreach ($m in $4kmovieplex) {
    $imdbid_plex = "tt" + ($m.guid -replace "[^0-9]" , '')
    $tmdb = Get-TMDBMovie -ImdbID $imdbid_plex -Tmdbapi $tmdbapi_v4

    if (-not (Test-Path "/data/$($tmdb.Id)")) {
        Write-Output "Creating folder for $($m.title)" 
        $null = New-Item -Path "/data" -Name $tmdb.Id -ItemType Directory
        Write-Output "Downloading the $($m.title)"
        Invoke-WebRequest -Uri "https://image.tmdb.org/t/p/original$($tmdb.poster_path)" -OutFile "/data/$($tmdb.id)/poster.jpg"
        Write-Output "Processing $($m.title) - $($tmdb.Id) with magick"
        magick "/data/$($tmdb.id)/poster.jpg" /4k_logo.jpg -resize x"%[fx:t?u.h*0.1:u.h]" -background black -gravity north -extent "%[fx:u.w]x%[fx:s.h]" -composite "/data/$($tmdb.Id)/4kposter.jpg"
    
        $plexparams = @{
            URI    = "$plexURL/library/metadata/$($m.ratingkey)/posters?includeExternalMedia=1&X-Plex-Token=$plextoken"
            Method = "POST"
            InFile = "/data/$($tmdb.id)/4kposter.jpg"
            SkipCertificateCheck = $true
        }
        Write-Output "Setting 4K poster for $($m.Title)"
        Invoke-RestMethod @plexparams

    }
}