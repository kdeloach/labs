<?php

class AppMain
{
    public static function handleRequest($appPath)
    {
    	self::registerIncludePath(dirname(__FILE__));
    	self::registerIncludePath($appPath);
    	self::registerAutoload();
    	
    	//set_error_handler(array('AppMain', 'errorHandler'));
    	
    	// TODO: Where to put this? Hm...
		Twig_Autoloader::register();
		
        self::executeHandlers();
    }
	
	private static function executeHandlers()
	{
        $config = ConfigurationManager::instance();
		if($handlers = $config->section('handlers'))
		{
			$uri = $_SERVER['REQUEST_URI'];
			foreach($handlers as $handler)
			{
				$pattern = $handler->requestPattern();
				$route = new HandlerRoute($pattern);
				if($route->match($uri) !== false)
				{
					$handler->handleRequest();
					break;
				}
			}
		}
	}
	
	static function registerAutoload()
	{
		spl_autoload_register('AppMain::autoload');
	}
	
	static function autoload($className)
	{
		$filename = str_replace(array('_', '\\'), DIRECTORY_SEPARATOR, $className) . '.php';
		if(($res = include $filename) !== false)
		{
			return true;
		}
		return false;
	}
	
	static function errorHandler($errno, $errstr, $errfile, $errline, $errcontext)
	{
		if (!(error_reporting() & $errno)) {
	        // This error code is not included in error_reporting
	        return true;
	    }
	    throw new Exception("$errstr, $errfile, $errline", 0);	    
	}
	
	static function registerIncludePath($rootPath)
	{
		set_include_path(get_include_path() . PATH_SEPARATOR . self::getIncludepath($rootPath));
	}
	
	static function getIncludepath($rootPath)
	{		
		$directory = new RecursiveDirectoryIterator($rootPath);
		$iterator = new RecursiveIteratorIterator($directory, RecursiveIteratorIterator::SELF_FIRST);

		$result = $rootPath;
		foreach($iterator as $path => $fileinfo)
		{
    		if(strstr($path, '.svn') !== false)
    		    continue;
            $result .= PATH_SEPARATOR . $path;
		}
		
		return $result;
	}
}
