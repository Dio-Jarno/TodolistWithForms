//
//  Logger.m
//  SimpleApp
//
//  Created by Jörn Kreutel on 01.02.12.
//  Copyright (c) 2012 de.fhb.mobile. All rights reserved.
//
#import "Logger.h"

// testmodsvn

@implementation Logger

@synthesize klass, level, profile;

static NSMutableDictionary* logger2level;

static NSMutableDictionary* logger2noprofile;

static Log4cLevels rootLevel;

+ (Log4cLevels) string2log4clevel:(NSString*)level {
    
    if ([[level lowercaseString] isEqualToString:@"debug"]) {
        return log4cdebug;
    }
    else if ([[level lowercaseString] isEqualToString:@"info"]) {
        return log4cinfo;
    }
    else if ([[level lowercaseString] isEqualToString:@"lifecycle"]) {
        return log4clifecycle;
    }
    else if ([[level lowercaseString] isEqualToString:@"warn"]) {
        return log4cwarn;
    }
    else if ([[level lowercaseString] isEqualToString:@"error"]) {
        return log4cerror;
    }    
    else if ([[level lowercaseString] isEqualToString:@"event"]) {
        return log4cevent;
    }    
    else {
        return log4cdebug;
    }
}

+ (void) initialize {
    
    NSLog([NSString stringWithFormat:@"LOG4CINI initialising log4c"]);
    
    logger2level = [[NSMutableDictionary alloc] init];
    logger2noprofile = [[NSMutableDictionary alloc] init];
    
    NSString *filepath = [[NSBundle mainBundle] pathForResource:@"log4c" ofType:@"properties"];
    
    //NSLog([NSString stringWithFormat:@"LOG4CINI filepath for log4c.properties is: %@", filepath]);
    
    NSData* data = [NSData dataWithContentsOfFile:filepath];
    
    //NSLog([NSString stringWithFormat:@"LOG4CINI data is: %@", data]);
    
    NSString* error;
    NSPropertyListFormat format;
    
    NSDictionary* props = [NSPropertyListSerialization propertyListFromData:data mutabilityOption:NSPropertyListImmutable format:&format errorDescription:&error];
    
    //NSLog([NSString stringWithFormat:@"LOG4CINI read in properties: %@ of class: %@", props, [props class]]);
    
    // initialise the maps
    NSEnumerator* propsenum = [props keyEnumerator];
    NSString* currentprop;
    
    while (currentprop = [propsenum nextObject]) {
        if ([currentprop hasPrefix:@"log4c.rootLogger"]) {
            rootLevel = [Logger string2log4clevel:[props objectForKey:currentprop]];
        }
        else if ([currentprop hasPrefix:@"log4c.logger."]) {
            [logger2level setObject:[[NSNumber alloc] initWithInt:[Logger string2log4clevel:[props objectForKey:currentprop]]] forKey:[currentprop substringFromIndex:[@"log4c.logger." length]]];    
        }
        else if ([currentprop hasPrefix:@"log4c.profile."] && [@"no" isEqualToString:[(NSString*)[props objectForKey:currentprop] lowercaseString]]) {
            [logger2noprofile setObject:[[NSNumber alloc] initWithInt:FALSE] forKey:[currentprop substringFromIndex:[@"log4c.profile." length]]];    
        }
    }
    
    NSLog([NSString stringWithFormat:@"LOG4CINI rootLevel is: %i. Levels are: %@. Noprofile are: %@", rootLevel, logger2level, logger2noprofile]);
    
}

- (id) initForClass:(Class)kl {
    
    //NSLog([NSString stringWithFormat:@"creating logger for class: %@", [kl description]]);
    
    klass = kl;
    
    if ([logger2level objectForKey:[klass description]]) {
        level = [(NSNumber*)[logger2level objectForKey:[klass description]] intValue];
        //NSLog([NSString stringWithFormat:@"specific log level specified for %@: %i", [klass description], level]);
    }
    else {
        //NSLog([NSString stringWithFormat:@"no entry for %@ in %@. Use default.", [klass description], logger2level]);
        level = rootLevel;
    }
    
    if ([logger2noprofile objectForKey:[klass description]]) {
        profile = FALSE;
    }
    else {
        profile = TRUE;
    }
    
    return [super init];    
}

- (BOOL) debugEnabled {
    return level <= log4cdebug;
}

- (BOOL) eventEnabled {
    return level <= log4cevent;
}

- (BOOL) infoEnabled {
    return level <= log4cinfo;    
}

- (BOOL) lifecycleEnabled {
    return level <= log4clifecycle;    
}

- (BOOL) warnEnabled {
    return level <= log4cwarn;        
}

- (BOOL) errorEnabled {
    return level <= log4cerror;            
}

- (BOOL) profileEnabled {
    return profile;
}

- (void) debug:(NSString*)msg,... {
    
    va_list msgparams;
    va_start(msgparams, msg);
        
    if ([self debugEnabled]) {
        NSLog([NSString stringWithFormat:@"DEBUG [%@] - %@",klass,[self prepareMessage:msg withParameters:msgparams]]);
    }
    
    va_end(msgparams);
}

- (void) info:(NSString*)msg,... {

    va_list msgparams;
    va_start(msgparams, msg);

    if ([self infoEnabled]) {
        NSLog([NSString stringWithFormat:@"INFO  [%@] - %@",klass,[self prepareMessage:msg withParameters:msgparams]]);
    }

    va_end(msgparams);
}

