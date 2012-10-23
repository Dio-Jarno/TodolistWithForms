//
//  UITableViewResponder.m
//  TodolistWithForms
//
//  Created by Jörn Kreutel on 20.04.12.
//  Copyright (c) 2012 de.fhb.mobile. All rights reserved.
//

#import "GenericRespondingTableView.h"
#import "Logger.h"

// we use this class to show how custom classes can be used for interface builder components
@implementation GenericRespondingUITableView

// this is not necessary
- (BOOL)canBecomeFirstResponder {
    return YES;
}

@end

// we need to declare the the cell may become first responder to an event
@implementation GenericRespondingUITableViewCell

// class attribute
static Logger* logger;

// static initialiser
+ (void)initialize {
    logger = [[Logger alloc] initForClass:[GenericRespondingUITableViewCell
                                           class]];    
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

@end
