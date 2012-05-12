This is a prototype of an idea I had for a [jsFiddle](http://jsfiddle.net/) / [codepad](http://codepad.org/) style site for SQL. 

You can define a database schema using JSON and query arbitrary SQL against it. The database is also populated with randomized test data. 

This utilizes SQLAlchemy ORM and the in-memory SQLite database functionality.

Other ideas I may implement:

  * a unique URL for each "sandbox" so you can share SQL snippets with others
  * add support for other SQL dialects
  * seeds for consistent test data per "sandbox"

![](https://github.com/kdeloach/labs/raw/master/python/sqlsandbox/static/preview2.PNG)
