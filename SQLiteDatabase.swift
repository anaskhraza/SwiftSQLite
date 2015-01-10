//
//  SQLiteDatabase.swift
//  SwiftSQLite
//
//  Created by Chris on 4/07/2014.
//  Copyright (c) 2014 Victory One Media Pty Ltd. All rights reserved.
//

import Foundation

let blankDatabaseFilename:String = "Blank.sqlite"

let instanceDatabaseFilename:String = "Instance.sqlite"

var _SQLiteDatabase:SQLiteDatabase?

class SQLiteDatabase : NSObject {
    
    var cDb:COpaquePointer = nil
    
    override init () {
        
    }
    
    func open( filename:String ) -> SQLiteStatusCode {
        
        var cFilename = filename.cStringUsingEncoding(NSUTF8StringEncoding)
        
        return SQLiteStatusCode(rawValue: sqlite3_open(cFilename!, &self.cDb))!
    }
    
    // MARK: Transaction
    
    func beginTransaction() -> SQLiteStatusCode {
        
        var cSqlQuery = "BEGIN TRANSACTION".cStringUsingEncoding(NSUTF8StringEncoding)
        
        var cStatusCode = sqlite3_exec(self.cDb, cSqlQuery!, nil, nil, nil)
        
        return SQLiteStatusCode(rawValue: cStatusCode)!
    }
    
    func commitTransaction() -> SQLiteStatusCode {
        
        var cSqlQuery = "COMMIT TRANSACTION".cStringUsingEncoding(NSUTF8StringEncoding)
        
        var cStatusCode = sqlite3_exec(self.cDb, cSqlQuery!, nil, nil, nil)
        
        return SQLiteStatusCode(rawValue: cStatusCode)!
    }
    
    // MARK: Error
    
    func getErrorMessage() -> String? {
        return String.fromCString(sqlite3_errmsg(self.cDb))
    }
}

