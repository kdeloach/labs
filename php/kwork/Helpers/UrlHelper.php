<?php

class UrlHelper
{
    // Source: http://www.webcheatsheet.com/PHP/get_current_page_url.php
    static function currentUrl()
    {
        $pageURL = 'http';
        if(isset($_SERVER["HTTPS"]) && $_SERVER["HTTPS"] == "on") {
            $pageURL .= "s";
        }
        $pageURL .= "://";
        if($_SERVER["SERVER_PORT"] != "80") {
            $pageURL .= $_SERVER["SERVER_NAME"].":".$_SERVER["SERVER_PORT"].$_SERVER["REQUEST_URI"];
        } else {
            $pageURL .= $_SERVER["SERVER_NAME"].$_SERVER["REQUEST_URI"];
        }
        return $pageURL;
    }
    
    static function removeQueryString($url)
    {
        if(($pos=strpos($url, '?')) !== false)
        {
            $newUrl = substr($url, 0, $pos);
            return $newUrl;
        }
        return $url;
    }
}
