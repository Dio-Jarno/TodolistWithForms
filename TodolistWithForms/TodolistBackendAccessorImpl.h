//
//  TodolistBackendAccessorImpl.h
//  Todolist
//
//  Created by Jörn Kreutel on 10.04.12.
//  Copyright (c) 2012 de.fhb.mobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ITodolistBackendAccessor.h"
#import "Todolist.h"
#import "ServerAccess.h"

@interface TodolistBackendAccessorImpl : NSObject <ITodolistBackendAccessor> {
    
    @private Todolist* todolist;

    ServerAccess* serverAccess;
    
}

@end
