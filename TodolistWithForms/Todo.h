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

@property (nonatomic,retain) NSString* details;

@property (nonatomic,retain) NSDate* dueAt;

@property (nonatomic) BOOL done;

@property (nonatomic) int ID;

- (id) initForId:(int)_id andName:(NSString*)_name andPlace:(NSString*)_place andPlacemark:(MKPlacemark*)_placemark andDetails:(NSString*)_details andDueAt:(NSDate*)_date;

- (id) initForId:(int)_id andName:(NSString*)_name andPlace:(NSString*)_place andPlacemark:(MKPlacemark*)_placemark andDetails:(NSString*)_details andDueAtString:(NSString*)_date;

- (NSString*) dueAtString;

- (NSString*) dueAtStringWithFormat:(NSString*)format;

+ (NSDateFormatter*) dateFormatter;

- (NSComparisonResult)compareForDueAt:(Todo*)todo;


@end