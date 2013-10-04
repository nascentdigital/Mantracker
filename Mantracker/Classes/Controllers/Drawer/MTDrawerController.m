//
//  MTDrawerController.m
//  Mantracker
//
//  Created by Misa Sakamoto on 2013-09-30.
//  Copyright (c) 2013 Nascent. All rights reserved.
//

#import "MTDrawerController.h"
#import "MTDrawerTransitionAnimator.h"
#import "MTKVO.h"
#import "MTSettingsManager.h"


#pragma mark - Class Interface

@interface MTDrawerController ()
{
    @private __strong MTKVO *_kvo;
    @private CGFloat _height;
    @private CGFloat _centerXCoord;
}

@property (nonatomic, weak) IBOutlet UIImageView *bkgImage;

- (IBAction)MT_hideDrawer;
- (void)MT_onCenterChanged: (NSDictionary *)change;

@end


#pragma mark - Class Implementation

@implementation MTDrawerController


#pragma mark - Overridden Methods

- (void)dealloc
{
    if (_kvo != nil)
    {
        [_kvo stopObserving: self.view
            forKeyPath: @"center"];
        _kvo = nil;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // get original height and center of screen
    _height = self.view.bounds.size.height;
    _centerXCoord = self.view.center.x;
    
    // bind kvo
    _kvo = [[MTKVO alloc]
        init];
    [_kvo startObserving: self.view
        forKeyPath: @"center"
        options: NSKeyValueObservingOptionNew
        target: self
        selector: @selector(MT_onCenterChanged:)];
}

- (void)viewWillAppear: (BOOL)animated
{
    [super viewWillAppear: animated];

    MTSettingsManager *settingsManager = [MTSettingsManager sharedInstance];
    if ([self.transitioningDelegate isKindOfClass: [MTDrawerTransitionAnimator class]]
        && settingsManager.blurBackground)
    {
        [((MTDrawerTransitionAnimator *)self.transitioningDelegate) applyBlur];
    }
    else
    {
        self.bkgImage.image = nil;
    }
}


#pragma mark - Public Methods

- (void)useBlurredImage: (UIImage *)image
{
    self.bkgImage.image = image;
}


#pragma mark - Private Methods

- (IBAction)MT_hideDrawer
{
    if ([self.transitioningDelegate isKindOfClass: [MTDrawerTransitionAnimator class]])
    {
        [((MTDrawerTransitionAnimator *)self.transitioningDelegate) hideDrawer];
    }
}

- (void)MT_onCenterChanged: (NSDictionary *)change
{
    CGPoint p = [[change objectForKey: NSKeyValueChangeNewKey]
        CGPointValue];
    CGFloat newCenterY = _height - p.y;
    self.bkgImage.center = CGPointMake(_centerXCoord, newCenterY);
}

@end
