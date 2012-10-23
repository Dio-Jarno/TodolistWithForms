//
//  HideKeyboardViewController.h
//  TodolistWithForms
//
//  Created by Arvid on 04.07.12.
//  Copyright (c) 2012 de.fhb.mobile. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HideKeyboardViewController : UIViewController {
    UITextField* textField;
}

@property (nonatomic, retain) IBOutlet UITextField *textField;

- (IBAction)textFieldReturn:(id)sender;


@end