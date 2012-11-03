//
//  TodolistViewController.m
//  TodolistWithForms
//
//  Created by Jörn Kreutel on 18.04.12.
//  Copyright (c) 2012 de.fhb.mobile. All rights reserved.
//

#import "TodolistViewController.h"
#import "TodolistAppDelegate.h"
#import "TodoDetailsViewController.h"
#import "ITodo.h"
#import "TodoTableViewCell.h"
#import <AudioToolbox/AudioToolbox.h>

@implementation TodolistViewController

@synthesize todolist;

// class attribute
static Logger* logger;

// static initialiser
+ (void)initialize {
    logger = [[Logger alloc] initForClass:[TodolistViewController class]];
}

#pragma object lifecycle
// alse here all constructor calls will be directed to the one without arguments
- (id) init {
    [logger lifecycle:@"init"];
    self = [super initWithNibName:@"TodolistView" bundle:NULL];
    serverAccess = [[ServerAccess alloc] init];
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    [logger lifecycle:@"initWithNibName: %@ bundle: %@", nibNameOrNil, nibBundleOrNil];
    return [self init];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    [logger lifecycle:@"initWithCoder: %@", aDecoder];
    return [self init];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void) dealloc {
    [todolist release];
    [deleteButton release];
    [dragCell release];
    [super dealloc];
}

#pragma view lifecycle methods

/*
 // Implement loadView to create a view hierarchy programmatically, without using a nib.
 - (void)loadView
 {
 }
 */

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [logger lifecycle:@"viewDidLoad"];
    [super viewDidLoad];
    dndOngoing = false;
    longPressBegan = false;
    dragCellColor = [dragCell backgroundColor];
    [dragCellColor retain];
    cellY = 0.0f;
    [logger debug:@"initialised todolist %@. TableView is: %@", todolist, tableView];
    
    // set the callbacks on the ui elements
    [tableView setDelegate:self];
    [tableView setDataSource:self];
    
    [logger lifecycle:@"initialiseViewOnAppearance"];
    
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.distanceFilter = kCLDistanceFilterNone; // whenever we move
    locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters; // 100 m
    locationManager.pausesLocationUpdatesAutomatically = NO;
    [self startGPS];
    
    // set the activity indicator
    if (!activityIndicator) {
        activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [activityIndicator setColor:[UIColor darkGrayColor]];
    }
    activityIndicator.center = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/3);
    [self.view addSubview:activityIndicator];
    
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd  target:self action:@selector(createTodo:)];
    self.navigationItem.rightBarButtonItem = addButton;
    
    // start an asynchronous thread for loading the todolist
    [NSThread detachNewThreadSelector:@selector(asyncLoadTodolist) toTarget:self withObject:NULL];
}

