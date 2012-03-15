<?php

class StringHelper
{
    // Source: http://www.jonasjohn.de/snippets/php/starts-with.htm
    static function startsWith($haystack, $needle)
    {
        return strpos($haystack, $needle) === 0;
    }
    
    // Source: http://www.jonasjohn.de/snippets/php/ends-with.htm
    static function endsWith($haystack, $needle)
    {
        return strrpos($haystack, $needle) === strlen($haystack)-strlen($needle);
    }
}
