@echo off

xcopy /Y /R %cd%\Crypt\* C:\Perl64\lib\Crypt\

xcopy /Y /R %cd%\Digest\Perl\* C:\Perl64\lib\Digest\Perl\

xcopy /Y /R %cd%\OLE\* C:\Perl64\lib\OLE\

xcopy /Y /R %cd%\Spreadsheet\* C:\Perl64\lib\Spreadsheet\
xcopy /Y /R %cd%\Spreadsheet\ParseExcel\* C:\Perl64\lib\Spreadsheet\ParseExcel\
xcopy /Y /R %cd%\Spreadsheet\ParseExcel\SaveParser\* C:\Perl64\lib\Spreadsheet\ParseExcel\SaveParser\


pause