- (void)viewDidUnload {
    [deleteButton release];
    deleteButton = nil;
    [dragCell release];
    dragCell = nil;
    [dragCellColor release];
    dragCellColor = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    [logger lifecycle:@"viewWillAppear"];
    [logger debug:@"todolist is: %@", todolist];
    [super viewWillAppear:animated];
    [[self navigationItem] setTitle:@"Todos"];
    if (todolist) {
        [self refreshTodolist];
    }
    [dragCell setHidden:YES];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma custom methods for initialising / refreshing the views
- (void) asyncLoadTodolist {
    [activityIndicator startAnimating];
    [logger debug:@"asyncLoadTodolist"];
    [NSThread sleepForTimeInterval:1.5];
    Todolist* _todolist = [[[(TodolistAppDelegate*)[[UIApplication sharedApplication] delegate] backendAccessor] loadTodolist] retain];    
    [self setTodolist:_todolist];
    [logger debug:@"asyncLoadTodolist: done. stop animation and refresh todolist"];
    [self refreshTodolist];
}

- (void)refreshTodolist {
    [logger debug:@"refreshTodolist"];
    [todolist sortUsingSelector:@selector(compareForDueAt:)];
    [activityIndicator stopAnimating];
    [tableView reloadData];
}

#pragma UITableViewDelegate / UITableViewDataSource implementation
// determine the list size
- (NSInteger)tableView:(UITableView *)_tableView numberOfRowsInSection:(NSInteger)section {
    [logger debug:@"tableView: %@ numberOfRowsInSection: %@", _tableView, section]; 
    
    // check whether the todolist has been loaded already
    if (todolist) {    
        // Return the number of rows in the section.
        return [todolist countTodos] - (dndOngoing ? 1 : 0);
    }
    return 0;
}

// create a single table cell
- (UITableViewCell *)tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    [logger debug:@"cellForRowAtIndexPath: %@", indexPath]; 
    static NSString* CellIdentifier = @"Cell";
    TodoTableViewCell* cell = [_tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [[[TodoTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }

    // add the data onto the cell
    [cell setTodo:[todolist todoAtPosition:[indexPath row]]];
    // add the delegate for callback
    [cell setActionsDelegate:self];
    // let the cell layout itself given the todo object we have passed
    [cell doLayout];

    UILongPressGestureRecognizer *recognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];    
    [cell addGestureRecognizer:recognizer];
    
    return cell;
}

// select a cell
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [logger debug:@"didSelectRowAtIndexPath: %@", indexPath]; 
    [self showDetailsForTodo:[todolist todoAtPosition:[indexPath row]] editable:false];
}

// handle a long press
- (IBAction)longPress:(UILongPressGestureRecognizer*) recognizer {
    CGPoint LongTapPoint = [recognizer locationInView:self.view];
    TodoTableViewCell* cell = NULL;
    if ([recognizer.view isKindOfClass:[TodoTableViewCell class]]) {
        cell = (TodoTableViewCell*)recognizer.view;
    }
    cellPath = [tableView indexPathForCell:cell];
    [cellPath retain];
    
    if (recognizer.state == UIGestureRecognizerStateBegan && cell) {
        [logger debug:@"LongPress began"];
        [cell becomeFirstResponder];
        wasOverDelete = false;
        longPressBegan = true;
        cellRow = cellPath.row;
        cellY = cellRow*44 + tableView.frame.origin.y -22;
        dragCell.center = CGPointMake(LongTapPoint.x, LongTapPoint.y);
        [dragCell setTodo:[cell todo]];
        [[dragCell textLabel] setText:[[cell todo] name]];
        [[dragCell textLabel] setTextColor:[[cell textLabel] textColor]];
        [[dragCell detailTextLabel] setText:[[cell todo] dueAtString]];
        [[dragCell detailTextLabel] setTextColor:[[cell detailTextLabel] textColor]];
        [cell setSelected:YES];
        [[[self navigationItem] rightBarButtonItem] setEnabled:NO];
        [deleteButton setEnabled:YES];
    } else if (recognizer.state == UIGestureRecognizerStateEnded) {
        [logger debug:@"LongPress ended"];
        [cell setSelected:NO];
        [[[self navigationItem] rightBarButtonItem] setEnabled:YES];
        [deleteButton setEnabled:NO];
        [cellPath release];
    }
}

- (IBAction)handlePan:(UIPanGestureRecognizer *) sender {
    UIImage* deleteButtonImage;
    if (longPressBegan) {
        if (sender.state == UIGestureRecognizerStateBegan) {
            if (cellPath != nil && cellRow >= 0) {
                [logger debug:@"Cell number %i selected", cellRow];
                dndOngoing = true;
                [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:cellPath] withRowAnimation:UITableViewRowAnimationMiddle];
                dndOngoing = false;
            }
            [dragCell setHidden:NO];
        } else if (sender.state == UIGestureRecognizerStateEnded) {
            [logger debug:@"Pan ended"];
            longPressBegan = false;
            [deleteButton setEnabled:NO];
            [[[self navigationItem] rightBarButtonItem] setEnabled:YES];
            deleteButtonImage = [UIImage imageNamed:@"delete.png"];
            [deleteButton setImage:deleteButtonImage forState:UIControlStateNormal];
            if (wasOverDelete) {
                [self deleteTodo:[dragCell todo]];
                [dragCell setHidden:YES];
            } else {
                //wieder in Liste zurück
                [UIView animateWithDuration:0.5
                        animations:^{dragCell.frame = CGRectMake(15, cellY, 290, 44);}
                        completion:^(BOOL finished) {
                            [dragCell setHidden:YES];
                            NSArray *insertIndexPaths = [NSArray arrayWithObject:[NSIndexPath indexPathForRow:cellRow inSection:0]];
                            [tableView insertRowsAtIndexPaths:insertIndexPaths withRowAnimation:UITableViewRowAnimationMiddle];
                        }];
            }
            [dragCell setBackgroundColor:dragCellColor];
            [cellPath release];
        } else {        
            CGPoint tapPoint = [sender locationInView:self.view];
            sender.view.center = CGPointMake(tapPoint.x, tapPoint.y);
            if ([self hasChangedPosition:&tapPoint]) {
                if (wasOverDelete) {
                    [logger debug:@"Cell entered into delete button"];
                    deleteButtonImage = [UIImage imageNamed:@"delete_over.png"];
                    [deleteButton setImage:deleteButtonImage forState:UIControlStateNormal];
                    [dragCell setBackgroundColor:[UIColor colorWithRed:1 green:0 blue:0 alpha:0.3]];
                } else {
                    [logger debug:@"Cell leaved delete button"];
                    deleteButtonImage = [UIImage imageNamed:@"delete.png"];
                    [deleteButton setImage:deleteButtonImage forState:UIControlStateNormal];
                    [dragCell setBackgroundColor:dragCellColor];
                }
            }
        }
    }
}

