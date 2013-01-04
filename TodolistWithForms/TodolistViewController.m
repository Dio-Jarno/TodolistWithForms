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
    deletedTodosSet = [[NSMutableSet alloc] init];
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
    
    //[[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    
    // set the activity indicator
    if (!activityIndicator) {
        activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [activityIndicator setColor:[UIColor blackColor]];
    }
    activityIndicator.center = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/3);
    [self.view addSubview:activityIndicator];
    
    UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh  target:self action:@selector(synchronize)];
    self.navigationItem.leftBarButtonItem = refreshButton;
    
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd  target:self action:@selector(createTodo:)];
    self.navigationItem.rightBarButtonItem = addButton;
    
    // loading the todolist
    [NSThread detachNewThreadSelector:@selector(asyncLoadTodolist) toTarget:self withObject:nil];
    //[self asyncLoadTodolist];
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

- (void) syncTodos {
    [NSThread detachNewThreadSelector:@selector(asyncLoadTodolist) toTarget:self withObject:nil];
}

#pragma custom methods for initialising / refreshing the views
- (void) asyncLoadTodolist {
    [activityIndicator startAnimating];
    Todolist* _todolist = [[[(TodolistAppDelegate*)[[UIApplication sharedApplication] delegate] backendAccessor] loadTodolist] retain];
    [activityIndicator stopAnimating];
    if (_todolist != NULL) {
        [logger debug:@":done"];
        [self setTodolist:_todolist];
        [self refreshTodolist];
    } else {
        [self showError:@"Could not load todos from the internet. Do you want to try again?"];
    }
}

- (void)refreshTodolist {
    [logger debug:@"refreshTodolist"];
    [todolist sortUsingSelector:@selector(compareForDueAt:)];
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
                // delete todo
                AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
                [self deleteTodo:[dragCell todo]];
                [UIView animateWithDuration:0.4
                        animations:^{dragCell.frame = CGRectMake(deleteButton.frame.origin.x + 25, deleteButton.frame.origin.y + 10, 0, 0);}
                        completion:^(BOOL finished) {[dragCell setHidden:YES];}
                 ];
            } else {
                // back in list
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
    [todolist addTodo:todo];
    int ID = [serverAccess addTodo:todo];
    if (ID > 0) {
        [todo setID:ID];
    } else {
        int IDTemp = -1;
        id<ITodo> todoTemp;
        for (int i=0; i<[todolist countTodos]; i++) {
            todoTemp = [todolist todoAtPosition:i];
            if ([todoTemp ID] < 0) {
                if ([todoTemp ID] == IDTemp) {
                    IDTemp--;
                } else {
                    break;
                }
            }
        }
        [todo setID:IDTemp];
        NSMutableString *message = [NSMutableString stringWithString:@"Could not save todo '"];
        [message appendString:[todo name]];
        [message appendString:@"'. Do you want to try again in background?"];
        [self showError:message];
    }
    [self showDetailsForTodo:todo editable:true];
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
- (BOOL) saveTodo:(id<ITodo>)todo {
    [logger debug:@"saveTodo: %@", todo];
    [activityIndicator startAnimating];
    BOOL successful = [serverAccess updateTodo:todo];
    [activityIndicator stopAnimating];
    if (successful) {
        [todo setChanged:NO];
        return TRUE;
    } else {
        NSMutableString *message = [NSMutableString stringWithString:@"Could not save todo '"];
        [message appendString:[todo name]];
        [message appendString:@"'. Do you want to try again in background?"];
        [self showError:message];
        return FALSE;
    }
}

- (BOOL) deleteTodo:(id<ITodo>)todo {
    [logger debug:@"deleteTodo: %@", todo];
    //[[(TodolistAppDelegate*)[[UIApplication sharedApplication] delegate] backendAccessor] deleteTodo:todo];
    [todolist deleteTodo:todo];
    [self refreshTodolist];
    [activityIndicator startAnimating];
    BOOL successful = [serverAccess deleteTodo:todo];
    [activityIndicator stopAnimating];
    if (successful) {
        return TRUE;
    } else {
        [deletedTodosSet addObject:todo];
        NSMutableString *message = [NSMutableString stringWithString:@"Could not delete todo '"];
        [message appendString:[todo name]];
        [message appendString:@"'. Do you want to try again in background?"];
        [self showError:message];
        return FALSE;
    }
}

- (void) editTodo:(id<ITodo>)todo {
    [logger debug:@"editTodo: %@", todo];    
    [self showDetailsForTodo:todo editable:true];
}

- (void) showError:(NSString *) message {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                              message:message
                                              delegate:self
                                              cancelButtonTitle:@"No"
                                              otherButtonTitles:@"Yes", nil];
    [alert show];
    [alert release];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        [logger error:@"YES pushed"];
        if (![self synchronize]) {
            [logger error:@"aborted synchronizing"];
            [self showError:@"Could not synchronize todos. Do you want to try again?"];
        }
    }
}

- (BOOL) synchronize {
    [logger info:@"start synchronizing..."];
    id<ITodo> todo;
    BOOL successful;
    
    // save deleted todos
    for (int i=0; i<[deletedTodosSet count]; i++) {
        [logger info:@"There are deleted todos to synchronize."];
        todo = [todolist todoAtPosition:i];
        successful = [serverAccess deleteTodo:todo];
        if (!successful) {
            return FALSE;
        }
    }
    
    // save new/updated todos
    for (int i=0; i<[todolist countTodos]; i++) {
        todo = [todolist todoAtPosition:i];
        if ([todo ID] < 0) {
            // save new todos
            [logger info:@"There are new todos to synchronize."];
            int ID = [serverAccess addTodo:todo];
            if (ID > 0) {
                [todo setID:ID];
            } else {
                return FALSE;
            }
        } else if ([todo changed]) {
            // save updated todos
            [logger info:@"There are updated todos to synchronize."];
            successful = [serverAccess updateTodo:todo];
            if (successful) {
                [todo setChanged:NO];
            } else {
                return FALSE;
            }
        }
    }
    
    // get updated todos
    
    [logger info:@"finished synchronizing"];
    return TRUE;
}


@end
