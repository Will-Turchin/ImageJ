@echo off
setlocal

REM ─── Configuration ─────────────────────────────────────────────────────────
set OUT_DIR=out
set FAT_JAR=ImageJ-modified.jar
set MAIN_CLASS=ij.ImageJ

REM ─── 1) Clean and recreate out directory ─────────────────────────────────
if exist %OUT_DIR% rd /s /q %OUT_DIR%
mkdir %OUT_DIR%

REM ─── 2) Compile core + gui + plugin sources into out ────────────────────
echo Recursively compiling every .java under ij\ into %OUT_DIR%\...
for /R ij %%F in (*.java) do (
  javac -Xlint:none -d %OUT_DIR% "%%F" || (
    echo.
    echo *** Compilation failed at %%F
    exit /b 1
  )
)
if errorlevel 1 (
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

REM ─── 4) Package everything into the fat JAR ──────────────────────────────
echo Packaging all classes into %FAT_JAR%...
jar cfm %FAT_JAR% manifest.txt -C %OUT_DIR% .
if errorlevel 1 (
  echo.
  echo *** Failed to build %FAT_JAR%
  pause
  exit /b 1
)

echo.
echo Build complete!
echo Run it with:
echo     java -jar %FAT_JAR%
pause

endlocal
