//
//  SQLiteDatabase.swift
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

public class SQLiteDatabase : NSObject {
    
    var cDb:COpaquePointer = nil
    
    override init () {
        
    }
    
    public func open(filename: String) -> SQLiteStatusCode? {
        
        if let cFilename = filename.cStringUsingEncoding(NSUTF8StringEncoding) {
            return SQLiteStatusCode(rawValue: sqlite3_open(cFilename, &self.cDb))
        }
        
        return nil
    }
    
    public class func deleteDatabase(filename: String) -> Bool {
        
        var pathToDocuments = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        
        let documentsDirectory:AnyObject = pathToDocuments[0]
        
        let databasePath = documentsDirectory.stringByAppendingPathComponent(filename)
        
        if ( NSFileManager.defaultManager().isReadableFileAtPath(databasePath) ) {
            
            do {
                try NSFileManager.defaultManager().removeItemAtPath(databasePath)
            }
            catch {
                print("Failed to delete database")
                return false
            }
        }
        
        return true
    }
    
    public class func createDatabaseWithFilename(filename: String, withBlankDatabaseFilename blankDatabaseFilename: String) -> Bool {
        
        if let pathToResources = NSBundle.mainBundle().resourcePath, blankDatabasePath = NSURL(string: pathToResources)?.URLByAppendingPathComponent(blankDatabaseFilename) {
            
            let pathToDocuments = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
            
            if let documentsDirectoryString = pathToDocuments.first, documentsDirectory = NSURL(string: documentsDirectoryString) {
                
                let databasePath = documentsDirectory.URLByAppendingPathComponent(filename)
                
                if let _path = databasePath.path where !NSFileManager.defaultManager().isReadableFileAtPath(_path) {
                    
                    do {
                        try NSFileManager.defaultManager().copyItemAtURL(blankDatabasePath, toURL: databasePath)
                    }
                    catch {
                        return false
                    }
                }
                
                return true
            }
        }
        
        return false
    }
    
    // MARK: Transaction
    
    public func beginTransaction() -> SQLiteStatusCode? {
        
        if let cSqlQuery = "BEGIN TRANSACTION".cStringUsingEncoding(NSUTF8StringEncoding) {
        
            let rawStatusCode = sqlite3_exec(self.cDb, cSqlQuery, nil, nil, nil)
            
            return SQLiteStatusCode(rawValue: rawStatusCode)
        }
        
        return nil
    }
    
    public func commitTransaction() -> SQLiteStatusCode? {
        
        if let cSqlQuery = "COMMIT TRANSACTION".cStringUsingEncoding(NSUTF8StringEncoding) {
        
            let rawStatusCode = sqlite3_exec(self.cDb, cSqlQuery, nil, nil, nil)
            
            return SQLiteStatusCode(rawValue: rawStatusCode)
        }
        
        return nil
    }
    
    public func rollbackTranscaction() -> SQLiteStatusCode? {
        
        if let cSqlQuery = "ROLLBACK TRANSACTION".cStringUsingEncoding(NSUTF8StringEncoding) {
            
            let rawStatusCode = sqlite3_exec(self.cDb, cSqlQuery, nil, nil, nil)
            
            return SQLiteStatusCode(rawValue: rawStatusCode)
        }
        
        return nil
    }
    
    // MARK: Error
    
    public func getErrorMessage() -> String? {
        return String.fromCString(sqlite3_errmsg(self.cDb))
    }
}


