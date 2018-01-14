echo off
::setup the window size 
mode con:cols=80 lines=60
::setup background and foreground color
cls
color 0B

::check our shell
:CHECKSHELL
    if %COMSPEC%==%SYSTEMROOT%\system32\cmd.exe goto SHELLOK
    echo.
    echo ERROR: You must run this script from the standard Windows Command Shell
    echo (%SYSTEMROOT%\system32\cmd.exe). Please start this shell first before
    echo running this script.
    pause
GOTO:EOF

:SHELLOK
set VERSION=05-16-2015-PTR
set PROGRAM_NAME=FASTBOOT TETHERED RECOVERY LAUNCHER %VERSION%

set WORKINGDIR=""
set WORKINGDIR=%~dp0 
for %%f in ("%WORKINGDIR%") do set WORKINGDIR=%%~sf

call "%WORKINGDIR%resources\functions.bat"

GOTO:TETHERED_ACCEPT


:TETHERED_ACCEPT
    set TRIGGER="%WORKINGDIR%\FB_RecoveryLauncher\recovery.trigger.original"
    set LAUNCHER="%WORKINGDIR%\FB_RecoveryLauncher\recovery.launcher"
    set RECOVERY="%WORKINGDIR%\FB_RecoveryLauncher\recovery.zip"
    call %default-color%
    cls
    :: set window title specific to this section
    title %PROGRAM_NAME% disclaimer
    ::print our default header
    echo. READ ME:
::  echo *                                  *                                  * ::this line is used as a centering reference nothing prints here
    echo =======================================================================
    echo. Luu y:
    echo.
    echo.                     Nhung luu y can doc
    echo.
    echo.                     Day la phien ban thu nghiem
    echo.                  No co the dan den nhieu rui ro
    echo.             Chung toi khong chiu trach nhiem voi quyet dinh cua ban
    echo.
    echo.                        Xin cam on.
    echo.
    echo.
    echo. . Nhap " ACCEPT " de tiep tuc . . .
    echo.
    echo. . Nhạp quit hay exit neu khong muon tiep tuc
    echo.
    echo =======================================================================
    set choice=
    echo.&set /p choice=: ||goto :TETHERED_ACCEPT

    :: alternative platform-tools
    if %choice% == ALTTOOLS1 set PLATFORM_TOOLS=%FUNCTION%platform-tools_alt1\&set default-color=color 0D &goto:TETHERED_ACCEPT

    :: the only accepted answer to continue
    if %choice% == ACCEPT echo.&"%PLATFORM_TOOLS%adb" start-server &goto:TRIGGER_SELECTION

    :: we always want to use our close tool to exit the toolKIT
    :: so we remap commonly used commands for exiting
    if %choice% == e GOTO:CLOSE_TOOL
    if %choice% == q GOTO:CLOSE_TOOL
    if %choice% == exit GOTO:CLOSE_TOOL
    if %choice% == quit GOTO:CLOSE_TOOL
GOTO:TETHERED_ACCEPT

:TRIGGER_SELECTION
    call "%CHECK_DEVICE%"
    set OEMTRIGGER=
    set OEMCMD=
    cls
    :: set window title specific to this section
    title %PROGRAM_NAME%
    set nxt=0
    set ric=0
    ::print our default header
    cls
    echo.
    echo ***********************************************************************
    echo. %PROGRAM_NAME%
    echo ***********************************************************************
    echo.
    echo =======================================================================
    echo. Chon option de cai dat recovery :
    echo.
    echo. T1 . launch using oem startftm trigger
    echo.
    echo.
    echo. T2 . launch using oem backup_factory trigger 
    echo.
    echo.
    echo. T3 . launch using oem stop_partitioning trigger
    echo.
    echo.
    echo. T4 . launch using oem stop_partitioning trigger alternate version
    echo.
    echo.
    echo.  D . donate open default web browser paypal donate
    echo.
    echo. type shell to launch an adb shell
    echo =======================================================================
    call "%PRINT_DEVICE%"
    set choice=
    echo.&set /p choice=please make a selection or type quit or exit to close the tool kit: ||GOTO:TRIGGER_SELECTION
    set OEMTRIGGER=
    set OEMCMD=
    :: the only accepted answer to continue
    if %choice% == T1 set OEMTRIGGER="/sbin/adbd" &set OEMCMD="startftm" &goto :REBOOT4TETHERED
    if %choice% == T2 set OEMTRIGGER="/system/bin/cp" &set OEMCMD="backup_factory" &goto :REBOOT4TETHERED
    if %choice% == T3 set OEMTRIGGER="/sbin/partlink" &set OEMCMD="stop_partitioning" &goto :REBOOT4TETHERED
    if %choice% == T4 set OEMTRIGGER="/system/bin/logcat" &set OEMCMD="stop_partitioning" &set TRIGGER="%WORKINGDIR%\FB_RecoveryLauncher\recovery.trigger.new" &goto :REBOOT4TETHERED
    if %choice% == d start http://forum.xda-developers.com/donatetome.php?u=4821597 &GOTO:TRIGGER_SELECTION
	if %choice% == D start http://forum.xda-developers.com/donatetome.php?u=4821597 &GOTO:TRIGGER_SELECTION
    
    if %choice% == shell GOTO:adbSHELL

    :: command to change the fastboot oem command possibly work on other intel devices 
    if %choice% == CUSTOMOEMCMD echo.&set /p OEMCMD=fastboot oem command: &set /p OEMTRIGGER=path of binary triggerd by oem command: &GOTO:REBOOT4TETHERED

    :: for debugging
    if %choice% == cmd GOTO:CMD_LINE

    :: we always want to use our close tool to exit the toolKIT
    :: so we remap commonly used commands for exiting
    if %choice% == e GOTO:CLOSE_TOOL
    if %choice% == q GOTO:CLOSE_TOOL
    if %choice% == exit GOTO:CLOSE_TOOL
    if %choice% == quit GOTO:CLOSE_TOOL
    echo.
    echo. invalid input please try again.
    echo.
    pause
