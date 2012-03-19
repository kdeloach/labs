<?php

error_reporting(E_ALL);

require_once 'PHPUnit/Framework.php';
require_once dirname(__FILE__) . DIRECTORY_SEPARATOR . 'UrlRewriter.php';
require_once dirname(__FILE__) . DIRECTORY_SEPARATOR . 'UrlRewriteRule.php';
require_once dirname(__FILE__) . DIRECTORY_SEPARATOR . 'UrlRewriteRuleMetaData.php';

class UrlRewriterTest_UrlRewriter extends UrlRewriter
{
    var $rules = array();

    function _dbGetRules()
    {
        return $this->rules;
    }
}

class UrlRewriterTest_TestRule extends UrlRewriteRule
{
    function __construct($pattern)
    {
        $this->Pattern = $pattern;
    }
}

class UrlRewriterTest extends PHPUnit_Framework_TestCase
{
    function testRuleParsing1()
    {
        $url = 'http://kevinx.local/Philadelphia/PA';
        $rule = new UrlRewriterTest_TestRule('http://kevinx.local/[city]/[state]');

        $tags = $rule->getTags();
        $this->assertEquals(2, count($tags), var_export($tags, true));
        $this->assertContains('[city]', $tags);
        $this->assertContains('[state]', $tags);

        $data = $rule->match($url);
        $this->assertTrue($data !== false);
        $this->assertNotNull($data);
        $this->assertArrayHasKey('city', $data);
        $this->assertArrayHasKey('state', $data);
        $this->assertEquals('Philadelphia', $data['city'], var_export($data['city'], true));
        $this->assertEquals('PA', $data['state']);

        $data = array('city' => 'Camden', 'state' => 'NJ');
        $url = $rule->url($data);
        $this->assertTrue($url !== false);
        $this->assertEquals('http://kevinx.local/Camden/NJ', $url);
    }
    
    // Test parsing with url encoded characters
    function testRuleParsing2()
    {
        $url = 'http://kevinx.local/Philadelphia/PA/10%20Miles';
        $rule = new UrlRewriterTest_TestRule('http://kevinx.local/[city]/[state]/[distance]');
        $tags = $rule->getTags();
        $this->assertEquals(3, count($tags), var_export($tags, true));
        $data = $rule->match($url);
        $this->assertEquals('10 Miles', $data['distance']);
    }
    
    // Test parsing with spaces
    function testRuleParsing3()
    {
        $url = 'http://kevinx.local/Philadelphia/PA/10 Miles';
        $rule = new UrlRewriterTest_TestRule('http://kevinx.local/[city]/[state]/[distance]');
        $tags = $rule->getTags();
        $this->assertEquals(3, count($tags), var_export($tags, true));
        $data = $rule->match($url);
        $this->assertEquals('10 Miles', $data['distance']);
    }
    
    // Test creating url when one tag contains an array of data
    function testUrl1()
    {
        $rule = new UrlRewriterTest_TestRule('http://kevinx.local/[city]');
        $data = array('city' => array('Philadelphia', 'Ardmore'));
        $url = $rule->url($data);
        $this->assertEquals('http://kevinx.local/Philadelphia,Ardmore', $url);
    }
    
    function testUrl2()
    {
        $url = 'http://kevinx.local/PA,NJ/Philadelphia,Camden';
        $rule = new UrlRewriterTest_TestRule('http://kevinx.local/[state]/[city]');
        $rule->MetaData = array(
            new UrlRewriteRuleMetaData('ArrayField', 'state'),
            new UrlRewriteRuleMetaData('ArrayField', 'city')
        );
        $data = $rule->match($url);
        print_r($data);
        $this->assertTrue($data !== false);
        $this->assertArrayHasKey('state', $data);
        $this->assertEquals(2, count($data['state']));
    }

    function testRewriter1()
    {
        $url = 'http://kevinx.local/abc123.html';
        $rw = new UrlRewriterTest_UrlRewriter();
        $rw->rules[] = new UrlRewriterTest_TestRule('http://kevinx.local/[correct].html');
        $rw->rules[] = new UrlRewriterTest_TestRule('http://kevinx.local/[wrong]');
        $rw->rules[] = new UrlRewriterTest_TestRule('http://kevinx.local/[also]/[wrong]');
        $match = $rw->match($url);
        $this->assertTrue($match !== false);
        $this->assertArrayHasKey('correct', $match);
        $this->assertEquals('abc123', $match['correct']);
    }
    
