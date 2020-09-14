@echo off
SET THEFILE=c:\users\ramiro\docume~1\github\tp-alg~1\trabaj~1.exe
echo Linking %THEFILE%
c:\dev-pas\bin\ldw.exe  -s   -b base.$$$ -o c:\users\ramiro\docume~1\github\tp-alg~1\trabaj~1.exe link.res
if errorlevel 1 goto linkend
goto end
:asmend
echo An error occured while assembling %THEFILE%
goto end
:linkend
echo An error occured while linking %THEFILE%
:end
