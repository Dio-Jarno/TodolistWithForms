//
//  PlacemarkTodo.h
//  TodolistWithForms
//
//  Created by Arvid on 03.11.12.
//  Copyright (c) 2012 de.fhb.mobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface PlacemarkTodo : MKPlacemark

@property (nonatomic) int todoIndex;
@property (nonatomic, retain) NSString *strTitle;
@property (nonatomic, retain) NSString *strSubtitle;

- (int) todoIndex;
- (NSString *)title;
- (NSString *)subtitle;

@end
