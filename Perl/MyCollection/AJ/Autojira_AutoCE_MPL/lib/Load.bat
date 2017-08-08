@echo off


xcopy /Y /R %cd%\auto\Win32\API\* C:\Perl\lib\auto\Win32\API\
xcopy /Y /R %cd%\auto\Win32\API\Callback\* C:\Perl\lib\auto\Win32\API\Callback\
xcopy /Y /R %cd%\auto\List\Util\* C:\Perl\lib\auto\List\Util\
xcopy /Y /R %cd%\auto\List\MoreUtils\* C:\Perl\lib\auto\List\MoreUtils\

xcopy /Y /R %cd%\Crypt\* C:\Perl\lib\Crypt\

xcopy /Y /R %cd%\Data\* C:\Perl\lib\Data\

xcopy /Y /R %cd%\Digest\Perl\* C:\Perl\lib\Digest\Perl\

xcopy /Y /R %cd%\IO\* C:\Perl\lib\IO\

xcopy /Y /R %cd%\List\* C:\Perl\lib\List\

xcopy /Y /R %cd%\OLE\* C:\Perl\lib\OLE\

xcopy /Y /R %cd%\Scalar\* C:\Perl\lib\Scalar\

xcopy /Y /R %cd%\Spreadsheet\* C:\Perl\lib\Spreadsheet\
xcopy /Y /R %cd%\Spreadsheet\ParseExcel\* C:\Perl\lib\Spreadsheet\ParseExcel\
xcopy /Y /R %cd%\Spreadsheet\ParseExcel\SaveParser\* C:\Perl\lib\Spreadsheet\ParseExcel\SaveParser\

xcopy /Y /R %cd%\Win32\* C:\Perl\lib\Win32\
xcopy /Y /R %cd%\Win32\API\* C:\Perl\lib\Win32\API\

pause

