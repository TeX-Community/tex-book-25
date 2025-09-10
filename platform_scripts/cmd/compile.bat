@echo off
setlocal enabledelayedexpansion

goto :boot

REM ptex の --jobname オプションを前提としているので，動作保証は TeX Live 版のみです。
REM --exercise オプションを指定する場合，デフォルトで妥当なフォルダを探す機能を追加した方がよいような気がしていますが未対応です。

:show_help
echo 概要：
echo   TeX ファイルを ptex と dvipdfmx を使用して PDF に変換します。
echo   ptex の --jobname オプションが使用できることを前提としており，動作保証は TeX Live 版のみです。
echo.
echo 使用方法：
echo   %~n0     [オプション] [ファイル名]
echo   %~nx0 [オプション] [ファイル名]
echo.
echo オプション：
echo   -h, --help                          このヘルプメッセージを表示します。
echo   -d, --directory, --dir ^<DIR^>        カレントディレクトリを^<DIR^>に指定します。
echo   -e, --exercise, --exe ^<NUM^>         演習問題を^<NUM^>に指定します。
echo                                       ただし，^<NUM^>::=^<章番号^>.^<問題番号^>とし，
echo                                       ^<章番号^>はゼロ埋めしないものとします。
echo.
echo 引数：
echo   ファイル名                          コンパイルする TeX ファイル名
echo                                       （.tex 拡張子は省略可能です）
echo.
echo 使用例：
echo   %~nx0 report                  カレントディレクトリの report.tex を組版する。
echo   %~nx0 -d C:\tex report        指定したディレクトリの report.tex を組版する。
echo   %~nx0 --exercise 2.3          演習問題 2.3.tex を組版する。
echo   %~nx0 -d exercises -e 1.5     exercises ディレクトリで演習問題 1.5 を組版する。
echo.
echo 演習問題に関する補足：
echo   --exercise オプションは以下の順序でファイルを検索します：
echo   1. 現在のディレクトリで ^<章番号^>.^<問題番号^>.tex を検索します。
echo   2. ../../exercise/ch^<2桁でゼロ埋めした章番号^>/ ディレクトリで ^<章番号^>.^<問題番号^>.tex を検索します。
echo      ここで^<2桁でゼロ埋めした章番号^>は，^<章番号^>が一桁の場合に，0を先頭に付したものとして定義されます。
echo.
echo 注意事項：
echo   *  ptex と dvipdfmx がインストールされている必要があります。
echo   *  ptex は --jobname オプションに対応している必要があります。
echo   *  演習問題のファイル検索機能は，tex-book-25 リポジトリのディレクトリ構造を想定したものです。
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

REM ヘルプが表示された場合は終了
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
        echo Error: -d オプションは，移動先のディレクトリを引数として渡す必要があります。
        exit /b 1
    )
    set "WORKING_DIR=%~2"
    shift
    shift
    goto :parse_args_loop
)
if "%~1"=="--directory" (
    if "%~2"=="" (
        echo Error: --directory オプションは，移動先のディレクトリを引数として渡す必要があります。
        exit /b 1
    )
    set "WORKING_DIR=%~2"
    shift
    shift
    goto :parse_args_loop
)
if "%~1"=="--dir" (
    if "%~2"=="" (
        echo Error: --directory オプションは，移動先のディレクトリを引数として渡す必要があります。
        exit /b 1
    )
    set "WORKING_DIR=%~2"
    shift
    shift
    goto :parse_args_loop
)
if "%~1"=="--exercise" (
    if "%~2"=="" (
        echo Error: --exercise オプションは，^<章番号^>.^<問題番号^>形式で表現された演習問題を引数として渡す必要があります。
        exit /b 1
    )
    set "EXERCISE=%~2"
    shift
    shift
    goto :parse_args_loop
)
if "%~1"=="--exe" (
    if "%~2"=="" (
        echo Error: --exe option オプションは，^<章番号^>.^<問題番号^>形式で表現された演習問題を引数として渡す必要があります。
        exit /b 1
    )
    set "EXERCISE=%~2"
    shift
    shift
    goto :parse_args_loop
)
if "%~1"=="-e" (
    if "%~2"=="" (
        echo Error: -e オプションは，^<章番号^>.^<問題番号^>形式で表現された演習問題を引数として渡す必要があります。
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
echo Error: 想定されていないオプションです："%~1"
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
    echo Error: %~1 の実行に失敗しました。
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
    echo Error: pTeX がインストールされていません。
)
exit /b 0

:is_dvipdfmx_installed
dvipdfmx --version >nul 2>&1
if %errorlevel% equ 0 (
    echo Log:   dvipdfmx is installed
) else (
    echo Error: dvipdfmx がインストールされていません。
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
    echo Error: "%WORKING_DIR%"ディレクトリが存在しません。
    exit /b 1
)

cd /d "%WORKING_DIR%"
if %errorlevel% neq 0 (
    echo Error: "%WORKING_DIR%"ディレクトリに移動できませんでした。
    exit /b 1
)

echo Log:   %WORKING_DIR%ディレクトリに移動しました。
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

echo Error: ソースファイルが指定されていないか，カレントディレクトリに見つかりません。引数にファイル名を渡すか，--exercise オプションを指定してください。
echo Hint:  カレントディレクトリを変更したい場合は，--directory オプションを指定してください。
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

echo Error: "%FILE%.tex"，"%FILE%"がカレントディレクトリに存在しません。does not exist in the current directory.
echo Hint:  カレントディレクトリを変更したい場合は，--directory オプションを指定してください。
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
    echo Error: 演習問題の形式が正しくありません。^<章番号^>.^<問題番号^>形式で表現された演習問題を引数として渡す必要があります。
    exit /b 1
)

if not defined Problem (
    echo Error: 演習問題の形式が正しくありません。^<章番号^>.^<問題番号^>形式で表現された演習問題を引数として渡す必要があります。
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
    echo Error: "%Chapter%.%Problem%.tex"ファイルがカレントディレクトリに存在しません。
    echo Hint:  カレントディレクトリを変更したい場合は，--directory オプションを指定してください。
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
echo Error: "%Chapter%.%Problem%.tex"ファイルがカレントディレクトリに存在しません。
echo Hint:  カレントディレクトリを変更したい場合は，--directory オプションを指定してください。
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