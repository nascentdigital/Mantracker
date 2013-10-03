//
//  MTDrawerTransitionAnimator.m
//  Mantracker
//
//  Created by Misa Sakamoto on 2013-09-30.
//  Copyright (c) 2013 Nascent. All rights reserved.
//

#import "MTDrawerTransitionAnimator.h"
#import "MTDrawerController.h"
#import "MTHomeController.h"
#import "UIImage+ImageEffects.h"
#import "MTLocationController.h"

#define USE_SIMPLE_ANIMATION 0
#define LOWER_BOUNDS_FOR_DRAWER_BUTTON 50.f
#define BLUR_BACKGROUND

static NSString * const GroundBoundaryIdentifier = @"groundBoundary";

@interface MTDrawerTransitionAnimator()
{
    @private CGRect _toBeginFrame;
    @private CGRect _toEndFrame;
    @private UIImage *_blurredImage;
    @private BOOL _useSimpleAnimation;
}

@property (nonatomic, weak) UIView *dynamicView;
@property (nonatomic, assign) CGPoint startingCenterForDrawerView;
@property (nonatomic, assign) CGPoint startingCenterForBlurredView;

@property (nonatomic, strong) id<UIViewControllerContextTransitioning>transitionContext;
@property (nonatomic, assign, getter = isInteractive) BOOL interactive;
@property (nonatomic, assign, getter = isAppearing) BOOL appearing;
@property (nonatomic, assign, getter = isCancelled) BOOL cancelled;
@property (nonatomic, assign) float percentComplete;

@property (nonatomic, strong) UIDynamicAnimator *animator;
@property (nonatomic, strong) UIDynamicItemBehavior *bodyBehavior;
@property (nonatomic, strong) UICollisionBehavior *collisionBehavior;
@property (nonatomic, strong) UIAttachmentBehavior *attachBehavior;
@property (nonatomic, strong) UIGravityBehavior *gravityBehavior;

- (void)MT_applyBlur;
- (void)MT_initializeTransition: (id<UIViewControllerContextTransitioning>)transitionContext;

@end

@implementation MTDrawerTransitionAnimator



#pragma mark - UIViewControllerTransitioningDelegate Methods

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:
    (UIViewController *)presented
    presentingController: (UIViewController *)presenting
    sourceController:(UIViewController *)source
{
    self.appearing = YES;
    return self;
}


