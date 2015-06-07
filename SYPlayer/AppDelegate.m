//
//  AppDelegate.m
//  SYPlayer
//
//  Created by YinYanhui on 15-2-24.
//  Copyright (c) 2015年 YinYanhui. All rights reserved.
//

#import "AppDelegate.h"
#import "MobClick.h"
#import "SYRootViewController.h"
#import "SYAudioController.h"
#import "SYAuthor.h"
#import <Crashlytics/Crashlytics.h>

@interface AppDelegate ()
@property (nonatomic,strong) SYAudioController * audioController;
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [Crashlytics startWithAPIKey:@"95a455f149ee437632f8d7be182c078e93746625"];
    [MobClick startWithAppkey:@"553501df67e58e0eec0012ca" reportPolicy:BATCH   channelId:@""];
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    SYRootViewController *rootController = [[SYRootViewController alloc] init];

    self.window.rootViewController = rootController;
    [self.window makeKeyAndVisible];
    
    NSString *nce_root = @"nce_root.db";
    NSString *srcPath = [[NSBundle mainBundle] pathForResource:nce_root ofType:nil];
    NSString *descPath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Library/Caches"] stringByAppendingPathComponent:nce_root];
    if (![[NSFileManager defaultManager] fileExistsAtPath:descPath]) {
        [[NSFileManager defaultManager] copyItemAtPath:srcPath toPath:descPath error:nil];
    }
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    [application beginBackgroundTaskWithExpirationHandler:nil];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - property
-(SYAudioController *)audioController{
    if (_audioController == nil) {
        _audioController = [SYAudioController sharedAudioController];
    }
    return _audioController;
}
@end
