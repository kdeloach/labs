This is the prototype of a framework I designed a long time ago for a personal project. It served my purposes at the time and was fun to write. I haven't used or tested it extensively, and it is far from production quality code.

Some aspects I copied from .NET, such as structured config files and user controls (kind of). The project that I implemented this on used Twig for templating, PDO for data access, and some minor event based control flow commonly found in .NET applications.

The project structure for implementations may be organized like this:

    / kwork
    / custom_app
        / Model
        / View 
        / Controller
        config.xml
    / www
        .htaccess
        index.php

The index.php file establishes the include_path and invokes kwork/AppMain::handleRequest(). Example of a config.xml file:

    <?xml version="1.0" ?>
    <config>
        <settings>
            <siteUrl>http://kevinx.local/custom_app/www/</siteUrl>
            <appPath>C:\wamp\www\kevinx.net\custom_app</appPath>
            <database dsn="mysql:dbname=custom_app;host=localhost" user="" pass="" />
        </settings>
        <handlers>
            <add name="RouteHandler" pattern="*" />
        </handlers>
        <routes>
            <route name="add" controller="IndexController" action="add" pattern="/add" />
            <route name="detail" controller="IndexController" action="detail" pattern="/detail/[id]" />
            <route name="browse" controller="IndexController" action="browse" pattern="/browse" />
            <route name="browse" controller="IndexController" action="browse" pattern="/browse/[filter]" />
            <route name="catchall" controller="IndexController" action="index" pattern="" />
        </routes>
    </config>
    
I thought this may be worth preserving just in case I ever decide to resume this project.
