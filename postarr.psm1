function Get-TMDBMovie {
    [CmdletBinding()]
    param (
        [string]
        $ID,

        [string]
        $Name,

        [string]
        $IMDBID,

        [string]
        $TMDBAPI = $env:tmdbapi
    )
    
    begin {
        $IRMParams = @{
            Headers     = @{
                Authorization = ("Bearer {0}") -f $TMDBAPI
            }
            ContentType = "application/json"
        }
    }
    
    process {
        switch ($PSBoundParameters.Keys) {
            'ID' {
                $URI = "https://api.themoviedb.org/3/movie/{0}" -f $ID
                Invoke-RestMethod -Uri $URI @IRMParams
            }
            'Name' {
                $URI = "https://api.themoviedb.org/3/search/movie?query={0}" -f [uri]::EscapeDataString($name)
                (Invoke-RestMethod -Uri $URI @IRMParams).Results
            }
            'IMDBID' {
                $URI = "https://api.themoviedb.org/3/find/{0}?&external_source=imdb_id" -f $IMDBID,$TMDBAPI
                (Invoke-RestMethod -Uri $URI @IRMParams).movie_results
            }
            Default {
                if ($ID -and $Name) {
                    Write-Warning "Choose either ID or Movie name, not both."
                }
            }
        }
    }
    
    end {
        
    }
}

function Get-TMDBConfiguration {
    [CmdletBinding()]
    param (

    )
    
    begin {
        $IRMParams = @{
            Headers     = @{
                Authorization = ("Bearer {0}") -f $env:tmdbconfig["API"]
            }
            ContentType = "application/json"
        }
    }
    
    process {
        Invoke-RestMethod -URI "https://api.themoviedb.org/3/configuration" @IRMParams | 
        Select-Object -ExpandProperty Images
    }
    
    end {
        
    }
}

Export-ModuleMember -Function *