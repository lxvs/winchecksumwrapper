@if not defined _gpss_name (exit /b)
call "%_gpss_target_dir%\install.bat" --uninstall >nul
