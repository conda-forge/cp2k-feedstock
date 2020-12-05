@echo off

SET ARCH=Windows-x64-conda
SET VERSION=sopt
COPY  %RECIPE_DIR%/%ARCH%.%VERSION% arch\%ARCH%.%VERSION%
make -j%CPU_COUNT% ARCH=%ARCH% VERSION=%VERSION%
make -j%CPU_COUNT% ARCH=%ARCH% VERSION=%VERSION% test
cd %SRC_DIR%
mkdir %PREFIX%\bin
COPY  exe\%ARCH%\cp2k.%VERSION% %PREFIX%\bin\cp2k.%VERSION%
COPY  exe\%ARCH%\cp2k_shell.%VERSION% %PREFIX%\bin\cp2k_shell.%VERSION%
