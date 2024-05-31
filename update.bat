@echo off

chcp 65001

REM 运行 hexo clean 命令
start /b /wait cmd /c "hexo clean"

echo 缓存清除完成

REM 运行 hexo g 命令
start /b /wait cmd /c "hexo g"

echo 构建结束

REM 交互式判断
set /p input='s'\/'d':
if "%input%"=="s" (
    REM 运行 hexo s 命令
    start /b /wait cmd /c "hexo s"
) else if "%input%"=="d" (
    REM 运行 hexo d 命令
    start /b /wait cmd /c "hexo d"
) else (
    echo 无效的输入
)