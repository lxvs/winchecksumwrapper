@if not defined name (exit /b)
call getreg.cmd "HKCU\Environment" "Path" UserPath
setlocal EnableDelayedExpansion
if defined UserPath (
    if not defined silent (
        if defined path_dir (
            setx Path "!UserPath:%path_dir%;=!" 1>nul
        ) else (
            >&2 echo warning: no installation found; try to uninstall anyway
        )
        reg delete "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\%name%.exe" /f 1>nul
    ) else (
        if defined path_dir (setx Path "!UserPath:%path_dir%;=!" 1>nul 2>&1)
        reg delete "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\%name%.exe" /f 1>nul 2>&1
    )
) else (
    if not defined silent (
        >&2 echo error: failed to get user Path
    )
    exit /b 1
)
exit /b 0
