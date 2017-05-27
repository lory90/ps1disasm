@echo off
echo Assembling...
binaries\wla-z80 -vo ps1.asm ps1.o> bank_info.txt
if %ERRORLEVEL% neq 0 goto assemble_fail

echo Linking...
binaries\wlalink -rs link.txt ps1built.sms
if %ERRORLEVEL% neq 0 goto link_fail

echo ==========================
echo   Build Success.
echo ==========================

goto end

:assemble_fail
echo Error while assembling.
goto fail
:link_fail
echo Error while linking.
:fail

echo ==========================
echo   Build failure."
echo ==========================

pause

:end