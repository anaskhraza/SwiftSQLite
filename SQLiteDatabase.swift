//
//  SQLiteDatabase.swift
//  SwiftSQLite
//
//  Created by Chris on 4/07/2014.
//  Copyright (c) 2014 Victory One Media Pty Ltd. All rights reserved.
//

import Foundation

class SQLiteDatabase : NSObject {
    
    var cDb:COpaquePointer = nil
    
    init () {
        
    }
    
    func open( filename:String ) -> SQLiteStatusCode {
        
        var cFilename:CString = filename.bridgeToObjectiveC().UTF8String;
        
        return SQLiteStatusCode.fromRaw(sqlite3_open(cFilename, &self.cDb))!
    }
}
