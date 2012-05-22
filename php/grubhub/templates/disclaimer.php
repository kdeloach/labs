<?php include 'header.php'; ?>
<h2>Disclaimer</h2>
<p>Stored data:</p>
<ul>
    <li>Hash of your username (MD5)</li>
    <li>GrubHub authentication cookie</li>
    <li>Order history</li>
</ul>
<p><form method="post" action="clear" style="display:inline">
<input type="submit" name="clear" value="Clear All Data" style="font-weight: bold;" class="btn" />
</form> will delete ALL data including database records and stored cookies.</p>
<hr />
<p><a href="dashboard">Return to Dashboard</a></p>
<?php include 'footer.php'; ?>
