<?php

class UrlRewriteRuleMetaData
{
    public $Name = '';
    public $Value = '';

    function __construct($name = '', $value = '')
    {
        $this->Name = $name;
        $this->Value = $value;
    }
}
