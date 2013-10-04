//
//  MTSettingsController.m
//  Mantracker
//
//  Created by Misa Sakamoto on 2013-10-03.
//  Copyright (c) 2013 Nascent. All rights reserved.
//

#import "MTSettingsController.h"
#import "MTSettingsManager.h"

#pragma mark - Constants

#define PARALLAX_TAG 100
#define BLUR_TAG 200
#define CUSTOM_TRANSITIONS_TAG 300
#define INTERACTIVE_TRANSITIONS_TAG 400
#define ENVIRONMENTAL_FEEDBAG_TAG 500
#define LIFE_ANIMATIONS_TAG 600


@interface MTSettingsController ()

- (IBAction)MT_dismissSettings;
- (IBAction)MT_changeSettings: (UISwitch *)sender;

@end

@implementation MTSettingsController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    for (UIView *view in [self.view subviews])
    {
        if ([view isKindOfClass: [UISwitch class]])
        {
            MTSettingsManager *settingsManager = [MTSettingsManager sharedInstance];
            UISwitch *switchButton = (UISwitch *)view;
            switch (switchButton.tag)
            {
                case PARALLAX_TAG:
                    switchButton.on = settingsManager.enableParallax;
                break;
                
                case BLUR_TAG:
                    switchButton.on = settingsManager.blurBackground;
                break;
                
                case CUSTOM_TRANSITIONS_TAG:
                    switchButton.on = settingsManager.customTransitions;
                break;
                
                case INTERACTIVE_TRANSITIONS_TAG:
                    switchButton.on = settingsManager.interactiveTransitions;
                break;
                
                case ENVIRONMENTAL_FEEDBAG_TAG:
                    switchButton.on = settingsManager.environmentalFeedback;
                break;
                
                case LIFE_ANIMATIONS_TAG:
                    switchButton.on = settingsManager.lifeAnimations;
                break;
            }
        }
    }
}


#pragma mark - Private Methods

- (IBAction)MT_dismissSettings
{
    [self dismissViewControllerAnimated: YES
        completion: nil];
}


- (IBAction)MT_changeSettings: (UISwitch *)sender
{
    MTSettingsManager *settingsManager = [MTSettingsManager sharedInstance];
    switch (sender.tag)
    {
        case PARALLAX_TAG:
            settingsManager.enableParallax = sender.on;
        break;
        
        case BLUR_TAG:
            settingsManager.blurBackground = sender.on;
        break;
        
        case CUSTOM_TRANSITIONS_TAG:
            settingsManager.customTransitions = sender.on;
        break;
        
        case INTERACTIVE_TRANSITIONS_TAG:
            settingsManager.interactiveTransitions = sender.on;
        break;
        
        case ENVIRONMENTAL_FEEDBAG_TAG:
            settingsManager.environmentalFeedback = sender.on;
        break;
        
        case LIFE_ANIMATIONS_TAG:
            settingsManager.lifeAnimations = sender.on;
        break;
    }
}

@end
