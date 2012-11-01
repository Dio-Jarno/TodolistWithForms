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

@synthesize ID, name, place, placemark, dueAt, details, done, notification;


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
- (id) initForId:(int)_id andName:(NSString*)_name andPlace:(NSString*)_place andPlacemark:(MKPlacemark*)_placemark andDetails:(NSString*)_details andDueAt:(NSDate*)_date {
    self = [super init];
    [self setID:_id];
    [self setName:_name];
    [self setPlace:_place];
    [self setPlacemark:_placemark];
    [self setDetails:_details];
    [self setDueAt:_date];
    return self;
}

// instance method: constructor 2
- (id) initForId:(int)_id andName:(NSString*)_name andPlace:(NSString*)_place andPlacemark:(MKPlacemark*)_placemark andDetails:(NSString*)_details andDueAtString:(NSString*)_date {
    return [self initForId:_id andName:_name andPlace:_place andPlacemark:_placemark andDetails:_details andDueAt:[[Todo dateFormatter] dateFromString:_date]];
}

- (void) dealloc {
    [name release];
    [details release];
    [dueAt release];
    [placemark release];
    [super release];
    [super dealloc];
}

#pragma instance methods
// instance method: toString
- (NSString*) description {
    return [NSString stringWithFormat:@"{%@ %i %@ %@ %@ %@ %@}",[super description], ID, name, place, details, dueAt, (done ? @"done" : @"pending")];    
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
    df.dateFormat = @"dd-MM-yyyy hh:mm";
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
