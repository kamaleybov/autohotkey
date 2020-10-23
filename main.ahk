#NoEnv
#Warn
#SingleInstance
#WinActivateForce
SendMode Input
SetTitleMatchMode RegEx

; Run with administrator priveleges, because otherwise hotkeys involving [Win] key will not work in elevated programs.
; (This is turned off for now as it was causing issues with folder paths.)
;IfEqual, A_IsAdmin, % False, Run, % "*RunAs """A_ScriptFullPath """",, UseErrorLevel
;IfEqual, A_IsAdmin, % False, ExitApp

#include <system>
#include <windows>
#include <diagnostics>
#include trayminimizer.ahk

;**********************************************************************************************************************************************************************
;*** Minimize applications [see hotkeys below]
;**********************************************************************************************************************************************************************
;                                                                    Display Name       Title Regex              Show Hotkey    Hide Hotkey   Send on Activation
;                                                                      (unique)           (unique)                 (unique)                      
;**********************************************************************************************************************************************************************
__trayMinimizer := new TrayMinimizer([ new MinimizableApplication(    "OneNote",      ".*? - OneNote",              "!w",        "capslock",          ""           ) ])
ObjAddRef(&__trayMinimizer)

HotKey, capslock, Nop

; Map capslock to gvim's Ctrl+[
#IfWinActive .*? - GVIM\d*$
    capslock::send ^[
#IfWinActive

;*************************************************************************************
;*** Open powershell in current folder [Alt + O]
;*************************************************************************************
#IfWinNotActive (Microsoft Visual Studio)
    !o::
        folder := Windows.GetActiveExplorerWindowFolderPath()
        if (folder)
            Run, pwsh -NoLogo, %folder%
        else
            Run, pwsh -NoLogo, %A_Desktop%
    return
#IfWinNotActive


;*************************************************************************************
;*** Open powershell in current folder with admin rights [Alt + Shift + O]
;*************************************************************************************
!+o::
    folder := Windows.GetActiveExplorerWindowFolderPath()
    systemRoot := System.GetEnvironmentVariable("SystemRoot")

    ; Windows does not let working directory to be set when running something with admin rights.
    ; We instead run cmd with admin rights, change directory within it, and then launch powershell,
    ; which inherits the cmd's working directory.
    if (folder)
        Run *RunAs %systemRoot%\system32\cmd.exe /k `"cd `"`"%folder%`"`" & start pwsh -NoLogo & exit`"
    else
        Run *RunAs %systemRoot%\system32\cmd.exe /k `"cd `"`"%A_Desktop%`"`" & start pwsh -NoLogo & exit`"
return


;*************************************************************************************
;*** Open selected file in vim [Alt + V]
;*************************************************************************************
!v::
    path := Windows.GetActiveExplorerWindowFirstSelectedItemPath()
    if (path)
    {
        Run gvim `"%path%`"
    }
return


;*************************************************************************************
;*** Create a new TODO email [Alt + N]
;*************************************************************************************
!n::
    email := System.GetEnvironmentVariable("PERSONAL_EMAIL")

    Run mailto:%email%?subject=[TODO]`%20
return


;*************************************************************************************
;*** Open git in source folder [Alt + G]
;*************************************************************************************
!g::
    rootSourceFolder := System.GetEnvironmentVariable("ROOT_SOURCE_FOLDER")

    Run, pwsh -NoLogo, %rootSourceFolder%
return


;*************************************************************************************
;*** Reload current script [Alt + Shift + R]
;*************************************************************************************
!+r::
    Reload
return


;*************************************************************************************
;*** Create a new chrome window [Win + Space]
;*************************************************************************************
#space::
    Run, chrome.exe --explicitly-allowed-ports=563 --new-window --profile-directory=Default, , Max, chromeWindowId
    WinActivate, New Tab - Google Chrome
    WinWait, New Tab - Google Chrome
    Send {End}
return


;*************************************************************************************
;*** Mute [Ctrl + VolumeDown]
;*************************************************************************************
^VOLUME_DOWN::
    Send {VOLUME_MUTE}
return


;*************************************************************************************
;*** Change default sound device [Ctrl + NumPad 1/2/3/4]
;*************************************************************************************
^NumPad1::
    Run, mmsys.cpl
    WinWait, Sound
    ControlSend, SysListView321, {Down 1}
    ControlClick, &Set Default
    ControlClick, OK
return

^NumPad2::
    Run, mmsys.cpl
    WinWait, Sound
    ControlSend, SysListView321, {Down 2}
    ControlClick, &Set Default
    ControlClick, OK
return

^NumPad3::
    Run, mmsys.cpl
    WinWait, Sound
    ControlSend, SysListView321, {Down 3}
    ControlClick, &Set Default
    ControlClick, OK
return

^NumPad4::
    Run, mmsys.cpl
    WinWait, Sound
    ControlSend, SysListView321, {Down 4}
    ControlClick, &Set Default
    ControlClick, OK
return


;*************************************************************************************
;*** Vertical Line (|) Symbol in Russian Keyboard Layout [Shift + \]
;*************************************************************************************
; Defined for lshift and rshift separately, because when using just shift it screws
; up English layout for some reason.
~LShift & \::|
~RShift & \::|


;*************************************************************************************
;*** Hash Symbol (#) in Russian Keyboard Layout [Shift + 3]
;*************************************************************************************
; Defined for lshift and rshift separately, because when using just shift it screws
; up English layout for some reason.
~LShift & 3::#
~RShift & 3::#

