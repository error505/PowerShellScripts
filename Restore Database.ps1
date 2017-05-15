$SQLServer = "ServerName"
$SQLDBName = "DataBaseName"
$uid ="UserName"
$pwd = "Password"
$backupPath= "C:\temp\test.bak"

Restore-SqlDatabase -ServerInstance $SQLServer -Database $SQLDBName -BackupFile $backupPath -SqlCredential [$uid, $pwd]

Write-Host "...Backup of the database"$dbname" completed..."