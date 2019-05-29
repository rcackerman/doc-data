$DOCPath = $PSScriptRoot

$RequestsFolder = Join-Path $DOCPath "requests\"
$ResponseFolder = Join-Path $DOCPath "responses\"

$config = ([xml](Get-Content (Join-Path $DOCPath "config.xml"))).config

$password = ConvertTo-SecureString $config.sftp.Password -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential $config.sftp.Username, $password

$sqlParams         = @{ Host           = $config.database.host
                        Database       = $config.database.dbname }
$sftpOptionParams  = @{ Hostname       = $config.sftp.HostName
                        Protocol       = "Sftp"
                        Credential     = $credential }

###
# Upload request file
$sessionOption = New-WinSCPSessionOption @sftpOptionParams -GiveUpSecurityAndAcceptAnySshHostKey
New-WinSCPSession -SessionOption $sessionOption

# Retrieve items from the SFTP folder
# Removes the response file from the SFTP folder after retrieval
Receive-WinSCPItem -RemotePath (Join-Path $config.sftp.SFTPRequestFolder "*.csv") -LocalPath $ResponseFolder -Remove

Remove-WinSCPSession
# End the SFTP session
##