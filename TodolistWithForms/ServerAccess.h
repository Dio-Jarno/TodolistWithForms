//
//  ServerAccess.h
//  TodolistWithForms
//
//  Created by Arvid on 03.07.12.
//  Copyright (c) 2012 de.fhb.mobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ITodo.h"
#import "Todolist.h"

@interface ServerAccess : NSObject

@property (nonatomic, retain) NSString* url;

- (Todolist*) loadTodos;

- (int) addTodo:(id <ITodo>) todo;

- (void) updateTodo:(id <ITodo>) todo;

- (void) deleteTodo:(id <ITodo>) todo;

@end
