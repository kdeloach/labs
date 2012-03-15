<?php

function wordfind($query, $exclude)
{
    $range = array();
    foreach(str_split('abcdefghijklmnopqrstuvwxyz') as $letter)
    {
        if(!in_array($letter, $exclude))
        {
            $range[] = $letter;
        }
    }
    $range = implode('', $range);

    $query = trim($query);
    $pattern = preg_replace('/[^a-z]/i', '*', $query);
    $pattern = '/'.str_replace('*', "[$range]", $pattern).'/i';

    $words = file('words.txt');
    $result = array();

    foreach($words as $word)
    {
        if(strlen(trim($word)) != strlen($query))
        {
            continue;
        }
        if(preg_match($pattern, $word))
        {
            $result[] = trim($word);
        }
    }

    return $result;
}

if(isset($argv) && count($argv) >= 1)
{
    if(count($argv) < 2)
    {
        echo "Usage: php wordfind.php format [exclude]\n";
        echo "Example: php wordfind.php appl_ aiou\n";
        exit;
    }
    $range = array();
    if(isset($argv[2]))
    {
        $range = str_split($argv[2]);
    }
    $result = wordfind($argv[1], $range);
    echo implode("\n", $result);
    exit;
}
