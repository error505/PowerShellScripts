$SQLServer = "ServerName"
$DatabaseName = "DataBaseName"
$uid ="UserName"
$pwd = "Password"

$backupPath= "D:\test.bak"
# Connect to server
$mySrvConn = new-object Microsoft.SqlServer.Management.Common.ServerConnection
$mySrvConn.ServerInstance=$SQLServer
$mySrvConn.LoginSecure = $false
$mySrvConn.Login = $uid
$mySrvConn.Password = $pwd

$srv = new-Object Microsoft.SqlServer.Management.Smo.Server($mySrvConn)
#Create a new database 
$NewDB = New-Object Microsoft.SqlServer.Management.Smo.Database($srv, $DatabaseName)
$NewDB.Create()

#Reference the database and display the date when it was created.   
$db = $srv.Databases[$DatabaseName]
$db.logfiles|measure-object -property size -sum
$logsize = ($db.logfiles|measure-object -property Size -sum).Sum/1024
$size = $db.Size - $logsize
write-host "log size:" $logsize
write-host "data size:" $size
 
$db.CreateDate

#Drop the database  
$NewDB.Drop()  

Write-Host "...Backup of the database"$DatabaseName" completed..."
$srv.ConnectionContext.Disconnect() 