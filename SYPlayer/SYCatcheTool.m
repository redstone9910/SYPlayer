//
//  SYCatcheTool.m
//  SYPlayer
//
//  Created by YinYanhui on 15-5-30.
//  Copyright (c) 2015年 YinYanhui. All rights reserved.
//

#import "SYCatcheTool.h"
#import "FMDB.h"
#import "SYModel.h"
#import "SYAuthor.h"
#import "SYAlbum.h"
#import "SYSong.h"
#import "SYOperationQueue.h"

@implementation SYCatcheTool

static FMDatabaseQueue *databaseQueue;
//static NSOperationQueue * operationQueue;
/** 检查或新建数据库 */
+ (void)assertBase
{
    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"nce_root.db"];
    
    databaseQueue = [FMDatabaseQueue databaseQueueWithPath:path];
    
    [databaseQueue close];
}

+(BOOL)assertTable:(id)obj{
    NSString *sql = [self assembleTableSql:obj];
    if (sql) {
        [self assertBase];
        
        [databaseQueue inDatabase:^(FMDatabase *db) {
            [db executeUpdate:sql];
        }];
        [databaseQueue close];
        return YES;
    }
    return NO;
}

+(BOOL)insertData:(id)data withSubdatas:(BOOL)withSubdatas{
    if ([self assertTable:data]) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[data toDict]];
        
        NSDictionary *dataDict = [data toDict];
        NSArray *keys = [dataDict allKeys];
        NSArray *subDatas = nil;
        NSString *subKey = nil;
        for (NSString *key in keys) {
            id value = dataDict[key];
            if ([value isKindOfClass:[NSArray class]]) {
                subDatas = value;
                subKey = key;
                [dict removeObjectForKey:key];
            }
            
            if ([key isEqualToString:@"self_id"]) {
                [dict removeObjectForKey:key];
            }
        }
        
        NSString *insertSql = [self assembleInsertSql:data];
        NSString *updateSql = [self assembleUpdateSql:data];

//        [[SYOperationQueue sharedOperationQueue] addOperationWithBlock:^{
            SYModel *model = data;
            NSLog(@"start %@",model.name);
        
            [databaseQueue inDatabase:^(FMDatabase *db) {
                FMResultSet *rs = nil;
                NSString *queryStr = [NSString stringWithFormat:@"select * from %@ where %@ = \"%@\";", NSStringFromClass([data class]), @"name", dict[@"name"]];
                rs = [db executeQuery:queryStr];
                
                if (rs.next) {
                    [db executeUpdate:updateSql withParameterDictionary:dict];
                }else{
                    [db executeUpdate:insertSql withParameterDictionary:dict];
                }
                [rs close];
            }];
            [databaseQueue close];
            
            NSLog(@"finish %@",model.name);
//        }];
        
        if (subDatas && withSubdatas){
            for (id subData in subDatas) {
                if ([data isKindOfClass:[SYAuthor class]]) {
                    [self insertData:[SYAlbum instanceWithDict:subData] withSubdatas:YES];
                }else if ([data isKindOfClass:[SYAlbum class]]) {
                    [self insertData:[SYSong instanceWithDict:subData] withSubdatas:YES];
                }
            }
        }
        return YES;
    }
    
    return NO;
}

+(NSArray *)loadAuthor:(SYAuthor *)data{
    [self assertTable:data];
    
    NSString *queryStr = [NSString stringWithFormat:@"select * from %@;", NSStringFromClass([data class])];
    __block NSMutableArray *retArray = [NSMutableArray array];
    
    [databaseQueue inDatabase:^(FMDatabase *db) {
//        NSLog(@"loadAuthor");
        FMResultSet *rs = nil;
        rs = [db executeQuery:queryStr];
        while (rs.next) {
            NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[data toDict]];
            NSArray *keys = [dict allKeys];
            for (NSString *key in keys) {
                id r = [rs objectForColumnName:key];
                dict[key] = r;
            }
            
            SYAuthor *sdata = [SYAuthor instanceWithDict:dict];
//            SYAlbum *subData = [[SYAlbum alloc] init];
//            subData.authorName = sdata.name;
//            NSArray *subDatas = [self loadAlbum:subData];
//            sdata.albums = subDatas;
            [retArray addObject:sdata];
        }
        [rs close];
    }];
    [databaseQueue close];
    
    for (SYAuthor *sdata in retArray) {
        SYAlbum *subData = [[SYAlbum alloc] init];
        subData.authorName = sdata.name;
        NSArray *subDatas = [self loadAlbum:subData];
        sdata.albums = subDatas;
    }
    return [retArray copy];
}

