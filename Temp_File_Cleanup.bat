:: Purpose:       Temp file cleanup
:: Requirements:  Admin access helps but is not required
:: Author:        vocatus on reddit.com/r/sysadmin ( vocatus.gate@gmail.com ) // PGP key ID: 0x82A211A2
:: Version:       3.1  - Removed some double-ampersands (&&)
::                3.0  * Converted some by-line sections into FOR loops
::                2.9b * Reworked CUR_DATE variable to handle more than one Date/Time format
::                       Can now handle ISO standard dates (yyyy-mm-dd) and Windows default dates (e.g. "Fri 01/24/2014")
::                2.9  * Updated the section that deletes a users temp files to loop through ALL user's temp files
::                       instead of just the current user. Thanks to reddit.com/user/srisinger for contributing this patch
::                2.8d + Added "UPDATED" variable to reflect last date of script modification
::                2.8c / Changed a couple 2>&1 redirects to read 2>NUL
::                2.8b + Added removal of C:\Dell folder (leftover driver installation files)
::                2.8  + Added emptying of ALL user's recycle bins
::                2.7  + Added removal of C:\AMD folder
::                     + Added removal of C:\ATI folder
::                     * Tweaked job footer to include what user the script executed as
::                     * Fixed removal of Flash cookies. Was broken in all previous versions.
::                2.6b + Added removal of C:\NVIDIA folder
::                2.6  + Improved detection of Windows XP/2003 hotfix folders
::                     + Added quotes around paths in the Macromedia Flash section cleanup and added /F /Q flags to del command
::                     / Moved all /F /Q flags on del commands to front of command (del /F /Q <files> instead of del <files> /F /Q)
::                     - Removed "cd\" from prep section
::                     - Removed "2>&1" redirection from most del commands. 
::                         The "2>&1" command says to redirect STDERR to the log file.
::                         Most del commands now redirect their errors to NUL instead of the log file.
::                         Since we don't really care if del couldn't find a file, we don't need to log the error. 
::                2.5  + Improved detection of operating system and added new OS detection section near script start
::                     + Added section to remove C:\Windows\Media on Server-based operating systems
::                     - Comment cleanup and removal of unneeded error piping (2>&1)
::                2.4d / Switched to CUR_DATE format to be consistent with all other scripts
::                     / LOGFILE variable is no longer appended with .log, instead now just uses log name that we specify at beginning of script
::                2.4c + Added section to remove Dell builtin wallpaper
::                     + Added SETLOCAL command to prevent system-wide variable changes
::                2.4b / Minor comment cleanup
::                2.4  + Added deletion of .exe files in C:\ at startup
::                2.3  * Improved log file rotation (uses size limit to determine rotating)
::                2.2  + Log files now rotate and delete old versions
::                2.1  + Small updates. Added version display while cleaning
::                2.0  * Major re-write
::                        + Added section to test for and delete hotfix uninstallers on XP
::                        + Added log file
::                1.9  / Fixed deleting of the Windows Tour section
::                1.8  / Split into USER and SYSTEM subsections 
::                1.7  + Added section to delete Windows update log files and built-in .bmp files
::                1.6  / Changed some delete flags to /F /S /Q instead of just /F /Q
::                       The "/S" flag says to recurse into subdirectories. 
::                1.5  + Added new areas to clean -- %TEMP%\ folder
::                1.0    Initial write


::::::::::
:: Prep :: -- Don't change anything in this section
::::::::::
SETLOCAL
@echo off
%SystemDrive%
cls
set VERSION=3.1
set UPDATED=2014-07-03
if "%DATE:~-5,1%"=="/" (set CUR_DATE=%DATE:~-4%-%DATE:~4,2%-%DATE:~7,2%) else (set CUR_DATE=%DATE%)
set IS_SERVER_OS=no
title [TEMP FILE CLEANUP v%VERSION%]

:::::::::::::::
:: VARIABLES :: -- Set these to your desired values
:::::::::::::::
:: Set your paths here. Don't use trailing slashes (\) in directory paths
set LOGPATH=%SystemDrive%\Logs
set LOGFILE=%COMPUTERNAME%_TempFileCleanup.log
:: Max log file size allowed in bytes before rotation and archive. 1048576 bytes is one megabyte
set LOG_MAX_SIZE=104857600


