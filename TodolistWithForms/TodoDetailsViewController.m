//
//  TodolDetailsViewController.m
//  TodolistWithForms
//
//  Created by Jörn Kreutel on 17.04.12.
//  Copyright (c) 2012 de.fhb.mobile. All rights reserved.
//

#import "TodoDetailsViewController.h"
#import "Logger.h"

@implementation TodoDetailsViewController

@synthesize todo, editable, editButton, doneButton, actionsDelegate, todolist, mapViewController;

// class attribute
static Logger* logger;

// static initialiser
+ (void)initialize {
    logger = [[Logger alloc] initForClass:[TodoDetailsViewController class]];    
}


#pragma object lifecycle
// all constructors will result in calling this one here that explicitly selects the nib to be used
- (id) init {
    [logger lifecycle:@"init"];
    return [self initWithNibName:@"TodoDetailsView" bundle:NULL];
}

- (id) initWithEditMode:(BOOL)_editable {
    [logger lifecycle:@"initWithEditMode:%i", _editable];
    [self setEditable:_editable];
    return [self init];
}

- (IBAction)hideKeyboard:(id)sender {
    [sender resignFirstResponder];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    [logger lifecycle:@"initWithNibName: %@ bundle: %@", nibNameOrNil, nibBundleOrNil];
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void) dealloc {
    [logger lifecycle:@"dealloc"];
    [todo release];
    [actionsDelegate release];
    [doneSwitch release];
    [super dealloc];
}

#pragma inherited

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma inherited: view lifecycle

 // Implement loadView to create a view hierarchy programmatically, without using a nib.
 /*- (void)loadView {
 }*/
 
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    MKPlacemark* placemark = [mapViewController placemark];
    if (placemark != NULL) {
        [logger debug:@"MapView closed and new location has been set."];
        if ([placemark locality] != NULL && ![[placemark locality] isEqual:@""]) {
            [placeField setText:[placemark locality]];
        } else if ([placemark subLocality] != NULL && ![[placemark subLocality] isEqual:@""]) {
            [placeField setText:[placemark subLocality]];
        }
        [self saveTodo];
    }
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [logger lifecycle:@"viewDidLoad. todo is: %@", todo];
    [super viewDidLoad];
    
    // set myself as delegate for being notified about input events
    [nameField setDelegate:self];
    [placeField setDelegate:self];
    //[detailsView setDelegate:self];
    
    // populate the view elements with data
    [self loadData];
    
    // control enablement
    [nameField setEnabled:editable];
    [placeField setEnabled:editable];
    [detailsView setEditable:editable];
    [dueAtLabelButton setEnabled:editable];
    
    editButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(toggleEditMode)];
    doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(toggleEditMode)];
    
    if (editable) {
        self.navigationItem.rightBarButtonItem = doneButton;
    } else {
        self.navigationItem.rightBarButtonItem = editButton;
    }
}

- (void) loadData {
    [[self navigationItem] setTitle:@"Details"];
    if ([[todo name] isEqualToString:@" "]) {
        [nameField setText:@""];
    } else {
        [nameField setText:[todo name]];
    }
    [placeField setText:[todo place]];
    [detailsView setText:[todo details]];
    [self displayDueAtLabelButton];
    [doneSwitch setOn:[todo done]];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void) viewWillDisappear:(BOOL)animated {
    [self saveTodo];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

// edit the date
- (IBAction) editDate: (id) sender {    
    [logger debug:@"editDate"];
    
    GenericDatePickerViewController* datePicker = [[GenericDatePickerViewController alloc] initWithNibName:@"TodoDetailsDatePickerView" andDate:[todo dueAt]];
    [datePicker setActionsDelegate:self];
    [datePicker setValidationDelegate:self];
    
    //datePicker.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    //[self presentViewController:datePicker animated:YES completion:nil];
    [self.view addSubview:[datePicker view]];
}

// reopen / markasdone
- (IBAction)toggleDone:(id)sender {
    [logger debug:@"toggleDone"];
    [todo setDone:![todo done]];
    [self saveTodo];
}

- (IBAction)showMap:(id)sender {
    if (![[placeField text] isEqual:@""]) {
        if ([[self todo] placemark] != NULL) {
            mapViewController = [[MapViewController alloc] initWithPlacemark:[[self todo] placemark]];
        } else {
            mapViewController = [[MapViewController alloc] initWithLocation:[placeField text]];
        }
    } else {
        mapViewController = [[MapViewController alloc] initWithUserLocation];
    }
    [[self navigationController] pushViewController:mapViewController animated:YES];
}

- (IBAction)swipeBack:(UISwipeGestureRecognizer *) sender {
    [logger info:@"Swipe right done."];
    [[self navigationController] popViewControllerAnimated:TRUE];
}

- (IBAction)swipeToPreviousTodo:(UISwipeGestureRecognizer *) sender {
    [logger info:@"Swipe down done."];
    [UIView animateWithDuration:0.4
            animations:^{self.view.frame = CGRectMake(0, self.view.frame.origin.y + self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height);}
            completion:^(BOOL finished) {
                         self.view.frame = CGRectMake(0, 0 - self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height);
                         [self loadPreviousTodo];
                         [UIView animateWithDuration:0.4
                                 animations:^{self.view.frame = CGRectMake(0, self.view.frame.origin.y + self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height);}
                                 completion:^(BOOL finished) {
                         }];
    }];
}

- (IBAction)swipeToNextTodo:(UISwipeGestureRecognizer *) sender {
    [logger info:@"Swipe up done."];
    [UIView animateWithDuration:0.4
            animations:^{self.view.frame = CGRectMake(0, self.view.frame.origin.y - self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height);}
            completion:^(BOOL finished) {
                         self.view.frame = CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height);
                         [self loadNextTodo];
                         [UIView animateWithDuration:0.4
                                 animations:^{self.view.frame = CGRectMake(0, self.view.frame.origin.y - self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height);}
                                 completion:^(BOOL finished) {
                          }];
    }];    
}

