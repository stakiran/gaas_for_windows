@echo off
for /F "usebackq" %%i in (`dir %~dp0 /b /ad`) do (
	if exist %%i\.git (
		pushd %%i
		echo [%%i]
		git pull
		popd
	)
)
pause
