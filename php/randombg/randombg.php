<?php

function clamp($val, $bounds)
{ 
    list($lo, $hi) = $bounds;
    return max($lo, min($hi, $val));
}

function rand_val($arr)
{
    shuffle($arr);
    return $arr[array_rand($arr)];
}

function rand_size()
{
    return rand_val(range(30, 50, 10));
}

function rand_width()
{
    return rand_val(range(1, 7));
}

function rand_height()
{
    return rand_val(range(1, 4));
}

function default_bounds()
{
    return array(
        'r' => array(75, 200),
        'g' => array(75, 200),
        'b' => array(75, 200)
    );
}

function randombg($s, $w, $h, $bounds)
{
    $w *= $s;
    $h *= $s;

    $im = imagecreatetruecolor($w, $h);
    imagecolorallocate($im, 0, 0, 0);

    foreach(range(0, $h, $s) as $y)
    {
        foreach(range(0, $w, $s) as $x)
        {
            $color = imagecolorallocate($im,
                clamp(rand(0, 255), $bounds['r']),
                clamp(rand(0, 255), $bounds['g']),
                clamp(rand(0, 255), $bounds['b'])
            );
            imagefilledrectangle($im, $x, $y, $x + $s, $y + $s, $color);
        }
    }

    header('Content-type: image/gif');
    imagegif($im);
    imagedestroy($im);
}

if(basename($_SERVER['SCRIPT_NAME']) == basename(__FILE__))
{
    if(isset($_GET['seed']) && is_numeric($_GET['seed']))
    {
        srand((int)$_GET['seed']);
    }
    $s = isset($_GET['s']) ? $_GET['s'] : rand_size();
    $w = isset($_GET['w']) ? $_GET['w'] : rand_width();
    $h = isset($_GET['h']) ? $_GET['h'] : rand_height();
    $bounds = isset($_GET['bounds']) ? $_GET['bounds'] : default_bounds();
    randombg($s, $w, $h, $bounds);
}
