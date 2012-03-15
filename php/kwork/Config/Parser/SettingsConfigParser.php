<?php

class SettingsConfigParser implements IConfigParser
{
    var $config;
    
    function __construct($config)
    {
        $this->config = $config; 
    }
    
    function evaluate($node)
    {
        $this->config->settings = $node;
    }
}