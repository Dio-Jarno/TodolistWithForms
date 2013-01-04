//
//  LocationManager.h
//  TodolistWithForms
//
//  Created by Arvid on 27.11.12.
//  Copyright (c) 2012 de.fhb.mobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface TestController : UIViewController <CLLocationManagerDelegate> {
    
    CLLocationManager *locationManager;
    
}

@property (retain, nonatomic) UIScrollView *scrollView;

@property (retain, nonatomic) UIButton *exitButton;

- (void) startGPS;

@end
