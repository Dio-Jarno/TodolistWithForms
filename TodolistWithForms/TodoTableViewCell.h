//
//  TodoTableViewCell.h
//  TodolistWithForms
//
//  Created by Jörn Kreutel on 20.04.12.
//  Copyright (c) 2012 de.fhb.mobile. All rights reserved.
//

#import "GenericRespondingTableView.h"
#import "ITodo.h"
#import "TodolistViewController.h"

@interface TodoTableViewCell : GenericRespondingUITableViewCell

@property (nonatomic, retain) id<ITodo> todo;

@property (nonatomic, retain) id<ITodoActionsDelegate> actionsDelegate;

- (void) doLayout;

@end
