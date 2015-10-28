//
//  AppDelegate.m
//  One Dreamer Company
//  www.one-dreamer.com
//  Copyright (c) 2014 One Dreamer Company. All rights reserved.


//-- Import Required Frameworks/Header Files
#import "AppDelegate.h"


@implementation AppDelegate


//---- Application Did Launch - Called when app starts ----
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    //-- Load the Settings.plist file
    self.Settings = [[Settings alloc] init];
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"Settings"]
                                                         ofType:@"plist"];
    
    self.Settings = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
    
    // Determine User Device
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
        
        UIStoryboard *storyBoard;
        CGSize result = [[UIScreen mainScreen] bounds].size;
        
        // If IPhone 4, load the correct storyboard
        if(result.height != 568){
            
            storyBoard = [UIStoryboard storyboardWithName:@"Main_iPhone_3.5" bundle:nil];
            UIViewController *initViewController = [storyBoard instantiateInitialViewController];
            [self.window setRootViewController:initViewController];
        }
    }
    
    // Override point for customization after application launch.
    return YES;
}


- (BOOL)shouldRequestInterstitialsInFirstSession {
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}


//---- Application Did Become active ----
- (void)applicationDidBecomeActive:(UIApplication *)application
{
    
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
