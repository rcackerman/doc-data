$DOCPath = $PSScriptRoot

$RequestsFolder = Join-Path $DOCPath "requests"
$ResponseFolder = Join-Path $DOCPath "responses"
$infilePath = Join-Path $DOCPath "request.sql"
$outfilePath = Join-Path $RequestsFolder "NYCOUNTY_REQUEST_$((Get-Date).toString("yyyyMMddHHmm")).csv"
$logPath = Join-Path $DOCPath "debug.log"

$config = ([xml](Get-Content (Join-Path $DOCPath "config.xml"))).config

$username = System.Management.Automation.PSCredential $config.sftp.Username
$password = ConvertTo-SecureString $config.sftp.Password -AsPlainText -Force
$credential = New-Object $username, $password

$sqlParams         = @{ Host           = $config.database.host
                        Database       = $config.database.dbname }
$sftpOptionParams  = @{ Hostname       = $config.sftp.HostName
                        Protocol       = Sftp
                        Credential     = $credential }
$sftpSsnParams     = @{ DebugLogLevel  = 2
                        DebugLogPath   = $logPath
                        SessionLogPath = $logPath }

###
# Generate Request File

# Create the outfile in ascii format
$nysids = Invoke-Sqlcmd @sqlParams -AbortOnError -InputFile $infileName
Out-File -FilePath $outfilePath -InputObject $nysids -Encoding ascii

# Importing CSV of NYSIDs, then removing the header line and all trailing whitespace
$nysids = Get-Content $outfilePath
$cleanedNysids = ( Get-Content $outfilePath | Select-Object -Skip 4 ) | Foreach {$_.TrimEnd()}
Set-Content -Value $cleanedNysids $outfilePath

# Convert CRLFs to LFs only.
# Note:
#  * (...) around Get-Content ensures that $file is read *in full*
#    up front, so that it is possible to write back the transformed content
#    to the same file.
#  * + "`n" ensures that the file has a *trailing LF*, which Unix platforms
#     expect.
# From this post: https://stackoverflow.com/a/19132572/702383
$text = [IO.File]::ReadAllText($outfilePath) -replace "`r`n", "`n"
[IO.File]::WriteAllText($outfilePath, $text)
Set-Content $outfilePath -Encoding Ascii -Value $text


###
# Upload request file

# Start the SFTP session
New-WinSCPSession -SessionOption (New-WinSCPSessionOption @sftpParams -GiveUpSecurityAndAcceptAnySshHostKey)

# Remove old files
Remove-WinSCPItem -Path (Join-Path $config.sftp.SFTPResponseFolder "*.csv") 
# Upload new request file
Send-WinSCPItem -Path $RequestFileName -Destination $config.sftp.SFTPRequestFolder

Remove-WinSCPSession
# End the SFTP session
##