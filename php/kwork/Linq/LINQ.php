<?php

class LINQ
{
    static function where($items, $fn)
    {
        $i = 0;
        $result = array();
        foreach($items as $k => $item)
        {
            if($fn($item, $i) == true)
            {
                $result[$k] = $item;
            }
            $i++;
        }
        return $result;
    }
    
    static function single($items, $fn)
    {
        $i = 0;
        foreach($items as $item)
        {
            if($fn($item, $i) == true)
            {
                return $item;
            }
            $i++;
        }
        return null;
    }

    static function select($items, $fn)
    {
        $i = 0;
        $result = array();
        foreach($items as $k => $item)
        {
            $result[$k] = $fn($item, $i);
            $i++;
        }
        return $result;
    }
}
