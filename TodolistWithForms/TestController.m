//
//  LocationManager.m
//  TodolistWithForms
//
//  Created by Arvid on 27.11.12.
//  Copyright (c) 2012 de.fhb.mobile. All rights reserved.
//

#import "TestController.h"
#import "Logger.h"
#import "TodolistAppDelegate.h"

@implementation TestController

static Logger* logger;

- (id) init {
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.distanceFilter = kCLDistanceFilterNone; // whenever we move
    locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
    
    logger = [[Logger alloc] initForClass:[TestController class]];
    return self;
}

// function to start capture GPS, we check settings first to see if GPS is disabled before attempting to get GPS
- (void) startGPS {
    if([self isGPSEnabled]) {
        // Location Services is not disabled, get it now
        [locationManager startUpdatingLocation];
        [logger lifecycle:@"location manager started"];
    } else {
        // Location Services is disabled, do sth here to tell user to enable it
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Information"
                                                        message:@"Please enable the location service for hole functionality."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
}

// check whether GPS is enabled
- (BOOL) isGPSEnabled {
    if (! ([CLLocationManager locationServicesEnabled]) || ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied)) {
        return NO;
    }
    return YES;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    
    [logger info:@"GPS data - latitude: %i longitude: %i", newLocation.coordinate.latitude, newLocation.coordinate.longitude];
    
    Todolist* _todolist = [[[(TodolistAppDelegate*)[[UIApplication sharedApplication] delegate] backendAccessor] getTodolist] retain];
    
    if ((newLocation.coordinate.latitude != oldLocation.coordinate.latitude) && newLocation.coordinate.longitude != oldLocation.coordinate.longitude) {
        [logger info:@"location has changed"];
        for (int i=0; i<[_todolist countTodos]; i++) {
            id<ITodo> _todo = [_todolist todoAtPosition:i];
            MKPlacemark* placemark = [_todo placemark];
            if (placemark != NULL) {
                CLLocationDistance distance = [newLocation distanceFromLocation:[placemark location]];
                if (distance < 1000.0) {
                    [logger info:@"there is a todo in the vicinity"];
                    if (![_todo done] && ![_todo notification]) {
                        [self scheduleNotification:_todo];
                    }
                }
            }
        }
    }
}

- (void) scheduleNotification:(id<ITodo>)todo {
    [logger info:@"create notification for todo with id %d", [todo ID]];
    
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    
    NSMutableString *message = [NSMutableString stringWithString:@"The todo '"];
    [message appendString:[todo name]];
    [message appendString:@"' is in your vicinity."];
    notification.alertBody = message;
    notification.alertAction = @"Show me";
    notification.soundName = UILocalNotificationDefaultSoundName;
    notification.applicationIconBadgeNumber += 1;
    
    NSDictionary *userDict = [NSDictionary dictionaryWithObject:[todo name] forKey:@"todoName"];
    notification.userInfo = userDict;
    
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    [notification release];
    
    [todo setNotification:YES];
}

- (void)viewDidLoad {
    //self.exitButton = [[UIButton alloc] init];
    
    
    [self.view addSubview:mapView];
}

- (void)dealloc {
    [_scrollView release];
    [_exitButton release];
    [super dealloc];
}
- (void)viewDidUnload {
    [self setScrollView:nil];
    [self setExitButton:nil];
    [super viewDidUnload];
}
@end
