//
//  ITodo.h
//  Todolist
//
//  Created by Jörn Kreutel on 13.04.12.
//  Copyright (c) 2012 de.fhb.mobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Logger.h"

@protocol ITodo <NSObject>

// accessors
- (NSString*) name;
- (void) setName:(NSString*)name;

- (NSString*) details;
- (void) setDetails:(NSString*)details;

- (NSDate*) dueAt;
- (void) setDueAt:(NSDate*)dueAt;

- (int) ID;

// instance method
- (NSString*) dueAtString;

@end
