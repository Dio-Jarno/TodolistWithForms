//
//  GenericMapViewController.h
//  TodolistWithForms
//
//  Created by Arvid Grunenberg on 12.06.12.
//  Copyright (c) 2012 de.fhb.mobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "MapViewController.h"
#import "Todolist.h"

@protocol MapViewController <NSObject>

@end

@interface MapViewController : UIViewController <MKMapViewDelegate> {
    IBOutlet UIActivityIndicatorView* activityIndicator;
    IBOutlet MKMapView *mapView;
}

@property (nonatomic, retain) NSString* location; 

@property (nonatomic, retain) MKPlacemark* placemark; 

- (id) initWithPlacemark:(MKPlacemark*) _placemark;

- (id) initWithLocation:(NSString*) _location;

- (id) initWithUserLocation;

- (void) displayMap;

- (IBAction)longPress:(UILongPressGestureRecognizer *)sender;


@end