:::::::::::::::::::::::
:: LOG FILE HANDLING ::
:::::::::::::::::::::::
:: Make the logfile if it doesn't exist
if not exist %LOGPATH% mkdir %LOGPATH%
if not exist %LOGPATH%\%LOGFILE% echo. > %LOGPATH%\%LOGFILE%

:: Check log size. If it's less than our max, then jump to the cleanup section
for %%R in (%LOGPATH%\%LOGFILE%) do IF %%~zR LSS %LOG_MAX_SIZE% goto os_version_detection

:: If the log was too big, go ahead and rotate it.
pushd %LOGPATH%
del %LOGFILE%.ancient 2>NUL
rename %LOGFILE%.oldest %LOGFILE%.ancient 2>NUL
rename %LOGFILE%.older %LOGFILE%.oldest 2>NUL
rename %LOGFILE%.old %LOGFILE%.older 2>NUL
rename %LOGFILE% %LOGFILE%.old 2>NUL
popd


::::::::::::::::::::::::::
:: OS VERSION DETECTION ::
::::::::::::::::::::::::::
:os_version_detection
:: Check Windows version. If it's a Server OS set the variable "IS_SERVER_OS" to yes. This affects what we do later.
wmic os get name | findstr "Server" > nul
IF %ERRORLEVEL%==0 set IS_SERVER_OS=yes


::::::::::::::::::::::::::
:: USER CLEANUP SECTION :: -- Most stuff in here doesn't require Admin rights
::::::::::::::::::::::::::
:: Create the log header for this job
echo -------------------------------------------------------------------------------------------->> %LOGPATH%\%LOGFILE%
echo  %CUR_DATE% %TIME%  TempFileCleanup v%VERSION%, executing as %USERDOMAIN%\%USERNAME%>> %LOGPATH%\%LOGFILE%
echo -------------------------------------------------------------------------------------------->> %LOGPATH%\%LOGFILE%

title [CLEANING TEMP FILES v%VERSION%]
:: Status message to the user
echo.
echo  Starting temp file cleanup
echo  --------------------------
echo.
echo  Cleaning USER temp files...
:: This is ugly but it creates the log line.
echo. >> %LOGPATH%\%LOGFILE% && echo  ! Cleaning USER temp files...>> %LOGPATH%\%LOGFILE% && echo. >> %LOGPATH%\%LOGFILE%

:: User temp files, history, and random My Documents stuff
del /F /S /Q "%TEMP%" >> %LOGPATH%\%LOGFILE% 2>NUL

:: Windows Vista and up
IF EXIST "%SystemDrive%\Users\" (
    for /D %%x in ("%SystemDrive%\Users\*") do ( 
        del /F /Q "%%x\AppData\Local\Temp\*" >> %LOGPATH%\%LOGFILENAME% 2>NUL
        del /F /Q "%%x\AppData\Roaming\Microsoft\Windows\Recent\*" >> %LOGPATH%\%LOGFILENAME% 2>NUL
        del /F /Q "%%x\AppData\Local\Microsoft\Windows\Temporary Internet Files\*">> %LOGPATH%\%LOGFILENAME% 2>NUL
        del /F /Q "%%x\AppData\Local\ApplicationHistory\*">> %LOGPATH%\%LOGFILENAME% 2>NUL
        del /F /Q "%%x\My Documents\*.tmp" >> %LOGPATH%\%LOGFILENAME% 2>NUL
    )
)

:: Windows XP
IF EXIST "%SystemDrive%\Documents and Settings\" (
    for /D %%x in ("%SystemDrive%\Documents and Settings\*") do ( 
        del /F /Q "%%x\Local Settings\Temp\*" >> %LOGPATH%\%LOGFILENAME% 2>NUL
        del /F /Q "%%x\Recent\*" >> %LOGPATH%\%LOGFILENAME% 2>NUL
        del /F /Q "%%x\Local Settings\Temporary Internet Files\*" >> %LOGPATH%\%LOGFILENAME% 2>NUL
        del /F /Q "%%x\Local Settings\Application Data\ApplicationHistory\*">> %LOGPATH%\%LOGFILENAME% 2>NUL
        del /F /Q "%%x\My Documents\*.tmp" >> %LOGPATH%\%LOGFILENAME% 2>NUL
    )
)

