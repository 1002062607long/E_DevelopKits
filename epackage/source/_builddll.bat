@echo off

rem 假设masm32安装在\tools\masm32目录中

if exist %1.obj del %1.obj
if exist %1.dll del %1.dll
if exist dll.res del dll.res

if not exist dll.rc goto noresfound

\tools\masm32\bin\rc.exe dll.rc
if errorlevel 1 goto errrc

:noresfound

\tools\masm32\bin\ml /c /coff %1.asm
if errorlevel 1 goto errasm

if not exist dll.res goto nores
if not exist %1.def goto nodef1

\tools\masm32\bin\Link /SUBSYSTEM:WINDOWS /DLL /DEF:%1.def %1.obj dll.res
if errorlevel 1 goto errlink
goto OK

:nodef1
\tools\masm32\bin\Link /SUBSYSTEM:WINDOWS /DLL %1.obj dll.res
if errorlevel 1 goto errlink
goto OK

:nores
if not exist %1.def goto nodef2

\tools\masm32\bin\Link /SUBSYSTEM:WINDOWS /DLL /DEF:%1.def %1.obj
if errorlevel 1 goto errlink
goto OK

:nodef2
\tools\masm32\bin\Link /SUBSYSTEM:WINDOWS /DLL %1.obj
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
if exist dll.res del dll.res
dir %1.*

echo -------------------------------------
pause
