<?php

require 'randombg.php';

$s = isset($_GET['s']) ? $_GET['s'] : rand_size();
$w = isset($_GET['w']) ? $_GET['w'] : rand_width();
$h = isset($_GET['h']) ? $_GET['h'] : rand_height();
$bounds = isset($_GET['bounds']) ? $_GET['bounds'] : default_bounds();

$query = http_build_query(array(
    's' => $s,
    'w' => $w,
    'h' => $h,
    'bounds' => $bounds,
    'seed' => rand()
));

function optionsHtml($val)
{
    $result = '';
    foreach(range(0, 255) as $n)
    {
        $selected = $n == $val ? 'selected="selected"' : '';
        $result .= "<option $selected>$n</option>";
    }
    return $result;
}

?><!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
<head>
  <style type="text/css">
    html,body,p,input,select { font:18px/18px serif; }
    form { margin:0;padding:0; padding:15px 25px; }
    form p { clear:both; padding:0; margin:5px 0; }
    form label { float:left; width:150px; }
    body{ background:url(randombg.php?<?php echo $query; ?>) }
    #frm { position: absolute; top: 100px; left: 150px; width: 430px; background: #eee; -webkit-border-radius: 10px; -moz-border-radius: 10px; border-radius: 10px;}
    #size, #w, #h { float:left; }
    .ff {float:left; margin-left:10px; } 
  </style>
  <script type="text/javascript" src="slider/js/range.js"></script>
  <script type="text/javascript" src="slider/js/timer.js"></script>
  <script type="text/javascript" src="slider/js/slider.js"></script>
  <link type="text/css" rel="StyleSheet" href="slider/css/bluecurve/bluecurve.css" />
</head>
<body>
<div id="frm">
  <form method="get" action="<?php echo $_SERVER['REQUEST_URI']; ?>">
  
    <p>
    <label for="size">Size:</label>
    <div class="slider" id="size">
        <input class="slider-input" id="size-input" name="s" />
    </div>
    <span class="ff" id="size-value"></span>
    <script type="text/javascript">
        var s = new Slider(document.getElementById('size'), document.getElementById('size-input'));
        s.setMinimum(10);
        s.setMaximum(50);
        s.setValue(<?php echo $s; ?>);
        s.onchange = function() {
            document.getElementById('size-value').innerHTML = s.getValue();
        };
        document.getElementById('size-value').innerHTML = s.getValue();
    </script>
    </p>
    
    <p>
    <label for="w">Cols:</label>

    <div class="slider" id="w">
        <input class="slider-input" id="w-input" name="w" />
    </div>
    <span class="ff" id="w-value"></span>
    <script type="text/javascript">
        var w = new Slider(document.getElementById('w'), document.getElementById('w-input'));
        w.setMinimum(1);
        w.setMaximum(20);
        w.setValue(<?php echo $w; ?>);
        w.onchange = function() {
            document.getElementById('w-value').innerHTML = w.getValue();
        };
        document.getElementById('w-value').innerHTML = w.getValue();
    </script>
    </p>
    
    <p>
    <label for="h">Rows:</label>
    <div class="slider" id="h">
        <input class="slider-input" id="h-input" name="h" />
    </div>
    <span class="ff" id="h-value"></span>
    <script type="text/javascript">
        var h = new Slider(document.getElementById('h'), document.getElementById('h-input'));
        h.setMinimum(1);
        h.setMaximum(20);        
        h.setValue(<?php echo $h; ?>);
        h.onchange = function(){ document.getElementById('h-value').innerHTML=h.getValue(); };
        document.getElementById('h-value').innerHTML = h.getValue();
    </script>
    </p>
    
    <hr/>
    
    <p>
        <label for="r1">Red (min/max):</label>
        <select name="bounds[r][0]" id="r1"><?php echo optionsHtml($bounds['r'][0]); ?></select> / 
        <select name="bounds[r][1]" id="r2"><?php echo optionsHtml($bounds['r'][1]); ?></select>
    </p>
    <p>
        <label for="g1">Green (min/max):</label>
        <select name="bounds[g][0]" id="g1"><?php echo optionsHtml($bounds['g'][0]); ?></select> / 
        <select name="bounds[g][1]" id="g2"><?php echo optionsHtml($bounds['g'][1]); ?></select>
    </p>
    <p>
        <label for="b1">Blue (min/max):</label>
        <select name="bounds[b][0]" id="g1"><?php echo optionsHtml($bounds['b'][0]); ?></select> / 
        <select name="bounds[b][1]" id="g2"><?php echo optionsHtml($bounds['b'][1]); ?></select>
    </p>
    
    <hr/>
    <p style="text-align:right"><a href="randombg.php?<?php echo $query; ?>">View background image</a> <input type="submit" value="generate" /></p>
  </form>
</div>

</body>
</html>
