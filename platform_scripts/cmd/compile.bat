@echo off
setlocal enabledelayedexpansion

REM ptex の --jobname オプションを前提としているので，動作保証は TeX Live 版のみです。

set WORKING_DIR=
set SHOW_HELP=
set EXERCISE=
set FILE=
set FILE_SPECIFIED=
call :parse_args %*

call :run "is_TeX_installed"
call :run "is_dvipdfmx_installed"
call :run "main"
goto :end

:parse_args
:parse_args_loop
if "%~1"=="" goto :parse_args_done
if "%~1"=="-d" (
    if "%~2"=="" (
        echo Error: -d option requires a directory argument
        exit /b 1
    )
    set "WORKING_DIR=%~2"
    shift
    shift
    goto :parse_args_loop
)
if "%~1"=="--directory" (
    if "%~2"=="" (
        echo Error: --directory option requires a directory argument
        exit /b 1
    )
    set "WORKING_DIR=%~2"
    shift
    shift
    goto :parse_args_loop
)
if "%~1"=="--dir" (
    if "%~2"=="" (
        echo Error: --directory option requires a directory argument
        exit /b 1
    )
    set "WORKING_DIR=%~2"
    shift
    shift
    goto :parse_args_loop
)
if "%~1"=="--exercise" (
    if "%~2"=="" (
        echo Error: --exercise option requires a exercise number argument
        exit /b 1
    )
    set "EXERCISE=%~2"
    shift
    shift
    goto :parse_args_loop
)
if "%~1"=="--exe" (
    if "%~2"=="" (
        echo Error: --exe option requires a exercise number argument
        exit /b 1
    )
    set "EXERCISE=%~2"
    shift
    shift
    goto :parse_args_loop
)
if "%~1"=="-e" (
    if "%~2"=="" (
        echo Error: -e option requires a exercise number argument
        exit /b 1
    )
    set "EXERCISE=%~2"
    shift
    shift
    goto :parse_args_loop
)
if "%~1"=="-h" (
    set "SHOW_HELP=1"
    shift
    goto :parse_args_loop
)
if "%~1"=="--help" (
    set "SHOW_HELP=1"
    shift
    goto :parse_args_loop
)
if "%FILE_SPECIFIED%"=="" (
    set "FILE=%~1"
    set "FILE_SPECIFIED=1"
    shift
    goto :parse_args_loop
)
echo Error: Unknown option "%~1"
echo;
goto :end
exit /b 1

:parse_args_done
echo SHOW_HELP: [%SHOW_HELP%]
echo FILE: [%FILE%]
echo EXERCISE: [%EXERCISE%]
echo WORKING_DIR: [%WORKING_DIR%]
echo;
exit /b 0

:run
echo begin %~1
call :%~1
if errorlevel 1 (
    echo Error: %~1 failed.
    exit /b 1
)
echo end %~1
echo.
exit /b 0

:is_TeX_installed
ptex --version >nul 2>&1
if %errorlevel% equ 0 (
    for /f "tokens=*" %%a in ('tex --version 2^>nul ^| findstr "^e-upTeX "') do (
        for /f "tokens=2" %%b in ("%%a") do (
            echo TeX %%b is installed.
        )
    )
)
exit /b 0

:is_dvipdfmx_installed
dvipdfmx --version >nul 2>&1
if %errorlevel% equ 0 (
    echo dvipdfmx is installed
) else (
    echo dvipdfmx is not found
)
exit /b 0

:main
if defined SHOW_HELP (
    echo Help was requested
    goto :main_end
)
if defined WORKING_DIR (
    if not exist "%WORKING_DIR%" (
        echo Error: Directory "%WORKING_DIR%" does not exist.
        goto :main_end
    )
    cd /d "%WORKING_DIR%"
    if %errorlevel% neq 0 (
        echo Error: Failed to change to directory "%WORKING_DIR%".
        goto :main_end
    )
    echo Changed to directory: %WORKING_DIR%
)

if "%FILE_SPECIFIED%"=="1" (
    if exist "%FILE%.tex" (
        set "%FILE"="%FILE%.tex"
        goto :compile_file
    )
    if exist "%FILE%" (
        goto :compile_file
    )
    echo Error: File "%FILE%.tex" or "%FILE%" does not exist in the current directory.
    echo Hint: If you want to change working directory, then you specify --directory option.
    goto :main_end
)
if "%FILE_SPECIFIED%"=="" (
    if defined %EXERCISE% (
        if exist "%EXERCISE%.tex" (
            set "%FILE"="%EXERCISE%.tex"
            set "%FILE_SPECIFIED%"=1
            goto :compile_file
        )
        if exist "%EXERCISE%" (
            set "%FILE"="%EXERCISE%"
            set "%FILE_SPECIFIED%"=1
            goto :compile_file
        )
        echo Error: File "%EXERCISE%.tex" or "%EXERCISE%" does not exist in the current directory.
        echo Hint: If you want to change working directory, then you specify --directory option.
        goto :main_end
    )
    echo Error: Any source file is not specified. You can use --file option or --exercise option.  
    goto :main_end
)

:compile_file
echo %FILE%
ptex --jobname="%FILE%" %FILE%
dvipdfmx %FILE%.dvi
goto :main_end

:main_end
exit /b 0

:end
echo end.