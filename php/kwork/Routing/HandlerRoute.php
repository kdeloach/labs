<?php

/***
 * This class is used to perform route matching for request handlers (defined in <handlers> config block).
 * The main difference between the normal route class is that this should support wildcard matching.
 */
class HandlerRoute extends Route
{
    function __construct($pattern, $args=array())
    {
        parent::__construct($pattern, $args);
    }
    
    function getPatternRegex()
    {
        $pattern = parent::getPatternRegex();
        $pattern = str_replace('\*', '(.*)', $pattern);
        return $pattern;
    }
}
