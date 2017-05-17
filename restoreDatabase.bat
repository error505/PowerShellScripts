echo off
cls
echo -- RESTORE DATABASE --
set /p BACKUPFILENAME=Enter backup file name:C:\temp\
set /p DATABASENAME=Enter database name:
set /p SERVERNAME=your server name here:
set /p USERNAME=your user name here:
set /p PASSWORD=your password here:

sqlcmd -U %USERNAME% -P %PASSWORD% -S %SERVERNAME% -d master -Q "ALTER DATABASE [%DATABASENAME%] SET SINGLE_USER WITH ROLLBACK IMMEDIATE"

:: WARNING - delete the database, suits me
:: sqlcmd -E -S %SERVERNAME% -d master -Q "IF EXISTS (SELECT * FROM sysdatabases WHERE name=N'%DATABASENAME%' ) DROP DATABASE [%DATABASENAME%]"
:: sqlcmd -E -S %SERVERNAME% -d master -Q "CREATE DATABASE [%DATABASENAME%]"

:: restore
sqlcmd -U %USERNAME% -P %PASSWORD% -S %SERVERNAME% -d master -Q "RESTORE DATABASE [%DATABASENAME%] FROM DISK = N'C:\temp\%BACKUPFILENAME%' WITH REPLACE"

:: remap user/login (http://msdn.microsoft.com/en-us/library/ms174378.aspx)
:: sqlcmd -E -S %SERVERNAME% -d %DATABASENAME% -Q "sp_change_users_login 'Update_One', 'login-name', 'user-name'"
:: sqlcmd -E -S %SERVERNAME% -d master -Q "ALTER DATABASE [%DATABASENAME%] SET MULTI_USER"
echo.
pause