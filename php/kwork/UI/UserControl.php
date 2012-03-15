<?php

abstract class UserControl extends TemplateControl
{
    function __construct()
    {
        parent::__construct();
    }
    
    function templateFileName($templateName)
    {
        $filename = parent::templateFileName($templateName);
        $filename = 'Controls' . DIRECTORY_SEPARATOR . $filename;
        return $filename;
    }
    
    function __toString()
    {
        return $this->render();
    }
}