echo.
echo  Done.
echo. >> %LOGPATH%\%LOGFILE% && echo  ! Done. >> %LOGPATH%\%LOGFILE% && echo. >> %LOGPATH%\%LOGFILE%


::::::::::::::::::::::::::::
:: SYSTEM CLEANUP SECTION :: -- Most stuff in here requires Admin rights
::::::::::::::::::::::::::::
echo.
echo  Cleaning SYSTEM temp files...
echo  ! Cleaning SYSTEM temp files... >> %LOGPATH%\%LOGFILE% && echo.>> %LOGPATH%\%LOGFILE%

:: System temp files
del /F /S /Q "%WINDIR%\TEMP\*" >> %LOGPATH%\%LOGFILE% 2>NUL

:: Root drive garbage (usually C drive)
rmdir /S /Q %SystemDrive%\Temp >> %LOGPATH%\%LOGFILE% 2>NUL
for %%i in (bat,txt,log,jpg,jpeg,tmp,bak,backup,exe) do (
			del /F /Q "%SystemDrive%\*.%%i>> "%LOGPATH%\%LOGFILE%" 2>NUL
		)

:: Remove files left over from installing Nvidia/ATI/AMD/Dell/Intel drivers
for %%i in (NVIDIA,ATI,AMD,Dell,Intel) do (
			rmdir /S /Q %SystemDrive%\%%i>> "%LOGPATH%\%LOGFILE%" 2>NUL
		)

:: Remove the Microsoft Office installation cache. Usually around ~1.5 GB
rmdir /S /Q %SystemDrive%\MSOCache >> %LOGPATH%\%LOGFILE% 2>NUL

:: Remove the Microsoft Windows installation cache. Can be up to 1.0 GB
rmdir /S /Q %SystemDrive%\i386 >> %LOGPATH%\%LOGFILE% 2>NUL
		
:: Empty all recycle bins on Windows 5.1 and 6.1 systems
rmdir /s /q %SystemDrive%\RECYCLER 2>NUL
rmdir /s /q %SystemDrive%\$Recycle.Bin 2>NUL

:: Windows update logs & built-in backgrounds (space waste)
del /F /Q %WINDIR%\*.log >> %LOGPATH%\%LOGFILE% 2>NUL
del /F /Q %WINDIR%\*.txt >> %LOGPATH%\%LOGFILE% 2>NUL
del /F /Q %WINDIR%\*.bmp >> %LOGPATH%\%LOGFILE% 2>NUL
del /F /Q %WINDIR%\*.tmp >> %LOGPATH%\%LOGFILE% 2>NUL
del /F /Q %WINDIR%\Web\Wallpaper\*.* >> %LOGPATH%\%LOGFILE% 2>NUL
rmdir /S /Q %WINDIR%\Web\Wallpaper\Dell >> %LOGPATH%\%LOGFILE% 2>NUL

:: Flash cookies
rmdir /S /Q "%appdata%\Macromedia\Flash Player\#SharedObjects\#SharedObjects" >> %LOGPATH%\%LOGFILE% 2>NUL

:: Windows "guided tour" annoyance
del %WINDIR%\system32\dllcache\tourstrt.exe >> %LOGPATH%\%LOGFILE% 2>NUL
del %WINDIR%\system32\dllcache\tourW.exe >> %LOGPATH%\%LOGFILE% 2>NUL
rmdir /S /Q %WINDIR%\Help\Tours >> %LOGPATH%\%LOGFILE% 2>NUL

echo.
echo  Done.
echo. >> %LOGPATH%\%LOGFILE%
echo  ! Done. >> %LOGPATH%\%LOGFILE%
echo. >> %LOGPATH%\%LOGFILE%


::::::::::::::::::::::::::::
:: Windows Server cleanup :: -- This section runs only if the OS is Windows Server 2000, 2003, 2008, or 2012
::::::::::::::::::::::::::::
:server_cleanup

:: 0. Check our operating system. If it's not a Server OS, skip this section.
IF '%IS_SERVER_OS%'=='no' goto :xp_2003

:: 1. If we made it here then we're on a Server OS, so go ahead and run server-specific tasks
echo.
echo  ! Windows Server operating system detected.
echo    Removing built-in media files (.wav, .midi, etc)...
echo.
echo. >> %LOGPATH%\%LOGFILE% && echo  ! Windows Server operating system detected. Removing built-in media files (.wave, .midi, etc)... >> %LOGPATH%\%LOGFILE% && echo. >> %LOGPATH%\%LOGFILE%

