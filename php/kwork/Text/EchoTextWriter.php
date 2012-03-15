<?php

class EchoTextWriter implements ITextWriter
{
    function write($text)
    {
        echo $text;
    }
    
    function writeLine($text)
    {
        echo $text . PHP_EOL;
    }
}
