//
//  LocationManager.h
//  TodolistWithForms
//
//  Created by Arvid on 27.11.12.
//  Copyright (c) 2012 de.fhb.mobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface LocationManagerController : NSObject <CLLocationManagerDelegate> {
    
    CLLocationManager *locationManager;
    
}

- (void) startGPS;

@end
