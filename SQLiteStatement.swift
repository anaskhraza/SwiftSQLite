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
        
        return SQLiteStatusCode(rawValue: cStatusCode)!
    }
    
    // Binding
    
    func bindNull(column:Int) -> SQLiteStatusCode {
        
        return bindNull(CInt(column))
    }
    
    func bindNull(cColumn:CInt) -> SQLiteStatusCode {
        
        var cStatusCode = sqlite3_bind_null(self.cStatement, cColumn)
        
        return SQLiteStatusCode(rawValue: cStatusCode)!
    }
    
    func bindString(column:Int, value:String?) -> SQLiteStatusCode {
        
        var cColumn:CInt = CInt(column)
        
        if let v = value {
            
            var cValue = v.cStringUsingEncoding(NSUTF8StringEncoding)
            
            var cStatusCode = bridged_sqlite3_bind_text(self.cStatement, cColumn, cValue!, -1)
            
            return SQLiteStatusCode(rawValue: cStatusCode)!
        }
        
        return bindNull(cColumn)
    }
    
    func bindDate(column:Int, value:NSDate?) -> SQLiteStatusCode {
        
        var cColumn:CInt = CInt(column)
        
        if let v = value {
            
            var cValue = v.toString().cStringUsingEncoding(NSUTF8StringEncoding)
            
            var cStatusCode = bridged_sqlite3_bind_text(self.cStatement, cColumn, cValue!, -1)
            
            return SQLiteStatusCode(rawValue: cStatusCode)!
        }
        
        return bindNull(cColumn)
    }
    
    func bindIntPrimaryKey(column:Int, value:Int?) -> SQLiteStatusCode {

        if let v = value {

            if v > 0 {

                return self.bindInt(column, value: v)
            }
        }

        return bindNull(column)
    }

    func bindInt(column:Int, value:Int?) -> SQLiteStatusCode {
        
        var cColumn:CInt = CInt(column)
        
        if let v = value {
            
            var cValue = CInt(v)
            
            var cStatusCode = sqlite3_bind_int(self.cStatement, cColumn, cValue)
            
            return SQLiteStatusCode(rawValue: cStatusCode)!
        }
        
        return bindNull(cColumn)
    }
    
    func bindBool(column:Int, value:Bool?) -> SQLiteStatusCode {
        
        var cColumn:CInt = CInt(column)
        
        if let v = value {
            
            var cValue = v ? CInt(1) : CInt(0)
            
            var cStatusCode = sqlite3_bind_int(self.cStatement, cColumn, cValue)
            
            return SQLiteStatusCode(rawValue: cStatusCode)!
        }
        
        return bindNull(cColumn)
    }
    
    func bindData(column:Int, value:NSData?) -> SQLiteStatusCode {
        
        var cColumn:CInt = CInt(column)
        
        if let v = value {
            
            var cStatusCode = bridged_sqlite3_bind_blob(self.cStatement, cColumn, value!.bytes, CInt(value!.length))
            
            return SQLiteStatusCode(rawValue: cStatusCode)!
        }
        
        return bindNull(cColumn)
    }
    
    func bindDouble(column:Int, value:Double?) -> SQLiteStatusCode {
        
        var cColumn:CInt = CInt(column)
        
        if let v = value {
            
            var cValue = CDouble(v)
            
            var cStatusCode = sqlite3_bind_double(self.cStatement, cColumn, cValue)
            
            return SQLiteStatusCode(rawValue: cStatusCode)!
        }

        return bindNull(cColumn)
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
    
    func getDoubleAt( column: Int ) -> Double {
    
        var cColumn:CInt = CInt(column)
        
        return Double(sqlite3_column_double(self.cStatement, cColumn))
    }
    
    // Other stuff
    
    func step() -> SQLiteStatusCode {
        return SQLiteStatusCode(rawValue: sqlite3_step(self.cStatement))!
    }
    
    func finalizeStatement() -> SQLiteStatusCode {
        return SQLiteStatusCode(rawValue: sqlite3_finalize(self.cStatement))!
    }
}
