SwiftSQLite
===========

This is an SQLite wrapper/binding for Apple's Swift language, that's low level enough to be quick to learn and easy to use for anyone that has used sqlite previously.

Object oriented
---
As sqlite itself is largely laid out in an object oriented fashion, this library appropriately wraps to an appropriate object oriented design (e.g. ```*sqlite3_stmt``` and any C functional that takes ```*sqlite3_stmt``` as its first parameter are mapped to the Swift class ```SQLiteStatement```).

Setting up the database
---
The code is largely proof-of-concept and is intended as code drop to get you started. There are however to main functions you should find useful for initialising/manipulating databases: ```SQLiteDatabase.createDatabaseWithFilename(filename: String, withBlankDatabaseFilename blankDatabaseFilename: String)``` and ```SQLiteDatabase.deleteDatabase(filename: String)```. Both return a ```true``` or ```false``` value for whether or not the operation completed successfully.

Using a database
---
Once you have a working database setup, you'll have to initialize a ```SQLiteDatabase``` object first, as follows:

    let database = SQLiteDatabase()

This will usually then require you to open the database:

    database.open("myDatabse.sqlite")

This design is effectively a Swift/Object-oriented version of the lower level C SQLite, which presumes you make create a database but then open it later, hence why the open operation is not rolled into the constructor. Also, ```open``` returns a status code for whether the call was successful or not.

Example usage
---

    let database = SQLiteDatabase()
    
    database.open("myDatabse.sqlite")
    
    let statement = SQLiteStatement(database: database)
    
    if ( statement.prepare("SELECT * FROM tableName WHERE Id = ?") != .Ok )
    {
        /* handle error */
    }
    
    statement.bindInt(1, value: 123)
    
    if ( statement.step() == .Row )
    {
        /* do something with statement */
        let id:Int = statement.getIntAt(0)
        let stringValue:String? = statement.getStringAt(1)
        let boolValue:Bool = statement.getBoolAt(2)
        let dateValue:NSDate? = statement.getDateAt(3)
    }
    
    statement.finalizeStatement() /* not called finalize() due to destructor/language keyword */

Work in progress
---
These classes are very bare at the moment. Feel free to flesh them out more, improve them and push your changes so I can incorporate them.

Copyright
---
You may do whatever you want to with these classes.

Contact
---
Contact me via [chris@victoryonemedia.com](mailto:chris@victoryonemedia.com) or [http://twitter.com/ChrisMSimpson](http://twitter.com/ChrisMSimpson) if you have any questions or improvements.
