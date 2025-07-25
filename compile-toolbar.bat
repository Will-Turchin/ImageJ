@echo off
set CP=.;ij.jar;ij\images

rem -- Compile all ij source files
javac -source 8 -target 8 -Xlint:none -cp "%CP%" ij\gui\Toolbar.java

rem -- NEW: compile the startup plug-in -----------------------
rem javac -Xlint:none -cp "%CP%" plugins\Default1440DPI.java

jar cf ij.jar ij

rem -- launch -------------------------------------------------
java -cp "%CP%" ij.ImageJ