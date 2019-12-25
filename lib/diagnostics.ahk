class Diagnostics
{
    GetAllWindowInfosAsString()
    {
        result := ""
        
        WinGet, allWindowsIds, List
        loop % allWindowsIds
        {
            id := allWindowsIds%a_index%
            WinGetTitle, title, ahk_id %id%
            
            result := result . "ID:[" . id . "]" . "`t" . (title ? title : "''") "`n"
        }
        
        return Trim(result)
    }
    
    Dump(obj, indent := 0)
    {
        result := ""
        padding := Diagnostics._RepeatChars("`t", indent)
        
        if (IsObject(obj))
        {
            result .= padding . "{`n"
            for key, value in obj
            {
                displayValue := value == "" ? "null" : value
                result .= padding . "`t" . key . " : " . displayValue . ",`n"
            }
            result .= padding . "}"
        }
        else
        {
            result := padding . (obj == "" ? "null" : obj)
        }
        
        return result
    }
    
    _RepeatChars(char, count)
    {
        if (count == 0)
        {
            return ""
        }
        
        VarSetCapacity(result, count, char)
        return result
    }
}
