<?php

abstract class TemplateControl
{
    var $config;
    
    function __construct()
    {
        $this->config = ConfigurationManager::instance();
    }
    
    function render($templateName=null, $args=null)
    {
        $appPath = (string)$this->config->setting('appPath');
        $templatePath = $appPath . DIRECTORY_SEPARATOR . 'Templates';
        $cachePath = $appPath . DIRECTORY_SEPARATOR . 'Templates/Cache';
                
        $templateArgs = $this->templateArgs($args);
        $templateName = $this->templateFileName($templateName);
               
        $loader = new Twig_Loader_Filesystem($templatePath);
        $twig = new Twig_Environment($loader, array(
            //'cache' => $cachePath
        ));
        
        $template = $twig->loadTemplate($templateName);   
        return $template->render($templateArgs);
    }
    
    function templateArgs($args)
    {
        if($args != null) {
            return $args;
        }
        $result = array();
        $rc = new ReflectionObject($this);
        foreach($rc->getProperties() as $prop)
        {
            $key = $prop->getName();
            $val = $this->{$key};
            if(is_object($val))
            {
                $rcProp = new ReflectionObject($val);
                if($rcProp->isSubClassOf('TemplateControl'))
                {
                    $result[$key] = $val->render();
                }
            }
            else
            {
                $result[$key] = $val;
            }
        }
        return $result;
    }
    
    function templateFileName($templateName)
    {
        if($templateName != null) {
            if(!StringHelper::endsWith($templateName, '.html')) {
                $templateName .= '.html';
            }
            return $templateName;
        }
        $rc = new ReflectionObject($this);
        $filename = $rc->getName() . '.html';
        return $filename;
    }
}
