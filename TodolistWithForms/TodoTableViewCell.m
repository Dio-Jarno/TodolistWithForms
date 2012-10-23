//
//  TodoTableViewCell.m
//  TodolistWithForms
//
//  Created by Jörn Kreutel on 20.04.12.
//  Copyright (c) 2012 de.fhb.mobile. All rights reserved.
//

#import "TodoTableViewCell.h"

@implementation TodoTableViewCell

@synthesize todo, actionsDelegate;

// class attribute
static Logger* logger;

// static initialiser
+ (void)initialize {
    logger = [[Logger alloc] initForClass:[TodoTableViewCell class]];    
}

#pragma object lifecycle
- (void) dealloc {
    [todo release];
    [actionsDelegate release];
    [super release];
    [super dealloc];
}

#pragma actions
// declare which actions we can handle
- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    //[logger debug:@"canPerformAction: %s", action];
    if (action == @selector(deleteTodo:)) {
        return YES;
    }
    else if (action == @selector(editTodo:)) {
        return YES;
    }
    
    return NO;
}

- (void)deleteTodo:(id)sender {
    [logger debug:@"delete: %@", todo];
    //[actionsDelegate deleteTodo:todo];
}

- (void)editTodo:(id)sender {
    [logger debug:@"edit: %@", todo];    
    [actionsDelegate editTodo:todo];
}

#pragma layout
- (void) doLayout {
    
    // configure the cell...
    [[self textLabel] setText:[todo name]];
    [[self detailTextLabel] setText:[todo dueAtString]];
    
    // determine the color depending on the done state of the cell
    BOOL done = [todo done];
    [self.contentView setBackgroundColor:done ? [UIColor lightGrayColor] : [UIColor whiteColor]];
    [self.textLabel setBackgroundColor:done ? [UIColor lightGrayColor] : [UIColor whiteColor]];
    [self.detailTextLabel setBackgroundColor:done ? [UIColor lightGrayColor] : [UIColor whiteColor]];
    
    // determine the text color depending on whether the todo is overdue or not
    BOOL overdue = !done && [[todo dueAt] compare:[[NSDate alloc] initWithTimeIntervalSinceNow:0.0]] == NSOrderedAscending;
    [[self textLabel] setTextColor:overdue ? [UIColor redColor] : [UIColor blackColor]];
    [[self detailTextLabel] setTextColor:overdue ? [UIColor redColor] : [UIColor blackColor]];
    
}

@end