- (void)loadPreviousTodo {
    id<ITodo> newTodo;
    if ([[self todolist] todoIndex:todo] > 0) {
        newTodo = [[self todolist]todoAtPosition:[[self todolist] todoIndex:todo] - 1];
    } else {
        newTodo = [[self todolist]todoAtPosition:[[self todolist] countTodos] - 1];
    }
    [self setTodo:newTodo];
    [self loadData];
}

- (void)loadNextTodo {
    id<ITodo> newTodo;
    if ([[self todolist] todoIndex:todo] < [[self todolist] countTodos] - 1) {
        newTodo = [[self todolist]todoAtPosition:[[self todolist] todoIndex:todo] + 1];
    } else {
        newTodo = [[self todolist]todoAtPosition:0];
    }
    [self setTodo:newTodo];
    [self loadData];
}

#pragma methods used by the actions
- (void)toggleEditMode {
    [logger debug:@"toggleEditMode"];
    
    editable = !editable;
    
    [nameField setEnabled:editable];
    [placeField setEnabled:editable];
    [detailsView setEditable:editable];
    [dueAtLabelButton setEnabled:editable];
    
    if (editable) {
        self.navigationItem.rightBarButtonItem = doneButton;
    } else {
        self.navigationItem.rightBarButtonItem = editButton;
    }
}

- (void) saveTodo {
    [todo setName:[nameField text]];
    if ([[todo name] isEqualToString:@""]) {
        [todo setName:@" "];
    }
    [todo setPlace:[placeField text]];
    if ([mapViewController placemark] != NULL) {
        [todo setPlacemark:[mapViewController placemark]];
    }
    [todo setDetails:[detailsView text]];
    
    // dueAt
    //[todo setDueAt:[detailsView text]];
    [actionsDelegate saveTodo:todo];
}

#pragma update ui element content
- (void) displayDueAtLabelButton {
    [dueAtLabelButton setTitle:[todo dueAtStringWithFormat:@"MM/dd/yyyy hh:mm"] forState:UIControlStateNormal];
}

#pragma UITextFieldDelegate implementation
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [logger lifecycle:@"textFieldDidBeginEditing: %@", textField];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [logger lifecycle:@"textFieldDidEndEditing: %@", textField];    
    
    if (textField == nameField) {
        [todo setName:[textField text]];
        //[[self navigationItem] setTitle:[todo name]];
    } else if (textField == placeField) {
        [todo setPlacemark:[mapViewController placemark]];
    }
}

#pragma GenericDatePickerActionsDelegate implementation
- (void) useSelectedDate:(NSDate*)date fromView:(UIPageViewController*)view {
    [todo setDueAt:date];
    [self displayDueAtLabelButton];
    [[view view] removeFromSuperview];
}

- (void) cancelDateSelectionInView:(UIPageViewController*)view {
    [[view view] removeFromSuperview];
}

#pragma GenericDatePickerValidator implementation
- (NSString*) validateSelectedDate:(NSDate*)date {
	if ([[[[NSDate alloc] initWithTimeIntervalSinceNow:0.0] autorelease]compare:date] == NSOrderedDescending) {
        return @"You must select a date in the future!";
    }
    return NULL;
}


@end
