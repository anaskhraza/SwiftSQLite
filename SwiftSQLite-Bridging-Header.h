//
//  Use this file to import your target's public headers that you would like to expose to Swift.
//

#include <stdio.h>
#import <sqlite3.h>

int bridged_sqlite3_bind_text(sqlite3_stmt *statement, int column, const char *value, int n);
int bridged_sqlite3_bind_blob(sqlite3_stmt *statement, int column, const void *value, int n);