    // Test correct meta data is returned from rule match
    function testMetaData1()
    {
        $url = 'http://kevinx.local/abc123.html';
        $rw = new UrlRewriterTest_UrlRewriter();
        $rule = new UrlRewriterTest_TestRule('http://kevinx.local/[test]');
        $rule->MetaData = array(
            new UrlRewriteRuleMetaData('abc', '123')
        );
        $rw->rules[] = $rule;
        $rules = $rw->getRules();
        foreach($rules as $rule)
        {
            $data = $rule->match($url);
            $this->assertTrue($data !== false);
            $this->assertArrayHasKey('test', $data);
            $this->assertArrayHasKey('abc', $data);
            $this->assertEquals('123', $data['abc']);
        }
    }
    
    // Test findRule returns false when non-string params are used
    function testFindRule1()
    {
        $rw = new UrlRewriterTest_UrlRewriter();
        $rw->rules[] = new UrlRewriterTest_TestRule('http://kevinx.local/a/[test]');
        $rw->rules[] = new UrlRewriterTest_TestRule('http://kevinx.local/b/[test]');
        $rw->rules[] = new UrlRewriterTest_TestRule('http://kevinx.local/c/[test]');
        $this->assertTrue($rw->findRule('') === false);
        $this->assertTrue($rw->findRule(null) === false);
        $this->assertTrue($rw->findRule('http://kevinx.local/a/abc123') !== false);
    }
    
    // Test using query strings
    function testQs1()
    {
        $rule = new UrlRewriterTest_TestRule('http://kevinx.local/[test]');
        $data = array('test' => 'abc123');
        $qs = array('page' => 1, 'foo' => 'bar');
        $url = $rule->qsurl($data, $qs);
        $this->assertEquals('http://kevinx.local/abc123/?page=1&foo=bar', $url);
    }
    
    function testQs2()
    {
        $rule = new UrlRewriterTest_TestRule('http://kevinx.local/[test]/');
        $data = array('test' => 'abc123');
        $qs = array('page' => 1, 'foo' => 'bar');
        $url = $rule->qsurl($data, $qs);
        $this->assertEquals('http://kevinx.local/abc123/?page=1&foo=bar', $url);
    }
    
    function testMetaDataMatch1()
    {
        $rule = new UrlRewriterTest_TestRule('http://kevinx.local/[test]/');
        $rule->MetaData = array(
            new UrlRewriteRuleMetaData('foo', 'bar'),
            new UrlRewriteRuleMetaData('abc', '123')
        );
        $this->assertTrue($rule->metaDataMatches(array('foo' => 'bar')) !== false);
        $this->assertTrue($rule->metaDataMatches(array('abc' => '123')) !== false);
        $this->assertTrue($rule->metaDataMatches(array('foo' => 'bar', 'abc' => '123')) !== false);
        $this->assertTrue($rule->metaDataMatches(null) === false);
        $this->assertTrue($rule->metaDataMatches(array()) === false);
        $this->assertTrue($rule->metaDataMatches(array('bha' => '1')) === false);
        $this->assertTrue($rule->metaDataMatches(array('foo' => '1')) === false);
        $this->assertTrue($rule->metaDataMatches(array('abc' => 'bar')) === false);
    }
    
    function testMetaDataMatch2()
    {
        $rule = new UrlRewriterTest_TestRule('http://kevinx.local/[test]/');
        $rule->MetaData = array(
            new UrlRewriteRuleMetaData('foo', 'bar'),
            new UrlRewriteRuleMetaData('abc', '123')
        );
        $rw = new UrlRewriterTest_UrlRewriter();
        $rw->rules[] = $rule;
        $this->assertTrue($rw->findRuleByMetaData(array('foo' => 'bar')) !== false);
        $this->assertTrue($rw->findRuleByMetaData(array('abc' => '123')) !== false);
        $this->assertTrue($rw->findRuleByMetaData(array('foo' => 'bar', 'abc' => '123')) !== false);
        $this->assertTrue($rw->findRuleByMetaData(null) === false);
        $this->assertTrue($rw->findRuleByMetaData(array()) === false);
        $this->assertTrue($rw->findRuleByMetaData(array('bha' => '1')) === false);
        $this->assertTrue($rw->findRuleByMetaData(array('foo' => '1')) === false);
        $this->assertTrue($rw->findRuleByMetaData(array('abc' => 'bar')) === false);
    }
    