- (void) lifecycle:(NSString*)msg,... {
    
    va_list msgparams;
    va_start(msgparams, msg);

    if ([self lifecycleEnabled]) {
        NSLog([NSString stringWithFormat:@"LFCYC  [%@] - %@",klass,[self prepareMessage:msg withParameters:msgparams]]);
    }
    
    va_end(msgparams);
}

- (void) event:(NSString*)msg,... {
    
    va_list msgparams;
    va_start(msgparams, msg);
    
    if ([self lifecycleEnabled]) {
        NSLog([NSString stringWithFormat:@"EVENT  [%@] - %@",klass,[self prepareMessage:msg withParameters:msgparams]]);
    }
    
    va_end(msgparams);
}


- (void) warn:(NSString*)msg,... {
    
    va_list msgparams;
    va_start(msgparams, msg);

    if ([self warnEnabled]) {
        NSLog([NSString stringWithFormat:@"WARN  [%@] - %@",klass,[self prepareMessage:msg withParameters:msgparams]]);
    }
    
    va_end(msgparams);
}

- (void) error:(NSString*)msg,... {
    
    va_list msgparams;
    va_start(msgparams, msg);

    if ([self errorEnabled]) {
        NSLog([NSString stringWithFormat:@"ERROR [%@] - %@",klass,[self prepareMessage:msg withParameters:msgparams]]);
    }
    
    va_end(msgparams);
}

- (void) profile:(NSString*)msg,... {
    
    va_list msgparams;
    va_start(msgparams, msg);

    if ([self profileEnabled]) {
        NSLog([NSString stringWithFormat:@"PROFILE [%@] - %@",klass,[self prepareMessage:msg withParameters:msgparams]]);   
    }
    
    va_end(msgparams);
}

- (NSString*) prepareMessage:(NSString*)msg withParameters:(va_list)msgParams {
    return [self prepareMessage:[[[NSString alloc] initWithFormat:msg arguments:msgParams] autorelease]];
}    


// sure there are more elegant ways to do this...
- (NSString*) prepareMessage:(NSString*)msg {
    
    while ([msg rangeOfString:@"  "].location != NSNotFound) {
        msg = [msg stringByReplacingOccurrencesOfString:@"  " withString:@" "];     
    }
    if ([msg rangeOfString:@";\n"].location != NSNotFound) {
        msg = [msg stringByReplacingOccurrencesOfString:@";\n" withString:@"; "];     
    }
    if ([msg rangeOfString:@"\n {\n"].location != NSNotFound) {
        msg = [msg stringByReplacingOccurrencesOfString:@"\n {\n" withString:@"{"];     
    }
    if ([msg rangeOfString:@"(\n"].location != NSNotFound) {
        msg = [msg stringByReplacingOccurrencesOfString:@"(\n" withString:@"("];     
    }
    if ([msg rangeOfString:@"\n)"].location != NSNotFound) {
        msg = [msg stringByReplacingOccurrencesOfString:@"\n)" withString:@")"];     
    }
    if ([msg rangeOfString:@"{\n"].location != NSNotFound) {
        msg = [msg stringByReplacingOccurrencesOfString:@"{\n" withString:@"{"];     
    }
    if ([msg rangeOfString:@"{ "].location != NSNotFound) {
        msg = [msg stringByReplacingOccurrencesOfString:@"{ " withString:@"{"];     
    }
    if ([msg rangeOfString:@" }"].location != NSNotFound) {
        msg = [msg stringByReplacingOccurrencesOfString:@" }" withString:@"}"];     
    }
    if ([msg rangeOfString:@" }"].location != NSNotFound) {
        msg = [msg stringByReplacingOccurrencesOfString:@" }" withString:@"}"];     
    }
    if ([msg rangeOfString:@"  "].location != NSNotFound) {
        msg = [msg stringByReplacingOccurrencesOfString:@"  " withString:@" "];     
    }
    if ([msg rangeOfString:@" = "].location != NSNotFound) {
        msg = [msg stringByReplacingOccurrencesOfString:@" = " withString:@"="];     
    }
    if ([msg rangeOfString:@",\n"].location != NSNotFound) {
        msg = [msg stringByReplacingOccurrencesOfString:@",\n" withString:@", "];     
    }
    if ([msg rangeOfString:@"}\n"].location != NSNotFound) {
        msg = [msg stringByReplacingOccurrencesOfString:@"}\n" withString:@"}"];     
    }
    while ([msg rangeOfString:@"  "].location != NSNotFound) {
        msg = [msg stringByReplacingOccurrencesOfString:@"  " withString:@" "];     
    }
    return [msg stringByReplacingOccurrencesOfString:@"\n" withString:@"<br>"];
    
}

+ (NSString*) logClassHierarchyForObj:(id)obj {
    
    NSMutableString* msg = [[NSMutableString alloc] initWithString:@""];
    NSMutableString* tabs = [[NSMutableString alloc] initWithString:@""];
    
    Class currentClass = [obj class];
    
    do {
        [msg appendString:[tabs copy]];
        [msg appendString:[currentClass description]];
        [msg appendString:@"\n"];
        currentClass = [currentClass superclass];
        [tabs appendString:@"\t"];
    }
    while (currentClass);
    
    return [NSString stringWithFormat:@"Class hierarchy of object %@ is:\n%@", obj, msg];
    
}



@end
