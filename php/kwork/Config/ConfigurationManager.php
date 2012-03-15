<?php

class ConfigurationManager
{
    static $instance;
    
    function __construct($filename)
    {
        $this->loadFile($filename);
    }
    
    static function instance()
    {
        if(self::$instance == null)
        {
            $config = new ConfigurationManager('config.xml');
            self::$instance = $config;
        }
        return self::$instance;
    }
    
    function loadFile($filename)
    {
        $strxml = file_get_contents($filename, FILE_USE_INCLUDE_PATH);
        $xml = simplexml_load_string($strxml, null, LIBXML_NOCDATA);
        foreach($xml as $node)
        {
            $className = ucfirst($node->getName()) . 'ConfigParser';
            if(!class_exists($className))
            {
            	throw new Exception("No ConfigurationParser called $className was found");
            }
			$parser = new $className($this);
			$parser->evaluate($node);
        }
    }
    
    /***
     * Single result
     */
    function setting($xpath)
    {
        if( $result = $this->settings->xpath($xpath) )
        {
            $result = $result[0];
            return $result;
        }
        return false;
    }
    
	/***
	 * Multiple results
	 */
    function settings($xpath)
    {
        return $this->settings->xpath($xpath);
    }
    
    function section($name)
	{
		if(isset($this->{$name}))
			return $this->{$name};
		return false;
	}
}