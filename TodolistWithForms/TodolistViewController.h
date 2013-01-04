//
//  TodolistViewController.h
//  TodolistWithForms
//
//  Created by Jörn Kreutel on 18.04.12.
//  Copyright (c) 2012 de.fhb.mobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Todolist.h"
#import "GenericRespondingTableView.h"
#import "ITodo.h"
#import "ServerAccess.h"

// a protocol that specifies callback actions for todo items
@protocol ITodoActionsDelegate <NSObject> 

- (BOOL) saveTodo:(id<ITodo>)todo;
- (BOOL) deleteTodo:(id<ITodo>)todo;
- (void) editTodo:(id<ITodo>)todo;

@end


@interface TodolistViewController : UIViewController <UITableViewDelegate, UITableViewDataSource,  ITodoActionsDelegate> {
    
    IBOutlet UITextField* newTodoField;
    IBOutlet UIButton* createButton;
    IBOutlet GenericRespondingUITableView* tableView;
    
    IBOutlet UITableViewCell* dragCell;
    IBOutlet UIButton* deleteButton;
    
    UIActivityIndicatorView* activityIndicator;
    UIColor* dragCellColor;

    BOOL dndOngoing;
    BOOL wasOverDelete;
    BOOL longPressBegan;
    NSIndexPath* cellPath;
    float cellY;
    NSInteger cellRow;
    
    ServerAccess* serverAccess;
    
    NSMutableSet* deletedTodosSet;
}

@property (nonatomic, retain) Todolist* todolist;

- (IBAction)hideKeyboard:(id)sender;

- (IBAction) createTodo: (id) sender; 

- (BOOL) deleteTodo:(id<ITodo>)todo;

- (IBAction)handlePan:(UIPanGestureRecognizer *)sender;

- (void)asyncLoadTodolist;

- (void)refreshTodolist;

- (void)showDetailsForTodo:(id<ITodo>)todo editable:(BOOL)editable;

- (BOOL)synchronize;

@end
