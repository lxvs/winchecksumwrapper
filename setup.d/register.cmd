@if not defined name (exit /b)
call unregister.cmd 1>nul 2>&1
call getreg.cmd "HKCU\Environment" "Path" UserPath
if defined UserPath (
    if not defined silent (
        setx Path "%path_dir%;%UserPath%" 1>nul || exit /b
        reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\App Paths\%name%.exe" /ve /d "%path_dir%\%exec%" /f 1>nul
    ) else (
        setx Path "%path_dir%;%UserPath%" 1>nul 2>&1 || exit /b
        reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\App Paths\%name%.exe" /ve /d "%path_dir%\%exec%" /f 1>nul 2>&1
    )
) else (
    if not defined silent (>&2 echo error: failed to get user Path)
    exit /b 1
)
exit /b 0
