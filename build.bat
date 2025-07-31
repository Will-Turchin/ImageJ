@echo off
setlocal EnableDelayedExpansion
cd /d %~dp0

REM ─── Configuration ─────────────────────────────────────────────────────────
set "OUT_DIR=out"
set "TMP_DIR=tmp"
set "IJ_CORE_JAR=ij.jar"
set "TWELVE_MONKEYS_DIR=twelvemonkeysjars"
set "FAT_JAR=RavenJ.jar"
set "MAIN_CLASS=ij.ImageJ"

REM ─── Build a compile-time CP that includes ij.jar, images, AND all TwelveMonkeys jars
set "CP=.;%IJ_CORE_JAR%;ij\images"
for %%f in ("%TWELVE_MONKEYS_DIR%\*.jar") do (
    set "CP=!CP!;%%~f"
)

echo Using compile CP:
echo   %CP%
echo.

REM ─── 1) Clean & recreate output dirs ──────────────────────────────────────
if exist "%OUT_DIR%" rd /s /q "%OUT_DIR%"
if exist "%TMP_DIR%" rd /s /q "%TMP_DIR%"
mkdir "%OUT_DIR%" "%TMP_DIR%"

REM ─── 2) Compile all IJ sources against ij.jar + TwelveMonkeys SPI ────────
echo Gathering sources...
del /q sources.txt 2>nul

REM 1) %%~f  – full path
REM 2) convert \ → / (avoids javac escaping rules)
REM 3) wrap in quotes to preserve spaces
for /R "ij" %%f in (*.java) do (
    set "p=%%~f"
    set "p=!p:\=/!"
    echo "!p!">>sources.txt
)

echo Compiling...
javac -encoding UTF-8 -cp "%CP%" -Xlint:none -d "%OUT_DIR%" @sources.txt || (
  echo.
  echo *** Compilation failed
  pause
  exit /b 1
)
del sources.txt

REM ─── 3) Write manifest ───────────────────────────────────────────────────
(
  echo Main-Class: %MAIN_CLASS%
  echo.
) > manifest.txt

REM ─── 4) Unpack ij.jar + TwelveMonkeys into tmp ───────────────────────────
echo Unpacking "%IJ_CORE_JAR%" into "%TMP_DIR%"\...
pushd "%TMP_DIR%"
  jar xf "..\%IJ_CORE_JAR%"
popd

echo Unpacking TwelveMonkeys jars...
for %%f in ("%TWELVE_MONKEYS_DIR%\*.jar") do (
  echo    %%~nxf
  pushd "%TMP_DIR%"
    jar xf "..\%%f"
  popd
)
del "%TMP_DIR%\META-INF\*.SF"  2>nul
del "%TMP_DIR%\META-INF\*.DSA" 2>nul

REM ─── 5) Overlay your newly compiled classes & resources ──────────────────
echo Overlaying modified classes…
robocopy "%OUT_DIR%" "%TMP_DIR%" /E /NFL /NDL /NJH /NJS >nul

REM optional images
if exist "images\microscope.gif" (
    if not exist "%TMP_DIR%\images" mkdir "%TMP_DIR%\images"
    copy "images\microscope.gif" "%TMP_DIR%\images\" >nul
)
if exist "images\about.jpg" (
    if not exist "%TMP_DIR%\images" mkdir "%TMP_DIR%\images"
    copy "images\about.jpg" "%TMP_DIR%\images\" >nul
)

REM IJ_Props.txt (optional)
if exist "IJ_Props.txt" copy "IJ_Props.txt" "%TMP_DIR%\" >nul

REM macros folder (optional)
if exist "macros" (
    robocopy "macros" "%TMP_DIR%\macros" /E /NFL /NDL /NJH /NJS >nul
)

REM extra plugin stubs (optional)
if not exist "%TMP_DIR%\ij\plugin" mkdir "%TMP_DIR%\ij\plugin"
if exist "plugins\MacAdapter.class"  copy "plugins\MacAdapter.class"  "%TMP_DIR%\ij\plugin\" >nul
if exist "plugins\MacAdapter9.class" copy "plugins\MacAdapter9.class" "%TMP_DIR%\ij\plugin\" >nul

REM ─── 6) Package into fat JAR ─────────────────────────────────────────────
echo Packaging "%FAT_JAR%" with resources and classes...
jar cfm "%FAT_JAR%" manifest.txt -C "%TMP_DIR%" . || (
  echo.
  echo *** Failed to build "%FAT_JAR%"
  pause
  exit /b 1
)

REM ─── 7) Cleanup ────────────────────────────────────────────────────────────
rd /s /q "%TMP_DIR%"

echo.
echo Build complete!
echo You can now run:
echo     java -jar "%FAT_JAR%"
pause

endlocal
