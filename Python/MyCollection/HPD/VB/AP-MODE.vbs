dim ArgObj, DID
set fso = CreateObject("Scripting.FileSystemObject")
set ArgObj = WScript.Arguments
DID = ArgObj(0)
Wscript.Echo ArgObj(0)

set OBJECT=WScript.CreateObject("WScript.Shell")

WScript.sleep 1000
OBJECT.SendKeys "adb -s "& DID & " root{ENTER}"
WScript.sleep 1000
OBJECT.SendKeys "adb -s "& DID & " shell{ENTER}"
WScript.sleep 1000

Do While 1
	OBJECT.SendKeys "QCMAP_CLI{ENTER}" 

	WScript.sleep 1000
	OBJECT.SendKeys "30{ENTER}" 
	WScript.sleep 1000
	OBJECT.SendKeys "1{ENTER}" 
	WScript.sleep 1000
	OBJECT.SendKeys "31{ENTER}" 
	WScript.sleep 1000
	OBJECT.SendKeys "1{ENTER}" 
	WScript.sleep 3000
	OBJECT.SendKeys "36{ENTER}" 
	WScript.sleep 1000
	OBJECT.SendKeys "1{ENTER}" 
	WScript.sleep 1000
	OBJECT.SendKeys "0{ENTER}" 
	WScript.sleep 1000
	OBJECT.SendKeys "0{ENTER}" 
	WScript.sleep 1000
	OBJECT.SendKeys "38{ENTER}" 
	WScript.sleep 10000

	OBJECT.SendKeys "96{ENTER}" 
	WScript.sleep 10000
Loop


