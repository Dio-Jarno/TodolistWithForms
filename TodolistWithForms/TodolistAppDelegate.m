//
//  TLAppDelegate.m
//  TodolistWithForms
//
//  Created by Jörn Kreutel on 17.04.12.
//  Copyright (c) 2012 de.fhb.mobile. All rights reserved.
//

#import "TodolistAppDelegate.h"
#import "TodolistViewController.h"
#import "TodoDetailsViewController.h"
#import "Logger.h"
#import "TodolistBackendAccessorImpl.h"
#import "MapViewPlacemarksController.h"

@implementation TodolistAppDelegate

@synthesize window = _window, backendAccessor;

// class attribute
static Logger* logger;

// static initialiser
+ (void)initialize {
    logger = [[Logger alloc] initForClass:[TodolistAppDelegate class]];    
}

#pragma object lifecycle
- (void) dealloc {
    [backendAccessor release];
    [super release];
    [super dealloc];
}

#pragma inherited methods
// lunching when app was closed
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    application.applicationIconBadgeNumber = 0;
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    
    // custom initialisation
    
    // initialise the central backend accessor used by the view controllers
    [self initialiseBackendAccessor];
    
    // prepare the initial view
    [self prepareRootViewController];
    
    UILocalNotification *notification = [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
    if (notification) {
        NSString *todoName = [notification.userInfo objectForKey:@"todoName"];
        [logger info:@"lunching closed app from notification of todo with id %@", todoName];
    }
    
    return YES;
}

// lunching when app was in background
- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    application.applicationIconBadgeNumber = 0;
    NSString *todoName = [notification.userInfo objectForKey:@"todoName"];
    NSMutableString *message = [NSMutableString stringWithString:@"The todo '"];
    [message appendString:todoName];
    [message appendString:@"' is in your vicinity."];
    UIApplicationState state = [application applicationState];
    if (state == UIApplicationStateInactive) {
        // Application was in the background when notification was delivered.
        [logger info:@"lunching app from notification of todo with id %@", todoName];
    } else {
        [logger info:@"receive notification of todo with id %@", todoName];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Information"
                                                  message:message
                                                  delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

#pragma custom methods

// prepare the initial view
- (void) prepareRootViewController {
    [logger lifecycle:@"prepareRootViewController"];
    // create the TodolistViewController
    TodolistViewController* rootVC = [[TodolistViewController alloc] init];
    MapViewPlacemarksController *mapVC = [[MapViewPlacemarksController alloc] init];
    //[rootVC setTodo:[[backendAccessor loadTodolist] todoAtPosition:0]];
    
    // create a navigation controller that will track transitions between view controllers and handle back button events
    UINavigationController* navCtrl = [[[UINavigationController alloc] initWithRootViewController:rootVC] autorelease];
    
    UITabBarController* tabBarCtrl = [[[UITabBarController alloc] init] autorelease];
    [tabBarCtrl setViewControllers:[NSArray arrayWithObjects:navCtrl, mapVC, nil]];
    NSArray *tabs =  tabBarCtrl.viewControllers;
    UIViewController *tab1 = [tabs objectAtIndex:0];
    [tab1 setTitle:@"List View"];
    tab1.tabBarItem.image = [UIImage imageNamed:@"tablist.png"];
    UIViewController *tab2 = [tabs objectAtIndex:1];
    [tab2 setTitle:@"Map View"];
    tab2.tabBarItem.image = [UIImage imageNamed:@"tabmap.png"];
    
    [logger debug:[Logger logClassHierarchyForObj:tabBarCtrl]];
    [logger lifecycle:[NSString stringWithFormat:@"setting rootViewController: %@ on window: %@",rootVC,[self window]]];
    
    // set the navigation controller as rootViewController of the applications's window
    [[self window] setRootViewController:tabBarCtrl];
    [[self window] makeKeyAndVisible];
    
    // release the reference because the rootVC object will be dealt with by the window instance
    [rootVC release];
}

// prepare the backend accessor
- (void) initialiseBackendAccessor {
    [logger lifecycle:@"initialiseBackendAccessor"];
    backendAccessor = [[[TodolistBackendAccessorImpl alloc] init] retain];
}

@end
