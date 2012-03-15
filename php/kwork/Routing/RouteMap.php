<?php

class RouteMap
{
    var $routes = array();
    
    function __construct()
    {
    }
    
    function add($route)
    {
        $this->routes[$route->getHashCode()] = $route;
    }
    
    function match($uri)
    {
        foreach($this->routes as $route)
        {
            if(($matches = $route->match($uri)) !== false)
            {
                return array($route, $matches);
            }
        }
        return null;
    }
}
