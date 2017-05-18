
echo off
cls
echo -- IIS BACKUP TOOL by Igor Iric --
set /p APPLICATIONPOOl=Enter Application pool name:
set /p APPLICATIONPOOlXML=Enter Application pool export XML name:

%windir%\system32\inetsrv\appcmd list apppool "%APPLICATIONPOOl%" /config /xml > C:\Users\%username%\Desktop\%APPLICATIONPOOlXML%.xml
echo.
pause

echo off
cls
echo -- IIS BACKUP TOOL by Igor Iric --
set /p WEBSITENAME=Enter Web Site name:
set /p APPLICATION=Enter Application name:
set /p WEBSITEXML=Enter Application export XML name:

%windir%\system32\inetsrv\appcmd list app "%WEBSITENAME%/%APPLICATION%" /config /xml > C:\Users\%username%\Desktop\%WEBSITEXML%.xml

echo.
pause