%windir%\system32\inetsrv\appcmd.exe set apppool "drugTrack Web Application Pool" /processModel.idleTimeout:01:00:00 /commit:apphost /commit:WEBROOT
%windir%\system32\inetsrv\appcmd.exe set config /commit:WEBROOT /section:sessionState /cookieless:UseCookies /mode:InProc /cookieName:drugTrack_debug /timeout:60 /useHostingIdentity:true

