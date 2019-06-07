## DOC Data Processing

This is a set of scripts to ask for and retrieve NYC DOC data. The core workflow of the scripts is generating a CSV of clients' NYSIDs, uploading that to the DOC server, and retrieving the DOC response. There are two other scripts, one which transfers the doc response to the shared drive and one that cleans up the logs.

#### Setup

##### Prerequisites

This script set is designed to be run on a Windows machine. To install and run successfully, you must have:

* [Powershell 4.x](https://www.microsoft.com/en-us/download/details.aspx?id=40855)
* [WinSCP](https://winscp.net/eng/index.php)
* [WinSCP Powershell Module Wrapper](https://www.powershellgallery.com/packages/WinSCP/5.15.1.0)

##### Install

[Download repo](https://github.com/rcackerman/doc-data/archive/master.zip) or clone.

Rename `example-config.xml` to `config.xml` and fill in the variables. The variables are named to be easily identifiable from WinSCP's [generated code](https://winscp.net/eng/docs/ui_generateurl#script).

In Task Scheduler, add the request task:

1. Name it something.
2. Set the task to run whether the user is logged on or not.
3. Create a new trigger to schedule the task (per DOC, it is set to 7am).
4. Add the action.
	* `Program/script` will be `Powershell.exe`, with `-File <path>\create_request_file.ps1` as the argument. (The <path> needs to be the full path, such as `C:\doc-data`.)

**Note**: The user running the task will need to have the correct ssh key to access to the SFTP server.

In Task Scheduler, add the response task:

1. Name it something.
2. Set the task to run whether the user is logged on or not.
3. Create a new trigger to schedule the task (per DOC, this should be after 9am).
4. Add the action.
	* `Program/script` will be `Powershell.exe`, with `-File <path>\retrieve_response_file.ps1` as the argument. (The <path> needs to be the full path, such as `C:\doc-data`.)
	
**Note**: The user running the task will need to have the correct ssh key to access to the SFTP server.