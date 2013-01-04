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

- (Todolist*) getTodolist {
    return todolist;
}

- (Todolist*) loadTodolist {
    [logger debug:@"loadTodolist"];
    serverAccess = [[ServerAccess alloc] init];
    
    // any complex datatype value can be used as a boolean expression
    if (todolist == NULL) {
        [logger debug:@"loadTodolist: list has not been loaded yet."];
        todolist = [serverAccess loadTodos];
        [logger debug:@"loadTodolist: list is: %@", todolist];
    } else {
        [logger debug:@"loadTodolist: list has been loaded and will update."];
        Todolist* newTodolist = [serverAccess loadTodosSince:timestamp];
        [self mergeTodolists:newTodolist];
    }
    timestamp = [NSDate date];

    return todolist;
}
             
- (void) mergeTodolists:(Todolist*) newTodolist {
    id<ITodo> newTodo;
    id<ITodo> oldTodo;
    BOOL isNew;
    for (int i=0; i<[newTodolist countTodos]; i++) {
        isNew = TRUE;
        newTodo = [todolist todoAtPosition:i];
        for (int j=0; j<[todolist countTodos]; j++) {
            oldTodo = [todolist todoAtPosition:j];
            if ([newTodo ID] == [oldTodo ID]) {
                // update old todo in todolist
                if ([[oldTodo modifiedAt] compare:timestamp] == NSOrderedAscending) {
                    // old todo < timestamp --> todo was not changed
                    [todolist deleteTodo:oldTodo];
                    [todolist addTodo:newTodo];
                } else {
                    // old todo was changed
                    NSMutableString *message = [NSMutableString stringWithString:@"There is a conflict with your todo '"];
                    [message appendString:[oldTodo name]];
                    [message appendString:@"'. Which todo would you like to use?"];
                    [self showError:message];
                    if (!wasDiscarded) {
                        [todolist deleteTodo:oldTodo];
                        [todolist addTodo:newTodo];
                    }
                }
                isNew = FALSE;
                break;
            }
        }
        if (isNew) {
            [todolist addTodo:newTodo];
        }
    }
}

- (void) showError:(NSString *) message {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                              message:message
                                              delegate:self
                                              cancelButtonTitle:@"Own"
                                              otherButtonTitles:@"From Server", nil];
    [alert show];
    [alert release];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        wasDiscarded = YES;
    } else if (buttonIndex == 1) {
        wasDiscarded = NO;
    }
}

- (id<ITodo>) createTodoForName:(NSString*)name {
    id<ITodo> todo = [[Todo alloc] init];
    [todo setName:name];
    [todo setPlace:@""];
    [todo setPlacemark:NULL];
    [todo setRadius:0];
    [todo setDetails:@""];
    [todo setDueAt:[[NSDate alloc] initWithTimeIntervalSinceNow:86400.0]];
    [todo setDone:FALSE];
    return [todo autorelease];
}

- (void) deleteTodo:(id<ITodo>)todo {
    [logger debug:@"deleteTodo: %@", todo];
}


@end
