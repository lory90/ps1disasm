@ECHO OFF

REM // build the ROM
call build %1

REM  // run fc
echo -------------------------------------------------------------
IF EXIST ps1built.bin ( fc /b ps1built.bin ps1original.bin
) ELSE echo ps1built.bin does not exist, probably due to an assembly error

REM // clean up after us
IF EXIST bank_info.txt del bank_info.txt
IF EXIST ps1built.bin del ps1built.bin
IF EXIST ps1.o del ps1.o
IF EXIST ps1built.sym del ps1built.sym

REM // if someone ran this from Windows Explorer, prevent the window from disappearing immediately
pause
