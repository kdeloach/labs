This is a basic url router written for a personal project. The synax is very simple, and arbitrary meta data can be attached to rules. The `ArrayField` meta data will split values by comma. Check `UrlRewriterTest` for documentation.

The code for pulling rules from a data source has been omitted. Further refactorings may be needed for general use.

Examples:

    $url = 'http://kevinx.local/PA';
    $rule = new UrlRewriteRule('http://kevinx.local/[state]');
    $data = $rule->match($url);
    print_r($data);

    Array
    (
        [state] => 'PA'
    )
    

    $url = 'http://kevinx.local/PA,NJ';
    $rule = new UrlRewriteRule('http://kevinx.local/[state]');
    $rule->MetaData = array(
        new UrlRewriteRuleMetaData('blah', 'test'),
        new UrlRewriteRuleMetaData('ArrayField', 'state')
    );
    $data = $rule->match($url);
    print_r($data);

    Array
    (
        [blah] => test
        [ArrayField] => Array
            (
                [0] => state
            )
        [state] => Array
            (
                [0] => PA
                [1] => NJ
            )
    )
    
    $url = 'http://kevinx.local/PA,NJ/Philadelphia,Camden';
    $rule = new UrlRewriteRule('http://kevinx.local/[state]/[city]');
    $rule->MetaData = array(
        new UrlRewriteRuleMetaData('ArrayField', 'state'),
        new UrlRewriteRuleMetaData('ArrayField', 'city')
    );
    $data = $rule->match($url);
    print_r($data);

    Array
    (
        [ArrayField] => Array
            (
                [0] => state
                [1] => city
            )
        [state] => Array
            (
                [0] => PA
                [1] => NJ
            )
        [city] => Array
            (
                [0] => Philadelphia
                [1] => Camden
            )
    )


    $rw = new UrlRewriter();
    if(($data = $rw->match($url)) !== false)
    {
        var_dump($data);
    }

    $data = array('page' => $data['page'] + 1);
    if(($rule = $rw->findRule($url)) !== false)
    {
        if(($url = $rule->url($data)) !== false)
        {
            header('Location: ' . $url);
        }
    }
