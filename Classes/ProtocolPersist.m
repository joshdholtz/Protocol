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
@synthesize objectRelationships = _objectRelationships;

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
        
        _objectRelationships = [NSMutableDictionary dictionary];
    }
    
    return self;
}

#pragma makr - Route Caching

- (void)saveRouteCache:(NSString*)route data:(NSData*)data {
    
    if ([self getRouteCache:route] == nil) {
    
        NSString *tableName = @"RouteCache";
        if (![self doesTableExist:tableName]) {
            NSLog(@"Table does not exist");
            [self createCacheTable];
            NSLog(@"Created table");
        }
        NSLog(@"After checking table");
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm"];
        
        sqlite3 *database = [self openDatabase];
        
        sqlite3_stmt *insert_statement;     
        char *sql = "INSERT INTO RouteCache (ROUTE, DATA, DATE) VALUES (? ,?, ?)" ;
        if(sqlite3_prepare_v2(database, sql, -1, &insert_statement, NULL) != SQLITE_OK)
        {
            //handle error
            NSLog(@"We got an error - %@", [NSString stringWithUTF8String:sqlite3_errmsg(database)]);
        } 
        
        sqlite3_bind_text(insert_statement, 1, [route UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_blob(insert_statement, 2, [data bytes], [data length], NULL);
        sqlite3_bind_text(insert_statement, 3, [[formatter stringFromDate:[NSDate date]] UTF8String], -1, SQLITE_TRANSIENT);
        
        if(SQLITE_DONE != sqlite3_step(insert_statement)) {
            NSAssert1(0, @"Error while inserting data. '%s'", sqlite3_errmsg(database));
        } else {
            NSLog(@"We inserted a record");
        }
        
        [self closeDatabase:database];
        
    } else {
        
        NSString *tableName = @"RouteCache";
        if (![self doesTableExist:tableName]) {
            NSLog(@"Table does not exist");
            [self createCacheTable];
            NSLog(@"Created table");
        }
        NSLog(@"After checking table");
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm"];
        
        sqlite3 *database = [self openDatabase];
        
        sqlite3_stmt *insert_statement;     
        char *sql = "update RouteCache set DATA = ?, DATE = ? WHERE ROUTE = ?;" ;
        if(sqlite3_prepare_v2(database, sql, -1, &insert_statement, NULL) != SQLITE_OK)
        {
            //handle error
            NSLog(@"We got an error - %@", [NSString stringWithUTF8String:sqlite3_errmsg(database)]);
        } 
        
        sqlite3_bind_blob(insert_statement, 1, [data bytes], [data length], NULL);
        sqlite3_bind_text(insert_statement, 2, [[formatter stringFromDate:[NSDate date]] UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(insert_statement, 3, [route UTF8String], -1, SQLITE_TRANSIENT);
        
        if(SQLITE_DONE != sqlite3_step(insert_statement)) {
            NSAssert1(0, @"Error while updating data. '%s'", sqlite3_errmsg(database));
        } else {
            NSLog(@"We updated a record");
        }

        [self closeDatabase:database];
        
    }
    
}

- (NSData*)getRouteCache:(NSString*)route {
    
    NSData *data = nil;
    
    NSString *query = @"SELECT DATA, DATE FROM RouteCache WHERE ROUTE = ?;";
    
    sqlite3 *database = [self openDatabase];
    sqlite3_stmt *statement = [self prepareDatabaseQuery:database withSQL:query];
    sqlite3_bind_text(statement, 1, [route UTF8String], -1, SQLITE_TRANSIENT);
    
    while (sqlite3_step(statement) == SQLITE_ROW) {
        NSLog(@"We found result");

        data = [[NSData alloc] initWithBytes:sqlite3_column_blob(statement, 0) length: sqlite3_column_bytes(statement, 0)]; 
        
//        NSString *dateField = [[NSString alloc] initWithUTF8String:
//                               (const char *) sqlite3_column_text(statement, 1)];
    }
    sqlite3_finalize(statement);
    
    [self closeDatabase:database];
    
    return data;
    
}

#pragma mark - Protocol Object Relationship Methods

- (void)setRelationship:(Class)fromClass to:(Class)toClass as:(ProtoclRelationshipTypes)relationshipType {
    
    NSMutableDictionary *classDict = [_objectRelationships objectForKey:fromClass];
    if (classDict == nil) {
        classDict = [NSMutableDictionary dictionary];
        [_objectRelationships setObject:classDict forKey:fromClass];
    }
    
    [classDict setObject:[NSNumber numberWithInt:relationshipType] forKey:toClass];
    
}

#pragma mark - Protocol Object Methods

- (NSArray*)getObjects:(Class)class {
    
    NSString *tableName = [class description];
    if (![self doesTableExist:tableName]) {
        return nil;
    }
    
    NSMutableArray *objects = [[NSMutableArray alloc] init];
    
    NSString *query = [[NSString alloc] initWithFormat:@"SELECT ID, DEFINED_ID, JSON FROM %@;", tableName];
    
    sqlite3 *database = [self openDatabase];
    sqlite3_stmt *statement = [self prepareDatabaseQuery:database withSQL:query];
    
    while (sqlite3_step(statement) == SQLITE_ROW) {
        NSLog(@"We found result");
        
        int idField = sqlite3_column_int(statement, 0);
        
        int definedIdField = sqlite3_column_int(statement, 1);
        
        NSString *jsonField = [[NSString alloc] initWithUTF8String:
                                (const char *) sqlite3_column_text(statement, 2)];
        
        NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:[jsonField dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableLeaves error:nil];
        ProtocolObject *obj = [[class alloc] initWithDictionary:jsonData andPrimaryId:idField];

        [objects addObject:obj];
    }
    sqlite3_finalize(statement);
    
    [self closeDatabase:database];
    
    return objects;
}

- (id)getObject:(Class)class withId:(NSInteger)objectId {
    
    ProtocolObject *obj = nil;
    
    NSString *tableName = [class description];
    if (![self doesTableExist:tableName]) {
        return nil;
    }
    
    sqlite3 *database = [self openDatabase];
    NSString *query = [[NSString alloc] initWithFormat:@"SELECT ID, DEFINED_ID, JSON FROM %@ WHERE ID = ?;", tableName];
    
    sqlite3_stmt *statement = [self prepareDatabaseQuery:database withSQL:query];
    sqlite3_bind_int(statement, 1, objectId);
    
    while (sqlite3_step(statement) == SQLITE_ROW) {
        NSLog(@"We found result");
        
        int idField = sqlite3_column_int(statement, 0);
        
        int definedIdField = sqlite3_column_int(statement, 1);
        
        NSString *jsonField = [[NSString alloc] initWithUTF8String:
                               (const char *) sqlite3_column_text(statement, 2)];
        
        NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:[jsonField dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableLeaves error:nil];
        obj = [[class alloc] initWithDictionary:jsonData andPrimaryId:idField];

    }
    sqlite3_finalize(statement);
    
    [self closeDatabase:database];
    
    return obj;
}

- (void)saveObject:(ProtocolObject<ProtocolPersistDelegate>*)protocolObject {
    NSDictionary *dict = [protocolObject dictionaryWithValuesForKeys:[protocolObject propertiesToPersist]];
    
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
    
    if ([protocolObject primaryId] == -1) {
    
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
            [protocolObject setPrimaryId: sqlite3_last_insert_rowid(database)];
        }
        
        //Reset the add statement.
        sqlite3_reset(addStmt);
        
    } else {
     
        sqlite3_stmt *addStmt = nil;
        if(addStmt == nil) {
            const char *sql = [[[NSString alloc] initWithFormat:@"update %@ set DEFINED_ID = ?, JSON = ? WHERE ID = ?;", tableName] UTF8String];
            if(sqlite3_prepare_v2(database, sql, -1, &addStmt, NULL) != SQLITE_OK)
                NSAssert1(0, @"Error while creating add statement. '%s'", sqlite3_errmsg(database));
        }
        
        sqlite3_bind_int(addStmt, 1, [protocolObject valueForPrimaryKey]);
        sqlite3_bind_text(addStmt, 2, [jsonString UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_int(addStmt, 3, [protocolObject primaryId]);
        
        if(SQLITE_DONE != sqlite3_step(addStmt)) {
            NSAssert1(0, @"Error while updating data. '%s'", sqlite3_errmsg(database));
        } else {
            NSLog(@"We updated a record");
            //        coffeeID = sqlite3_last_insert_rowid(datbase);
        }
        
        //Reset the add statement.
        sqlite3_reset(addStmt);
        
    }
    
    [self closeDatabase:database];
    
}

- (BOOL)deleteObject:(ProtocolObject<ProtocolPersistDelegate>*)protocolObject {
    
    BOOL deleted = NO;
    
    NSString *tableName = [[protocolObject class] description];
    if (![self doesTableExist:tableName]) {
        return deleted;
    }
    
    sqlite3 *database = [self openDatabase];
    sqlite3_stmt *addStmt = nil;
    if(addStmt == nil) {
        const char *sql = [[[NSString alloc] initWithFormat:@"delete from %@ where ID = ?", tableName] UTF8String];
        if(sqlite3_prepare_v2(database, sql, -1, &addStmt, NULL) != SQLITE_OK)
            NSAssert1(0, @"Error while creating add statement. '%s'", sqlite3_errmsg(database));
    }
    
    sqlite3_bind_int(addStmt, 1, [protocolObject primaryId]);
    
    if(SQLITE_DONE != sqlite3_step(addStmt)) {
        NSAssert1(0, @"Error while inserting data. '%s'", sqlite3_errmsg(database));
    } else {
        NSLog(@"We delete a record");
        //        coffeeID = sqlite3_last_insert_rowid(datbase);
        deleted = YES;
    }
    
    //Reset the add statement.
    sqlite3_reset(addStmt);
    
    [self closeDatabase:database];
    
    return deleted;
    
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

- (void)createCacheTable {
    NSString *query = [[NSString alloc] initWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (ID INTEGER PRIMARY KEY AUTOINCREMENT, ROUTE TEXT, DATA BLOB, DATE TEXT)", @"RouteCache"];
    
    sqlite3 *database = [self openDatabase];
    const char *sql_stmt = [query UTF8String];
    
    char *errMsg = nil;
    if (sqlite3_exec(database, sql_stmt, NULL, NULL, &errMsg) == SQLITE_OK) {
        NSLog(@"Table created for - %@", @"RouteCache");
    }
    [self closeDatabase:database];
}


@end
