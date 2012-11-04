//
//  GenericMapViewController.m
//  TodolistWithForms
//
//  Created by Arvid on 12.06.12.
//  Copyright (c) 2012 de.fhb.mobile. All rights reserved.
//

#import "MapViewController.h"
#import "Logger.h"

@implementation MapViewController

@synthesize placemark, location;

static Logger* logger;

+ (void) initialize {
    logger = [[Logger alloc] initForClass:[MapViewController class]];    
}

- (id) initWithPlacemark:(MKPlacemark*) _placemark {
    [logger debug:@"MapViewController - initWithPlacemark"];
    [self setPlacemark:_placemark];
    [self updateTitle];
    return self;
}

- (id) initWithLocation:(NSString *) _location {
    [logger debug:@"MapViewController - initWithLocation"];
    [self setLocation:_location];
    [[self navigationItem] setTitle:_location];
    return self;
}

- (void) updateTitle {
    if ([[self placemark] locality] != NULL && ![[[self placemark] locality] isEqual:@""]) {
        [[self navigationItem] setTitle:[[self placemark] locality]];
    } else if ([[self placemark] subLocality] != NULL && ![[[self placemark] subLocality] isEqual:@""]) {
        [[self navigationItem] setTitle:[[self placemark] subLocality]];
    }
}

- (id) initWithUserLocation {
    [logger debug:@"MapViewController - initWithUserLocation"];
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // start the activity indicator
    [activityIndicator startAnimating];
    
    mapView = [[MKMapView alloc] initWithFrame:self.view.bounds];
    [mapView setDelegate:self];
    [mapView setShowsUserLocation:YES];
    
    UILongPressGestureRecognizer* recognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
    [mapView addGestureRecognizer:recognizer];
    [recognizer release];
    
    [self.view addSubview:mapView];
    [NSThread detachNewThreadSelector:@selector(displayMap) toTarget:self withObject:nil];
}

- (void)mapView:(MKMapView *)_mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    CLLocationAccuracy accuracy = userLocation.location.horizontalAccuracy;
    if (accuracy && placemark == NULL) {
        [logger debug:@"user location: %f",[[mapView userLocation] coordinate]];
        [_mapView setRegion:MKCoordinateRegionMakeWithDistance([[_mapView userLocation] coordinate], 2000, 2000) animated:YES];
        placemark = [[MKPlacemark alloc] initWithCoordinate:[[_mapView userLocation] coordinate] addressDictionary:nil];
        [mapView addAnnotation:placemark];
    }
}

- (void)displayMap {
    if (placemark != NULL) {
        [logger debug:@"placemark location: %f",[[placemark location] coordinate]];
        CLGeocoder* geocoder = [[CLGeocoder alloc] init];
        [geocoder reverseGeocodeLocation:placemark.location
                  completionHandler:^(NSArray *placemarks, NSError *error) {
                      CLPlacemark *topResult = [placemarks objectAtIndex:0];
                      MKPlacemark *newPlacemark = [[MKPlacemark alloc] initWithPlacemark:topResult];
                      [mapView addAnnotation:newPlacemark];
                      [self setPlacemark:newPlacemark];
                      [self updateTitle];
                      [mapView setRegion:MKCoordinateRegionMakeWithDistance([newPlacemark.location coordinate], 2000, 2000) animated:YES];
                  }
         ];
    } else if (location != NULL && ![location isEqual:@""]) {
        CLGeocoder* geocoder = [[CLGeocoder alloc] init];
        [geocoder geocodeAddressString:[self location]
                     completionHandler:^(NSArray* placemarks, NSError* error) {
                         if (placemarks && placemarks.count > 0) {
                             CLPlacemark *topResult = [placemarks objectAtIndex:0];
                             MKPlacemark *newPlacemark = [[MKPlacemark alloc] initWithPlacemark:topResult];
                             [mapView addAnnotation:newPlacemark];
                             [self setPlacemark:newPlacemark];
                             [mapView setRegion:MKCoordinateRegionMakeWithDistance([newPlacemark.location coordinate], 2000, 2000) animated:YES];
                         }
                     }
         ];
        } else {
            [logger debug:@"user location: %f",[[mapView userLocation] coordinate]];
            [mapView setRegion:MKCoordinateRegionMakeWithDistance([[mapView userLocation] coordinate], 2000, 2000) animated:YES];
        }
    [activityIndicator stopAnimating];
}

- (void)longPress:(UILongPressGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateBegan) {
        [logger debug:@"Long press began on map."];
        CGPoint touchPoint = [sender locationInView:[sender view]];
        CLLocationCoordinate2D touchMapCoordinate = [mapView convertPoint:touchPoint toCoordinateFromView:mapView];
        MKReverseGeocoder *reverseGeocoder = [[MKReverseGeocoder alloc] initWithCoordinate:touchMapCoordinate];
        reverseGeocoder.delegate = self;
        [reverseGeocoder start];
    }
}

- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFindPlacemark:(MKPlacemark *)_placemark { 
    [logger debug:@"Address of placemark is: %@",_placemark.addressDictionary];
    [mapView removeAnnotations:[mapView annotations]];
    [mapView addAnnotation:_placemark];
    [self setPlacemark:_placemark];
    [self updateTitle];
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
