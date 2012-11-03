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

@protocol MapViewPlacemarksController <NSObject>

@end

@interface MapViewPlacemarksController : UIViewController <MKMapViewDelegate> {
    IBOutlet UIActivityIndicatorView* activityIndicator;
    IBOutlet MKMapView *mapView;
}

@end
