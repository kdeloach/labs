<?php include 'header.php'; ?>

<table>
    <tr>
        <td>
            <form method="post" action="import">
                <?php
                    if(count($pastOrders) == 0)
                    {
                        echo '<strong>Start here &dash;&gt;</strong>';
                    }
                ?>
                <input type="submit" name="import" value="Import Past Orders" class="btn" />
            </form>
        </td>
        <td>
            <form method="post" action="clear">
                <input type="submit" name="clear" value="Clear All Data" style="font-weight: bold;" class="btn" />
            </form>
        </td>
        <td>
            <a href="disclaimer" class="btn">Disclaimer</a>
        </td>
        <td>
            <a href="logout" class="btn">Logout</a>
        </td>

    </tr>
</table>

<p>&nbsp;</p>

<ul class="nav nav-tabs" id="myTab">
    <li class="active"><a href="#aggregate">Aggregate</a></li>
    <li><a href="#history">Order History</a></li>
</ul>
 
<div class="tab-content">
  <div class="tab-pane active" id="aggregate">
    <table class="table">
        <tr>
            <th>Name</th>
            <th>Orders Placed</th>
            <th>Days Ago</th>
            <th>Total Spent</th>
        </tr>
    <?php
    foreach($aggOrders as $order)
    {
        echo '<tr>';
        echo '<td>' . $order->name() . '</td>';
        echo '<td>' . $order->timesOrdered() . '</td>';
        echo '<td>' . $order->daysAgo() . '</td>';
        echo '<td style="text-align:right">' . $order->total() . '</td>';
        echo "</tr>\n";
    }
    ?>
    <?php
        if(count($aggOrders) > 0)
        {
            echo '<tr>';
            echo '<td>&nbsp;</td>';
            echo '<td>&nbsp;</td>';
            echo '<td>&nbsp;</td>';
            echo '<td style="text-align:right"><strong>' . '$' . number_format($grandTotal, 2) . '</strong></td>';
            echo "</tr>\n";
        }
    ?>
    </table>
  </div>
  <div class="tab-pane" id="history">
    <table class="table">
        <tr>
            <th>Name</th>
            <th>Date</th>
            <th>Total</th>
        </tr>
    <?php
    foreach($pastOrders as $order)
    {
        echo '<tr>';
        echo '<td>' . $order->name() . '</td>';
        echo '<td>' . $order->date() . '</td>';
        echo '<td style="text-align:right">' . $order->total() . '</td>';
        echo "</tr>\n";
    }
    ?>
    <?php
        if(count($pastOrders) > 0)
        {
            echo '<tr>';
            echo '<td>&nbsp;</td>';
            echo '<td>&nbsp;</td>';
            echo '<td style="text-align:right"><strong>' . '$' . number_format($grandTotal, 2) . '</strong></td>';
            echo "</tr>\n";
        }
    ?>
    </table>
  </div>
</div>
    
<p><a href="https://github.com/kdeloach/labs/tree/master/php/grubhub">Source Code</a></p>
    
<script src="https://ajax.googleapis.com/ajax/libs/jquery/1.7.2/jquery.min.js"></script>
<script type="text/javascript">
    $(function () {
        $('#myTab a').click(function (e) {
            e.preventDefault();
            $(this).tab('show');
        });
    });
</script>

<?php include 'footer.php'; ?>
