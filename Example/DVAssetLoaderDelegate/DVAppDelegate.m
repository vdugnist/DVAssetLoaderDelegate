//
//  DVAppDelegate.m
//  DVAssetLoaderDelegate
//
//  Created by vdugnist on 01/02/2018.
//  Copyright (c) 2018 vdugnist. All rights reserved.
//

#import "DVAppDelegate.h"
#import "DVViewController.h"

@implementation DVAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.rootViewController = [[DVViewController alloc] init];
    [self.window makeKeyAndVisible];
    return YES;
}

@end
