@echo off
setlocal enableExtensions disableDelayedExpansion
pushd "%~dp0"
call:setmetainfo
call:validatewinchecksum || goto end
call:init
call:setdefaultopts
call:checkinstallation

:parseargs
if %1. == . (goto endparseargs)
set _exit=1
if "%~1" == "--uninstall" ((set uninstall=1) & shift /1 & goto parseargs)
if "%~1" == "--help" (goto help)
if "%~1" == "/?" (goto help)
if "%~1" == "-?" (goto help)
call:err --before-welcome "error: invalid argument `%~1'"
goto end
:endparseargs

if defined uninstall (call:uninstall & goto end)

:welcome
call:refreshopts
call:welcomescreen
choice /c 1234567890UFQWERS /n /m ">       Choose what to do: "
set choice=%ERRORLEVEL%
if %choice% EQU 0 ((set _exit=1) & goto end)
if %choice% EQU 10 ((set _exit=1) & goto end)
if %choice% EQU 1 (call:install & goto end)
if %choice% EQU 2 (call:uninstall & goto end)
if %choice% EQU 3 (call:toggleopts md2 & goto welcome)
if %choice% EQU 4 (call:toggleopts md4 & goto welcome)
if %choice% EQU 5 (call:toggleopts md5 & goto welcome)
if %choice% EQU 6 (call:toggleopts sha1 & goto welcome)
if %choice% EQU 7 (call:toggleopts sha256 & goto welcome)
if %choice% EQU 8 (call:toggleopts sha384 & goto welcome)
if %choice% EQU 9 (call:toggleopts sha512 & goto welcome)
if %choice% EQU 11 (call:toggleopts umode & goto welcome)
if %choice% EQU 12 (call:toggleopts fmode & goto welcome)
if %choice% EQU 13 (if defined qflag (set qflag=) else (set qflag=--copy) & call:refreshopts & goto welcome)
if %choice% EQU 14 (if "%qflag%" == "--copy" (set qflag=) else (set qflag=--copy) & call:refreshopts & goto welcome)
if %choice% EQU 15 (if "%qflag%" == "--copy-with-filename" (set qflag=) else (set qflag=--copy-with-filename) & call:refreshopts & goto welcome)
if %choice% EQU 16 (if "%qflag%" == "--copy-with-path" (set qflag=) else (set qflag=--copy-with-path) & call:refreshopts & goto welcome)
if %choice% EQU 17 (call:toggleopts sckey & goto welcome)
goto welcome

:setmetainfo
set "_title=Winchecksum Wrapper"
set "_winchecksum_relative=winchecksum\winchecksum.bat"
set "_winchecksum=%~dp0%_winchecksum_relative%"
set "_winchecksum_dir=%~dp0winchecksum"
set "_icon=%SystemRoot%\System32\SHELL32.dll,-23"
set "_link=https://github.com/lxvs/winchecksumwrapper"
exit /b
::setmetainfo

:validatewinchecksum
if exist "%_winchecksum%" (exit /b 0)
call:err --before-welcome "error: failed to find file `%_winchecksum_relative%'"
exit /b 1
::validatewinchecksum

:init
title %_title%
set "regpath=HKCU\Software\lxvs\winchecksumwrapper"
set "regpathshell=HKCU\Software\Classes\*\shell\winchecksumwrapper"
set _exit=
set ec=0
set "allalgorithms=MD2 MD4 MD5 SHA1 SHA256 SHA384 SHA512"
set installing=
set addingtopath=
set uninstall=
exit /b
::init

:setdefaultopts
set algorithms=SHA256
set md2=
set md4=
set md5=
set sha1=
set sha256=
set sha384=
set sha512=
set umode=
set fmode=
set qflag=
set sckey=1
exit /b
::setdefaultopts

:checkinstallation
call:getreg "%regpath%" "Path" installation
if not defined installation (exit /b)
call:getreg "%regpath%" "UpperCaseMode" umode
call:getreg "%regpath%" "FileMode" fmode
call:getreg "%regpath%" "CopyFlag" qflag
call:getreg "%regpath%" "Algorithms" algorithms
exit /b
::checkinstallation

