<?php

class ReflectionHelper
{
    static function copyProperties($arrOrObj, $target)
    {
        if(is_array($arrOrObj))
            return self::copyPropertiesArr($arrOrObj, $target);
        else
            return self::copyPropertiesObj($arrOrObj, $target);
    }
    
    static function copyPropertiesArr($arr, $target)
    {
        foreach($arr as $propName => $val)
        {
            if(property_exists($target, $propName))
            {
                $target->{$propName} = $val;
            }  
        }
    }
    
    static function copyPropertiesObj($obj, $target)
    {
        $rc = new ReflectionObject($obj);
        foreach($rc->getProperties() as $prop)
        {
            if(property_exists($target, $prop->name))
            {
                $target->{$prop->name} = $prop->getValue($obj);
            }   
        }
    }
}
