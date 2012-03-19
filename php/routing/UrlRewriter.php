<?php 

require_once dirname(__FILE__) . DIRECTORY_SEPARATOR . 'UrlRewriteRule.php';
require_once dirname(__FILE__) . DIRECTORY_SEPARATOR . 'UrlRewriteRuleMetaData.php';

class UrlRewriter
{
    function __construct()
    {
    }

    /**
     * List of UrlRewriteRule instances
     * @return array of UrlRewriteRule
     */
    function getRules()
    {
        $rules = $this->_dbGetRules();
        $rules = $this->_prepareRules($rules);
        return $rules;
    }
    
    // Return array of rules
    function _dbGetRules()
    {
        // TODO: Pull rules from data source
    }
    
    function _prepareRules($rules)
    {
        return $rules;
    }
    
    /**
     * Returns first rule that matches the url
     * @param string $url
     * @return UrlRewriteRule or false 
     */
    function findRule($url)
    {
        $rules = $this->getRules();
        foreach($rules as $rule)
        {
            if($rule->match($url))
            {
                return $rule;
            }
        }
        return false;
    }
    
    /**
     * Returns first rule that matches the given meta data
     * @param array $data 
     * @return UrlRewriteRule or false
     */
    function findRuleByMetaData($data)
    {
        $rules = $this->getRules();
        foreach($rules as $rule)
        {
            if($rule->metaDataMatches($data))
            {
                return $rule;
            }
        }
        return false;
    }
    
    /**
     * Matches against url and returns data extracted
     * @param string $url
     * @return array
     */
    function match($url)
    {
        $rule = $this->findRule($url);
        if($rule !== false)
        {
            return $rule->match($url);
        }
        return false;
    }
}
