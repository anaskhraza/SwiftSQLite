//
//  SQLiteStatement.swift
//  SwiftSQLite
//
//  Copyright (c) 2014-2015 Chris Simpson (chris@victoryonemedia.com)
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

import Foundation

let isoStringFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'"

// Taken from: http://stackoverflow.com/questions/30760353/cannot-invoke-initializer-for-type-sqlite3-destructor-type

internal let SQLITE_STATIC = unsafeBitCast(0, sqlite3_destructor_type.self)
internal let SQLITE_TRANSIENT = unsafeBitCast(-1, sqlite3_destructor_type.self)

extension NSDate {
    
    func toString() -> String? {
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        dateFormatter.timeZone = NSTimeZone(forSecondsFromGMT: 0)
        dateFormatter.dateFormat = isoStringFormat
        
        return dateFormatter.stringFromDate(self)
    }
}

extension String {
    
    func toDate() -> NSDate? {
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        dateFormatter.timeZone = NSTimeZone(forSecondsFromGMT: 0)
        dateFormatter.dateFormat = isoStringFormat
        
        return dateFormatter.dateFromString(self)
    }
}

public class SQLiteStatement : NSObject {
    
    // Swift
    var database:SQLiteDatabase
    
    // C
    var cStatement:COpaquePointer = nil
    
    public init( database:SQLiteDatabase ) {
        
        self.database = database
    }
    
    // MARK: Prepare
    
    public func prepare(sqlQuery: String) -> SQLiteStatusCode? {
        
        if let cSqlQuery = sqlQuery.cStringUsingEncoding(NSUTF8StringEncoding) {
        
            let rawStatusCode = sqlite3_prepare_v2(self.database.cDb, cSqlQuery, -1, &self.cStatement, nil)
            
            return SQLiteStatusCode(rawValue: rawStatusCode)
        }
        
        return nil
    }
    
    // MARK: Reset
    
    public func reset() -> SQLiteStatusCode? {
        
        let rawStatusCode = sqlite3_reset(self.cStatement)
        
        return SQLiteStatusCode(rawValue: rawStatusCode)
    }
    
    // MARK: Binding
    
    public func bindNull(column: Int) -> SQLiteStatusCode? {
        
        let rawStatusCode = sqlite3_bind_null(self.cStatement, Int32(column))
        
        return SQLiteStatusCode(rawValue: rawStatusCode)
    }
    
    public func bindString(column: Int, value: String?) -> SQLiteStatusCode? {
        
        if let _value = value, cStringValue = _value.cStringUsingEncoding(NSUTF8StringEncoding) {
            
            let rawStatusCode = sqlite3_bind_text(self.cStatement, Int32(column), cStringValue, -1, SQLITE_TRANSIENT)
            
            return SQLiteStatusCode(rawValue: rawStatusCode)
        }
        
        return bindNull(column)
    }
    
    public func bindDate(column: Int, value: NSDate?) -> SQLiteStatusCode? {
        
        if let _value = value, cValue = _value.toString()?.cStringUsingEncoding(NSUTF8StringEncoding) {
            
            let rawStatusCode = sqlite3_bind_text(self.cStatement, Int32(column), cValue, -1, SQLITE_TRANSIENT)
            
            return SQLiteStatusCode(rawValue: rawStatusCode)
        }
        
        return bindNull(column)
    }
    
    public func bindIntPrimaryKey(column: Int, value: Int?) -> SQLiteStatusCode? {

        if let _value = value where _value > 0 {

            return self.bindInt(column, value: _value)
        }

        return bindNull(column)
    }

    public func bindInt(column: Int, value: Int?) -> SQLiteStatusCode? {
        
        if let _value = value {
            
            let rawStatusCode = sqlite3_bind_int(self.cStatement, Int32(column), Int32(_value))
            
            return SQLiteStatusCode(rawValue: rawStatusCode)
        }
        
        return bindNull(column)
    }
    
    public func bindBool(column: Int, value: Bool?) -> SQLiteStatusCode? {
        
        if let _value = value {
            
            let intValue:Int32 = _value ? 1 : 0
            
            let rawStatusCode = sqlite3_bind_int(self.cStatement, Int32(column), intValue)
            
            return SQLiteStatusCode(rawValue: rawStatusCode)
        }
        
        return bindNull(column)
    }
    
    public func bindData(column: Int, value: NSData?) -> SQLiteStatusCode? {
        
        if let _value = value where _value.length > 0 {
            
            let rawStatusCode = sqlite3_bind_blob(self.cStatement, Int32(column), _value.bytes, Int32(_value.length), nil)
            
            return SQLiteStatusCode(rawValue: rawStatusCode)
        }
        
        return bindNull(column)
    }
    
    public func bindDouble(column: Int, value: Double?) -> SQLiteStatusCode? {
        
        if let _value = value {
            
            let rawStatusCode = sqlite3_bind_double(self.cStatement, Int32(column), _value)
            
            return SQLiteStatusCode(rawValue: rawStatusCode)
        }

        return bindNull(column)
    }
    
    // MARK: Getters
    
    public func getStringAt(column: Int) -> String? {
        
        let cString = sqlite3_column_text(self.cStatement, Int32(column))
        
        if ( cString != nil ) {
            
            let cStringPtr = UnsafePointer<Int8>(cString)
            
            return String.fromCString(cStringPtr)
        }
        else {
            return nil
        }
    }
    
    public func getIntAt(column: Int) -> Int {
        
        return Int(sqlite3_column_int(self.cStatement, Int32(column)))
    }
    
    public func getBoolAt(column: Int) -> Bool {
        
        let intValue = sqlite3_column_int(self.cStatement, Int32(column))
        
        return intValue != 0
    }
    
    public func getDateAt(column: Int) -> NSDate? {
    
        let cString = sqlite3_column_text(self.cStatement, Int32(column))
        
        if ( cString != nil ) {
            
            let cStringPtr = UnsafePointer<Int8>(cString)
            return String.fromCString(cStringPtr)?.toDate()
        }
        else {
            return nil
        }
    }
    
    public func getDoubleAt(column: Int) -> Double {
    
        return Double(sqlite3_column_double(self.cStatement, Int32(column)))
    }
    
    public func getDataAt(column: Int) -> NSData? {
        
        return NSData(bytes:sqlite3_column_blob(self.cStatement, Int32(column)), length: Int(sqlite3_column_bytes(self.cStatement, Int32(column))))
    }
    
    // Other stuff
    
    public func step() -> SQLiteStatusCode? {
        return SQLiteStatusCode(rawValue: sqlite3_step(self.cStatement))
    }
    
    public func finalizeStatement() -> SQLiteStatusCode? {
        return SQLiteStatusCode(rawValue: sqlite3_finalize(self.cStatement))
    }
}
