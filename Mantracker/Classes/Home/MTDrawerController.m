//
//  MTDrawerController.m
//  Mantracker
//
//  Created by Misa Sakamoto on 2013-09-30.
//  Copyright (c) 2013 Nascent. All rights reserved.
//

#import "MTDrawerController.h"


@interface MTDrawerController ()

- (IBAction)MT_hideDrawer;

@end

@implementation MTDrawerController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private Methods

- (IBAction)MT_hideDrawer
{
    NSLog(@"p %f", [self.transitionCoordinator percentComplete]);
    if ([self.transitionCoordinator percentComplete] == 0)
    {
        [self dismissViewControllerAnimated: YES
            completion: nil];
    }
}

@end
