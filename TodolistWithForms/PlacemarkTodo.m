//
//  PlacemarkTodo.m
//  TodolistWithForms
//
//  Created by Arvid on 03.11.12.
//  Copyright (c) 2012 de.fhb.mobile. All rights reserved.
//

#import "PlacemarkTodo.h"

@implementation PlacemarkTodo

@synthesize todoIndex, strSubtitle, strTitle;

- (NSString *)subtitle {
    return self.strSubtitle;
}

- (NSString *)title {
    return self.strTitle;
}

@end
