@echo off
setlocal enabledelayedexpansion

goto :boot

REM ptex �� --jobname �I�v�V������O��Ƃ��Ă���̂ŁC����ۏ؂� TeX Live �ł݂̂ł��B
REM --exercise �I�v�V�������w�肷��ꍇ�C�f�t�H���g�őÓ��ȃt�H���_��T���@�\��ǉ����������悢�悤�ȋC�����Ă��܂������Ή��ł��B

:show_help
echo �T�v�F
echo   TeX �t�@�C���� ptex �� dvipdfmx ���g�p���� PDF �ɕϊ����܂��B
echo   ptex �� --jobname �I�v�V�������g�p�ł��邱�Ƃ�O��Ƃ��Ă���C����ۏ؂� TeX Live �ł݂̂ł��B
echo.
echo �g�p���@�F
echo   %~n0     [�I�v�V����] [�t�@�C����]
echo   %~nx0 [�I�v�V����] [�t�@�C����]
echo.
echo �I�v�V�����F
echo   -h, --help                          ���̃w���v���b�Z�[�W��\�����܂��B
echo   -d, --directory, --dir ^<DIR^>        �J�����g�f�B���N�g����^<DIR^>�Ɏw�肵�܂��B
echo   -e, --exercise, --exe ^<NUM^>         ���K����^<NUM^>�Ɏw�肵�܂��B
echo                                       �������C^<NUM^>::=^<�͔ԍ�^>.^<���ԍ�^>�Ƃ��C
echo                                       ^<�͔ԍ�^>�̓[�����߂��Ȃ����̂Ƃ��܂��B
echo.
echo �����F
echo   �t�@�C����                          �R���p�C������ TeX �t�@�C����
echo                                       �i.tex �g���q�͏ȗ��\�ł��j
echo.
echo �g�p��F
echo   %~nx0 report                  �J�����g�f�B���N�g���� report.tex ��g�ł���B
echo   %~nx0 -d C:\tex report        �w�肵���f�B���N�g���� report.tex ��g�ł���B
echo   %~nx0 --exercise 2.3          ���K��� 2.3.tex ��g�ł���B
echo   %~nx0 -d exercises -e 1.5     exercises �f�B���N�g���ŉ��K��� 1.5 ��g�ł���B
echo.
echo ���K���Ɋւ���⑫�F
echo   --exercise �I�v�V�����͈ȉ��̏����Ńt�@�C�����������܂��F
echo   1. ���݂̃f�B���N�g���� ^<�͔ԍ�^>.^<���ԍ�^>.tex ���������܂��B
echo   2. ../../exercise/ch^<2���Ń[�����߂����͔ԍ�^>/ �f�B���N�g���� ^<�͔ԍ�^>.^<���ԍ�^>.tex ���������܂��B
echo      ������^<2���Ń[�����߂����͔ԍ�^>�́C^<�͔ԍ�^>���ꌅ�̏ꍇ�ɁC0��擪�ɕt�������̂Ƃ��Ē�`����܂��B
echo.
echo ���ӎ����F
echo   *  ptex �� dvipdfmx ���C���X�g�[������Ă���K�v������܂��B
echo   *  ptex �� --jobname �I�v�V�����ɑΉ����Ă���K�v������܂��B
echo   *  ���K���̃t�@�C�������@�\�́Ctex-book-25 ���|�W�g���̃f�B���N�g���\����z�肵�����̂ł��B
echo.
exit /b 0

:boot
set WORKING_DIR=
set SHOW_HELP=
set EXERCISE=
set FILE=
set FILE_SPECIFIED=

call :parse_args %*
if errorlevel 1 goto :end

call :init
if errorlevel 1 goto :end

REM �w���v���\�����ꂽ�ꍇ�͏I��
if defined SHOW_HELP goto :end

call :run "is_TeX_installed"
if errorlevel 1 goto :end

call :run "is_dvipdfmx_installed"
if errorlevel 1 goto :end

call :run "main"
goto :end

:parse_args
:parse_args_loop
if "%~1"=="" goto :parse_args_done
if "%~1"=="-d" (
    if "%~2"=="" (
        echo Error: -d �I�v�V�����́C�ړ���̃f�B���N�g���������Ƃ��ēn���K�v������܂��B
        exit /b 1
    )
    set "WORKING_DIR=%~2"
    shift
    shift
    goto :parse_args_loop
)
if "%~1"=="--directory" (
    if "%~2"=="" (
        echo Error: --directory �I�v�V�����́C�ړ���̃f�B���N�g���������Ƃ��ēn���K�v������܂��B
        exit /b 1
    )
    set "WORKING_DIR=%~2"
    shift
    shift
    goto :parse_args_loop
)
if "%~1"=="--dir" (
    if "%~2"=="" (
        echo Error: --directory �I�v�V�����́C�ړ���̃f�B���N�g���������Ƃ��ēn���K�v������܂��B
        exit /b 1
    )
    set "WORKING_DIR=%~2"
    shift
    shift
    goto :parse_args_loop
)
if "%~1"=="--exercise" (
    if "%~2"=="" (
        echo Error: --exercise �I�v�V�����́C^<�͔ԍ�^>.^<���ԍ�^>�`���ŕ\�����ꂽ���K���������Ƃ��ēn���K�v������܂��B
        exit /b 1
    )
    set "EXERCISE=%~2"
    shift
    shift
    goto :parse_args_loop
)
if "%~1"=="--exe" (
    if "%~2"=="" (
        echo Error: --exe option �I�v�V�����́C^<�͔ԍ�^>.^<���ԍ�^>�`���ŕ\�����ꂽ���K���������Ƃ��ēn���K�v������܂��B
        exit /b 1
    )
    set "EXERCISE=%~2"
    shift
    shift
    goto :parse_args_loop
)
if "%~1"=="-e" (
    if "%~2"=="" (
        echo Error: -e �I�v�V�����́C^<�͔ԍ�^>.^<���ԍ�^>�`���ŕ\�����ꂽ���K���������Ƃ��ēn���K�v������܂��B
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
echo Error: �z�肳��Ă��Ȃ��I�v�V�����ł��F"%~1"
echo.
exit /b 1

:parse_args_done
rem echo SHOW_HELP: [%SHOW_HELP%]
rem echo FILE: [%FILE%]
rem echo EXERCISE: [%EXERCISE%]
rem echo WORKING_DIR: [%WORKING_DIR%]
rem echo;
exit /b 0

:init
if defined SHOW_HELP (
    call :show_help
    exit /b 0
)
exit /b 0

:run
echo Log:   begin %~1
call :%~1
if errorlevel 1 (
    echo Error: %~1 �̎��s�Ɏ��s���܂����B
    exit /b 1
)
echo Log:   end %~1
echo.
exit /b 0

:is_TeX_installed
ptex --version >nul 2>&1
if %errorlevel% equ 0 (
    for /f "tokens=*" %%a in ('ptex --version 2^>nul ^| findstr "^e-upTeX "') do (
        for /f "tokens=2" %%b in ("%%a") do (
            echo Log:   pTeX %%b is installed.
        )
    )
) else (
    echo Error: pTeX ���C���X�g�[������Ă��܂���B
)
exit /b 0

:is_dvipdfmx_installed
dvipdfmx --version >nul 2>&1
if %errorlevel% equ 0 (
    echo Log:   dvipdfmx is installed
) else (
    echo Error: dvipdfmx ���C���X�g�[������Ă��܂���B
)
exit /b 0

:main
call :change_working_directory
if errorlevel 1 goto :main_end

call :determine_and_compile_file
if errorlevel 1 goto :main_end

:main_end
exit /b 0

:change_working_directory
if not defined WORKING_DIR exit /b 0

if not exist "%WORKING_DIR%" (
    echo Error: "%WORKING_DIR%"�f�B���N�g�������݂��܂���B
    exit /b 1
)

cd /d "%WORKING_DIR%"
if %errorlevel% neq 0 (
    echo Error: "%WORKING_DIR%"�f�B���N�g���Ɉړ��ł��܂���ł����B
    exit /b 1
)

echo Log:   %WORKING_DIR%�f�B���N�g���Ɉړ����܂����B
exit /b 0

:determine_and_compile_file
if "%FILE_SPECIFIED%"=="1" (
    call :handle_file_specified
    exit /b %errorlevel%
)

if defined EXERCISE (
    call :handle_exercise_specified
    exit /b %errorlevel%
)

echo Error: �\�[�X�t�@�C�����w�肳��Ă��Ȃ����C�J�����g�f�B���N�g���Ɍ�����܂���B�����Ƀt�@�C������n�����C--exercise �I�v�V�������w�肵�Ă��������B
echo Hint:  �J�����g�f�B���N�g����ύX�������ꍇ�́C--directory �I�v�V�������w�肵�Ă��������B
exit /b 1

:handle_file_specified
if exist "%FILE%.tex" (
    set "FILE=%FILE%.tex"
    call :compile_file
    exit /b 0
)

if exist "%FILE%" (
    call :compile_file
    exit /b 0
)

echo Error: "%FILE%.tex"�C"%FILE%"���J�����g�f�B���N�g���ɑ��݂��܂���Bdoes not exist in the current directory.
echo Hint:  �J�����g�f�B���N�g����ύX�������ꍇ�́C--directory �I�v�V�������w�肵�Ă��������B
exit /b 1

:handle_exercise_specified
call :parse_exercise_number
if errorlevel 1 exit /b 1

call :try_current_directory
if %errorlevel% equ 0 exit /b 0

call :try_exercise_directory
exit /b %errorlevel%

:parse_exercise_number
set TEMP=%EXERCISE%
for /f "tokens=1 delims=." %%a in ("%TEMP%") do (
    set "Chapter=%%a"
)
for /f "tokens=2 delims=." %%a in ("%TEMP%") do (
    set "Problem=%%a"
)

if not defined Chapter (
    echo Error: ���K���̌`��������������܂���B^<�͔ԍ�^>.^<���ԍ�^>�`���ŕ\�����ꂽ���K���������Ƃ��ēn���K�v������܂��B
    exit /b 1
)

if not defined Problem (
    echo Error: ���K���̌`��������������܂���B^<�͔ԍ�^>.^<���ԍ�^>�`���ŕ\�����ꂽ���K���������Ƃ��ēn���K�v������܂��B
    exit /b 1
)

exit /b 0

:try_current_directory
if exist "%Chapter%.%Problem%.tex" (
    set "FILE=%Chapter%.%Problem%.tex"
    set "FILE_SPECIFIED=1"
    call :compile_file
    exit /b 0
)
exit /b 1

:try_exercise_directory
set "PaddedChapter=0%Chapter%"
set "PaddedChapter=%PaddedChapter:~-2%"
if not exist "../../exercise/ch%PaddedChapter%" (
    echo Error: "%Chapter%.%Problem%.tex"�t�@�C�����J�����g�f�B���N�g���ɑ��݂��܂���B
    echo Hint:  �J�����g�f�B���N�g����ύX�������ꍇ�́C--directory �I�v�V�������w�肵�Ă��������B
    exit /b 1
)

pushd "../../exercise/ch%PaddedChapter%"
if exist "%Chapter%.%Problem%.tex" (
    set "FILE=%Chapter%.%Problem%.tex"
    set "FILE_SPECIFIED=1"
    popd
    cd /d "../../exercise/ch%PaddedChapter%"
    call :compile_file
    exit /b 0
)

popd
echo Error: "%Chapter%.%Problem%.tex"�t�@�C�����J�����g�f�B���N�g���ɑ��݂��܂���B
echo Hint:  �J�����g�f�B���N�g����ύX�������ꍇ�́C--directory �I�v�V�������w�肵�Ă��������B
exit /b 1

:compile_file
echo Compiling: %FILE%
ptex --jobname="%FILE%" %FILE%
if %errorlevel% neq 0 (
    echo Error: ptex compilation failed.
    exit /b 1
)

dvipdfmx %FILE%.dvi
if %errorlevel% neq 0 (
    echo Error: dvipdfmx conversion failed.
    exit /b 1
)

echo Log:   Compilation completed successfully.
exit /b 0

:end