//
//  Logger.h
//  SimpleApp
//
//  Created by Jörn Kreutel on 01.02.12.
//  Copyright (c) 2012 de.fhb.mobile. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {log4cdebug, log4cevent, log4cinfo, log4clifecycle, log4cwarn, log4cerror} Log4cLevels;

@interface Logger : NSObject {
    
    Class klass;
    
    Log4cLevels level;
    
    BOOL profile;
    
}


@property (nonatomic, retain) Class klass;

@property Log4cLevels level;

@property BOOL profile;

- (id) initForClass:(Class)klass;

- (BOOL) debugEnabled;

- (BOOL) infoEnabled;

- (BOOL) lifecycleEnabled;

- (BOOL) warnEnabled;

- (BOOL) eventEnabled;

- (BOOL) errorEnabled;

- (BOOL) profileEnabled;

- (void) debug:(NSString*)msg,...;

- (void) info:(NSString*)msg,...;

- (void) lifecycle:(NSString*)msg,...;

- (void) warn:(NSString*)msg,...;

- (void) error:(NSString*)msg,...;

- (void) profile:(NSString*)msg,...;

- (void) event:(NSString*)msg,...;

- (NSString*) prepareMessage:(NSString*)msg;

- (NSString*) prepareMessage:(NSString*)msg withParameters:(va_list)msgParams;

+ (NSString*) logClassHierarchyForObj:(id)obj;

@end

