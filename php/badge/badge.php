<?php

if(!isset($_GET['txt']))
{
    die('Missing parameter: txt');
}
$text = stripslashes(trim($_GET['txt']));
$c = isset($_GET['c']) ? strtolower(trim($_GET['c'])) : '';
switch($c)
{
    case 'g':
    case 'gold':
        $color = '#ffcc00';
        break;
    case 's':
    case 'silver':
        $color = '#c0c0c0';
        break;
    case 'b':
    case 'bronze':
    default:
        $color = '#cc9966';
        break;
}
list($r, $g, $b) = sscanf($color, '#%2x%2x%2x');

//////

$size = 11;
$angle = 0;
$font = 'CALIBRI.TTF';
$box = imagettfbbox($size, $angle, $font, $text);
$box['width'] = abs($box[2] - $box[0]);
if($box[0] < -1) {
    $box['width'] = abs($box[2]) + abs($box[0]) - 1;
}

$emblemwidth = 18;
$imgwidth = $box['width'] + $emblemwidth + 7;
$imgheight = 24;

$im = imagecreatetruecolor($imgwidth, $imgheight);
imagealphablending ($im, true);

$transcolor = imagecolorallocate($im, 0xFF, 0xFF, 0xFF);
$badgecolor = imagecolorallocate($im, 0x33, 0x33, 0x33);
$color = imagecolorallocate($im, 0xff, 0xff, 0xff);
$emblemcolor = imagecolorallocate($im, $r, $g, $b);

imagefill($im, 0, 0, $transcolor);
imagefillroundedrect($im, 0, 0, $imgwidth-1, $imgheight-1, 5, $badgecolor);

// draw emblem
$r = 7;
$x = 10;
$y =  $imgheight/2;
imagefilledellipseaa ($im, $x, $y, $r, $r, $emblemcolor);

// draw text
$x = $emblemwidth;
$y = $size / 2 + $imgheight / 2;
imagettftext($im, $size, $angle, $x, $y, $color, $font, $text);

// output
header('Content-type: image/png');
imagepng($im);

//////////////////

// Parses a color value to an array.
function color2rgb($color)
{
    $rgb = array();
    $rgb[] = 0xFF & ($color >> 16);
    $rgb[] = 0xFF & ($color >> 8);
    $rgb[] = 0xFF & ($color >> 0);
    return $rgb;
}

// Parses a color value to an array.
function color2rgba($color)
{
    $rgb = array();
    $rgb[] = 0xFF & ($color >> 16);
    $rgb[] = 0xFF & ($color >> 8);
    $rgb[] = 0xFF & ($color >> 0);
    $rgb[] = 0xFF & ($color >> 24);
    return $rgb;
}

// Adapted from http://homepage.smc.edu/kennedy_john/BELIPSE.PDF
function imagefilledellipseaa_Plot4EllipsePoints(&$im, $CX, $CY, $X, $Y, $color, $t)
{
    imagesetpixel($im, $CX+$X, $CY+$Y, $color); //{point in quadrant 1}
    imagesetpixel($im, $CX-$X, $CY+$Y, $color); //{point in quadrant 2}
    imagesetpixel($im, $CX-$X, $CY-$Y, $color); //{point in quadrant 3}
    imagesetpixel($im, $CX+$X, $CY-$Y, $color); //{point in quadrant 4}
    $aColor = color2rgba($color);
    $mColor = imagecolorallocate($im, $aColor[0], $aColor[1], $aColor[2]);
    if ($t == 1)
    {
          imageline($im, $CX-$X, $CY-$Y+1, $CX+$X, $CY-$Y+1, $mColor);
          imageline($im, $CX-$X, $CY+$Y-1, $CX+$X, $CY+$Y-1, $mColor);
    } else {
          imageline($im, $CX-$X+1, $CY-$Y, $CX+$X-1, $CY-$Y, $mColor);
          imageline($im, $CX-$X+1, $CY+$Y, $CX+$X-1, $CY+$Y, $mColor);
    }
    imagecolordeallocate($im, $mColor);
}

