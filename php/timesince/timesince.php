<?php

$a = time();
$b = time();

$t = 0;
$s = '';

if(isset($_GET) && !empty($_GET))
{
    extract($_GET);

    $a = strtotime($a);
    $b = strtotime($b);

    if($a === false || $b === false)
    {
        die('bad date format');
    }

    $c = abs($a - $b) / 3600;

    $a2 = date('g:i a', $a);
    $b2 = date('g:i a', $b);

    $s = "Elapsed hours between $a2 and $b2: $c hour(s).<br />\n" . $s;
    $t += $c;
}

$_GET['t'] = $t;
$_GET['s'] = $s;

?>

<form method="get" action="">
    <input type="hidden" name="t" value="<?php echo (isset($_GET['t'])?$_GET['t']:'') ?>" />
    <input type="hidden" name="s" value="<?php echo (isset($_GET['s'])?$_GET['s']:'') ?>" />

    start datetime - <input type="text" name="a" value="<?php echo (isset($_GET['a'])?$_GET['a']:'') ?>" /><br />
    stop  datetime - <input type="text" name="b" value="<?php echo (isset($_GET['b'])?$_GET['b']:'') ?>" />
    <input type="submit" /> <a href="timesince.php">Reset</a>
</form>

<?php
    if(!empty($_GET))
    {
        echo '<hr />';
        echo '<em>Total elapsed time: '. $t .'</em><br/>';
        echo $s;
    }
?>