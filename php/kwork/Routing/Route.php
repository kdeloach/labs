<?php

class Route
{
    var $pattern;
    var $args;
    
    function __construct($pattern, $args=array())
    {
        $this->pattern = $pattern;
        $this->args = $args;
    }
    
    function match($url)
    {
        if($path = $this->getCleanUrl($url))
        {
            if(preg_match($this->getPatternRegex(), $path, $matches))
            {
                foreach($matches as $k => $v)
                {
                    if(is_numeric($k))
                    {
                        unset($matches[$k]);
                    }
                }
                return $matches;
            }
        }
        return false;
    }
    
    // TODO: Move to UrlHelper?
    function getCleanUrl($url)
    {
        if($urlinfo = parse_url($url))
        {
            $path = '';
            if(array_key_exists('path', $urlinfo))
            {
                $path = $urlinfo['path'];           
            }
            $path = $this->normalizeSlashes($path);
            return $path;
        }
        return false;
    }
    
    // TODO: Move to PathHelper?
    function normalizeSlashes($path)
    {
        // Url must not end with slash
        while(StringHelper::endsWith($path, '/'))
        {
            $path = substr($path, 0, -1);
        }
        // Url must start with slash
        if(!StringHelper::startsWith($path, '/'))
        {
            $path = '/' . $path;
        }
        return $path;
    }
    
    function getPatternRegex()
    {
        $pattern = $this->pattern;
        $pattern = $this->normalizeSlashes($pattern);
        $pattern = preg_quote($pattern, '/');
        $replace = array(
            '\[' => '[',
            '\]' => ']'
        );
        $pattern = str_replace(array_keys($replace), array_values($replace), $pattern);
        $pattern = preg_replace('/\[(\w+)\]/', '(?<\\1>.+)', $pattern);
        $pattern = sprintf('/%s$/i', $pattern);
        return $pattern;
    }
    
    function getHashCode()
    {
        return md5(serialize($this));
    }
}
