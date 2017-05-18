echo off
cls
echo -- IIS BACKUP TOOL by Igor Iric --
set /p APPLICATIONPOOlXML=Enter Application pool xml name to import:


%windir%\system32\inetsrv\appcmd add apppool /in < C:\Users\%username%\Desktop\%APPLICATIONPOOlXML%.xml
echo.
pause


echo off
cls
echo -- IIS BACKUP TOOL by Igor Iric --
set /p WEBSITEXML=Enter Application XML name to import:

%windir%\system32\inetsrv\appcmd add app /in < C:\Users\%username%\Desktop\%WEBSITEXML%.xml
echo.
pause