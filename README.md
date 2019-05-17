## DOC Data Processing

This is a set of scripts to ask for and retrieve NYC DOC data. The core workflow of the scripts is generating a CSV of clients' NYSIDs, uploading that to the DOC server, and retrieving the DOC response.

#### Setup

##### Prerequisites

This script set is designed to be run on a Windows machine. To install and run successfully, you must have:

* [Powershell 4.x](https://www.microsoft.com/en-us/download/details.aspx?id=40855)
* [WinSCP](https://winscp.net/eng/index.php)
* [WinSCP Powershell Module Wrapper](https://www.powershellgallery.com/packages/WinSCP/5.15.1.0)

##### Install

[Download repo](https://github.com/rcackerman/doc-data/archive/master.zip) or clone

In Task Scheduler, add the request task:

1. Name it something.
2. Create a new trigger to schedule the task (per DOC, it is set to 7am).
3. Add actions. This is where we will tell the task scheduler how to run all of the commands. You will add two actions:
    * For each action, the `Program/script` should be `Powershell.exe`.
    * For the first action, add `-File "<path>\create_request_file.ps1"` as the argument.
    * For the second action add `-File "<path>\move_request_file_to_sftp.ps1"` as the argument.

In Task Scheduler, add the response task:

1. Name it something.
2. Create a new trigger to schedule the task (per DOC, this should be after 9am).
	* For the action, the `Program/script` should be `Powershell.exe`.
    * Add ``-File "<path>\retrieve_response_file.ps1"` as the argument.
