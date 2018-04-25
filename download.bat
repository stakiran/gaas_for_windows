@echo off
setlocal

pushd %cd%
echo downloading...
git pull
popd

call %~dp0displaywait.bat