- (BOOL)isOverDeleteButton:(CGPoint*)tapPoint {
    if (deleteButton.frame.origin.x < tapPoint->x &&
        deleteButton.frame.origin.x + 50 > tapPoint->x &&
        deleteButton.frame.origin.y < tapPoint->y &&
        deleteButton.frame.origin.y + 50 > tapPoint->y) {
        return true;
    } else {
        return false;
    } 
}

- (BOOL)hasChangedPosition:(CGPoint*)tapPoint {
    BOOL isOverDelete = [self isOverDeleteButton:tapPoint];
    if (isOverDelete != wasOverDelete) {
        wasOverDelete = isOverDelete;
        return true;
    } else {
        return false;
    }
}

#pragma action
- (IBAction)hideKeyboard:(id)sender {
    [sender resignFirstResponder];
}

- (IBAction) createTodo: (id) sender {
    [logger debug:@"createTodo"];
    id<ITodo> todo = [[(TodolistAppDelegate*)[[UIApplication sharedApplication] delegate] backendAccessor] createTodoForName:[newTodoField text]];
    if ([[todo name] isEqualToString:@""]) {
        [todo setName:@" "];
    }
    int ID = [serverAccess addTodo:todo];
    if (ID > 0) {
        [todo setID:ID];
        [todolist addTodo:todo];
        [self showDetailsForTodo:todo editable:true];
    } else {
        [todolist deleteTodo:todo];
    }
}

#pragma custom method for action handling
- (void)showDetailsForTodo:(id<ITodo>)todo editable:(BOOL)editable {
    TodoDetailsViewController* detailsVC = [[[TodoDetailsViewController alloc] initWithEditMode:editable] autorelease];
    [detailsVC setTodo:todo];
    [detailsVC setActionsDelegate:self];
    [logger debug:[NSString stringWithFormat:@"pushing details view controller %@ onto navigation controller: %@", detailsVC, [self navigationController]]];
    [detailsVC setTodolist:[self todolist]];
    [[self navigationController] pushViewController:detailsVC animated:YES];
}

#pragma TodoActionsDelegate implementation
- (void) saveTodo:(id<ITodo>)todo {
    [logger debug:@"saveTodo: %@", todo];
    [serverAccess updateTodo:todo];
}