- (id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:
    (UIViewController *)dismissed
{
    self.appearing = NO;
    return self;
}

- (id <UIViewControllerInteractiveTransitioning>)interactionControllerForPresentation:
    (id <UIViewControllerAnimatedTransitioning>)animator
{
    self.appearing = YES;
    if (self.isInteractive)
        return self;
    else
        return nil;
}

- (id <UIViewControllerInteractiveTransitioning>)interactionControllerForDismissal:
    (id <UIViewControllerAnimatedTransitioning>)animator
{
    self.appearing = NO;
    if (self.isInteractive)
        return self;
    else
        return nil;
}


#pragma mark - UIViewControllerAnimatedTransitioning Methods

- (void)animationEnded: (BOOL) transitionCompleted;
{
    NSLog(@"ended, resetting");
    // reset
    self.transitionContext = nil;
    self.interactive = NO;
    self.appearing = NO;
    self.percentComplete = 0.f;
    self.dynamicView = nil;
    self.cancelled = NO;
}

- (NSTimeInterval)transitionDuration:
    (id<UIViewControllerContextTransitioning>)transitionContext
{
    return _useSimpleAnimation == YES
        ? 0.3f
        : 1.f;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    NSLog(@"starting animation transtion");
    
    // initialize the transitionContext
    [self MT_initializeTransition: transitionContext];
    
    UIViewController *fromVC = [transitionContext viewControllerForKey:
        UITransitionContextFromViewControllerKey];
    UIViewController *toVC = [transitionContext viewControllerForKey:
        UITransitionContextToViewControllerKey];
    UIView *containerView = [transitionContext containerView];
    
    if (self.isAppearing)
    {
        toVC.view.frame = _toBeginFrame;
        [containerView addSubview: toVC.view];
    }
    else
    {
        toVC.view.frame = [transitionContext initialFrameForViewController: fromVC];
        fromVC.view.frame = [transitionContext initialFrameForViewController: fromVC];
        
        [containerView insertSubview: toVC.view
            belowSubview: fromVC.view];
    }

    void (^animation)() =  ^
    {
        if (self.isAppearing)
        {
            toVC.view.frame = [transitionContext finalFrameForViewController: toVC];
        }
        else
        {
            fromVC.view.frame = _toBeginFrame;
        }

    };
    
    if (_useSimpleAnimation == YES)
    {
        [UIView animateWithDuration: [self transitionDuration: transitionContext]
            animations: ^
            {
                animation();
            }
            completion: ^(BOOL finished)
            {
                [transitionContext completeTransition: YES];
            }];
    }
    else
    {
        [UIView animateWithDuration: [self transitionDuration: transitionContext]
            delay: 0.f
            usingSpringWithDamping: self.isAppearing == YES
                ? 0.65f
                : 0.3f
            initialSpringVelocity: 1.f
            options: UIViewAnimationOptionCurveEaseInOut
            animations: ^
            {
                animation();
            }
            completion: ^(BOOL finished)
            {
                [transitionContext completeTransition: YES];
            }];
    }
}


#pragma mark - UIViewControllerInteractiveTransitioning Methods

- (void)startInteractiveTransition: (id<UIViewControllerContextTransitioning>)transitionContext
{
    NSLog(@"starting interactive transtion");
    
    // initialize the transitionContext
    [self MT_initializeTransition: transitionContext];
    
    UIViewController *fromVC = [transitionContext viewControllerForKey:
        UITransitionContextFromViewControllerKey];
    UIViewController *toVC = [transitionContext viewControllerForKey:
        UITransitionContextToViewControllerKey];
    UIView *containerView = [transitionContext containerView];
    
    if (self.isAppearing)
    {    
        toVC.view.frame = _toBeginFrame;
        [containerView addSubview: toVC.view];
        _startingCenterForDrawerView = toVC.view.center;
        self.dynamicView = toVC.view;
    }
    else
    {
        toVC.view.frame = [transitionContext finalFrameForViewController: toVC];
        [containerView insertSubview: toVC.view
            belowSubview: fromVC.view];
        _startingCenterForDrawerView = fromVC.view.center;
        self.dynamicView = fromVC.view;
    }
}


#pragma mark - UIGestureRecognizerDelegate Methods

- (BOOL)gestureRecognizerShouldBegin: (UIGestureRecognizer *)recognizer
{
    if (recognizer.numberOfTouches != 1
        || self.transitionContext != nil)
    {
        return NO;
    }

    CGPoint point =  [recognizer locationInView: self.homeController.navigationController.view];
    CGRect navigationBarFrame = self.homeController.navigationController.navigationBar.frame;
    
    UIViewController *visibleController =
        self.homeController.navigationController.visibleViewController;
            
    if (([visibleController isKindOfClass: [MTHomeController class]]
        || [visibleController isKindOfClass: [MTLocationController class]])
            && point.y < navigationBarFrame.origin.y + navigationBarFrame.size.height)
    {
        return YES;
    }
    else if ([visibleController isKindOfClass: [MTDrawerController class]]
        && point.y > self.homeController.navigationController.view.frame.size.height
            - LOWER_BOUNDS_FOR_DRAWER_BUTTON)
    {
        return YES;
    }
    return NO;
}


#pragma mark - UIDynamicAnimatorDelegate Methods

- (void)dynamicAnimatorDidPause: (UIDynamicAnimator *)animator
{
    NSLog(@"pause");
    CGPoint velocity = [self.bodyBehavior linearVelocityForItem: self.dynamicView];
    if(velocity.y < .5
        && [[animator behaviors] count] > 0)
    {
        NSLog(@"complete %d", self.isCancelled == NO);
        if(self.isCancelled)
            [self.transitionContext cancelInteractiveTransition];
        else
            [self.transitionContext finishInteractiveTransition];
        [self.transitionContext completeTransition: self.isCancelled == NO];
    
        // remove dynamic behaviors
        [self.dynamicAnimator removeAllBehaviors];
        [self removeChildBehavior: self.attachBehavior];
        [self removeChildBehavior: self.collisionBehavior];
        [self removeChildBehavior: self.bodyBehavior];
        [self removeChildBehavior: self.gravityBehavior];
    }
}


#pragma mark - Public Methods

- (void)handleGesture:(UIPanGestureRecognizer *)recognizer
{
    CGPoint translation = [recognizer translationInView:
        self.homeController.navigationController.view];

    UIGestureRecognizerState state = recognizer.state;
    NSLog(@"state %d", state);
    switch (state)
    {
        case UIGestureRecognizerStateBegan:
        {
            // set the interactive flag
            self.interactive = YES;
            
            // determine whether we are presenting or dismissing the drawer and start the transition
            CGPoint point =  [recognizer locationInView: self.homeController.navigationController.view];
            CGRect navigationBarFrame = self.homeController.navigationController.navigationBar.frame;
            UIViewController *visibleController =
                self.homeController.navigationController.visibleViewController;
            if (([visibleController isKindOfClass: [MTHomeController class]]
                || [visibleController isKindOfClass: [MTLocationController class]])
                    && point.y < navigationBarFrame.origin.y + navigationBarFrame.size.height)
            {
                NSLog(@"presenting drawer");
                [self.homeController presentViewController: self.homeController.drawerController
                    animated: YES
                    completion: nil];
            }
            else if ([visibleController isKindOfClass: [MTDrawerController class]]
                && point.y > self.homeController.navigationController.view.frame.size.height
                    - LOWER_BOUNDS_FOR_DRAWER_BUTTON)
            {
                NSLog(@"dismissing drawer");
                [self.homeController dismissViewControllerAnimated: YES
                    completion: nil];
            }
        }
        break;
        
        case UIGestureRecognizerStateChanged:
        {
            UIViewController *fromVC = [_transitionContext viewControllerForKey:
                UITransitionContextFromViewControllerKey];
            UIViewController *toVC = [_transitionContext viewControllerForKey:
                UITransitionContextToViewControllerKey];
            UIView *view = self.isAppearing == YES
                ? toVC.view
                : fromVC.view;
            
            // move the drawer view
            view.center = CGPointMake(
                _startingCenterForDrawerView.x,
                _startingCenterForDrawerView.y + translation.y);
            
            // move the blurred image
            CGRect navigationBarFrame = self.homeController.navigationController.navigationBar.frame;
            CGRect bluredImgFrame = self.homeController.drawerController.bkgImage.frame;
            bluredImgFrame.origin.y = self.isAppearing == YES
                ? bluredImgFrame.size.height - translation.y
                    - navigationBarFrame.origin.y - navigationBarFrame.size.height
                : -translation.y;
            self.homeController.drawerController.bkgImage.frame = bluredImgFrame;
        
            // update the percentage complete
            self.percentComplete = (translation.y / _toEndFrame.size.height);
            
            // call update on the transition context
            [_transitionContext updateInteractiveTransition: self.percentComplete];
        }
        break;

        case UIGestureRecognizerStateFailed:
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        {
            UIView *containerView = [_transitionContext containerView];
            if (self.dynamicView == nil)
            {
                self.dynamicView = self.isAppearing
                    ? [_transitionContext viewControllerForKey:
                        UITransitionContextToViewControllerKey].view
                    : [_transitionContext viewControllerForKey:
                        UITransitionContextFromViewControllerKey].view;
            }
            UIView *dynamicView = self.dynamicView;
            CGRect frame = dynamicView.frame;
            float height = frame.size.height;
            
            // determine whether the transition should be cancelled
            self.cancelled = state == UIGestureRecognizerStateCancelled
                || state == UIGestureRecognizerStateFailed
                || ABS(translation.y) < height * 0.5f;
            
            // create the animator
            self.animator = [[UIDynamicAnimator alloc]
                initWithReferenceView: containerView];
            self.animator.delegate = self;
            
            // set the dynamic item behavior
            self.bodyBehavior = [[UIDynamicItemBehavior alloc]
                init];
            self.bodyBehavior.elasticity = .3f;
            [self.bodyBehavior addItem: dynamicView];
            
            // set the collision behavior
            self.collisionBehavior = [[UICollisionBehavior alloc]
                initWithItems: @[dynamicView]];
            [self.collisionBehavior setTranslatesReferenceBoundsIntoBoundaryWithInsets:
                UIEdgeInsetsMake(
                    -height,
                    0.f,
                    0.f,
                    0.f)];
            [self.collisionBehavior addItem: dynamicView];
            
            // set the attachment behavior
            CGPoint anchor = ((self.isAppearing && self.cancelled)
                || (self.isAppearing == NO && self.cancelled == NO))
                    ? CGPointMake(dynamicView.center.x, -1 * height - 40.f)
                    : CGPointMake(dynamicView.center.x, 0.f);
            self.attachBehavior = [[UIAttachmentBehavior alloc]
                initWithItem: dynamicView
                attachedToAnchor: anchor];
            self.attachBehavior.damping = .1;
            self.attachBehavior.frequency = 3.0;
            self.attachBehavior.length = .5 * frame.size.height + 20.f;
            
            // set the gravity behavior
            self.gravityBehavior = [[UIGravityBehavior alloc]
                initWithItems: @[dynamicView]];
            [self.gravityBehavior setMagnitude: 3.f];
            
            // add all child dynamic behaviors
            [self addChildBehavior: self.attachBehavior];
            [self addChildBehavior: self.collisionBehavior];
            [self addChildBehavior: self.bodyBehavior];
            [self addChildBehavior: self.gravityBehavior];
            
            MTDrawerTransitionAnimator *weakSelf = self;
            self.action = ^
            {
                // call update on the transition context
                [weakSelf.transitionContext updateInteractiveTransition:
                    [weakSelf percentComplete]];
                
                // move the blurred image
                CGFloat diff = -height - dynamicView.frame.origin.y;
                weakSelf.homeController.drawerController.bkgImage.center = CGPointMake(
                    weakSelf.startingCenterForBlurredView.x,
                    weakSelf.startingCenterForBlurredView.y + diff);
                NSLog(@"new blur center %f diff %f", weakSelf.homeController.drawerController.bkgImage.center.y, diff);
            };
            
            // start the dynamics animation
            [self.animator addBehavior:self];
        }
        break;

        default:
        break;
    }
}

- (void)showDrawer
{
    if (self.transitionContext == nil)
    {
        [self.homeController presentViewController: self.homeController.drawerController
            animated: YES
            completion: nil];
    }
}

- (void)hideDrawer
{
    if (self.transitionContext == nil)
    {
        [self.homeController dismissViewControllerAnimated: YES
            completion: nil];
    }
}


#pragma mark - Private Methods

- (void)MT_applyBlur
{
    CGSize size = self.homeController.view.frame.size;
    size.height += self.homeController.view.frame.origin.y;
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.f);
    
    [self.homeController.navigationController.view drawViewHierarchyInRect: CGRectMake(
        0.f,
        self.homeController.view.frame.origin.y,
        size.width,
        size.height)
        afterScreenUpdates: NO];
    
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    // blur the UIImage
    _blurredImage = [viewImage applyLightEffect];
    self.homeController.drawerController.bkgImage.image = _blurredImage;
    
    CGPoint center = self.homeController.drawerController.bkgImage.center;
    center.y = size.height * 1.5f;
    self.homeController.drawerController.bkgImage.center = center;
    _startingCenterForBlurredView = self.homeController.drawerController.bkgImage.center;
    NSLog(@"starting blur center %f", _startingCenterForBlurredView.y);
}

