@echo off
setlocal EnableDelayedExpansion

rem -- Where compiuled classes go
set "OUT_DIR=out"
if not exist "%OUT_DIR%" md "%OUT_DIR%"

rem -- Build compile-time classpath
set "CP=.;ij.jar;ij\images;"
set "TWELVE_MONKEYS_DIR=twelvemonkeysjars"

rem -- Adds twelvemonkeyjars for tiff support
for %%f in ("%TWELVE_MONKEYS_DIR%\*.jar") do (
    set "CP=!CP!;%%~f"
)

echo Using class-path:
echo  %CP%
echo .

rem sanity check if javac see the TIFF SPI
echo Verifying TwelveMonkeys is visible to the compiler
javap -classpath "%CP%" com.twelvemonkeys.imageio.plugins.tiff.TIFFImageWriterSpi >nul 2>&1
if errorlevel 1 (
    echo *** ERROR: TIFFImageWriterSpi not found on compile-time classpath
    pause
    exit /b 1
) else (
    echo     OK TIFF writer class is present.
    echo.
)

rem -- OPTIONAL BACKUP COMMAND IF .class FILES ARE CORRUPT
rem del /s *.class

rem -- Compile all ij source files
javac -encoding UTF-8 -cp "%CP%" -Xlint:none -d "%OUT_DIR%" ^
    ij\*.java ^
    ij\gui\*.java ^
    ij\plugin\*.java ^
    ij\plugin\filter\*.java ^
    ij\plugin\frame\*.java || (
  echo.
  echo *** Compilation failed
  pause
  exit /b 1
)

rem -- Rebuild ij.jar from compiled classes
del /q ij.jar >nul 2>&1
jar cf ij.jar -C "%OUT_DIR%" ij

rem -- run with OUT_DIR *ahead* of ij.jar
set "RUN_CP=%OUT_DIR%;%CP%"
echo Launching with:
echo   %RUN_CP%
java -cp "%RUN_CP%" ij.ImageJ