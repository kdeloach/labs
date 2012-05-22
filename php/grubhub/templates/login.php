<?php include 'header.php'; ?>
<form method="post" action="login" class="form-horizontal">
<fieldset>
<legend>Sign in with your GrubHub account</legend>
    <div class="control-group">
        <label class="control-label" for="username">Email</label>
        <div class="controls">
            <input type="text" name="username" id="username" />
        </div>
    </div>
    <div class="control-group">
        <label class="control-label" for="password">Password</label>
        <div class="controls">
            <input type="password" name="password" id="password" />
        </div>
    </div>
    <div class="form-actions">
        <input type="submit" name="login" value="Login" class="btn btn-primary" />
    </div>
</fieldset>
</form>
<hr />
<p><a href="https://github.com/kdeloach/labs/tree/master/php/grubhub">Source Code</a></p>
<?php include 'footer.php'; ?>