@echo off
setlocal

REM ─── Configuration ─────────────────────────────────────────────────────────
set "OUT_DIR=out"
set "TMP_DIR=tmp"
set "IJ_CORE_JAR=ij.jar"
set "FAT_JAR=RavenJ.jar"
set "MAIN_CLASS=ij.ImageJ"

REM ─── 1) Clean out & tmp dirs ──────────────────────────────────────────────
if exist "%OUT_DIR%" rd /s /q "%OUT_DIR%"
if exist "%TMP_DIR%" rd /s /q "%TMP_DIR%"
mkdir "%OUT_DIR%" "%TMP_DIR%"

REM ─── 2) Compile your modified core + GUI + plugins in one javac call ─────
echo Compiling modified core + GUI + plugin sources...
javac -Xlint:none -d "%OUT_DIR%" ^
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

REM ─── 3) Write manifest.txt ──────────────────────────────────────────────
(
  echo Main-Class: %MAIN_CLASS%
  echo.
) > manifest.txt

REM ─── 4) Unpack full ImageJ core (classes + resources) ────────────────────
echo Unpacking "%IJ_CORE_JAR%" into "%TMP_DIR%"\...
pushd "%TMP_DIR%"
  jar xf "..\%IJ_CORE_JAR%"
popd

REM ─── 5) Overlay your newly compiled classes ───────────────────────────────
echo Overlaying modified classes...
xcopy /Y /E "%OUT_DIR%\*" "%TMP_DIR%\" >nul

REM ─── Copy resources needed at runtime ────────────────────────────────────
if not exist "%TMP_DIR%\images" mkdir "%TMP_DIR%\images"
copy images\microscope.gif "%TMP_DIR%\images\" >nul
copy images\about.jpg "%TMP_DIR%\images\" >nul
copy IJ_Props.txt "%TMP_DIR%\" >nul
xcopy /Y /E "macros" "%TMP_DIR%\macros\" >nul
if not exist "%TMP_DIR%\ij\plugin" mkdir "%TMP_DIR%\ij\plugin"
copy plugins\MacAdapter.class "%TMP_DIR%\ij\plugin\" >nul
copy plugins\MacAdapter9.class "%TMP_DIR%\ij\plugin\" >nul

REM ─── 6) Package everything into the fat JAR ──────────────────────────────
echo Packaging "%FAT_JAR%" with resources and classes...
jar cfm "%FAT_JAR%" manifest.txt -C "%TMP_DIR%" . || (
  echo.
  echo *** Failed to build "%FAT_JAR%"
  pause
  exit /b 1
)

REM ─── 7) Cleanup temporary folder ────────────────────────────────────────
rd /s /q "%TMP_DIR%"

echo.
echo Build complete!
echo You can now double-click or run:
echo     java -jar "%FAT_JAR%"
pause

endlocal
