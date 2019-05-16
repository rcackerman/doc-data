$DOCPath = $PSScriptRoot
$config = ([xml](Get-Content (Join-Path -Path $DOCPath -ChildPath "config.xml"))).config
$RequestsFolder = Join-Path -Path $DOCPath -ChildPath "requests"
$infileName = Join-Path -Path $DOCPath -ChildPath "request.sql"
$outfileName = Join-Path -Path $RequestsFolder -ChildPath "NYCOUNTY_REQUEST_$((Get-Date).toString("yyyyMMddHHmm")).csv"

$sqlParams = @{ Host = $config.database.host
                Database = $config.database.dbname }

# Query for NYSIDs returns data, then pipe to the outfile in ascii format
Invoke-Sqlcmd @sqlParams -AbortOnError -InputFile $infileName | Out-File -FilePath $outfileName -Encoding ascii

# Importing CSV of NYSIDs, then removing the header line and all trailing whitespace
$nysids = Get-Content $outfileName
$cleanedNysids = ( Get-Content $outfileName | Select-Object -Skip 4 ) | Foreach {$_.TrimEnd()}
Set-Content -Value $cleanedNysids -Path $outfileName

# Convert CRLFs to LFs only.
# Note:
#  * (...) around Get-Content ensures that $file is read *in full*
#    up front, so that it is possible to write back the transformed content
#    to the same file.
#  * + "`n" ensures that the file has a *trailing LF*, which Unix platforms
#     expect.
# From this post: https://stackoverflow.com/a/19132572/702383
$text = [IO.File]::ReadAllText($outfileName) -replace "`r`n", "`n"
[IO.File]::WriteAllText($outfileName, $text)
Set-Content $outfileName -Encoding Ascii -Value $text