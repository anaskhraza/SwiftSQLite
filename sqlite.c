//
//  sqlite.c
//  SwiftSQLite
//
//  Created by Chris on 4/07/2014.
//  Copyright (c) 2014 Victory One Media Pty Ltd. All rights reserved.
//

#include <stdio.h>
#include <sqlite3.h>

int bridged_sqlite3_bind_text(sqlite3_stmt *statement, int column, const char *value, int n)
{
    return sqlite3_bind_text(statement, column, value, n, SQLITE_TRANSIENT);
}

int bridged_sqlite3_bind_blob(sqlite3_stmt *statement, int column, const void *value, int n)
{
    return sqlite3_bind_blob(statement, column, value, n, NULL);
}