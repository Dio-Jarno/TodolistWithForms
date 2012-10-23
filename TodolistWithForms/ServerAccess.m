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

- (id)initWithServerURL:(NSString *) _url {
    [logger debug:@"ServerAccess initialized with url: %@", _url];
    [self setUrl:_url];
    return self;
}

- (Todolist*) loadTodos {
    Todolist* todolist = [[Todolist alloc] init];
    
    NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] init] autorelease];
    [request setURL:[NSURL URLWithString:[self url]]];
    [request setHTTPMethod:@"POST"];
    NSMutableString *postString = [[NSMutableString alloc] initWithString:@"do=getTodos"];
    [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSError *error;
    NSURLResponse *response;
    NSData *urlData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
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
        todo = [[Todo alloc] initForId:[[todoObject objectForKey:@"id"] intValue] andName:[todoObject objectForKey:@"name"] andPlace:[todoObject objectForKey:@"place"] andPlacemark:placemark andDetails:[todoObject objectForKey:@"details"] andDueAtString:[todoObject objectForKey:@"dueAt"]];
        [todolist addTodo:todo];
    }
    return todolist;
}

- (int) addTodo:(id <ITodo>) todo {
    NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] init] autorelease];
    [request setURL:[NSURL URLWithString:[self url]]];
    [request setHTTPMethod:@"POST"];
    NSMutableString *postString = [[NSMutableString alloc] initWithString:@"do=insertTodo"];
    [postString appendString:@"&todo="];
    [postString appendString:[todo name]];
    [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSError *error;
    NSURLResponse *response;
    NSData *urlData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    NSString *result = [[NSString alloc]initWithData:urlData encoding:NSUTF8StringEncoding];
    [logger debug:@"Fetched todo id from server: %@", result];
    
    int ID = [result intValue];
    return ID;
}

- (void) updateTodo:(id <ITodo>) todo {
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
                             [todo dueAtString], @"dueAt",
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
    [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSError *error;
    NSURLResponse *response;
    [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
}

- (void) deleteTodo:(id <ITodo>) todo {
    NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] init] autorelease];
    [request setURL:[NSURL URLWithString:[self url]]];
    [request setHTTPMethod:@"POST"];
    NSMutableString *postString = [[NSMutableString alloc] initWithString:@"do=deleteTodo"];
    [postString appendString:@"&todo="];
    [postString appendString:[NSString stringWithFormat:@"%d",[todo ID]]];
    [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSError *error;
    NSURLResponse *response;
    [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
}


@end
