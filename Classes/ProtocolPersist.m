//
//  ProtocolPersist.m
//  Protocol
//
//  Created by Josh Holtz on 4/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ProtocolPersist.h"

#import "ProtocolObject.h"

#import "/usr/include/sqlite3.h"

@implementation ProtocolPersist

@synthesize databaseFilePath = _databaseFilePath;

static ProtocolPersist *sharedInstance = nil;

#pragma mark - Public Singleton

+ (ProtocolPersist *)sharedInstance {
    if (sharedInstance == nil) {
        sharedInstance = [[super allocWithZone:NULL] init];
    }
    return sharedInstance;
}

#pragma mark - Private Singleton

- (id)init
{
    self = [super init];
    
    if (self) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        _databaseFilePath = [[NSString alloc] initWithFormat:@"%@/%@", documentsDirectory, @"ProtocolPersist.sqlite"];
    }
    
    return self;
}

#pragma mark - Protocol Object Methods

- (NSArray*)get:(Class)class {
    
    NSString *tableName = [class description];
    if (![self doesTableExist:tableName]) {
        return nil;
    }
    
    NSString *query = [[NSString alloc] initWithFormat:@"SELECT ID, DEFINED_ID, JSON FROM %@;", tableName];
    
    sqlite3 *database = [self openDatabase];
    sqlite3_stmt *statement = [self prepareDatabaseQuery:database withSQL:query];
    
    while (sqlite3_step(statement) == SQLITE_ROW) {
        NSLog(@"We found result");
        
        int idField = sqlite3_column_int(statement, 0);
        
        int definedIdField = sqlite3_column_int(statement, 1);
        
        NSString *jsonField = [[NSString alloc] initWithUTF8String:
                                (const char *) sqlite3_column_text(statement, 2)];
        
        NSLog(@"%d %d %@", idField, definedIdField, jsonField);
        
    }
    sqlite3_finalize(statement);
    
    [self closeDatabase:database];
    
    return nil;
}

- (void)save:(ProtocolObject<ProtocolPersistDelegate>*)protocolObject {
    NSDictionary *dict = [protocolObject dictionaryWithValuesForKeys:[protocolObject propertiesToSave]];
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:nil];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSLog(@"JSON data - %@", jsonString);
    
    NSString *tableName = [[protocolObject class] description];
    if (![self doesTableExist:tableName]) {
        NSLog(@"Table does not exist");
        [self createTable:tableName];
        NSLog(@"Created table");
    }
    NSLog(@"After checking table");
    
    sqlite3 *database = [self openDatabase];
    sqlite3_stmt *addStmt = nil;
    if(addStmt == nil) {
        const char *sql = [[[NSString alloc] initWithFormat:@"insert into %@(DEFINED_ID, JSON) Values(?, ?)", tableName] UTF8String];
        if(sqlite3_prepare_v2(database, sql, -1, &addStmt, NULL) != SQLITE_OK)
            NSAssert1(0, @"Error while creating add statement. '%s'", sqlite3_errmsg(database));
    }
    
    sqlite3_bind_int(addStmt, 1, [protocolObject valueForPrimaryKey]);
    sqlite3_bind_text(addStmt, 2, [jsonString UTF8String], -1, SQLITE_TRANSIENT);
    
    if(SQLITE_DONE != sqlite3_step(addStmt)) {
        NSAssert1(0, @"Error while inserting data. '%s'", sqlite3_errmsg(database));
    } else {
        NSLog(@"We inserted a record");
//        coffeeID = sqlite3_last_insert_rowid(datbase);
    }
    
    //Reset the add statement.
    sqlite3_reset(addStmt);
    
    [self closeDatabase:database];
    
}

#pragma mark - Private

- (sqlite3*)openDatabase {
    
    sqlite3 *database = nil;
    const char *databasePath = [_databaseFilePath UTF8String];
    
    if (sqlite3_open(databasePath, &database) != SQLITE_OK) {
        NSLog(@"Could not open database");
        database = nil;
    }
    
    return database;
}

- (void)closeDatabase:(sqlite3*)database {
    sqlite3_close(database);
}

- (sqlite3_stmt*)prepareDatabaseQuery:(sqlite3*)database withSQL:(NSString*)sql {
    
    sqlite3_stmt *statement = nil;
    const char *query_stmt = [sql UTF8String];
    
    if (sqlite3_prepare_v2(database, query_stmt, -1, &statement, NULL) != SQLITE_OK) {
        NSLog(@"Could not prepare statement");
        statement = nil;
    }
    
    return statement;
}

- (BOOL)doesTableExist:(NSString*)tableName {
    BOOL exists = NO;
    
    NSString *query = [[NSString alloc] initWithFormat:@"SELECT name FROM sqlite_master WHERE type='table' AND name='%@';", tableName];
    
    sqlite3 *database = [self openDatabase];
    sqlite3_stmt *statement = [self prepareDatabaseQuery:database withSQL:query];
    
    while (sqlite3_step(statement) == SQLITE_ROW) {
        exists = YES;
//        NSInteger *idField = sqlite3_column_int(statement, 0);
//        
//        NSString *jsonField = [[NSString alloc] initWithUTF8String:
//                                (const char *) sqlite3_column_text(statement, 1)];
        
        
        
    }
    sqlite3_finalize(statement);
    
    [self closeDatabase:database];
    
    return exists;
}

- (void)createTable:(NSString*)tableName {
    NSString *query = [[NSString alloc] initWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (ID INTEGER PRIMARY KEY AUTOINCREMENT, DEFINED_ID INTEGER, JSON TEXT)", tableName];
    
    sqlite3 *database = [self openDatabase];
    const char *sql_stmt = [query UTF8String];
    
    char *errMsg = nil;
    if (sqlite3_exec(database, sql_stmt, NULL, NULL, &errMsg) == SQLITE_OK) {
        NSLog(@"Table created for - %@", tableName);
    }
    [self closeDatabase:database];
}


@end
