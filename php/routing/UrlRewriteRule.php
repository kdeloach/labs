<?php

require_once dirname(__FILE__) . DIRECTORY_SEPARATOR . 'UrlRewriteRuleMetaData.php';

class UrlRewriteRule
{
    public $Pattern = '';
    public $Endpoint = '';
    public $MetaData = array();
    
    function __construct($pattern='', $endpoint='')
    {
        $this->Pattern = $pattern;
        $this->Endpoint = $endpoint;
    }

    /**
     * Determine if pattern matches url
     */
    function match($url)
    {
        $regex = $this->toRegex();
        if(preg_match($regex, $url, $matches))
        {
            $result = array();
            foreach($matches as $tag => $val)
            {
                if(is_numeric($tag))
                {
                    continue;
                }
                if($this->isArrayField($tag))
                {
                    $val = explode(',', $val);
                }
                $val = is_array($val) ? array_map('urldecode', $val) : urldecode($val);
                $result[$tag] = $val;
            }
            return array_merge($this->metaDataArray(), $result);
        }
        return false;
    }
    
    function isArrayField($tag)
    {
        foreach($this->MetaData as $metaData)
        {
            if($metaData->Name == 'ArrayField' && $metaData->Value == $tag)
            {
                return true;
            }
        }
        return false;
    }

    /**
     * Generate url
     * param @data Array of key/value pairs
     */
    function url($data)
    {
        $result = $this->Pattern;
        $tags = $this->getTags();
        foreach($tags as $tag)
        {
            $tagName = str_replace(array('[', ']'), '', $tag);
            $tagVal = isset($data[$tagName]) ? $data[$tagName] : '';
            $valz = is_array($tagVal) ? $tagVal : array($tagVal);
            $valz = array_map('urlencode', $valz);
            $val = implode(',', $valz);
            $result = str_replace($tag, $val, $result);
        }
        return $result;
    }
    
    /**
     * Generate url with querystring
     * param @data Array of tags (key/value pairs)
     * param @qs   Array of key/value pairs
     */
    function qsurl($data, $qs)
    {
        $url = $this->url($data);
        if(!$this->endsWith('/', $url))
        {
            $url .= '/';
        }
        return  $url . '?' . http_build_query($qs);
    }
    
    function endsWith($needle, $haystack)
    {
        return strrpos($haystack, $needle) === strlen($haystack) - 1;
    }
    
    /**
     * Remove brackets from tag
     */
    function cleanTag($tag)
    {
        return str_replace(array('[', ']'), '', $tag);
    }

    /**
     * Convert url pattern to regex
     */
    function toRegex()
    {
        $result = preg_quote($this->Pattern, '~');
        $tags = $this->getTags();
        foreach($tags as $tag)
        {
            $tagName = str_replace(array('[', ']'), '', $tag);
            $escapedTag = '\[' . $tagName . '\]';
            // We always assume tags in the url pattern are separated by one or more delimiters.
            // Therefore, we are able to end the regex with a "?" to support values ommitted from the url (optional search form fields).
            // Named capture groups are used so we don't have to keep track of index position and ordering.
            $regex = "(?P<$tagName>[^\?/]+)?";
            $result = str_replace($escapedTag, $regex, $result);
        }
        $result = '~^' . $result . '/?$~i';
        return $result;
    }

    /**
     * Returns array of placeholder tags detected in url pattern
     */
    function getTags()
    {
        if(preg_match_all("/\[[a-z0-9_]+\]/i", $this->Pattern, $matches))
        {
            return $matches[0];
        }
        return array();
    }
    
    function getTagsUnique()
    {
        return array_unique($this->getTags());
    }
    
    /**
     * Determine if rule meta data matches $data
     * @param array $data
     * @return bool
     */
    function metaDataMatches($data)
    {
        if(!isset($data) || !is_array($data) || empty($data))
        {
            return false;
        }
        $arrMetaData = $this->metaDataArray();
        foreach($data as $k => $v)
        {
            if(!isset($arrMetaData[$k]) || $arrMetaData[$k] != $v)
            {
                return false;
            }
        }
        return true;
    }
    
    /**
     * Returns meta data as array of key/value pairs
     * @return array
     */
    function metaDataArray()
    {
        $result = array();
        foreach($this->MetaData as $meta)
        {
            switch($meta->Name)
            {
                case 'ArrayField':
                    if(!isset($result['ArrayField']))
                    {
                        $result['ArrayField'] = array();
                    }
                    $result['ArrayField'][] = $meta->Value;
                    break;
                default:
                    $result[$meta->Name] = $meta->Value;
                    break;
            }
        }
        return $result;
    }
}
