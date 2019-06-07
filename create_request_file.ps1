# Load WinSCP .NET assembly
Add-Type -Path "C:\Program Files (x86)\WinSCP\WinSCPnet.dll"
$DOCPath = $PSScriptRoot

$RequestsFolder = Join-Path $DOCPath "requests"
$ResponseFolder = Join-Path $DOCPath "responses"

$config = ([xml](Get-Content (Join-Path $DOCPath "config.xml"))).config

########################
########################
#
# Starting logging
# 
########################
########################

$logFolder = Join-Path $PSScriptRoot "logs"
$logPath = Join-Path $logFolder "log_$((Get-Date).toString("yyyyMMdd")).log"
Start-Transcript -NoClobber -Append -IncludeInvocationHeader -Path $logPath 

########################
########################
#
# Generate Request File
#
#########################
#########################

$sqlParams = @{ Host           = $config.database.host
                Database       = $config.database.dbname }
$sqlPath = Join-Path $DOCPath "request.sql"

# Query database
$nysids = Invoke-Sqlcmd @sqlParams -AbortOnError -InputFile $sqlPath

# Create request file in ascii format from results
$outfilePath = Join-Path $RequestsFolder "NYCOUNTY_REQUEST_$((Get-Date).toString("yyyyMMddHHmm")).csv"
Out-File -FilePath $outfilePath -InputObject $nysids -Encoding ascii
Write-Host "NYSIDS written: $($nysids.Length)"

# File Cleaning
# Notes:
#  * (...) around Get-Content ensures that the outfile is read *in full*
#    up front, so that it is possible to write back the transformed content
#    to the same file.
#
#  * For transforming newlines into Unix format, Powershell 4 requires directly
#    using the .Net framework (`[IO.File]`), per this answer:
#    https://stackoverflow.com/a/19132572/702383
#    In the future, this script could use other options from this
#    answer: https://stackoverflow.com/a/19132572/702383
$cleanedNysids = ( Get-Content $outfilePath | Select-Object -Skip 4 ) | Foreach {$_.TrimEnd()}
Set-Content -Value $cleanedNysids $outfilePath

$text = [IO.File]::ReadAllText($outfilePath) -replace "`r`n", "`n"
[IO.File]::WriteAllText($outfilePath, $text)
Set-Content $outfilePath -Encoding Ascii -Value $text

Write-Host "Finished NYSIDs"

########################
########################
#
# Set up SFTP
#
#########################
#########################

$sessionOptions = New-Object WinSCP.SessionOptions -Property @{
    Protocol = [WinSCP.Protocol]::Sftp
    HostName = $config.sftp.HostName
    UserName = $config.sftp.Username
    Password = $config.sftp.Password
    SshHostKeyFingerprint = $config.sftp.SshHostKey
    SshPrivateKeyPath = $config.sftp.SshPrivateKeyPath
    SshPrivateKeyPassphrase = $config.sftp.SshPrivateKeyPassphrase
}

$sessionOptions.AddRawSettings("FSProtocol", "2")

$session = New-Object WinSCP.Session
$session.DebugLogLevel = 1
$session.DebugLogPath = Join-Path $logFolder "upload_$((Get-Date).toString("yyyyMMddHHmmss")).log"
$session.SessionLogPath = Join-Path $logFolder "session_$((Get-Date).toString("yyyyMMddHHmmss")).log"


########################
########################
#
# Transfer files
#
#########################
#########################

try
{
    Write-Host (Get-Date).toString("dd/MM/yyyy HH:mm:ss")
    Write-Host "Starting upload"
    
    $session.Open($sessionOptions)
    $session.RemoveFiles("/Request (dl-datacenter-support@doc.nyc.gov)/*.csv")
    $session.PutFiles($outfilePath, "/Request (dl-datacenter-support@doc.nyc.gov)/")
}
catch
{
    Write-Host (Get-Date).toString("dd/MM/yyyy HH:mm:ss")
    Write-Host "Error: $($_.Exception.Message)"
}
finally
{
    $session.Dispose()
    Write-Host (Get-Date).toString("dd/MM/yyyy HH:mm:ss")
    Write-Host "Upload finished"
}

Stop-Transcript