//
//  MTSettingsController.m
//  Mantracker
//
//  Created by Misa Sakamoto on 2013-10-03.
//  Copyright (c) 2013 Nascent. All rights reserved.
//

#import "MTSettingsController.h"

@interface MTSettingsController ()

- (IBAction)MT_dismissSettings;

@end

@implementation MTSettingsController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}


#pragma mark - Private Methods

- (IBAction)MT_dismissSettings
{
    [self dismissViewControllerAnimated: YES
        completion: nil];
}

@end
