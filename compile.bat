@echo off
set CP=.;ij.jar

rem -- add the current directory, ij.jar, and ij/images onto the CP
set CP=.;ij.jar;ij\images

rem -- re-compile the parts of ImageJ you modified ------------
javac -Xlint:none -cp "%CP%" ij\ImageJ.java
javac -Xlint:none -cp "%CP%" ij\plugin\*.java
javac -Xlint:none -cp "%CP%" ij\plugin\filter\*.java
javac -Xlint:none -cp "%CP%" ij\plugin\frame\*.java

rem -- NEW: compile the startup plug-in -----------------------
javac -Xlint:none -cp "%CP%" plugins\Default1440DPI.java

rem -- launch -------------------------------------------------
java -cp "%CP%" ij.ImageJ
