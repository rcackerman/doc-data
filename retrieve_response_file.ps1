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
$session.DebugLogPath = Join-Path $logFolder "download_$((Get-Date).toString("yyyyMMddHHmmss")).log"
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
    Write-Host "Starting download"
    
    $session.Open($sessionOptions)
    $session.GetFiles($config.sftp.SFTPResponseFolder, (Join-Path $ResponseFolder "*"), $true).Check()
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
    Write-Host "Download finished"
}

Stop-Transcript