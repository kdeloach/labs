<?php
    if(isset($_GET['q']))
    {
        require 'wordfind.php';
        $exclude = isset($_GET['lz']) ? str_split($_GET['lz']) : array();
        $result = wordfind($_GET['q'], $exclude);
        header('Content-type: application/json');
        echo json_encode($result);
        exit;
    }
?><!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
   "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<style type="text/css">
    p { clear: both; }
    label { float: left; width: 100px; padding: 10px; }
    input { font-size: 18pt; letter-spacing: 5px; }
    #res { position: absolute; top: 0; right: 0; width: 40%; background-color: #ddd; overflow: scroll; height: 100%; }
    .hide { display: none; }
</style>
<script src="https://ajax.googleapis.com/ajax/libs/jquery/1.7.1/jquery.min.js"></script>
<script type="text/javascript">
    var qt = null;
    $(document).ready(function() {
        $('input').keyup(function(evt) {
            clearTimeout(qt);
            qt = setTimeout(function() {
                update();
            }, 500);
        });
        update();
    });
    function update() {
        var args = {
            q: $('#q').val(),
            lz: $('#lz').val()
        };
        $.get('<?php echo $_SERVER['REQUEST_URI']; ?>', args, function(data) {
            $('#res').show();
            var ul = $('<ul>');
            for(i in data) {
                ul.append($('<li>' + data[i] + '</li>'));
            }
            $('#res').html('');
            $('#res').append(ul);
        });
    }
</script>
</head>
<body>
<form method="get">
    <p>
        <label for="q">Format:</label>
        <input type="text" name="q" id="q" maxlength="50" autocomplete="off" value="te_t" />
    </p>
    <p>
        <label for="lz">Letters used:</label>
        <input type="text" name="lz" id="lz" autocomplete="off" value="aeiou" />
    </p>
</form>
<div id="res" class="hide"></div>
</body>
</html>
