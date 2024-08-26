@ECHO OFF
TITLE %~n0
IF /i "%OS%" NEQ "Windows_NT" (
    ECHO Script only support on Windows
    PAUSE & EXIT /B 1
)

:FindGit
FOR /f "tokens=2*" %%A IN ('reg QUERY "%~1" /v InstallPath 2^>NUL') DO SET "GIT_PATH=%%B"
IF DEFINED GIT_PATH EXIT /B 0 ELSE EXIT /B 1

CALL :FindGit "HKEY_LOCAL_MACHINE\SOFTWARE\GitForWindows"
IF ERRORLEVEL 1 CALL :FindGit "HKEY_CURRENT_USER\SOFTWARE\GitForWindows"
IF ERRORLEVEL 1 (
    ECHO Git not installed/found
    PAUSE & EXIT /B 1
)

SET "FILE_PATH=%~1"
set "FILE_NAME=%~n1"
SET "FILE_EXT=%~x1"
SET "FILE_PATH_UNIX=%FILE_PATH:\=/%"
IF "%FILE_EXT%" EQU NUL EXIT /B 1
IF /i "%FILE_EXT%" NEQ ".sh" (
    ECHO File extension must match *.sh
    PAUSE & EXIT /B 1
)

TITLE %~n0/%FILE_NAME%
SET "GIT_BASH_PATH=%GIT_PATH%\bin\bash.exe"
"%GIT_BASH_PATH%" -c "'%FILE_PATH_UNIX%' '%~n0'"
PAUSE & EXIT /B 0