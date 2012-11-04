//
//  TodolDetailsViewController.h
//  TodolistWithForms
//
//  Created by Jörn Kreutel on 17.04.12.
//  Copyright (c) 2012 de.fhb.mobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ITodo.h"
#import "TodolistViewController.h"
#import "GenericDatePickerViewController.h"
#import "MapViewController.h"

@interface TodoDetailsViewController : UIViewController <UITextFieldDelegate, IGenericDatePickerActionsDelegate, IGenericDatePickerValidationDelegate
> {
    
    IBOutlet UITextField* nameField;
    IBOutlet UITextField* placeField;
    IBOutlet UIButton* placeDetailsButton;
    IBOutlet UITextView* detailsView;
    IBOutlet UIButton* dueAtLabelButton;
    IBOutlet UISwitch *doneSwitch;
}

@property (nonatomic, retain) id<ITodo> todo;

@property (nonatomic) BOOL editable;

@property (nonatomic) BOOL successful;

@property (nonatomic, retain) UIBarButtonItem *editButton;
@property (nonatomic, retain) UIBarButtonItem *doneButton;

@property (nonatomic, retain) id<ITodoActionsDelegate> actionsDelegate;

@property (nonatomic, retain) Todolist* todolist;

@property (nonatomic, retain) MapViewController* mapViewController;

- (id) initWithEditMode:(BOOL)editable;

- (IBAction) hideKeyboard:(id)sender;

- (IBAction) editDate: (id) sender; 

- (IBAction) toggleDone: (id) sender;

- (IBAction) showMap:(id) sender;

- (IBAction) swipeBack:(UISwipeGestureRecognizer *)sender;

- (IBAction) swipeToPreviousTodo:(UISwipeGestureRecognizer *)sender;

- (IBAction) swipeToNextTodo:(UISwipeGestureRecognizer *)sender;

- (void) displayDueAtLabelButton;

- (void) saveTodo;

- (void) toggleEditMode;

- (void) loadPreviousTodo;

- (void) loadNextTodo;

@end
