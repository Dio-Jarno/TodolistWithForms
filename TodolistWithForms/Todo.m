//
//  Todo.m
//  Todolist
//
//  Created by Jörn Kreutel on 10.04.12.
//  Copyright (c) 2012 de.fhb.mobile. All rights reserved.
//

#import "Todo.h"
#import "Logger.h"

@implementation Todo

@synthesize ID, name, place, placemark, radius, dueAt, modifiedAt, details, done, notification;


// class attribute
static Logger* logger;

// static initialiser
+ (void)initialize {
    logger = [[Logger alloc] initForClass:[Todo class]];    
}

// class attributes
static Logger* logger;

#pragma object lifecycle
// instance method: constructor 1
- (id) initForId:(int)_id andName:(NSString*)_name andPlace:(NSString*)_place andPlacemark:(MKPlacemark*)_placemark andRadius:(int)_radius andDetails:(NSString*)_details andDueAt:(NSDate*)_date andModifiedAt:(NSDate*)_modifiedAt {
    self = [super init];
    [self setID:_id];
    [self setName:_name];
    [self setPlace:_place];
    [self setPlacemark:_placemark];
    [self setRadius:_radius];
    [self setDetails:_details];
    [self setDueAt:_date];
    [self setModifiedAt:_modifiedAt];
    [self setChanged:NO];
    return self;
}

// instance method: constructor 2
- (id) initForId:(int)_id andName:(NSString*)_name andPlace:(NSString*)_place andPlacemark:(MKPlacemark*)_placemark andRadius:(int)_radius andDetails:(NSString*)_details andDueAtString:(NSString*)_date andModifiedAt:(NSDate*)_modifiedAt {
    return [self initForId:_id andName:_name andPlace:_place andPlacemark:_placemark andRadius:_radius andDetails:_details andDueAt:[[Todo dateFormatter] dateFromString:_date] andModifiedAt:(NSDate*)_modifiedAt];
}

- (void) dealloc {
    [name release];
    [details release];
    [dueAt release];
    [modifiedAt release];
    [placemark release];
    [super release];
    [super dealloc];
}

#pragma instance methods
// instance method: toString
- (NSString*) description {
    return [NSString stringWithFormat:@"{%@ %i %@ %@ %i %@ %@ %@ %@}",[super description], ID, name, place, radius, details, dueAt, modifiedAt, (done ? @"done" : @"pending")];
}

- (NSString*) dueAtString {
    return [[Todo dateFormatter] stringFromDate:[self dueAt]]; 
}

- (NSString*) dueAtStringWithFormat:(NSString*)format {
    NSDateFormatter* df = [[[NSDateFormatter alloc] init] autorelease]; 
    df.dateFormat = format;
    return [df stringFromDate:[self dueAt]]; 
}

// class method: obtain a date formatter 
+ (NSDateFormatter*) dateFormatter {
    NSDateFormatter* df = [[[NSDateFormatter alloc] init] autorelease]; 
    df.dateFormat = @"dd.MM.yyyy HH:mm";
    return df;
}

#pragma comparison method for sorting
- (NSComparisonResult)compareForDueAt:(Todo*)todo {
    
    if ([self done] && ![todo done]) {
        return NSOrderedDescending;
    }
    else if (![self done] && [todo done]) { 
        return NSOrderedAscending;
    }
    else {
        return [[self dueAt] compare:[todo dueAt]];
    }
}


@end
