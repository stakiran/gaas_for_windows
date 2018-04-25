@echo off
setlocal

pushd %cd%
set GITSTATUS=
for /F "usebackq" %%i in (`git status --short`) do (
  set GITSTATUS=%%i
)
popd

if "%GITSTATUS%"=="" (
	rem pass
) else (
	call %~dp0save.bat
)

pushd %cd%
echo uploading...
git push origin master
popd

call %~dp0displaywait.bat
