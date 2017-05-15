$SQLServer = "ServerName"
$SQLDBName = "DataBaseName"
$uid ="UserName"
$pwd = "Password"
$backupPath= "C:\temp\DataBaseName.bak"

# Backup database
Backup-SqlDatabase -ServerInstance $SQLServer -Database $SQLDBName -BackupFile $backupPath -SqlCredential [$uid, $pwd] -Compression On -Initialize


Write-Host "...Backup of the database"$SQLDBName" completed..."