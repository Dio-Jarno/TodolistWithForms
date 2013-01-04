//
//  ServerAccess.m
//  TodolistWithForms
//
//  Created by Arvid on 03.07.12.
//  Copyright (c) 2012 de.fhb.mobile. All rights reserved.
//

#import "ServerAccess.h"
#import "Logger.h"
#import "JSON.h"
#import "Todolist.h"
#import "Todo.h"

@implementation ServerAccess

@synthesize url;

static Logger* logger;

+ (void) initialize {
    logger = [[Logger alloc] initForClass:[ServerAccess class]];    
}

- (id) init {
    url = @"http://arvids-macbook-air.local:8080/TodoApp/index?";
    [logger debug:@"ServerAccess initialized with url: %@", url];
    return self;
}

- (Todolist*) loadTodos {
    return [self loadTodosSince:NULL];
}

- (Todolist*) loadTodosSince:(NSDate*) timestamp {
    Todolist* todolist = [[Todolist alloc] init];
    
    NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] init] autorelease];
    [request setURL:[NSURL URLWithString:[self url]]];
    [request setHTTPMethod:@"POST"];
    NSMutableString *postString = [[NSMutableString alloc] initWithString:@"do=getTodos"];
    
    NSDateFormatter* dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    if (timestamp != NULL) {
        NSString *timestampString = [dateFormatter stringFromDate:timestamp];
        [postString appendString:@"&timestamp="];
        [postString appendString:timestampString];
    }
    [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSError *error;
    NSURLResponse *response = nil;
    [logger debug:@"Send request to server"];
    NSData *urlData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    if (urlData == nil) {
        //if (error != nil) {
        //    return NULL;
        //}
        [logger debug:@"No data fetched"];
        return NULL;
    } else {
        NSString *json_string = [[NSString alloc]initWithData:urlData encoding:NSUTF8StringEncoding];
        [logger debug:@"Fetched data from server: %@", json_string];
        
        id<ITodo> todo;
        MKPlacemark* placemark = NULL;
        SBJSON *parser = [[SBJSON alloc] init];
        NSArray *todoObjects = [parser objectWithString:json_string error:nil];
        
        for (NSDictionary *todoObject in todoObjects) {
            [logger debug:@"JSON-Object: %@", todoObject];
            if ([[todoObject objectForKey:@"placemark_latitude"] floatValue] != 0.0 &&
                [[todoObject objectForKey:@"placemark_longitude"] floatValue] != 0.0) {
                placemark = [[MKPlacemark alloc] initWithCoordinate:CLLocationCoordinate2DMake([[todoObject objectForKey:@"placemark_latitude"] floatValue], [[todoObject objectForKey:@"placemark_longitude"] floatValue]) addressDictionary:nil];
            }
            NSDate* modifiedAt = [dateFormatter dateFromString:[todoObject objectForKey:@"modifiedAt"]];
            todo = [[Todo alloc] initForId:[[todoObject objectForKey:@"id"] intValue] andName:[todoObject objectForKey:@"name"] andPlace:[todoObject objectForKey:@"place"] andPlacemark:placemark andRadius:[[todoObject objectForKey:@"radius"] intValue] andDetails:[todoObject objectForKey:@"details"] andDueAtString:[todoObject objectForKey:@"dueAt"] andModifiedAt:modifiedAt];
            [todolist addTodo:todo];
        }
        return todolist;
    }
}

- (int) addTodo:(id <ITodo>) todo {
    NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] init] autorelease];
    [request setURL:[NSURL URLWithString:[self url]]];
    [request setHTTPMethod:@"POST"];
    NSMutableString *postString = [[NSMutableString alloc] initWithString:@"do=insertTodo"];
    [postString appendString:@"&todo="];
    [postString appendString:[todo name]];
    [postString appendString:@"&deviceId="];
    [postString appendString:[self getDeviceID]];
    [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSError *error = nil;
    NSURLResponse *response = nil;
    NSData *urlData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    NSString *result = [[NSString alloc]initWithData:urlData encoding:NSUTF8StringEncoding];
    [logger debug:@"Fetched todo id from server: %@", result];
    
    int ID = [result intValue];
    return ID;
}

- (BOOL) updateTodo:(id <ITodo>) todo {
    NSString *modifiedAtString = NULL;
    if ([todo modifiedAt] != NULL) {
        NSDateFormatter* dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
        dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
        modifiedAtString = [dateFormatter stringFromDate:[todo modifiedAt]];
    }
    
    MKPlacemark* placemark = [todo placemark];
    CLLocationCoordinate2D placemarkCoordinate = [placemark coordinate];
    NSString * done = [todo done] ? @"true" : @"false";
    SBJsonWriter *jsonWriter = [[SBJsonWriter alloc] init];
    NSDictionary *command = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSString stringWithFormat:@"%d",[todo ID]], @"id",
                             [todo name], @"name",
                             [todo details], @"details",
                             [todo place], @"place",
                             [NSString stringWithFormat:@"%f", placemarkCoordinate.latitude], @"placemark_latitude",
                             [NSString stringWithFormat:@"%f", placemarkCoordinate.longitude], @"placemark_longitude",
                             [NSString stringWithFormat:@"%d",[todo radius]], @"radius",
                             [todo dueAtString], @"dueAt",
                             modifiedAtString, @"modifiedAt",
                             done, @"done",
                             nil];
    NSString *json = [jsonWriter stringWithObject:command];
    [logger debug:@"todo as json: %@", json];
    
    NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] init] autorelease];
    [request setURL:[NSURL URLWithString:[self url]]];
    [request setHTTPMethod:@"POST"];
    NSMutableString *postString = [[NSMutableString alloc] initWithString:@"do=updateTodo"];
    [postString appendString:@"&todo="];
    [postString appendString:json];
    [postString appendString:@"&deviceId="];
    [postString appendString:[self getDeviceID]];
    [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSError *error = nil;
    NSURLResponse *response = nil;
    [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    if (error) {
        return FALSE;
    }
    return TRUE;
}

- (BOOL) deleteTodo:(id <ITodo>) todo {
    return [self deleteTodoWithId:[todo ID]];
}

- (BOOL) deleteTodoWithId:(int) todoID {
    NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] init] autorelease];
    [request setURL:[NSURL URLWithString:[self url]]];
    [request setHTTPMethod:@"POST"];
    NSMutableString *postString = [[NSMutableString alloc] initWithString:@"do=deleteTodo"];
    [postString appendString:@"&todo="];
    [postString appendString:[NSString stringWithFormat:@"%d",todoID]];
    [postString appendString:@"&deviceId="];
    [postString appendString:[self getDeviceID]];
    [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSError *error = nil;
    NSURLResponse *response = nil;
    [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    if (response == nil) {
        return FALSE;
    }
    if (error) {
        return FALSE;
    }
    return TRUE;
}

- (NSString*) getDeviceID {
    NSString *deviceID;
    UIDevice *device = [UIDevice currentDevice];
    NSString *os = [device systemVersion];
    float osVersion = [os floatValue];
    if (osVersion >= 6.0f) {
        deviceID = [[device identifierForVendor] UUIDString];
    } else {
        deviceID = [device uniqueIdentifier];
    }
    return deviceID;
}


@end
