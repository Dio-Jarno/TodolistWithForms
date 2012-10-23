//
//  TodolistBackendAccessorImpl.m
//  Todolist
//
//  Created by Jörn Kreutel on 10.04.12.
//  Copyright (c) 2012 de.fhb.mobile. All rights reserved.
//

#import "TodolistBackendAccessorImpl.h"
#import "Logger.h"

@implementation TodolistBackendAccessorImpl 

// class attribute
static Logger* logger;

// static initialiser
+ (void)initialize {
    logger = [[Logger alloc] initForClass:[TodolistBackendAccessorImpl class]];    
}


- (Todolist*) loadTodolist {
 
    [logger debug:@"loadTodolist"];
    
    // any complex datatype value can be used as a boolean expression
    if (todolist) {
        [logger debug:@"loadTodolist: list has already been loaded."];
    }
    else {
        [logger debug:@"loadTodolist: list has not been loaded yet."];
        todolist = [[Todolist createTestdata] retain];        
        [logger debug:@"loadTodolist: list is: %@", todolist];
    }
    
    return todolist;    
}

- (void) dealloc {
    [todolist release];
    
    [super dealloc];
}

@end
