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

@implementation SYCatcheTool

static FMDatabaseQueue *_queue;
/** 检查或新建数据库 */
+ (void)assertBase
{
    // 0.获得沙盒中的数据库文件名
    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"nce_root.sqlite"];
    
    _queue = [FMDatabaseQueue databaseQueueWithPath:path];
    
    [_queue close];
}

+(BOOL)assertTable:(id)obj{
    NSString *sql = [self assembleTableSql:obj];
    if (sql) {
        [self assertBase];
        
        [_queue inDatabase:^(FMDatabase *db) {
            [db executeUpdate:sql];
        }];
        [_queue close];
        return YES;
    }
    return NO;
}

+(BOOL)insertData:(id)data{
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
                break;
            }
        }
        if (subKey) {
            [dict removeObjectForKey:subKey];
        }
        
        NSString *sql = [self assembleInsertSql:data];
        
        [_queue inDatabase:^(FMDatabase *db) {
            FMResultSet *rs = nil;
            NSString *queryStr = [NSString stringWithFormat:@"select * from %@ where %@ = \"%@\";", NSStringFromClass([data class]), @"name", dict[@"name"]];
            rs = [db executeQuery:queryStr];
            
            if (!rs.next) {
                [db executeUpdate:sql withParameterDictionary:dict];
            }
            [rs close];
        }];
        [_queue close];
        
        if (subDatas) {
            for (id subData in subDatas) {
                if ([data isKindOfClass:[SYAuthor class]]) {
                    [self insertData:[SYAlbum instanceWithDict:subData]];
                }else if ([data isKindOfClass:[SYAlbum class]]) {
                    [self insertData:[SYSong instanceWithDict:subData]];
                }
            }
        }
        return YES;
    }
    
    return NO;
}

+(NSArray *)loadData:(id)data{
    [self assertTable:data];
    
    NSMutableArray *retArrary = [NSMutableArray array];
    [_queue inDatabase:^(FMDatabase *db) {
        FMResultSet *rs = nil;
        NSString *queryStr = [NSString stringWithFormat:@"select * from %@;", NSStringFromClass([data class])];
        rs = [db executeQuery:queryStr];
        
        while (rs.next) {
            NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[data toDict]];
            NSArray *keys = [dict allKeys];
            for (NSString *key in keys) {
                id r = [rs objectForColumnName:key];
                dict[key] = r;
            }
            
            if ([data isKindOfClass:[SYAuthor class]]) {
                SYAuthor *sdata = [SYAuthor instanceWithDict:dict];
                NSArray *subDatas = [self loadData:[[SYAlbum alloc] init]];
                sdata.albums = subDatas;
                [retArrary addObject:sdata];
            }else if ([data isKindOfClass:[SYAlbum class]]) {
                SYAlbum *sdata = [SYAlbum instanceWithDict:dict];
                NSArray *subDatas = [self loadData:[[SYSong alloc] init]];
                sdata.songs = subDatas;
                [retArrary addObject:sdata];
            }else if ([data isKindOfClass:[SYSong class]]) {
                SYSong *sdata = [SYSong instanceWithDict:dict];
                [retArrary addObject:sdata];
            }
        }
        [rs close];
    }];
    [_queue close];
    
    return [retArrary copy];
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
        if (![obj isKindOfClass:[NSArray class]]) {
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
+(NSString*) assembleTableSql:(id)tableObj
{
    NSDictionary *dict = [self dictCheck:tableObj];
    NSArray *columns = [dict allKeys];
    
    NSMutableString *params = [NSMutableString new];
    for(int i=0;i<[columns count];i++){
        NSString *columnName = [columns objectAtIndex:i];// 列名
        id obj = dict[columnName];
        if (![obj isKindOfClass:[NSArray class]]) {
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
//        params = [[params substringFromIndex:1] copy];
    
    NSString *sql = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (id INTEGER PRIMARY KEY AUTOINCREMENT %@);",NSStringFromClass([tableObj class]),params];
    return sql;
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