- (void) deleteTodo:(id<ITodo>)todo {
    [logger debug:@"deleteTodo: %@", todo];
    [[(TodolistAppDelegate*)[[UIApplication sharedApplication] delegate] backendAccessor] deleteTodo:todo];
    [todolist deleteTodo:todo];
    [serverAccess deleteTodo:todo];
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    [self refreshTodolist];
}

- (void) editTodo:(id<ITodo>)todo {
    [logger debug:@"editTodo: %@", todo];    
    [self showDetailsForTodo:todo editable:true];
}

// check whether GPS is enabled
- (BOOL) isGPSEnabled {
    if (! ([CLLocationManager locationServicesEnabled]) || ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied)) {
        return NO;
    }
    return YES;
}

// function to start capture GPS, we check settings first to see if GPS is disabled before attempting to get GPS
- (void) startGPS {
    if([self isGPSEnabled]) {
        // Location Services is not disabled, get it now
        [locationManager startUpdatingLocation];
    } else {
        // Location Services is disabled, do sth here to tell user to enable it
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Information"
                                                  message:@"Please enable the location service for hole functionality."
                                                  delegate:nil
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    CLLocation *location = [locations lastObject];
    float latitude = location.coordinate.latitude;
    float longitude = location.coordinate.longitude;
    
    [logger info:@"GPS data - latitude: %i longitude: %i", latitude, longitude];
    //if ((newLocation.coordinate.latitude != oldLocation.coordinate.latitude) && newLocation.coordinate.longitude != oldLocation.coordinate.longitude) {
    [logger info:@"location has changed"];
    for (int i=0; i<[[self todolist] countTodos]; i++) {
        id<ITodo> _todo = [[self todolist] todoAtPosition:i];
        MKPlacemark* placemark = [_todo placemark];
        if (placemark != NULL) {
            CLLocationDistance distance = [location distanceFromLocation:[placemark location]];
            if (distance < 1000.0) {
                [logger info:@"there is a todo in the vicinity"];
                if (![_todo done] && ![_todo notification]) {
                    [self scheduleNotification:_todo];
                }
            }
        }
    }
    //}
}

/*- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    int latitude = newLocation.coordinate.latitude;
    int longitude = newLocation.coordinate.longitude;
    [logger info:@"GPS data - latitude: %i longitude: %i", latitude, longitude];
    //if ((newLocation.coordinate.latitude != oldLocation.coordinate.latitude) && newLocation.coordinate.longitude != oldLocation.coordinate.longitude) {
        [logger info:@"location has changed"];
        for (int i=0; i<[[self todolist] countTodos]; i++) {
            id<ITodo> _todo = [[self todolist] todoAtPosition:i];
            MKPlacemark* placemark = [_todo placemark];
            CLLocationDistance distance = [newLocation distanceFromLocation:[placemark location]];
            if (distance < 1000.0) {
                [logger info:@"there is a todo in the vicinity"];
                if (![_todo done] && ![_todo notification]) {
                    [self scheduleNotification:_todo];
                }
            }
        }
    //}
}*/

- (void)scheduleNotification:(id<ITodo>)todo {
    [logger info:@"create notification for todo with id %d", [todo ID]];
    //[[UIApplication sharedApplication] cancelAllLocalNotifications];
    
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    
    NSMutableString *message = [NSMutableString stringWithString:@"The todo '"];
    [message appendString:[todo name]];
    [message appendString:@"' is in your vicinity."];
    notification.alertBody = message;
    notification.alertAction = @"Show me";
    notification.soundName = UILocalNotificationDefaultSoundName;
    notification.applicationIconBadgeNumber += 1;
    
    NSDictionary *userDict = [NSDictionary dictionaryWithObject:[todo name] forKey:@"todoName"];
    notification.userInfo = userDict;
        
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    [notification release];
    
    [todo setNotification:YES];
}

@end
