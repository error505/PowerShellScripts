echo off
cls
echo -- BACKUP DATABASE --
set /p DATABASENAME=Enter database name:

:: filename format Name-Date (eg MyDatabase-2009.5.19.bak)
set DATESTAMP=%DATE%
set BACKUPFILENAME=C:\%DATABASENAME%-%DATESTAMP%.bak
set /p SERVERNAME=your server name here:
set /p USERNAME=your user name here:
set /p PASSWORD=your password here:
echo.

sqlcmd -U %USERNAME% -P %PASSWORD% -S %SERVERNAME% -d master -Q "BACKUP DATABASE [%DATABASENAME%] TO DISK = N'%BACKUPFILENAME%' WITH INIT , NOUNLOAD , NAME = N'%DATABASENAME% backup', NOSKIP , STATS = 10, NOFORMAT"
echo.
pause