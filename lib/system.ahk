Nop()
{
    return
}

class System
{
    GetEnvironmentVariable(name)
    {
        EnvGet, value, %name%
        return value
    }

    GetKeyboardLayout()
    {
        code := DllCall("user32.dll\GetKeyboardLayout") & 0xFFFF

        if (code = 1033)
        {
            return "EN"
        }

        if (code = 1049)
        {
            return "RU"
        }
        
        return code
    }
}
