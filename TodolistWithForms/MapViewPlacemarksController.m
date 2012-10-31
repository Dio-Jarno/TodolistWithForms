//
//  MapViewPlacemarksController.m
//  TodolistWithForms
//
//  Created by Arvid on 25.06.12.
//  Copyright (c) 2012 de.fhb.mobile. All rights reserved.
//

#import "MapViewPlacemarksController.h"
#import "TodolistAppDelegate.h"
#import "Logger.h"

@implementation MapViewPlacemarksController

@synthesize todolist;

static Logger* logger;

+ (void) initialize {
    logger = [[Logger alloc] initForClass:[MapViewController class]];    
}

- (id) init {
    [logger debug:@"MapViewPlacemarksController - init"];
    return self;
}

- (void) viewDidLoad {
    [super viewDidLoad];
    // start the activity indicator
    [activityIndicator startAnimating];
    
    mapView = [[MKMapView alloc] initWithFrame:self.view.bounds];
    [mapView setDelegate:self];
    [mapView setShowsUserLocation:YES];
    
    [self.view addSubview:mapView];
    
    UIToolbar *toolbar = [[UIToolbar alloc] init];
    toolbar.frame = CGRectMake(0, 0, self.view.frame.size.width, 44);
    NSMutableArray *items = [[NSMutableArray alloc] init];
    UIBarButtonItem *flexiableItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    [items addObject:flexiableItem];
    
    UIBarButtonItem *lookOutTodosItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(lookOutTodos)];
    [items addObject:lookOutTodosItem];
    
    [toolbar setItems:items animated:NO];
    [items release];
    [self.view addSubview:toolbar];
    [toolbar release];
}

- (void) viewDidAppear:(BOOL)animated {
    [logger debug:@"MapViewPlacemarksController - viewDidAppear"];
    dispatch_group_t group = dispatch_group_create();
    Todolist* _todolist = [[[(TodolistAppDelegate*)[[UIApplication sharedApplication] delegate] backendAccessor] loadTodolist] retain];    
    [self setTodolist:_todolist];
    [mapView removeAnnotations:[mapView annotations]];
    for (int i=0; i<[[self todolist] countTodos]; i++) {
        MKPlacemark* _placemark = [[[self todolist] todoAtPosition:i] placemark];
        if (_placemark != NULL) {
            dispatch_group_enter(group);
            CLGeocoder* geocoder = [[CLGeocoder alloc] init];
            [geocoder reverseGeocodeLocation:_placemark.location
                           completionHandler:^(NSArray *placemarks, NSError *error) {
                               CLPlacemark *topResult = [placemarks objectAtIndex:0];
                               MKPlacemark *newPlacemark = [[MKPlacemark alloc] initWithPlacemark:topResult];
                               [mapView addAnnotation:newPlacemark];
                               dispatch_group_leave(group);
                           }
             ];
        }
    }
    while (dispatch_group_wait(group, DISPATCH_TIME_NOW)) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:1.f]];
    }
    dispatch_release(group);
    [self zoomToFitMapAnnotations];
}

// http://stackoverflow.com/a/7200744
- (void) zoomToFitMapAnnotations { 
    [logger debug:@"MapViewPlacemarksController - zoomToFitMapAnnotations: %@", [mapView annotations]];
    if ([mapView.annotations count] == 0) return; 
    
    CLLocationCoordinate2D topLeftCoord; 
    topLeftCoord.latitude = -90; 
    topLeftCoord.longitude = 180; 
    
    CLLocationCoordinate2D bottomRightCoord; 
    bottomRightCoord.latitude = 90; 
    bottomRightCoord.longitude = -180; 
    
    for(id<MKAnnotation> annotation in mapView.annotations) { 
        topLeftCoord.longitude = fmin(topLeftCoord.longitude, annotation.coordinate.longitude); 
        topLeftCoord.latitude = fmax(topLeftCoord.latitude, annotation.coordinate.latitude); 
        bottomRightCoord.longitude = fmax(bottomRightCoord.longitude, annotation.coordinate.longitude); 
        bottomRightCoord.latitude = fmin(bottomRightCoord.latitude, annotation.coordinate.latitude); 
    } 
    
    MKCoordinateRegion region; 
    region.center.latitude = topLeftCoord.latitude - (topLeftCoord.latitude - bottomRightCoord.latitude) * 0.5;
    region.center.longitude = topLeftCoord.longitude + (bottomRightCoord.longitude - topLeftCoord.longitude) * 0.5;
    
    // Add a little extra space on the sides
    region.span.latitudeDelta = fabs(topLeftCoord.latitude - bottomRightCoord.latitude) * 1.1;
    region.span.longitudeDelta = fabs(bottomRightCoord.longitude - topLeftCoord.longitude) * 1.1;
    
    region = [mapView regionThatFits:region]; 
    [mapView setRegion:region animated:YES];
}

- (void) lookOutTodos {
    for (int i=0; i<[[self todolist] countTodos]; i++) {
        MKPlacemark* placemark = [[[self todolist] todoAtPosition:i] placemark];
        CLLocationDistance distance = [[[mapView userLocation] location] distanceFromLocation:[placemark location]];
        if (distance < 1000.0) {
            [logger info:@"distance to placemark is %f meters", distance];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Information"
                                                      message:@"There is a todo in your vicinity. Do you want to zoom in?"
                                                      delegate:self
                                                      cancelButtonTitle:@"No"
                                                      otherButtonTitles:@"Yes",nil];
            [alert show];
            [alert release];
        }
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    [logger info:@"button %d clicked in alert view", buttonIndex];
    if (buttonIndex == 1) {
        [mapView setRegion:MKCoordinateRegionMakeWithDistance([[mapView userLocation] coordinate], 2000, 2000) animated:YES];
    }
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)dealloc {
    [super dealloc];
    [mapView release];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    [mapView release];
    mapView = nil;
}


@end
