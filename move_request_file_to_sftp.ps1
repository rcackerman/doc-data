$DOCPath = $PSScriptRoot
$RequestsFolder = Join-Path -Path $DOCPath -ChildPath "requests"
$OutfileName = Join-Path -Path $RequestsFolder -ChildPath "NYCOUNTY_REQUEST_$((Get-Date).toString("yyyyMMdd")).csv"

$credential = Get-Credential
$sessionOption = New-WinSCPSessionOption -HostName <> -Protocol Sftp -Credential $credential

New-WinSCPSession -SessionOption $sessionOption
Send-WinSCPItem -Path $OutfileName -Destination '<>'