:refreshopts
if defined installation (set _installed=yes) else (set _installed=no)
if defined algorithms (for %%i in (%algorithms%) do (set %%i=1) & set algorithms=)
if defined md2 (set _md2=yes) else (set _md2=no)
if defined md4 (set _md4=yes) else (set _md4=no)
if defined md5 (set _md5=yes) else (set _md5=no)
if defined sha1 (set _sha1=yes) else (set _sha1=no)
if defined sha256 (set _sha256=yes) else (set _sha256=no)
if defined sha384 (set _sha384=yes) else (set _sha384=no)
if defined sha512 (set _sha512=yes) else (set _sha512=no)
if defined umode (set _umode=yes) else (set _umode=no)
if defined fmode (set _fmode=yes) else (set _fmode=no)
set _qmode=no
set _q_value=no
set _q_name=no
set _q_path=no
if defined qflag (
    set _qmode=yes
    if "%qflag%" == "--copy" (
        set _q_value=yes
    ) else if "%qflag%" == "--copy-with-filename" (
        set _q_name=yes
    ) else if "%qflag%" == "--copy-with-path" (
        set _q_path=yes
    )
)
if defined sckey (
    set _sckey=yes
    set "sck= (&K)"
    set "sck_u= (&U)"
    set "sck_f= (&F)"
    set "sck_q= (&Q)"
) else (
    set _sckey=no
    set sck=
    set sck_u=
    set sck_f=
    set sck_q=
)
exit /b
::refreshopts

:toggleopts
if %1. == . (
    call:refreshopts
    exit /b
)
if not defined %1 (set %1=1) else (set %1=)
shift /1
goto toggleopts
::toggleopts

:welcomescreen
cls
@echo;
@echo         Winchecksum Wrapper ^(%_link%^)
@echo         Installed: %_installed%
@echo;
@echo         Operations:
@echo                 [1] Add below algorithm^(s^) to context menu
@echo                 [2] Remove all winchecksum items from context menu
@echo                 [0] Exit
@echo;
@echo         Algorithms:
@echo                 [3] MD2         [%_md2%]
@echo                 [4] MD4         [%_md4%]
@echo                 [5] MD5         [%_md5%]
@echo                 [6] SHA1        [%_sha1%]
@echo                 [7] SHA256      [%_sha256%]
@echo                 [8] SHA384      [%_sha384%]
@echo                 [9] SHA512      [%_sha512%]
@echo;
@echo         Options:
@echo                 [U] Add UPPERCASE mode              [%_umode%]
@echo                 [F] Add quietly write to file mode  [%_fmode%]
@echo                 [Q] Add quietly copy mode           [%_qmode%]
@echo                     [W] Copy checksum value         [%_q_value%]
@echo                     [E] Copy file name and checksum [%_q_name%]
@echo                     [R] Copy file path and checksum [%_q_path%]
@echo                 [S] Add shortcut keys               [%_sckey%]
@echo;
exit /b
::welcomescreen

:install
call:populatealgorithms
if not defined algorithms (
    call:err "error: no algorithm to install"
    exit /b 1
)
set installing=1
call:uninstall
reg add "%regpath%" /v "Path" /d "%_winchecksum%" /f 1>nul || exit /b 1
reg add "%regpath%" /v "UpperCaseMode" /d "%umode%" /f 1>nul || exit /b 1
reg add "%regpath%" /v "FileMode" /d "%fmode%" /f 1>nul || exit /b 1
reg add "%regpath%" /v "CopyFlag" /d "%qflag%" /f 1>nul || exit /b 1
reg add "%regpath%" /v "Algorithms" /d "%algorithms%" /f 1>nul || exit /b 1
for %%i in (%algorithms%) do (
    reg add "%regpathshell%_%%~i" /ve /d "Winchecksum - %%~i%sck%" /f 1>nul || exit /b 1
    reg add "%regpathshell%_%%~i" /v "icon" /d "%_icon%" /f 1>nul || exit /b 1
    reg add "%regpathshell%_%%~i\command" /ve /d "\"%_winchecksum%\" \"%%1\" --pause --algorithm %%~i" /f 1>nul || exit /b 1
    if defined umode (
        reg add "%regpathshell%_%%~i_u" /ve /d "Winchecksum - %%~i (UPPERCASE)%sck_u%" /f 1>nul || exit /b 1
        reg add "%regpathshell%_%%~i_u" /v "icon" /d "%_icon%" /f 1>nul || exit /b 1
        reg add "%regpathshell%_%%~i_u\command" /ve /d "\"%_winchecksum%\" \"%%1\" --pause --algorithm %%~i --uppercase" /f 1>nul || exit /b 1
    )
    if defined fmode (
        reg add "%regpathshell%_%%~i_f" /ve /d "Winchecksum - %%~i (to file)%sck_f%" /f 1>nul || exit /b 1
        reg add "%regpathshell%_%%~i_f" /v "icon" /d "%_icon%" /f 1>nul || exit /b 1
        reg add "%regpathshell%_%%~i_f\command" /ve /d "\"%_winchecksum%\" \"%%1\" --quiet --algorithm %%~i --file --overwrite" /f 1>nul || exit /b 1
    )
    if defined qflag (
        reg add "%regpathshell%_%%~i_q" /ve /d "Winchecksum - %%~i (copy quietly)%sck_q%" /f 1>nul || exit /b 1
        reg add "%regpathshell%_%%~i_q" /v "icon" /d "%_icon%" /f 1>nul || exit /b 1
        reg add "%regpathshell%_%%~i_q\command" /ve /d "\"%_winchecksum%\" \"%%1\" --quiet --algorithm %%~i %qflag%" /f 1>nul || exit /b 1
    )
)
call:say "Install complete"
exit /b 0
::install

