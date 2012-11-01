//
//  ITodo.h
//  Todolist
//
//  Created by Jörn Kreutel on 13.04.12.
//  Copyright (c) 2012 de.fhb.mobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MKPlacemark.h>
#import "Logger.h"

@protocol ITodo <NSObject>

// accessors
- (NSString*) name;
- (void) setName:(NSString*)name;

- (NSString*) place;
- (void) setPlace:(NSString*)place;

- (MKPlacemark*) placemark;
- (void) setPlacemark:(MKPlacemark*)placemark;

- (NSString*) details;
- (void) setDetails:(NSString*)details;

- (NSDate*) dueAt;
- (void) setDueAt:(NSDate*)dueAt;

- (BOOL) done;
- (void) setDone:(BOOL)done;

- (int) ID;
- (void) setID:(int)ID;

- (BOOL) notification;
- (void) setNotification:(BOOL)notification;

// instance methods
- (NSString*) dueAtString;

- (NSString*) dueAtStringWithFormat:(NSString*)format;

@end
