//
//  GenericDatePickerViewController.h
//  TodolistWithForms
//
//  Created by Jörn Kreutel on 20.04.12.
//  Copyright (c) 2012 de.fhb.mobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GenericDatePickerViewController.h"


@protocol IGenericDatePickerValidationDelegate <NSObject> 

- (NSString*) validateSelectedDate:(NSDate*)date;

@end

@protocol IGenericDatePickerActionsDelegate <NSObject>

- (void) useSelectedDate:(NSDate*)date fromView:(UIViewController*)viewcontroller;

- (void) cancelDateSelectionInView:(UIViewController*)viewcontroller;

@end

@interface GenericDatePickerViewController : UIViewController {
    UIDatePicker *datePicker;
}

@property (nonatomic, retain) NSDate* date;

@property (nonatomic, retain) IBOutlet UIDatePicker* datePicker;

@property (nonatomic, retain) id<IGenericDatePickerActionsDelegate> actionsDelegate;

@property (nonatomic, retain) id<IGenericDatePickerValidationDelegate> validationDelegate;

- (id)initWithNibName:(NSString *)nibNameOrNil andDate:(NSDate*)_date;

-(IBAction) ok;

-(IBAction) cancel;


@end

