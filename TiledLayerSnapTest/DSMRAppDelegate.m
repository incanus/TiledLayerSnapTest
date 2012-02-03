//
//  DSMRAppDelegate.m
//  TiledLayerSnapTest
//
//  Created by Justin Miller on 2/2/12.
//  Copyright (c) 2012 Development Seed. All rights reserved.
//

#import "DSMRAppDelegate.h"

#import "DSMRViewController.h"

@implementation DSMRAppDelegate

@synthesize window = _window;
@synthesize viewController = _viewController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.viewController = [[DSMRViewController alloc] initWithNibName:@"DSMRViewController" bundle:nil];
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    return YES;
}

@end