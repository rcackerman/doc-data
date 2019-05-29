$DOCPath = $PSScriptRoot
$config = ([xml](Get-Content (Join-Path -Path $DOCPath -ChildPath "config.xml"))).config
$RequestsFolder = Join-Path $DOCPath "requests"

# Select the most recently written file in the requests directory
$RequestFileName = Join-Path $RequestsFolder (Get-ChildItem "$($RequestsFolder)/*.csv" | Sort-Object LastWriteTime | Select-Object -Last 1).name

$credential = New-Object System.Management.Automation.PSCredential $config.sftp.Username, (ConvertTo-SecureString $config.sftp.Password -AsPlainText -Force)
$sessionOption = New-WinSCPSessionOption -HostName $config.sftp.HostName -Protocol Sftp -Credential $credential -GiveUpSecurityAndAcceptAnySshHostKey

##
# Start the SFTP session
New-WinSCPSession -SessionOption $sessionOption

# Remove old files
Remove-WinSCPItem -Path (Join-Path $config.sftp.SFTPResponseFolder "*.csv") 
# Upload new request file
Send-WinSCPItem -Path $RequestFileName -Destination $config.sftp.SFTPRequestFolder

Remove-WinSCPSession
# End the SFTP session
##