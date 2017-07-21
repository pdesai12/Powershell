# Script to backup an MS SQL server database and move to ftp server
# Author: Palak Desai
#############################################

Clear-Host

# Import the SQLPS Module 
Import-Module 'sqlps' -DisableNameChecking 

# Enter SQL Server details below:
$SQLServer = <Server IP>
$SQLInstance = <Instance name> # Leave blank if no named instance e.g. ""
$SQLUser= <SQL User>
$SQLPass= <SQL Password>

# Log Directory
$logpath = “D:\Backups\logs"

# Get today’s date
$now = get-date

# Timestamp to be added to the Database backup
$timestamp = "Replace(REPLACE(CONVERT(char(19), GETDATE(), 120), ':', '_'),' ','_')"

# Connect SQL and initialize back up

Write-output "
Backup intialized…
"
$ErrorOccured = $false

Try 
{

Invoke-Sqlcmd -Serverinstance $SQLServer\$SQLInstance -U $SQLUser -P $SQLPass -querytimeout 300 -Query `
"DECLARE `
@DatabaseName sysname = N'SQL', `
@DatabaseBackupFileName varchar(255); `
SET @DatabaseBackupFileName = '\\ftpserver\Backups\Server\' + @DatabaseName + '_' + $timestamp + '.bak'; `
BACKUP DATABASE @DatabaseName `
TO DISK = @DatabaseBackupFileName `
WITH INIT, `
COMPRESSION;"

 "Success! Your backup is stored at ftp://ftpserver/backups/Server"
}

#Catch the exception and append to the log files
catch [exception]
{  
   $( "$now " + $_.Exception.Message) | out-file $logpath\failure_logs.txt -append 
   "$_.Exception.Message"
   continue;
}

# Successful backups appended to log file
if(!$ErrorOccured) {$("$now " + " successfully backup the SQL database") | out-file $logpath\success_logs.txt -append}
