//
//  TLAppDelegate.h
//  TodolistWithForms
//
//  Created by Jörn Kreutel on 17.04.12.
//  Copyright (c) 2012 de.fhb.mobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ITodolistBackendAccessor.h"

@interface TodolistAppDelegate : UIResponder <UIApplicationDelegate>

@property (nonatomic, retain) UIWindow *window;

@property (nonatomic, retain) id<ITodolistBackendAccessor> backendAccessor;

- (void) initialiseBackendAccessor;

- (void) prepareRootViewController;

@end
