//
//  Todolist.m
//  Todolist
//
//  Created by Jörn Kreutel on 10.04.12.
//  Copyright (c) 2012 de.fhb.mobile. All rights reserved.
//

#import "Todolist.h"
#import "Todo.h"
#import "Todo2.h"

@implementation Todolist

// constructor
- (id) init {
    
    self = [super init];
    todos = [[[NSMutableArray alloc] init] retain];
    
    return self;    
}

- (Todolist*) addTodo:(id<ITodo>)todo {
    [todos addObject:todo];
    
    return self;
}

- (int) countTodos {
    return [todos count];
}


- (id<ITodo>) getTodoAtPosition:(int)pos {
    return [todos objectAtIndex:pos];
}

- (NSString*) description {
    return [NSString stringWithFormat:@"{%@ %@}", [super description], todos];
}

+ (Todolist*) createTestdata {    
    return [[[[[[[[Todolist alloc] init] addTodo:[[Todo alloc] initForName:@"Todo 1.1" andDetails:@"Do something" andDueAtString:@"01-05-2012"]] addTodo:[[Todo alloc] initForName:@"Todo 1.2" andDetails:@"Continue doing something" andDueAtString:@"02-05-2012"]] addTodo:[[Todo alloc] initForName:@"Todo 1.3" andDetails:@"Do something more" andDueAtString:@"03-05-2012"]] addTodo:[[Todo2 alloc] initForName:@"Todo 2.1" andDetails:@"Do something" andDueAtString:@"01-06-2012"]] addTodo:[[Todo2 alloc] initForName:@"Todo 2.2" andDetails:@"Continue doing something" andDueAtString:@"02-06-2012"]] addTodo:[[Todo2 alloc] initForName:@"Todo 2.3" andDetails:@"Do something more" andDueAtString:@"03-06-2012"]];
}

- (void) dealloc {
    [todos release];
    
    [super dealloc];
}


@end
