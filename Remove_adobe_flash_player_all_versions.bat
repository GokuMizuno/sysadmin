:: Purpose:       Removes all versions of Adobe Flash Player
:: Requirements:  Run this script with a network admin account
:: Author:        vocatus on reddit.com/r/sysadmin ( vocatus.gate@gmail.com ) // PGP key ID: 0x82A211A2
:: History:       1.0d * Added pushd command to prep section to ensure we can run the script from a network drive
::                1.0c * Reworked CUR_DATE variable to handle more than one Date/Time format
::                       Can now handle ISO standard dates (yyyy-mm-dd) and Windows default dates (e.g. "Fri 01/24/2014")
::                1.0b * Comment cleanup
::                1.0  + Initial write

::::::::::
:: Prep ::
::::::::::
@echo off
set VERSION=1.0d
set UPDATED=2014-07-08
if "%DATE:~-5,1%"=="/" (set CUR_DATE=%DATE:~-4%-%DATE:~4,2%-%DATE:~7,2%) else (set CUR_DATE=%DATE%)
:: This is useful if we start from a network share; converts CWD to a drive letter
pushd %~dp0 2>NUL
cls

:::::::::::::::
:: Variables :: -- Set these to your desired values
:::::::::::::::
:: Log location and name. Do not use trailing slashes (\)
set LOGPATH=%SystemDrive%\Logs
set LOGFILE=%COMPUTERNAME%_adobe_flash_player_removal.log

:: Create the log directory if it doesn't exist
if not exist %LOGPATH% mkdir %LOGPATH%


:::::::::::::
:: Removal ::
:::::::::::::
:: Log that we started
echo. > %LOGPATH%\%LOGFILE%
echo %CUR_DATE% %TIME%  Beginning removal of Adobe Flash Player (all versions)... >> %LOGPATH%\%LOGFILE%

:: This line first runs the official Adobe package to remove Flash from v11.4.402.265 and older
echo %CUR_DATE% %TIME%  Running the Adobe uninstaller to remove versions v11.4.402.265 and below first...>> %LOGPATH%\%LOGFILE%
uninstall_flash_player_v11.4.402.265.exe -uninstall >> %LOGPATH%\%LOGFILE%

:: This line uses the official Microsoft WMIC method of uninstalling packages
echo %CUR_DATE% %TIME%  Now using the Microsoft WMIC method to uninstall...>> %LOGPATH%\%LOGFILE%
wmic product where "name like 'Adobe Flash Player%%'" uninstall /nointeractive >> %LOGPATH%\%LOGFILE%

:: Some "just in case" cleanup
echo %CUR_DATE% %TIME%  Now some "just in case" cleanup (deleting Adobe Flash Player Update Service, removing scheduled task, etc)>> %LOGPATH%\%LOGFILE%
net stop AdobeFlashPlayerUpdateSvc >> %LOGPATH%\%LOGFILE%
sc delete AdobeFlashPlayerUpdateSvc >> %LOGPATH%\%LOGFILE%
del /F /Q "%SystemDrive%\Windows\tasks\Adobe Flash Player Updater.job">> %LOGPATH%\%LOGFILE%

echo %CUR_DATE% %TIME%  All versions of Adobe Flash Player have been removed. Recommend rebooting.>> %LOGPATH%\%LOGFILE%

REM Return exit code to SCCM/PDQ Deploy/etc
exit /B %EXIT_CODE%