//
//  TodolistBackendAccessorImpl.m
//  Todolist
//
//  Created by Jörn Kreutel on 10.04.12.
//  Copyright (c) 2012 de.fhb.mobile. All rights reserved.
//

#import "TodolistBackendAccessorImpl.h"
#import "Logger.h"
#import "Todo.h"

@implementation TodolistBackendAccessorImpl 

// class attribute
static Logger* logger;

// static initialiser
+ (void)initialize {
    logger = [[Logger alloc] initForClass:[TodolistBackendAccessorImpl class]];
}

- (void) dealloc {
    [todolist release];
    [super dealloc];
}

- (Todolist*) loadTodolist {
    [logger debug:@"loadTodolist"];
    serverAccess = [[ServerAccess alloc] init];
    
    // any complex datatype value can be used as a boolean expression
    if (todolist) {
        [logger debug:@"loadTodolist: list has already been loaded."];
    }
    else {
        [logger debug:@"loadTodolist: list has not been loaded yet."];
        //ServerAccess* serverAccess = [[ServerAccess alloc] initWithServerURL:[[NSMutableString alloc] initWithString:URL]];
        todolist = [serverAccess loadTodos];
        [logger debug:@"loadTodolist: list is: %@", todolist];
    }
    return todolist;    
}

- (id<ITodo>) createTodoForName:(NSString*)name {
    id<ITodo> todo = [[Todo alloc] init];
    [todo setName:name];
    [todo setPlace:@""];
    [todo setPlacemark:NULL];
    [todo setDetails:@""];
    [todo setDueAt:[[NSDate alloc] initWithTimeIntervalSinceNow:86400.0]];
    [todo setDone:FALSE];
    return [todo autorelease];
}

- (void) deleteTodo:(id<ITodo>)todo {
    [logger debug:@"deleteTodo: %@", todo];
}


@end
