@echo off
setlocal ENABLEDELAYEDEXPANSION
echo Dump locations are
echo **************************************
IF EXIST temp.txt del temp.txt
IF EXIST JiraTicketInfo.txt del JiraTicketInfo.txt
echo.
cls
ls
set /p file=Select Test Bed:
cat %file%
echo.
pause
cls
echo Parsing........
	
for /f  "delims=" %%i in (%file%) do ( 
	set /a count=0
	IF EXIST %%i dir /b /s %%i\JiraTicketInfo.txt >> temp.txt	
	echo %%i >> JiraTicketInfo.txt		
	echo ************************************** >> JiraTicketInfo.txt
	IF EXIST temp.txt for /f  "delims=" %%j in (temp.txt) do ( 	
		for /f  "tokens=5 delims=/" %%k in ('type %%j') do set x=%%k
			echo !x!, >> JiraTicketInfo.txt	
			set /a count=!count!+1
	)	
	IF EXIST temp.txt del temp.txt
	echo. >> JiraTicketInfo.txt
	echo Total Jiras::!count! >> JiraTicketInfo.txt
	echo. >> JiraTicketInfo.txt
)
cls
IF EXIST JiraTicketInfo.txt type JiraTicketInfo.txt
setlocal DISABLEDELAYEDEXPANSION
pause