:populatealgorithms
set algorithms=
for %%i in (%allalgorithms%) do (if defined %%i (call:appendalgorithm "%%~i"))
exit /b
::populatealgorithms

:appendalgorithm
set "algorithms=%algorithms%%~1 "
exit /b
::appendalgorithm

:uninstall
reg delete "%regpath%" /f 1>nul 2>nul
for %%i in (%allalgorithms%) do (
    reg delete "%regpathshell%_%%~i" /f 1>nul 2>nul
    reg delete "%regpathshell%_%%~i_u" /f 1>nul 2>nul
    reg delete "%regpathshell%_%%~i_f" /f 1>nul 2>nul
    reg delete "%regpathshell%_%%~i_q" /f 1>nul 2>nul
)
if defined installing (exit /b)
if defined uninstall (call:say --before-welcome "Uninstall complete" & exit /b)
call:say "Uninstall complete"
exit /b 0
::uninstall

:getreg
set "getreg_path=%~1"
set getreg_key="%~2"
set %3=
set "getreg_name=%~2"
set getregretval=
if /i "%getreg_key%" == "/ve" (
    set getreg_switch=/ve
    set getreg_key=
    set "getreg_name=(Default)"
) else (
    set getreg_switch=/v
)
for /f "skip=2 tokens=1* delims=" %%a in ('reg query "%getreg_path%" %getreg_switch% %getreg_key% 2^>nul') do (
    call:getregparse "%%~a"
)
if defined getregretval (set "%3=%getregretval%")
exit /b
::getreg

:getregparse
if "%~1" == "" (exit /b 1)
set "getregparse_str=%~1"
set "getregparse_str=%getregparse_str:    =	%
for /f "tokens=1,2* delims=	" %%A in ("%getregparse_str%") do (
    if /i "%getreg_name%" == "%%~A" (set "getregretval=%%~C")
)
exit /b
::getregparse

:say
if "%~1" == "--before-welcome" (
    echo;
    shift /1
) else (
    call:welcomescreen
)
:say_loop
if "%~1" == "" (
    if %1. == . (exit /b)
    echo;
    shift /1
    goto say_loop
)
set "say_content=%~1"
set "say_content=%say_content:&=^&%"
echo         %say_content%
shift /1
goto say_loop
::say

:err
set ec=1
if "%~1" == "--before-welcome" (
    echo;
    shift /1
) else (
    call:welcomescreen
)
:err_loop
if "%~1" == "" (
    if %1. == . (exit /b)
    >&2 echo;
    shift /1
    goto err_loop
)
>&2 echo         %~1
shift /1
goto err_loop
::err

:help
call:say --before-welcome "usage: install.bat" "   or: install.bat --uninstall"
goto end

:end
title %ComSpec%
if defined _exit (exit /b %ec%)
@echo         Press any key to exit
pause >nul
exit /b %ec%
