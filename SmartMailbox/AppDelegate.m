//
//  AppDelegate.m
//  SmartMailbox
//
//  Created by Daniel Wang on 12/15/16.
//  Copyright © 2016 Factory Method. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *) application
didFinishLaunchingWithOptions:(NSDictionary *) launchOptions
{
	self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

	self.mainVC = [[ViewController alloc] init];
	UINavigationController* nav = [[UINavigationController alloc] initWithRootViewController:self.mainVC];

	self.window.rootViewController = nav;
	[self.window makeKeyAndVisible];

	return YES;
}

@end
