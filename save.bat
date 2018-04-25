@echo off
setlocal

pushd %cd%
git status --short
popd

set /p commitmsg="input your commit message>"
if "%commitmsg%"=="" (
	echo A commit message is required.
	exit /b
)
pushd %cd%
echo saving...
git add -A
git commit -m "%commitmsg%"
popd
