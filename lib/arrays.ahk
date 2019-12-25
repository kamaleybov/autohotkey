class Arrays
{
    SelectProperty(source, field)
    {
        result := []
        for key, value in source
            result.Push(value[field])
        return result
    }

    SelectPropertyFromEnumerable(source, field)
    {
        result := []
        for value in source
            result.Push(value[field])
        return result
    }
    
    Distinct(source)
    {
        result := []
        map := {}
        
        loop % source.Length()
        {
            if (!map.HasKey(source[a_index]))
            {
                result.Push(source[a_index])
                map[source[a_index]] := true
            }
        }
        
        return result
    }
}
