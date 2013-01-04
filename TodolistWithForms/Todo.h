//
//  Todo.h
//  Todolist
//
//  Created by Jörn Kreutel on 10.04.12.
//  Copyright (c) 2012 de.fhb.mobile. All rights reserved.
//

#import "ITodo.h"
#import <MapKit/MKPlacemark.h>

@interface Todo : NSObject <ITodo>

@property (nonatomic,retain) NSString* name;

@property (nonatomic,retain) NSString* place;

@property (nonatomic,retain) MKPlacemark* placemark;

@property (nonatomic) int radius;

@property (nonatomic,retain) NSString* details;

@property (nonatomic,retain) NSDate* dueAt;

@property (nonatomic,retain) NSDate* modifiedAt;

@property (nonatomic) BOOL done;

@property (nonatomic) BOOL changed;

@property (nonatomic) int ID;

@property (nonatomic) BOOL notification;

- (id) initForId:(int)_id andName:(NSString*)_name andPlace:(NSString*)_place andPlacemark:(MKPlacemark*)_placemark andRadius:(int)_radius andDetails:(NSString*)_details andDueAt:(NSDate*)_date andModifiedAt:(NSDate*) modifiedAt;

- (id) initForId:(int)_id andName:(NSString*)_name andPlace:(NSString*)_place andPlacemark:(MKPlacemark*)_placemark andRadius:(int)_radius andDetails:(NSString*)_details andDueAtString:(NSString*)_date andModifiedAt:(NSDate*) modifiedAt;

- (NSString*) dueAtString;

- (NSString*) dueAtStringWithFormat:(NSString*)format;

+ (NSDateFormatter*) dateFormatter;

- (NSComparisonResult)compareForDueAt:(Todo*)todo;


@end