@echo off  
setlocal enabledelayedexpansion  
set folderPath=%1
set "outputFile=output.txt"
  
(  
    for /r "%folderPath%" %%F in (*) do (  
        set "fileSize=0"  
        for %%i in ("%%~zF") do set "fileSize=%%~i"  
        echo %%F !fileSize! bytes  
    )  
) > "%outputFile%"  
  
echo Files and sizes have been dumped to %outputFile%  
endlocal
