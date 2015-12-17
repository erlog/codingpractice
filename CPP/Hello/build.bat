@echo off
IF %VISUALSTUDIOVERSION%=="" CALL "C:\Program Files (x86)\Microsoft Visual Studio 14.0\VC\vcvarsall.bat"
cl /EHsc hello.cpp
