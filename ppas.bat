@echo off
SET THEFILE=d:\github-desktop\tp-algoritmos\trabajopracticogrupal_n3.exe
echo Linking %THEFILE%
c:\dev-pas\bin\ldw.exe  -s   -b base.$$$ -o d:\github-desktop\tp-algoritmos\trabajopracticogrupal_n3.exe link.res
if errorlevel 1 goto linkend
goto end
:asmend
echo An error occured while assembling %THEFILE%
goto end
:linkend
echo An error occured while linking %THEFILE%
:end