    function testMetaDataToArray1()
    {
        $rule = new UrlRewriterTest_TestRule('http://kevinx.local/[test]/');
        $rule->MetaData = array(
            new UrlRewriteRuleMetaData('foo', 'bar'),
            new UrlRewriteRuleMetaData('abc', '123')
        );
        $arr = $rule->metaDataArray();
        $this->assertArrayHasKey('foo', $arr);
        $this->assertArrayHasKey('abc', $arr);
        $this->assertEquals('bar', $arr['foo']);
        $this->assertEquals('123', $arr['abc']);
    }
    
    function testMetaDataToArray2()
    {
        $rule = new UrlRewriterTest_TestRule('http://kevinx.local/[test]/');
        $rule->MetaData = array(
            new UrlRewriteRuleMetaData('foo', 'bar'),
            new UrlRewriteRuleMetaData('ArrayField', 'A'),
            new UrlRewriteRuleMetaData('ArrayField', 'B'),
            new UrlRewriteRuleMetaData('ArrayField', 'C')
        );
        $arr = $rule->metaDataArray();
        $this->assertArrayHasKey('foo', $arr);
        $this->assertArrayHasKey('ArrayField', $arr);
        $this->assertEquals('bar', $arr['foo']);
        $this->assertTrue(is_array($arr['ArrayField']));
        $this->assertEquals(3, count($arr['ArrayField']));
        $this->assertEquals('A', $arr['ArrayField'][0]);
        $this->assertEquals('B', $arr['ArrayField'][1]);
        $this->assertEquals('C', $arr['ArrayField'][2]);
    }
    
    function testMetaDataArrayField1()
    {
        $url = 'http://kevinx.local/Philadelphia';
        $rule = new UrlRewriterTest_TestRule('http://kevinx.local/[cities]');
        $rule->MetaData = array(
            new UrlRewriteRuleMetaData('ArrayField', 'cities')
        );
        $this->assertTrue($rule->isArrayField('cities'));
        $data = $rule->match($url);
        $this->assertTrue($data !== false);
        $this->assertArrayHasKey('cities', $data);
        $this->assertTrue(is_array($data['cities']), var_export($data, true));
        $this->assertEquals(1, count($data['cities']));
        $this->assertEquals('Philadelphia', $data['cities'][0]);
    }
    
    function testMetaDataArrayField2()
    {
        $url = 'http://kevinx.local/Philadelphia,Ardmore';
        $rule = new UrlRewriterTest_TestRule('http://kevinx.local/[cities]');
        $rule->MetaData = array(
            new UrlRewriteRuleMetaData('ArrayField', 'cities')
        );
        $this->assertTrue($rule->isArrayField('cities'));
        $data = $rule->match($url);
        $this->assertTrue($data !== false);
        $this->assertArrayHasKey('cities', $data);
        $this->assertTrue(is_array($data['cities']));
        $this->assertEquals(2, count($data['cities']));
        $this->assertEquals('Philadelphia', $data['cities'][0]);
        $this->assertEquals('Ardmore', $data['cities'][1]);
    }
    
    // Make sure meta info gets copied to fake rewrite rules
    function testExtraRules2()
    {
        $rw = new UrlRewriterTest_UrlRewriter();
        $rule = new UrlRewriterTest_TestRule('http://kevinx.local/[test]');
        $rule->MetaData = array(new UrlRewriteRuleMetaData('foo', 'bar'));
        $rw->rules[] = $rule;
        foreach($rw->getRules() as $rule)
        {
            $this->assertEquals(1, count($rule->MetaData));
        }
    }
    
    function testDuplicateTags()
    {
        $rule = new UrlRewriterTest_TestRule('http://kevinx.local/[test]/[test]');
        $this->assertTrue(count($rule->getTags()) != count($rule->getTagsUnique()));
        $this->assertEquals(2, count($rule->getTags()));
        $this->assertEquals(1, count($rule->getTagsUnique()));
    }
}
