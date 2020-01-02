@echo off

rem 假设masm32安装在\tools\masm32目录中

if exist %1.obj del %1.obj
if exist %1.exe del %1.exe
if exist rsrc.res del rsrc.res

if not exist rsrc.rc goto noresfound

\tools\masm32\bin\rc.exe rsrc.rc
if errorlevel 1 goto errrc

:noresfound

\tools\masm32\bin\ml /c /coff %1.asm
if errorlevel 1 goto errasm

if not exist rsrc.res goto nores

\tools\masm32\bin\Link /SUBSYSTEM:WINDOWS %1.obj rsrc.res
if errorlevel 1 goto errlink
goto OK

:nores
\tools\masm32\bin\Link /SUBSYSTEM:WINDOWS %1.obj
if errorlevel 1 goto errlink
goto OK

:errrc
echo -------------------------------------
echo RC error
goto TheEnd

:errlink
echo -------------------------------------
echo Link error
goto TheEnd

:errasm
echo -------------------------------------
echo Assembly Error
goto TheEnd

:OK
echo -------------------------------------
echo Compile %1.exe OK.
goto TheEnd

:TheEnd
if exist %1.obj del %1.obj
if exist rsrc.res del rsrc.res

echo -------------------------------------
pause
