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

@protocol MapViewControllerPlacemarks <NSObject>

@end

@interface MapViewControllerPlacemarks : UIViewController <MKMapViewDelegate> {
    IBOutlet UIActivityIndicatorView* activityIndicator;
    IBOutlet MKMapView *mapView;
}

@property (nonatomic, retain) Todolist* todolist;

- (id) initWithTodolist:(Todolist*) todolist;

- (void) displayMap;


@end