- (void)MT_initializeTransition: (id<UIViewControllerContextTransitioning>)transitionContext
{
    _useSimpleAnimation = USE_SIMPLE_ANIMATION == 1;

    self.transitionContext = transitionContext;
    UIViewController *toVC = [transitionContext viewControllerForKey:
        UITransitionContextToViewControllerKey];
    UIView *containerView = [transitionContext containerView];
    CGSize containerViewSize = containerView.frame.size;
    
//    CGRect toStart = [transitionContext initialFrameForViewController: toVC];
//    CGRect toEnd = [transitionContext finalFrameForViewController: toVC];
//    CGRect fromStart = [transitionContext initialFrameForViewController: fromVC];
//    CGRect fromEnd = [transitionContext finalFrameForViewController: fromVC];
    
    if (self.isAppearing)
    {
        CGRect navigationBarFrame = self.homeController.navigationController.navigationBar.frame;
    
        _toBeginFrame = CGRectMake(
            0.f,
            -containerViewSize.height + navigationBarFrame.origin.y + navigationBarFrame.size.height,
            containerViewSize.width,
            containerViewSize.height);
        _toEndFrame = [transitionContext finalFrameForViewController: toVC];

#ifdef BLUR_BACKGROUND
        // apply blur
        [self MT_applyBlur];
#endif
    }
}

@end
