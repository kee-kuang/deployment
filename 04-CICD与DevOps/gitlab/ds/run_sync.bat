@echo off
echo Starting sync process...
cd /d %~dp0

:: 设置Python路径（根据您的Python安装路径修改）
set PYTHON_PATH=python

:: 执行第一个脚本
echo Running sync-devops.py...
%PYTHON_PATH% sync-devops.py
if %ERRORLEVEL% NEQ 0 (
    echo sync-devops.py failed with error %ERRORLEVEL%
    exit /b %ERRORLEVEL%
)

:: 等待5秒
timeout /t 5

:: 执行第二个脚本
echo Running sync-repositories.py...
%PYTHON_PATH% sync-repositories.py
if %ERRORLEVEL% NEQ 0 (
    echo sync-repositories.py failed with error %ERRORLEVEL%
    exit /b %ERRORLEVEL%
)

echo Sync process completed successfully. 