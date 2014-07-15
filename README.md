SwiftSQLite
===========

This is an SQLite wrapper/binding for Apple's Swift language, that's low level enough to be quick to learn and easy to use for anyone that has used sqlite previous.

Object oriented
---
As sqlite itself is largely laid out in an object oriented fashion, this library appropriately wraps to an appropriate object oriented design (e.g. ```*sqlite3_stmt``` and any C functional that takes ```*sqlite3_stmt``` as its first parameter are mapped to the Swift class ```SQLiteStatement```).

Example usage
---

    var db = SQLiteDatabase();
    db.open("/path/to/database.sqlite");
        
    var statement = SQLiteStatement(database: db);
        
    if ( statement.prepare("SELECT * FROM tableName WHERE Id = ?") != .Ok )
    {
        /* handle error */
    }
        
    statement.bindInt(1, value: 123);
        
    if ( statement.step() == .Row )
    {
        /* do something with statement */
        var id:Int = statement.getIntAt(0)
        var stringValue:String? = statement.getStringAt(1)
        var boolValue:Bool = statement.getBoolAt(2)
        var dateValue:NSDate? = statement.getDateAt(3)
    }
        
    statement.finalizeStatement(); /* not called finalize() due to destructor/language keyword */

Work in progress
---
These classes are very bare at the moment. Feel free to flesh them out more, improve them and push your changes so I can incorporate them.

Copyright
---
You may do whatever you want to with these classes.

Contact
---
Contact me via [chris@victoryonemedia.com](mailto:chris@victoryonemedia.com) or [http://twitter.com/ChrisMSimpson](http://twitter.com/ChrisMSimpson) if you have any questions or improvements.
