$DOCPath = $PSScriptRoot
$config = ([xml](Get-Content (Join-Path -Path $DOCPath -ChildPath "config.xml"))).config
$ResponsesFolder = Join-Path $DOCPath "responses"

$credential = Get-Credential
$sessionOption = New-WinSCPSessionOption -HostName $config.sftp.HostName -Protocol Sftp -Credential $credential

##
# Start the SFTP session
New-WinSCPSession -SessionOption $sessionOption

# Retrieve items from the SFTP folder
Send-WinSCPItem -Path $RequestFileName -Destination $config.sftp.SFTPRequestFolder

# Clear out folder
Remove-WinSCPItem -Path (Join-Path $config.sftp.SFTPRequestFolder "*.csv")


Remove-WinSCPSession
# End the SFTP session
##