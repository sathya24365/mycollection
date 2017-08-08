set t=%TIME: =0%
set t=%t:~3,2%
set /A t=%t% * 60
set /A t=3600-%t%

TIMEOUT /T %t% /NOBREAK

pause



