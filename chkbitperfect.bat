@ECHO OFF

REM // build the ROM
call build %1

REM  // run fc
echo -------------------------------------------------------------
IF EXIST ps1built.sms ( fc /b ps1built.sms ps1original.sms
) ELSE echo ps1built.sms does not exist, probably due to an assembly error

REM // clean up after us
IF EXIST bank_info.txt del bank_info.txt
IF EXIST ps1built.sms del ps1built.sms
IF EXIST ps1.o del ps1.o
IF EXIST ps1built.sym del ps1built.sym

REM // if someone ran this from Windows Explorer, prevent the window from disappearing immediately
pause
