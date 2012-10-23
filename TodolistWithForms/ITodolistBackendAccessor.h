//
//  ITodolistBackendAccessor.h
//  Todolist
//
//  Created by Jörn Kreutel on 10.04.12.
//  Copyright (c) 2012 de.fhb.mobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Todolist.h"

@protocol ITodolistBackendAccessor <NSObject>

- (Todolist*) loadTodolist;

- (id<ITodo>) createTodoForName:(NSString*)name; 

- (void) deleteTodo:(id<ITodo>)todo;

@end
