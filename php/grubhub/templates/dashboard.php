<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
   "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<head>
<base href="<?php echo URL; ?>/" />
<style type="text/css">
form { margin: 0; padding: 0; }
table { border-collapse: collapse; border-color: #eee; }
h3 { margin-top: 0; padding-top: 0; }
</style>
</head>
<body>
<table>
    <tr>
        <td>
            <form method="post" action="import">
                <input type="submit" name="import" value="Import Past Orders" />
            </form>
        </td>
        <td>
            <form method="post" action="clear">
                <input type="submit" name="clear" value="Clear All Data" style="font-weight: bold;" />
            </form>
        </td>
        <td>
            <a href="disclaimer">Disclaimer</a>
        </td>
        <td>
            <a href="logout">Logout</a>
        </td>
    </tr>
</table>
<table cellpadding="15"><tr>
<td valign="top">
    <h3>Past Orders</h3>
    <table border="1" cellpadding="3">
        <tr>
            <th>Date</th>
            <th>Name</th>
            <th>Total</th>
        </tr>
    <?php
    foreach($pastOrders as $order)
    {
        echo '<tr>';
        echo '<td>' . $order->date() . '</td>';
        echo '<td>' . $order->name() . '</td>';
        echo '<td>' . $order->total() . '</td>';
        echo "</tr>\n";
    }
    ?>
    </table>
</td>
<td valign="top">
    <h3>Aggregate</h3>
    <table border="1" cellpadding="3">
        <tr>
            <th>Name</th>
            <th>Orders Placed</th>
            <th>Total Spent</th>
        </tr>
    <?php
    foreach($rankedOrders as $order)
    {
        echo '<tr>';
        echo '<td>' . $order->name() . '</td>';
        echo '<td>' . $order->timesOrdered() . '</td>';
        echo '<td>' . $order->total() . '</td>';
        echo "</tr>\n";
    }
    ?>
    </table>

</td>
<td valign="top">
    <h3>Days since last order</h3>
    <table border="1" cellpadding="3">
        <tr>
            <th>Name</th>
            <th>Number of days ago</th>
        </tr>
    <?php
    foreach($recentOrders as $order)
    {
        echo '<tr>';
        echo '<td>' . $order->name() . '</td>';
        echo '<td>' . ($order->daysAgo() == 0 ? 'Today!' : $order->daysAgo()) . '</td>';
        echo "</tr>\n";
    }
    ?>
    </table>

</td>
</tr></table>
</body>
</html>
