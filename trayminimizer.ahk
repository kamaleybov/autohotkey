#include <arrays>
#include <windows>
#include <diagnostics>

SetTitleMatchMode RegEx

class TrayMinimizer
{
    _minimizableApplications := {}      ; readonly { application name -> MinimizableApplication } - applications to minimize
                                        ; NOTE: _hiddenHwnd : HWND will be added to every MinimizableApplication that is hidden and will be removed when shown
    
    __new(minimizableApplications) ; MinimizableApplication[] - names, titleRegexes and showHotkeys must be unique
    {
        if (!minimizableApplications || minimizableApplications.Length() == 0)
        {
            throw "Provide at least one minimizable application."
        }
        
        uniqueApplicationNames := Arrays.Distinct(Arrays.SelectProperty(minimizableApplications, "Name"))
        if (uniqueApplicationNames.Length() != minimizableApplications.Length())
        {
            throw "Minimizable application names must be unique."
        }
        
        for index, application in minimizableApplications
        {
            this._minimizableApplications[application.Name] := application
        }
        
        ; standard menus
        restoreAllMethod := ObjBindMethod(this, "RestoreAllHiddenWindows")
        Menu, Tray, Add
        Menu, Tray, Add, &Unhide All, %restoreAllMethod%
        
        ; application hotkeys
        for name, application in this._minimizableApplications
        {
            showHotkey := application.ShowHotkey
            showBoundFunction := ObjBindMethod(this, "RestoreWindowByApplicationName", application.Name)
            Hotkey, %showHotkey%, %showBoundFunction%
            
            hideHotkey := application.HideHotkey
            hideBoundFunction := ObjBindMethod(this, "HideWindowByApplicationName", application.Name, true)
            Hotkey, IfWinActive, % application.TitleRegex
                Hotkey, %hideHotkey%, %hideBoundFunction%
            Hotkey, IfWinActive
        }
        
        OnExit(ObjBindMethod(this, "RestoreAllHiddenWindows"))
    }
    
    __delete()
    {
        this.RestoreAllHiddenWindows()
    }
    
    HideWindowByApplicationName(applicationName, hideOnlyIfActive := false)
    {
        if (!this._minimizableApplications.HasKey(applicationName))
        {
            throw "No application found with the name provided."
        }
        
        application := this._minimizableApplications[applicationName]
        isHiddenAlready := !!application._hiddenHwnd
        
        if (isHiddenAlready)
        {
            return
        }
        
        WinGet, windowId, ID, % application.TitleRegex
        if (windowId)
        {
            if (hideOnlyIfActive && !WinActive("ahk_id " . windowId))
            {
                return
            }
        
            application._hiddenHwnd := windowId

            WinGet, exePath, ProcessPath, ahk_id %windowId%
            WinHide, ahk_id %windowId%
            
            ; activate window behind hidden
            nextWindowId := Windows.GetTopmostWindowId()
            WinActivate, ahk_id %nextWindowId%
            
            ; add menu item
            menuTitle := application.Name
            restoreMethod := ObjBindMethod(this, "_RestoreWindowBySelectedTrayMenuItem")
            Menu, Tray, Add, %menuTitle%, %restoreMethod%
            Menu, Tray, Icon, %menuTitle%, %exePath%
        }
    }
    
    RestoreWindowByApplicationName(applicationName, activate := true, showEvenIfNotHidden := true)
    {
        if (!this._minimizableApplications.HasKey(applicationName))
        {
            throw "No application found with the name provided."
        }
        
        application := this._minimizableApplications[applicationName]
        isHidden := !!application._hiddenHwnd
        windowId := ""
        
        if (isHidden)
        {
            windowId := application._hiddenHwnd
        }
        else if (showEvenIfNotHidden)
        {
            WinGet, windowId, ID, % application.TitleRegex
        }
        
        if (windowId)
        {
            WinShow, ahk_id %windowId%
            
            if (activate)
            {
                WinWait, ahk_id %windowId%
                WinActivate, ahk_id %windowId%
                
                if (application.OnActivate)
                {
                    Send % application.OnActivate
                }
            }
        }
        
        if (isHidden)
        {
            Menu, Tray, Delete, % application.Name
            application.Delete("_hiddenHwnd")
        }
    }
    
    _RestoreWindowBySelectedTrayMenuItem()
    {
        applicationName := A_ThisMenuItem
        this.RestoreWindowByApplicationName(applicationName)
    }
    
    RestoreAllHiddenWindows()
    {
        for name, application in this._minimizableApplications
        {
            this.RestoreWindowByApplicationName(application.Name, false, false)     ; do not activate and do not show if not hidden
        }
    }
}

class MinimizableApplication
{
    Name := ""
    TitleRegex := ""    ; regex to match application by title
    ShowHotkey := ""    ; hotkey to show application window
    HideHotkey := ""    ; hotkey to hide application window
    OnActivate := ""    ; combination sent when window is shown, optional
    
    __new(name, titleRegex, showHotkey, hideHotkey, onActivate := "")
    {
        this.Name := name
        this.TitleRegex := titleRegex
        this.ShowHotkey := showHotkey
        this.HideHotkey := hideHotkey
        this.OnActivate := onActivate
    }
}
