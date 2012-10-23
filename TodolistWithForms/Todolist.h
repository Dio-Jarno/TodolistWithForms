//
//  Todolist.h
//  Todolist
//
//  Created by Jörn Kreutel on 10.04.12.
//  Copyright (c) 2012 de.fhb.mobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ITodo.h"

@interface Todolist : NSObject {
    
@private NSMutableArray* todos;
    
}

- (void) sortUsingSelector:(SEL)selector;

- (Todolist*) addTodo:(id<ITodo>)todo;

- (Todolist*) deleteTodo:(id<ITodo>)todo;

- (int) countTodos;

- (id<ITodo>) todoAtPosition:(int)pos;

- (int) todoIndex:(id<ITodo>)todo;

+ (Todolist*) createTestdata;

@end
