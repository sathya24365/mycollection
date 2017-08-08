@echo off

xcopy /Y /R %cd%\Data\* C:\Perl\lib\Data\
xcopy /Y /R %cd%\Win32\* C:\Perl\lib\Win32\

pause

