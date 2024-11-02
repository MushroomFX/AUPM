@echo off

:: BatchGotAdmin
:-------------------------------------
REM  --> Check for permissions
    IF "%PROCESSOR_ARCHITECTURE%" EQU "amd64" (
>nul 2>&1 "%SYSTEMROOT%\SysWOW64\cacls.exe" "%SYSTEMROOT%\SysWOW64\config\system"
) ELSE (
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
)

REM --> If error flag set, we do not have admin.
if '%errorlevel%' NEQ '0' (
    echo Requesting administrative privileges...
    goto UACPrompt
) else ( goto gotAdmin )

:UACPrompt
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    set params= %*
    echo UAC.ShellExecute "cmd.exe", "/c ""%~s0"" %params:"=""%", "", "runas", 1 >> "%temp%\getadmin.vbs"

    "%temp%\getadmin.vbs"
    del "%temp%\getadmin.vbs"
    exit /B

:gotAdmin
    pushd "%CD%"
    CD /D "%~dp0"
:-------------------------------------- 

node -v >nul 2>&1
if errorlevel 1 (
    echo Node.js is not installed.
    echo Trying to install Node!
    
    rmdir /S /Q tempNodeInstall
    mkdir tempNodeInstall
    cd tempNodeInstall/

    curl https://nodejs.org/dist/v22.11.0/node-v22.11.0-x64.msi -o node.msi
    msiexec /i node.msi /quiet
    cd.. 
    rmdir /Q /S tempNodeInstall

    @echo off
    echo.
    echo.
    echo.
    echo Installed node!
    echo Run this script again!
    echo If node is still not working, install it here: https://nodejs.org

    timeout -1

) else (
    echo Node.js is installed
    npm install
    npm run make
    
    cd "out\make\squirrel.windows\x64"
    "aupm-1.0.0 Setup.exe"

    timeout -1
)