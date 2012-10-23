//
//  GenericDatePickerViewController.m
//  TodolistWithForms
//
//  Created by Jörn Kreutel on 20.04.12.
//  Copyright (c) 2012 de.fhb.mobile. All rights reserved.
//

#import "Logger.h"
#import "GenericDatePickerViewController.h"

@implementation GenericDatePickerViewController

@synthesize datePicker, actionsDelegate, validationDelegate, date;

// class attribute
static Logger* logger;

// static initialiser
+ (void)initialize {
    logger = [[Logger alloc] initForClass:[GenericDatePickerViewController
                                           class]];    
}

#pragma object lifecycle
- (id)initWithNibName:(NSString *)nibNameOrNil andDate:(NSDate*)_date 
{
    [logger lifecycle:@"initWithNibName: %@", nibNameOrNil];
    [self setDate:_date];
    
    return [super initWithNibName:nibNameOrNil bundle:NULL];
}

- (void)dealloc {
    [datePicker release];
    [actionsDelegate release];
    [validationDelegate release];
    [date release];
    [super dealloc];
}

#pragma view lifecycle
- (void)viewDidLoad {
    [logger lifecycle:@"viewDidLoad"];
    [datePicker setDate:date];
}

#pragma actions
-(IBAction) ok {
    NSString* validationError = [[self validationDelegate] validateSelectedDate:[datePicker date]];
    [logger debug:@"validationError from %@ is: %@", [self validationDelegate], validationError];
    
    if (validationError) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Date Issue" 
                                                        message:validationError 
                                                       delegate:nil 
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
    else {
    [actionsDelegate useSelectedDate:[datePicker date] fromView:self];
    }
}

-(IBAction) cancel {
    [actionsDelegate cancelDateSelectionInView:self]; 
}


@end