+(NSArray *)loadAlbum:(SYAlbum *)data{
    [self assertTable:data];
    NSString *queryStr = [NSString stringWithFormat:@"select * from %@ where authorName = \"%@\";", NSStringFromClass([data class]), data.authorName];
    __block NSMutableArray *retArray = [NSMutableArray array];
    
    [databaseQueue inDatabase:^(FMDatabase *db) {
//        NSLog(@"loadAlbum");
        FMResultSet *rs = nil;
        rs = [db executeQuery:queryStr];
        while (rs.next) {
            NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[data toDict]];
            NSArray *keys = [dict allKeys];
            for (NSString *key in keys) {
                id r = [rs objectForColumnName:key];
                dict[key] = r;
            }
            
            SYAlbum *sdata = [SYAlbum instanceWithDict:dict];
//            SYSong *subData = [[SYSong alloc] init];
//            subData.authorName = sdata.authorName;
//            subData.albumName = sdata.name;
//            NSArray *subDatas = [self loadSong:subData];
//            sdata.songs = subDatas;
            [retArray addObject:sdata];
        }
        [rs close];
    }];
    [databaseQueue close];
    
    for (SYAlbum *sdata in retArray) {
        SYSong *subData = [[SYSong alloc] init];
        subData.authorName = sdata.authorName;
        subData.albumName = sdata.name;
        NSArray *subDatas = [self loadSong:subData];
        sdata.songs = subDatas;
    }
    return [retArray copy];
}

+(NSArray *)loadSong:(SYSong *)data{
    [self assertTable:data];
    NSString *queryStr = [NSString stringWithFormat:@"select * from %@ where authorName = \"%@\" AND albumName = \"%@\";", NSStringFromClass([data class]), data.authorName, data.albumName];
    __block NSMutableArray *retArray = [NSMutableArray array];
    
    [databaseQueue inDatabase:^(FMDatabase *db) {
//        NSLog(@"loadSong");
        FMResultSet *rs = nil;
        rs = [db executeQuery:queryStr];
        while (rs.next) {
            NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[data toDict]];
            NSArray *keys = [dict allKeys];
            for (NSString *key in keys) {
                id r = [rs objectForColumnName:key];
                dict[key] = r;
            }
            
            SYSong *sdata = [SYSong instanceWithDict:dict];
            [retArray addObject:sdata];
        }
        [rs close];
    }];
    [databaseQueue close];
    return [retArray copy];
}

