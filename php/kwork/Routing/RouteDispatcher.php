<?php

class RouteDispatcher
{
    function __construct()
    { 
    }
    
    function dispatch($route, $matches)
    {
        $className = $route->args['controller'];
        $methodName = $route->args['action'];
        $objController = null;
        
        try
        {
            $rc = new ReflectionClass($className);
            $objController = $rc->newInstance();
        }
        catch(ReflectionException $ex)
        {
            throw new Exception('Could not load controller class', 0, $ex);
        }

        try
        {
            $rm = new ReflectionMethod($className, $methodName);
            $orderedArgs = self::prepareActionArgs($matches, $rm->getParameters());
            $rm->invokeArgs($objController, $orderedArgs);
        }
        catch(ReflectionException $ex)
        {
            throw new Exception('Could not load controller action', 0, $ex);
        }
    }
    
    ///
    ///  Puts arguments from route in the right order according to the method signature.
    ///
    static function prepareActionArgs($routeArgs, $rmParams)
    {
        $result = array();
        foreach($rmParams as $param)
        {
            $val = null;
            $key = $param->name;
            if(isset($routeArgs[$key]))
            {
                $val = $routeArgs[$key];
            }
            else
            {
                $val = $param->getDefaultValue();
            }
            $result[$key] = $val;
        }
        return $result;
    }
}
