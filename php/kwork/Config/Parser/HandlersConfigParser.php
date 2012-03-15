<?php

class HandlersConfigParser implements IConfigParser
{
    var $config;
    
    function __construct($config)
    {
        $this->config = $config; 
    }
    
    function evaluate($node)
    {
		foreach($node as $child)
		{
			$attrs = $child->attributes();
			$className = (string)$attrs['name'];
			$pattern = (string)$attrs['pattern'];
			$rcHandler = new ReflectionClass($className);
			$handler = $rcHandler->newInstanceArgs(array($pattern));
			$this->config->handlers[] = $handler;
		}
    }
}