/** 返回格式：@"update %@ set %@ %@;" */
+(NSString*) assembleUpdateSql:(id)tableObj
{
    NSDictionary *dict = [self dictCheck:tableObj];
    NSArray *columns = [dict allKeys];
    
    NSMutableString *middle = [NSMutableString new];
    NSString *suffix = [NSString new];
    for(int i=0;i<[columns count];i++){
        NSString *columnName = [columns objectAtIndex:i];// 列名
        id obj = dict[columnName];
        if (![obj isKindOfClass:[NSArray class]] && ![columnName isEqualToString:@"self_id"]) {
            [middle appendString:[NSString stringWithFormat:@"%@ = :%@,", columnName, columnName]];
        }
    }
    middle = [[middle substringToIndex:middle.length - 1] copy];
    SYModel *model = (SYModel *)tableObj;
    suffix = [model.name copy];
    if (suffix.length) {
        suffix = [NSString stringWithFormat:@" where name = \"%@\" ",suffix];
    }else{
        suffix = @"";
    }
    
    NSString *sql = [NSString stringWithFormat:@"update %@ set %@ %@;",NSStringFromClass([tableObj class]),middle,suffix];
    return sql;
}
/** 返回格式：insert into table_name (c1,c2,c3) values (:a,:b,:c); */
+(NSString*) assembleInsertSql:(id)tableObj
{
    NSDictionary *dict = [self dictCheck:tableObj];
    NSArray *columns = [dict allKeys];
    
    NSMutableString *middle = [NSMutableString new];
    NSMutableString *suffix = [NSMutableString new];
    for(int i=0;i<[columns count];i++){
        NSString *columnName = [columns objectAtIndex:i];// 列名
        id obj = dict[columnName];
        if (![obj isKindOfClass:[NSArray class]] && ![columnName isEqualToString:@"self_id"]) {
            [middle appendString:columnName];
            [middle appendString:@","];
            
            [suffix appendString:@":"];
            [suffix appendString:columnName];
            [suffix appendString:@","];
        }
    }
    middle = [[middle substringToIndex:middle.length - 1] copy];
    suffix = [[suffix substringToIndex:suffix.length - 1] copy];
    
    NSString *sql = [NSString stringWithFormat:@"insert into %@ (%@) values (%@);",NSStringFromClass([tableObj class]),middle,suffix];
    return sql;
}
/** 返回格式：CREATE TABLE IF NOT EXISTS SYAuthor (id INTEGER PRIMARY KEY AUTOINCREMENT ,name TEXT,path TEXT,playingIndex INTEGER); */
+(NSString*) assembleTableSql:(id)data
{
    NSString *table = NSStringFromClass([data class]);
    NSString *superTable = @"";
    if ([data isKindOfClass:[SYAlbum class]]) {
        superTable = [NSString stringWithFormat:@"authorName REFERENCES %@(name) ON DELETE CASCADE ON UPDATE NO ACTION,",NSStringFromClass([SYAuthor class])];
    }else if ([data isKindOfClass:[SYSong class]]) {
        superTable = [NSString stringWithFormat:@"authorName REFERENCES %@(name),albumName REFERENCES %@(name) ON DELETE CASCADE ON UPDATE NO ACTION,",NSStringFromClass([SYAuthor class]),NSStringFromClass([SYAlbum class])];
    }
    NSString *params = [self assembleParams:data];
    NSString *assertTableSql = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (self_id INTEGER PRIMARY KEY AUTOINCREMENT,%@ %@);", table,superTable,params];
    return assertTableSql;
}
/** 返回格式：name TEXT,path TEXT,playingIndex INTEGER */
+(NSString*) assembleParams:(id)tableObj
{
    NSDictionary *dict = [self dictCheck:tableObj];
    NSArray *columns = [dict allKeys];
    
    NSMutableString *params = [NSMutableString new];
    for(int i=0;i<[columns count];i++){
        NSString *columnName = [columns objectAtIndex:i];// 列名
        id obj = dict[columnName];
        if ((![obj isKindOfClass:[NSArray class]]) && !([columnName isEqualToString:@"self_id"]) && !([columnName isEqualToString:@"authorName"]) && !([columnName isEqualToString:@"albumName"])) {
            [params appendString:@","];
            [params appendString:columnName];
            [params appendString:@" "];
            if ([obj isKindOfClass:[NSString class]]) {
                [params appendString:@"TEXT"];
            }else if ([obj isKindOfClass:[NSNumber class]]) {
                [params appendString:@"REAL"];
            }
        }
    }
    
    return [[params substringFromIndex:1] copy];
}
+(NSDictionary *)dictCheck:(id)tableObj{
    if ([tableObj isKindOfClass:[NSDictionary class]]) {
        return tableObj;
    }else if ([tableObj respondsToSelector:@selector(toDict)]) {
        return [tableObj toDict];
    }else{
        return nil;
    }
}
@end
