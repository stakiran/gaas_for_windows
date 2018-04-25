@echo off
setlocal
set TERM=msys
for /F "usebackq" %%i in (`dir %~dp0 /b /ad`) do (
	if exist %~dp0%%i\.git (
		pushd %~dp0%%i
		echo [%%i]
		git status --short
		git diff origin/master --name-status
		popd
	)
)
pause
