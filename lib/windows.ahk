#include <arrays>

; This class does not support Desktop - all methods ignore it (unless it is open as a separate Explorer window).
; The exception is GetTopmostWindowId() method.
class Windows
{
    GetTopmostWindowId()
    {
        WinGet, allWindowsIds, List
        
        Loop %allWindowsIds%
        {
            id := allWindowsIds%a_index%
            
            WinGetTitle, title, ahk_id %id%
            if (title != "")
            {
                return id
            }
        }
        
        return ""
    }

    GetActiveExplorerWindow()
    {
        activeWindowId := WinExist("A")
        WinGetClass activeWindowClass, ahk_id %activeWindowId%
        
        if (activeWindowClass ~= "Progman|WorkerW|CabinetWClass|ExploreWClass")
        {
            for window in ComObjCreate("Shell.Application").Windows
            {
                if (window.Hwnd == activeWindowId)
                {
                    return window
                }
            }
        }
    }
    
    GetActiveExplorerWindowFolderPath()
    {
        window := Windows.GetActiveExplorerWindow()
        return StrReplace(SubStr(window.LocationURL, 9), "%20", " ")
    }

    GetActiveExplorerWindowSelectedItemPaths()
    {
        window := Windows.GetActiveExplorerWindow()
        paths := Arrays.SelectPropertyFromEnumerable(window.Document.SelectedItems, "path")
        return paths
    }

    GetActiveExplorerWindowFirstSelectedItemPath()
    {
        paths := Windows.GetActiveExplorerWindowSelectedItemPaths()
        if (paths.Length() > 0)
        {
            return paths[1]
        }
        else
        {
            return ""
        }
    }
}