GOTO:TRIGGER_SELECTION

:REBOOT4TETHERED
    call "%CHECK_DEVICE%"
    cls
    :: set window title specific to this section
    title %PROGRAM_NAME% REBOOT
    ::print our default header
    echo.
    echo ***********************************************************************
    echo. %PROGRAM_NAME%
    echo ***********************************************************************
    echo. REBOOT
    echo =======================================================================
    echo.
    echo. DEVICE STATUS: %status%
    echo.
    echo. DEVICE INFORMATION: %deviceinfo%
    echo.
    echo =======================================================================
    echo.
    if /i %status% == UNKNOWN ( GOTO:CONNECTION_FAILED)
    if /i %status% == ADB-ONLINE ( GOTO:REBOOT2FASTBOOT)
    if /i %status% == FASTBOOT-ONLINE ( GOTO:TETHERED_TOOL)
GOTO:TRIGGER_SELECTION

:REBOOT2FASTBOOT
    "%PLATFORM_TOOLS%adb" reboot-bootloader &"%PLATFORM_TOOLS%fastboot" getvar all &GOTO:TETHERED_TOOL
GOTO:TRIGGER_SELECTION

:TETHERED_TOOL
cls
    call "%CHECK_DEVICE%"
    :: set window title specific to this section
    title %PROGRAM_NAME%
    ::print our default header
    echo.
    echo ***********************************************************************
    echo. %PROGRAM_NAME%
    echo ***********************************************************************
    echo.
    echo =======================================================================
    echo.
    echo. DEVICE STATUS: %status%
    echo.
    echo. DEVICE INFORMATION: %deviceinfo%
    echo.
    echo =======================================================================
    echo.
    echo copy needed files to our device
    "%PLATFORM_TOOLS%fastboot" flash /tmp/recovery.zip %RECOVERY%
    "%PLATFORM_TOOLS%fastboot" flash /tmp/recovery.launcher %LAUNCHER%

    if /i %OEMTRIGGER% == "/system/bin/logcat" ( echo we need to stop logcat before replacing it)
    if /i %OEMTRIGGER% == "/system/bin/logcat" ( "%PLATFORM_TOOLS%fastboot" oem start_partitioning)

    "%PLATFORM_TOOLS%fastboot" flash %OEMTRIGGER% %TRIGGER%
    echo.
    echo issue fastboot oem %OEMCMD% command to start cwm recovery:
    "%PLATFORM_TOOLS%fastboot" oem %OEMCMD%

    echo.
    ping -n 20 127.0.0.1 >nul
    cls
    call "%CHECK_DEVICE%"
    :: set window title specific to this section
    title %PROGRAM_NAME%
    ::print our default header
    echo.
    echo ***********************************************************************
    echo. %PROGRAM_NAME%
    echo ***********************************************************************
    echo.
    echo =======================================================================
    echo.
    echo. DEVICE STATUS: %status%
    echo.
    echo. DEVICE INFORMATION: %deviceinfo%
    echo.
    echo =======================================================================
    echo.
    echo complete
    pause
GOTO:TRIGGER_SELECTION

:CMD_LINE:
    SET PATH=%PATH%;%PLATFORM_TOOLS%
    cls
    echo.
    echo ***********************************************************************
    echo. %PROGRAM_NAME%
    echo ***********************************************************************
    echo.
::  echo *                                  *                                  * ::this line is used as a reference nothing prints here
    echo.     cli for debugging the toolKIT type " exit " to return to toolKIT
    echo.
    cmd
GOTO:TRIGGER_SELECTION

:adbSHELL
    @echo off
    call "%CHECK_DEVICE%"
    ::we need to make sure status is ADB-ONLINE
    if /i not %status% == ADB-ONLINE ( GOTO:CONNECTION_FAILED )
    cls
    title %PROGRAM_NAME% ADB SHELL
    echo ***********************************************************************
    echo. %PROGRAM_NAME%
    echo ***********************************************************************
    echo. type exit to close the adb shell
::  echo. *                                  *                                  * ::this line is used as a reference nothing prints here
    echo =======================================================================
    call "%PLATFORM_TOOLS%adb" shell
GOTO:TRIGGER_SELECTION

:CONNECTION_FAILED
    echo.
    echo.       ERROR ! ! ! ERROR PLEASE CHECK YOUR DEVICE ERROR ! ! ! ERROR
    echo.&set /p = FAILED TO COMUNICATE WITH DEVICE [ %status% ] HIT ANY KEY TO RETURN:
GOTO:TRIGGER_SELECTION

:CLOSE_TOOL
    cls
    echo.
    echo ***********************************************************************
    echo. %PROGRAM_NAME%
    echo ***********************************************************************
    echo.
    call "%PLATFORM_TOOLS%adb" kill-server &pause &exit
GOTO:EOK