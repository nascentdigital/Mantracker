//
//  MTDrawerTransitionAnimator.h
//  Mantracker
//
//  Created by Misa Sakamoto on 2013-09-30.
//  Copyright (c) 2013 Nascent. All rights reserved.
//

@class MTHomeController;

@interface MTDrawerTransitionAnimator : UIDynamicBehavior <
    UIViewControllerTransitioningDelegate,
    UIViewControllerAnimatedTransitioning,
    UIViewControllerInteractiveTransitioning,
    UIDynamicAnimatorDelegate,
    UIGestureRecognizerDelegate>

@property (nonatomic, weak) MTHomeController *homeController;

- (void)handleGesture: (UIPanGestureRecognizer *)recognizer;
- (void)showDrawer;
- (void)hideDrawer;

@end