:: 2. Take ownership of the files so we can actually delete them. By default even Administrators have Read-only rights. 
echo  ! Taking ownership of %WINDIR%\Media in order to delete files... && echo.
echo  ! Taking ownership of %WINDIR%\Media in order to delete files... >> %LOGPATH%\%LOGFILE% && echo. >> %LOGPATH%\%LOGFILE%
takeown /f %WINDIR%\Media /r /d y >> %LOGPATH%\%LOGFILE% 2>NUL && echo. >> %LOGPATH%\%LOGFILE%
icacls %WINDIR%\Media /grant administrators:F /t >> %LOGPATH%\%LOGFILE% && echo. >> %LOGPATH%\%LOGFILE%

:: 3. Do the cleanup
rmdir /S /Q %WINDIR%\Media>> %LOGPATH%\%LOGFILE% 2>NUL


::::::::::::::::::::::::::::::::::::
:: Windows XP/2003 hotfix cleanup ::
::::::::::::::::::::::::::::::::::::
:xp_2003
:: This section tests for Windows XP/2003 hotfixes and deletes them if they exist.
:: These hotfixes use a lot of space so clearing them out is beneficial.
:: Really we should use a tool that deletes their corresponding registry entries, but oh well.

:: 0. Check Windows version. If it's not XP or 2003 then skip this whole section.
:: Test for XP. Yes, we do it twice. There's some insanity in Windows where sometimes it won't set the ERRORLEVEL correctly. Sigh.
wmic os get name | findstr "XP" >NUL
wmic os get name | findstr "XP" >NUL
	IF %ERRORLEVEL%==0 goto :hotfix_cleanup
	IF NOT %ERRORLEVEL%==0 goto :complete
:: Test for 2003. Yes, we do it twice. There's some insanity in Windows where sometimes it won't set the ERRORLEVEL correctly. Sigh.
wmic os get name | findstr "2003" >NUL
wmic os get name | findstr "2003" >NUL
	IF %ERRORLEVEL%==0 goto :hotfix_cleanup
	IF NOT %ERRORLEVEL%==0 goto :complete

:: 1. If we made it here then we're doing the cleanup. Go ahead and notify the user and log it.
:hotfix_cleanup
echo.
echo  ! Windows XP/2003 detected.
echo    Removing hotfix uninstallers...
echo.
echo. >> %LOGPATH%\%LOGFILE% && echo ! Windows XP/2003 detected. Removing hotfix uninstallers... >> %LOGPATH%\%LOGFILE%

:: 2. Build the list of hotfix folders. They always have "$" signs around their name, e.g. "$NtUninstall092330$" or "$hf_mg$"
pushd %WINDIR%
dir /A:D /B $*$ > %TEMP%\hotfix_nuke_list.txt 2>NUL

:: 3. Do the hotfix clean up
for /f %%i in (%TEMP%\hotfix_nuke_list.txt) do (
	echo Deleting %%i...
	echo Deleted folder %%i >> %LOGPATH%\%LOGFILE%
	rmdir /S /Q %%i >> %LOGPATH%\%LOGFILE% 2>NUL
	)

:: 4. Log that we are done with hotfix cleanup and leave the Windows directory
echo. >> %LOGPATH%\%LOGFILE% && echo ! Windows XP/2003 hotfix uninstaller cleanup complete. >> %LOGPATH%\%LOGFILE% && echo.>> %LOGPATH%\%LOGFILE%
del %TEMP%\hotfix_nuke_list.txt >> %LOGPATH%\%LOGFILE%
popd


::::::::::::::::::::::::::
:: Cleanup and complete ::
::::::::::::::::::::::::::
:complete
@echo off
echo -------------------------------------------------------------------------------------------->> %LOGPATH%\%LOGFILE%
echo  %CUR_DATE% %TIME%  TempFileCleanup v%VERSION%, finished. Executed as %USERDOMAIN%\%USERNAME%>> %LOGPATH%\%LOGFILE%>> %LOGPATH%\%LOGFILE%
echo -------------------------------------------------------------------------------------------->> %LOGPATH%\%LOGFILE%
echo.
echo  Cleanup complete.
echo.
echo  Log saved at: %LOGPATH%\%LOGFILE%
echo.
ENDLOCAL