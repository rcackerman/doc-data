$DOCPath = $PSScriptRoot
$RequestsFolder = Join-Path -Path $DOCPath -ChildPath "requests"
$infileName = Join-Path -Path $DOCPath -ChildPath "request.sql"
$outfileName = Join-Path -Path $RequestsFolder -ChildPath "NYCOUNTY_REQUEST_$((Get-Date).toString("yyyyMMdd")).csv"

# Query for NYSIDs returns data, then pipe to the outfile in ascii format
Invoke-Sqlcmd -HostName "PDCMS2" -Database "NYPDCMS" -AbortOnError -InputFile $infileName | Out-File -FilePath $outfileName -Encoding ascii