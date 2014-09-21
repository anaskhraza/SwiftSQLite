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
        
        var cSqlQuery = sqlQuery.cStringUsingEncoding(NSUTF8StringEncoding)
        
        var cStatusCode = sqlite3_prepare_v2(self.database.cDb, cSqlQuery!, -1, &self.cStatement, nil)
        
        return SQLiteStatusCode.fromRaw(cStatusCode)!
    }
    
    // Binding
    
    func bindString(column:Int, value:String?) -> SQLiteStatusCode {
        
        var cColumn:CInt = CInt(column)
        
        if let v = value {
            
            var cValue = v.cStringUsingEncoding(NSUTF8StringEncoding)
            
            var cStatusCode = bridged_sqlite3_bind_text(self.cStatement, cColumn, cValue!, -1)
            
            return SQLiteStatusCode.fromRaw(cStatusCode)!
        }
        
        var cStatusCode = sqlite3_bind_null(self.cStatement, cColumn)
        
        return SQLiteStatusCode.fromRaw(cStatusCode)!
    }
    
    func bindDate(column:Int, value:NSDate?) -> SQLiteStatusCode {
        
        var cColumn:CInt = CInt(column)
        
        if let v = value {
            
            var cValue = v.toString().cStringUsingEncoding(NSUTF8StringEncoding)
            
            var cStatusCode = bridged_sqlite3_bind_text(self.cStatement, cColumn, cValue!, -1)
            
            return SQLiteStatusCode.fromRaw(cStatusCode)!
        }
        
        var cStatusCode = sqlite3_bind_null(self.cStatement, cColumn)
        
        return SQLiteStatusCode.fromRaw(cStatusCode)!
    }
    
    func bindInt(column:Int, value:Int?) -> SQLiteStatusCode {
        
        var cColumn:CInt = CInt(column)
        
        if let v = value {
            
            var cValue = CInt(v)
            
            var cStatusCode = sqlite3_bind_int(self.cStatement, cColumn, cValue)
            
            return SQLiteStatusCode.fromRaw(cStatusCode)!
        }
        
        var cStatusCode = sqlite3_bind_null(self.cStatement, cColumn)
        
        return SQLiteStatusCode.fromRaw(cStatusCode)!
    }
    
    func bindBool(column:Int, value:Bool?) -> SQLiteStatusCode {
        
        var cColumn:CInt = CInt(column)
        
        if let v = value {
            
            var cValue = v ? CInt(1) : CInt(0)
            
            var cStatusCode = sqlite3_bind_int(self.cStatement, cColumn, cValue)
            
            return SQLiteStatusCode.fromRaw(cStatusCode)!
        }
        
        var cStatusCode = sqlite3_bind_null(self.cStatement, cColumn)
        
        return SQLiteStatusCode.fromRaw(cStatusCode)!
    }
    
    func bindData(column:Int, value:NSData?) -> SQLiteStatusCode {
        
        var cColumn:CInt = CInt(column)
        
        if let v = value {
            
            var cStatusCode = bridged_sqlite3_bind_blob(self.cStatement, cColumn, value!.bytes, CInt(value!.length))
            
            return SQLiteStatusCode.fromRaw(cStatusCode)!
        }
        
        var cStatusCode = sqlite3_bind_null(self.cStatement, cColumn)
        
        return SQLiteStatusCode.fromRaw(cStatusCode)!
    }
    
    // Getters
    
    func getStringAt( column:Int ) -> String? {
        
        var cColumn:CInt = CInt(column)
        
        var c = sqlite3_column_text(self.cStatement, cColumn)
        
        if ( c != nil ) {
            
            var cStringPtr = UnsafePointer<Int8>(c)
            
            return String.fromCString(cStringPtr)
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
        
        if ( c != nil ) {
            
            var cStringPtr = UnsafePointer<Int8>(c);
            return String.fromCString(cStringPtr)?.toDate()
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