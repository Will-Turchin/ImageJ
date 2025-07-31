@echo off
setlocal EnableDelayedExpansion

rem — where twelvemonkeys jars live
set "TWELVE_MONKEYS_DIR=twelvemonkeysjars"

rem — build the compile-time classpath
set "CP=.;ij.jar;ij\images"
for %%f in ("%TWELVE_MONKEYS_DIR%\*.jar") do (
    set "CP=!CP!;%%~f"
)

echo Using class-path:
echo   %CP%
echo.

rem — compile only Toolbar.java into out\
if not exist out md out
javac -encoding UTF-8 -cp "%CP%" -d out ij\gui\Toolbar.java || (
  echo *** Compilation failed
  pause
  exit /b 1
)

rem — update ij.jar with the newly compiled class
jar uf ij.jar -C out ij/gui/Toolbar.class

rem — now run, preferring out\ over ij.jar
set "RUN_CP=out;ij\images;ij.jar;"
for %%f in ("%TWELVE_MONKEYS_DIR%\*.jar") do (
    set "RUN_CP=!RUN_CP!;%%~f"
)

echo Launching with:
echo   %RUN_CP%
java -cp "%RUN_CP%" ij.ImageJ