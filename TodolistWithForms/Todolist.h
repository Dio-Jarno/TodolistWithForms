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

- (Todolist*) addTodo:(id<ITodo>)todo;

- (int) countTodos;

- (id<ITodo>) getTodoAtPosition:(int)pos;

+ (Todolist*) createTestdata;

@end
