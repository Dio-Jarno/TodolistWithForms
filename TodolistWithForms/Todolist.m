//
//  Todolist.m
//  Todolist
//
//  Created by Jörn Kreutel on 10.04.12.
//  Copyright (c) 2012 de.fhb.mobile. All rights reserved.
//

#import "Todolist.h"
#import "Todo.h"
#import "Logger.h"

@implementation Todolist


// class attribute
static Logger* logger;

// static initialiser
+ (void)initialize {
    logger = [[Logger alloc] initForClass:[Todolist
                                           class]];    
}

#pragma object lifecycle
- (id) init {
    self = [super init];
    todos = [[[NSMutableArray alloc] init] retain];
    return self;    
}

- (void) dealloc {
    [todos release];
    [super dealloc];
}

#pragma content access
- (Todolist*) addTodo:(id<ITodo>)todo {
    [todos addObject:todo];
    return self;
}

- (Todolist*) deleteTodo:(id<ITodo>)todo {
    [todos removeObject:todo];
    return self;
}

- (int) countTodos {
    return [todos count];
}

- (id<ITodo>) todoAtPosition:(int)pos {
    return [todos objectAtIndex:pos];
}

- (int) todoIndex:(id<ITodo>)todo {
    return [todos indexOfObject:todo];
}

#pragma further instance methods
- (NSString*) description {
    return [NSString stringWithFormat:@"{%@ %@}", [super description], todos];
}

- (void) sortUsingSelector:(SEL)selector {
    [logger debug:@"sorting..."];
    [todos sortUsingSelector:selector];
}

/*
#pragma test instance
+ (Todolist*) createTestdata {    
    return [[[[[[[[Todolist alloc] init] addTodo:[[Todo alloc] initForName:@"Todo 1.1" andPlacemark:NULL andDetails:@"Do something" andDueAtString:@"04-06-2012"]] addTodo:[[Todo alloc] initForName:@"Todo 1.2" andPlacemark:NULL andDetails:@"Continue doing something" andDueAtString:@"05-07-2012"]] addTodo:[[Todo alloc] initForName:@"Todo 1.3" andPlacemark:NULL andDetails:@"Do something more" andDueAtString:@"05-07-2012"]] addTodo:[[Todo alloc] initForName:@"Todo 2.1" andPlacemark:NULL andDetails:@"Do something" andDueAtString:@"06-07-2012"]] addTodo:[[Todo alloc] initForName:@"Todo 2.2" andPlacemark:NULL andDetails:@"Continue doing something" andDueAtString:@"12-07-2012"]] addTodo:[[Todo alloc] initForName:@"Todo 2.3" andPlacemark:NULL andDetails:@"Do something more" andDueAtString:@"31-10-2012"]];
}*/


@end
