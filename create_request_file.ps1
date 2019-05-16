$DOCPath = $PSScriptRoot
$RequestsFolder = Join-Path -Path $DOCPath -ChildPath "requests"
$infileName = Join-Path -Path $DOCPath -ChildPath "request.sql"
$outfileName = Join-Path -Path $RequestsFolder -ChildPath "NYCOUNTY_REQUEST_$((Get-Date).toString("yyyyMMdd")).csv"

$sqlParams = @{ HostName = "PDCMS2"
                Database = "NYPDCMS" }

# Query for NYSIDs returns data, then pipe to the outfile in ascii format
Invoke-Sqlcmd @sqlParams -AbortOnError -InputFile $infileName | Out-File -FilePath $outfileName -Encoding ascii