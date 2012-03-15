<?php

class RouteHandler implements IRequestHandler
{
    var $requestPattern;
    
    function __construct($requestPattern)
    {
        $this->requestPattern = $requestPattern;
    }
    
    function requestPattern()
    {
        return $this->requestPattern;
    }
    
    function handleRequest()
    {        
        $config = ConfigurationManager::instance();
        $uri = $_SERVER['REQUEST_URI'];

        if(list($route, $matches) = $config->routes->match($uri))
        {        
            if(!array_key_exists('controller', $route->args))
            {
                echo 'No "controller" attribute specified for route.';
                print_r($route);
                exit;
            }
            if(!array_key_exists('action', $route->args))
            {
                echo 'No "action" attribute specified for route.';
                print_r($route);
                exit;
            }
            
            $rd = new RouteDispatcher();
            $rd->dispatch($route, $matches);
        }
        else
        {
            header("HTTP/1.0 404 Not Found");
            header("Status: 404 Not Found");
            die('No match found');
        }
    }
}
