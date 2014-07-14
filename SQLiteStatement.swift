//
//  SQLiteStatement.swift
//  SwiftSQLite
//
//  Created by Chris on 4/07/2014.
//  Copyright (c) 2014 Victory One Media Pty Ltd. All rights reserved.
//

import Foundation

let isoStringFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'"

extension NSDate {
    
    func toString() -> String! {
        
        var dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = isoStringFormat
        
        return dateFormatter.stringFromDate(self)
    }
}

extension String {
    
    func toDate() -> NSDate! {
        
        var dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = isoStringFormat

        return dateFormatter.dateFromString(self)
    }
}

class SQLiteStatement : NSObject {
    
    // Swift
    var database:SQLiteDatabase
    
    // C
    var cStatement:COpaquePointer = nil
    
    init( database:SQLiteDatabase ) {
        
        self.database = database
    }
    
    // Prepare
    
    func prepare(sqlQuery:String) -> SQLiteStatusCode {
        
        var cSqlQuery:CString = sqlQuery.bridgeToObjectiveC().UTF8String
        
        return SQLiteStatusCode.fromRaw(sqlite3_prepare_v2(self.database.cDb, cSqlQuery, -1, &self.cStatement, nil))!
    }
    
    // Binding
    
    func bindString(column:Int, value:String?) -> SQLiteStatusCode {
        
        var cColumn:CInt = CInt(column)
        
        if ( value ) {
            var cValue:CString = value!.bridgeToObjectiveC().UTF8String
            
            return SQLiteStatusCode.fromRaw(bridged_sqlite3_bind_text(self.cStatement, cColumn, cValue, -1))!
        }
        else {
            return SQLiteStatusCode.fromRaw(sqlite3_bind_null(self.cStatement, cColumn))!
        }
    }
    
    func bindDate(column:Int, value:NSDate?) -> SQLiteStatusCode {
        
        var cColumn:CInt = CInt(column)
        
        if ( value ) {
            
            var cValue = value!.toString().bridgeToObjectiveC().UTF8String
            
            return SQLiteStatusCode.fromRaw(bridged_sqlite3_bind_text(self.cStatement, cColumn, cValue, -1))!
        }
        else {
            return SQLiteStatusCode.fromRaw(sqlite3_bind_null(self.cStatement, cColumn))!
        }
    }
    
    func bindInt(column:Int, value:Int?) -> SQLiteStatusCode {
        
        var cColumn:CInt = CInt(column)
        
        if ( value ) {
        
            var cValue:CInt = CInt(value!)
            
            return SQLiteStatusCode.fromRaw(sqlite3_bind_int(self.cStatement, cColumn, cValue))!
        }
        else {
            return SQLiteStatusCode.fromRaw(sqlite3_bind_null(self.cStatement, cColumn))!
        }
    }
    
    func bindBool(column:Int, value:Bool?) -> SQLiteStatusCode {
        
        var cColumn:CInt = CInt(column)
        
        if ( value ) {
            var cValue:CInt = value ? CInt(1) : CInt(0)
            
            return SQLiteStatusCode.fromRaw(sqlite3_bind_int(self.cStatement, cColumn, cValue))!
        }
        else {
            return SQLiteStatusCode.fromRaw(sqlite3_bind_null(self.cStatement, cColumn))!
        }
    }
    
    func bindData(column:Int, value:NSData?) -> SQLiteStatusCode {
        
        var cColumn:CInt = CInt(column)
        
        if ( value ) {
            return SQLiteStatusCode.fromRaw(bridged_sqlite3_bind_blob(self.cStatement, cColumn, value!.bytes, CInt(value!.length)))!
        }
        else {
            return SQLiteStatusCode.fromRaw(sqlite3_bind_null(self.cStatement, cColumn))!
        }
    }
    
    // Getters
    
    func getStringAt( column:Int ) -> String? {
        
        var cColumn:CInt = CInt(column)
        
        var c = sqlite3_column_text(self.cStatement, cColumn)
        
        if ( c ) {
            var cString = CString(c)
            
            return String.fromCString(cString)
        }
        else {
            return nil
        }
    }
    
    func getIntAt( column:Int ) -> Int {
        
        var cColumn:CInt = CInt(column)
        
        return Int(sqlite3_column_int(self.cStatement, cColumn))
    }
    
    func getBoolAt( column:Int ) -> Bool {
        var cColumn:CInt = CInt(column)
        
        var cInt = sqlite3_column_int(self.cStatement, cColumn)
        
        return cInt != 0
    }
    
    func getDateAt( column:Int ) -> NSDate! {
        var cColumn:CInt = CInt(column)
        
        var c = sqlite3_column_text(self.cStatement, cColumn)
        
        if ( c ) {
            var cString = CString(c)
            
            return String.fromCString(cString).toDate()
        }
        else {
            return nil
        }
    }
    
    // Other stuff
    
    func step() -> SQLiteStatusCode {
        return SQLiteStatusCode.fromRaw(sqlite3_step(self.cStatement))!
    }
    
    func finalizeStatement() -> SQLiteStatusCode {
        return SQLiteStatusCode.fromRaw(sqlite3_finalize(self.cStatement))!
    }
}