// Adapted from http://homepage.smc.edu/kennedy_john/BELIPSE.PDF
function imagefilledellipseaa(&$im, $CX, $CY, $Width, $Height, $color)
{
    $XRadius = floor($Width/2);
    $YRadius = floor($Height/2);
    $baseColor = color2rgb($color);
    $TwoASquare = 2*$XRadius*$XRadius;
    $TwoBSquare = 2*$YRadius*$YRadius;
    $X = $XRadius;
    $Y = 0;
    $XChange = $YRadius*$YRadius*(1-2*$XRadius);
    $YChange = $XRadius*$XRadius;
    $EllipseError = 0;
    $StoppingX = $TwoBSquare*$XRadius;
    $StoppingY = 0;
    $alpha = 77;
    $color = imagecolorexactalpha($im, $baseColor[0], $baseColor[1], $baseColor[2], $alpha);
    while ($StoppingX >= $StoppingY)
    {
        imagefilledellipseaa_Plot4EllipsePoints($im, $CX, $CY, $X, $Y, $color, 0);
        $Y++;
        $StoppingY += $TwoASquare;
        $EllipseError += $YChange;
         $YChange += $TwoASquare;
        if ((2*$EllipseError + $XChange) > 0)
        {
            $X--;
            $StoppingX -= $TwoBSquare;
            $EllipseError += $XChange;
            $XChange += $TwoBSquare;
        }
        $filled = $X - sqrt(($XRadius*$XRadius - (($XRadius*$XRadius)/($YRadius*$YRadius))*$Y*$Y));
        $alpha = abs(90*($filled)+37);
        imagecolordeallocate($im, $color);
        $color = imagecolorexactalpha($im, $baseColor[0], $baseColor[1], $baseColor[2], $alpha);
    }
    $X = 0;
    $Y = $YRadius;
    $XChange = $YRadius*$YRadius;
    $YChange = $XRadius*$XRadius*(1-2*$YRadius);
    $EllipseError = 0;
    $StoppingX = 0;
    $StoppingY = $TwoASquare*$YRadius;
    $alpha = 77;
    $color = imagecolorexactalpha($im, $baseColor[0], $baseColor[1], $baseColor[2], $alpha);
    while ($StoppingX <= $StoppingY)
    {
        imagefilledellipseaa_Plot4EllipsePoints($im, $CX, $CY, $X, $Y, $color, 1);
        $X++;
        $StoppingX += $TwoBSquare;
        $EllipseError += $XChange;
        $XChange += $TwoBSquare;
        if ((2*$EllipseError + $YChange) > 0)
        {
            $Y--;
            $StoppingY -= $TwoASquare;
            $EllipseError += $YChange;
            $YChange += $TwoASquare;
        }
        $filled = $Y - sqrt(($YRadius*$YRadius - (($YRadius*$YRadius)/($XRadius*$XRadius))*$X*$X));
        $alpha = abs(90*($filled)+37);
        imagecolordeallocate($im, $color);
        $color = imagecolorexactalpha($im, $baseColor[0], $baseColor[1], $baseColor[2], $alpha);
    }
}

// Source: http://www.web-max.ca/PHP/misc_10.php
function imagefillroundedrect($im, $x, $y, $cx, $cy, $rad, $col)
{
    // Draw the middle cross shape of the rectangle
    imagefilledrectangle($im,$x,$y+$rad,$cx,$cy-$rad,$col);
    imagefilledrectangle($im,$x+$rad,$y,$cx-$rad,$cy,$col);
    
    $dia = $rad * 2;
    
    // Now fill in the rounded corners
    imagefilledellipse($im, $x+$rad, $y+$rad, $rad*2, $dia, $col);
    imagefilledellipse($im, $x+$rad, $cy-$rad, $rad*2, $dia, $col);
    imagefilledellipse($im, $cx-$rad, $cy-$rad, $rad*2, $dia, $col);
    imagefilledellipse($im, $cx-$rad, $y+$rad, $rad*2, $dia, $col);
}
