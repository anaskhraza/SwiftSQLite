//
//  ViewController.swift
//  SwiftSQLite
//
//  Copyright (c) 2014-2017 Chris Simpson (chris.m.simpson@icloud.com)
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

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        let database = SQLiteDatabase()
        
        database.open(filename: "myDatabse.sqlite")
        
        let statement = SQLiteStatement(database: database)
        
        if statement.prepare(sqlQuery: "SELECT * FROM tableName WHERE Id = ?") != .ok {
            /* handle error */
        }
        
        statement.bind(int: 1, at: 123)
        
        if statement.step() == .row {
            
            /* do something with statement */
            
            let id: Int? = statement.int(at: 0)
            
            let string: String? = statement.string(at: 1)
            let bool: Bool? = statement.bool(at: 2)
            let date: Date? = statement.date(at: 3)
        }
        
        statement.finalizeStatement() /* not called finalize() due to destructor/language keyword */
    }
}

