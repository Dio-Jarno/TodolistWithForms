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

UIActivityIndicatorView *activityIndicator;
dispatch_group_t group;

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
    [radiusField release];
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
        //[activityIndicator startAnimating];
        [NSThread detachNewThreadSelector:@selector(saveTodo) toTarget:self withObject:NULL];
    }
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [logger lifecycle:@"viewDidLoad. todo is: %@", todo];
    [super viewDidLoad];
    
    // set myself as delegate for being notified about input events
    [nameField setDelegate:self];
    [placeField setDelegate:self];
    [radiusField setDelegate:self];
    //[detailsView setDelegate:self];
    
    // populate the view elements with data
    [self loadData];
    
    // control enablement
    [nameField setEnabled:editable];
    [placeField setEnabled:editable];
    [radiusField setEnabled:editable];
    [detailsView setEditable:editable];
    [dueAtLabelButton setEnabled:editable];
    
    editButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(startEditMode)];
    doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(finishEditMode)];
    
    if (editable) {
        self.navigationItem.rightBarButtonItem = doneButton;
    } else {
        self.navigationItem.rightBarButtonItem = editButton;
    }
    
    activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [activityIndicator setColor:[UIColor blackColor]];

    activityIndicator.center = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/3);
    [self.view addSubview:activityIndicator];
}

- (void) loadData {
    [[self navigationItem] setTitle:@"Details"];
    if ([[todo name] isEqualToString:@" "]) {
        [nameField setText:@""];
    } else {
        [nameField setText:[todo name]];
    }
    [placeField setText:[todo place]];
    [radiusField setText:[NSString stringWithFormat:@"%d",[todo radius]]];
    [detailsView setText:[todo details]];
    [self displayDueAtLabelButton];
    [doneSwitch setOn:[todo done]];
}

- (void)viewDidUnload {
    [radiusField release];
    radiusField = nil;
    [super viewDidUnload];
    [logger lifecycle:@"viewDidUnload. todo is: %@", todo];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void) viewWillDisappear:(BOOL)animated {
    [logger lifecycle:@"viewWillDisappear. todo is: %@", todo];
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
    [activityIndicator startAnimating];
    [NSThread detachNewThreadSelector:@selector(saveTodo) toTarget:self withObject:NULL];
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
    if (!editable) {
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
}

- (IBAction)swipeToNextTodo:(UISwipeGestureRecognizer *) sender {
    [logger info:@"Swipe up done."];
    if (!editable) {
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


- (void) startEditMode {
    [self changeEditable:(YES)];
    [[self todo] setChanged:YES];
    //editable = YES;
    //[nameField setEnabled:YES];
    //[placeField setEnabled:YES];
    //[radiusField setEnabled:YES];
    //[detailsView setEditable:YES];
    //[dueAtLabelButton setEnabled:YES];
    
    self.navigationItem.rightBarButtonItem = doneButton;
}

- (void) changeEditable:(BOOL) _editable {
    editable = _editable;
    [nameField setEnabled:_editable];
    [placeField setEnabled:_editable];
    [radiusField setEnabled:_editable];
    [detailsView setEditable:_editable];
    [dueAtLabelButton setEnabled:_editable];
}

- (void) finishEditMode {
    NSString* location = [placeField text];
    if (location != NULL && ![location isEqual:@""] && ![location isEqual:[[self todo] place]]) {
        [logger info:@"save text of place field as placemark"];
        CLGeocoder* geocoder = [[CLGeocoder alloc] init];
        [geocoder geocodeAddressString:location
                     completionHandler:^(NSArray* placemarks, NSError* error) {
                         if (placemarks && placemarks.count > 0) {
                             CLPlacemark *topResult = [placemarks objectAtIndex:0];
                             MKPlacemark *newPlacemark = [[MKPlacemark alloc] initWithPlacemark:topResult];
                             [[self todo] setPlacemark:newPlacemark];
                         }
                     }
         ];
    }
    if ([location isEqual:@""]) {
        [[self todo] setPlacemark:NULL];
    }
    //group = dispatch_group_create();
    //[activityIndicator startAnimating];
    //dispatch_group_enter(group);
    [NSThread detachNewThreadSelector:@selector(saveTodo) toTarget:self withObject:nil];
    //while (dispatch_group_wait(group, DISPATCH_TIME_NOW)) {
    //    [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:1.f]];
    //}
    //dispatch_release(group);
    
    //if (successful) {
        [self changeEditable:(NO)];
        //editable = NO;
        //[nameField setEnabled:NO];
        //[placeField setEnabled:NO];
        //[radiusField setEnabled:NO];
        //[detailsView setEditable:NO];
        //[dueAtLabelButton setEnabled:NO];
        
        self.navigationItem.rightBarButtonItem = editButton;
    //}
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
    if (![[radiusField text] isEqualToString:@""]) {
        [todo setRadius:[[radiusField text] intValue]];
    }
    [todo setDetails:[detailsView text]];
    [todo setModifiedAt:[NSDate date]];
    
    [actionsDelegate saveTodo:todo];

    //[activityIndicator stopAnimating];
    //dispatch_group_leave(group);
}

- (void) showError:(NSString *) message {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                              message:message
                                              delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    [alert show];
    [alert release];
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
