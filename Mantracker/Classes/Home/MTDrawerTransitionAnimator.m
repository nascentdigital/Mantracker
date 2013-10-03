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
#define UPPER_BOUNDS_FOR_DRAWER_BUTTON 0.f
#define LOWER_BOUNDS_FOR_DRAWER_BUTTON 300.f
#define BLUR_BACKGROUND

static NSString * const GroundBoundaryIdentifier = @"groundBoundary";

@interface MTDrawerTransitionAnimator()
{
    @private CGFloat _navigationBarBottom;
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
@property (nonatomic, strong) UIGravityBehavior *gravityBehavior;

- (void)MT_applyBlur;
- (void)MT_initializeTransition: (id<UIViewControllerContextTransitioning>)transitionContext;
- (BOOL)MT_panGestureToPullDownDrawer: (UIViewController *)visibleController
    touchPoint: (CGPoint)point;
- (BOOL)MT_panGestureToPullUpDrawer: (UIViewController *)visibleController
    touchPoint: (CGPoint)point;
+ (CGPoint)centerPointForFrame: (CGRect)frame;

@end

@implementation MTDrawerTransitionAnimator


#pragma mark - Properties

- (void)setHomeController:(MTHomeController *)homeController
{
    _homeController = homeController;
    
    // get the bottom y coord of the navigation bar frame
    CGRect navigationBarFrame = self.homeController.navigationController.navigationBar.frame;
    _navigationBarBottom = navigationBarFrame.origin.y + navigationBarFrame.size.height;
}


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
            toVC.view.center = [MTDrawerTransitionAnimator centerPointForFrame:
                [transitionContext finalFrameForViewController: toVC]];
        }
        else
        {
            fromVC.view.center = [MTDrawerTransitionAnimator centerPointForFrame: _toBeginFrame];
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
                ? 0.8f
                : 0.3f
            initialSpringVelocity: 1.f
            options: UIViewAnimationOptionCurveLinear
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
    if (self.cancelled == YES)
    {
        [transitionContext cancelInteractiveTransition];
        [transitionContext completeTransition: NO];
        return;
    }

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

    CGPoint point =  [recognizer locationInView: recognizer.view];

    UIViewController *visibleController =
        self.homeController.navigationController.visibleViewController;
            
    if ([self MT_panGestureToPullDownDrawer: visibleController
        touchPoint: point] == YES)
    {
        return YES;
    }
    else if ([self MT_panGestureToPullUpDrawer: visibleController
        touchPoint: point] == YES)
    {
        return YES;
    }
    return NO;
}


#pragma mark - UIDynamicAnimatorDelegate Methods

- (void)dynamicAnimatorDidPause: (UIDynamicAnimator *)animator
{
    CGPoint velocity = [self.bodyBehavior linearVelocityForItem: self.dynamicView];
    if(velocity.y < .5
        && [[animator behaviors] count] > 0)
    {
        // remove dynamic behaviors
        [self.dynamicAnimator removeAllBehaviors];
        [self removeChildBehavior: self.gravityBehavior];
        [self removeChildBehavior: self.collisionBehavior];
        [self removeChildBehavior: self.bodyBehavior];
    }
    else if ([[animator behaviors] count] == 0)
    {
        // notify the transition context of cancel/finish + completion of transition
        if(self.isCancelled)
            [self.transitionContext cancelInteractiveTransition];
        else
            [self.transitionContext finishInteractiveTransition];
        [self.transitionContext completeTransition: self.isCancelled == NO];
    }
}


#pragma mark - Public Methods

- (void)handleGesture:(UIPanGestureRecognizer *)recognizer
{
    CGPoint translation = [recognizer translationInView:
        self.homeController.navigationController.view];

    UIGestureRecognizerState state = recognizer.state;
    switch (state)
    {
        case UIGestureRecognizerStateBegan:
        {
            // set the interactive flag
            self.interactive = YES;
            
            // determine whether we are presenting or dismissing the drawer and start the transition
            CGPoint point =  [recognizer locationInView: self.homeController.navigationController.view];

            UIViewController *visibleController =
                self.homeController.navigationController.visibleViewController;
            if ([self MT_panGestureToPullDownDrawer: visibleController
                touchPoint: point] == YES)
            {
                // present the drawer
                [self.homeController presentViewController: self.homeController.drawerController
                    animated: YES
                    completion: nil];
            }
            else if ([self MT_panGestureToPullUpDrawer: visibleController
                touchPoint: point] == YES)
            {
                // dismiss the drawer
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
            if (_transitionContext == nil)
            {
                self.cancelled = YES;
                return;
            }
        
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
            
            CGPoint velocity = [recognizer velocityInView:
                self.homeController.navigationController.view];
            CGFloat velocityThreshold = 600.f;

            // determine whether the transition should be cancelled
            self.cancelled = state == UIGestureRecognizerStateCancelled
                || state == UIGestureRecognizerStateFailed
                || (self.isAppearing && velocity.y < velocityThreshold)
                || (self.isAppearing == NO && velocity.y > -velocityThreshold)
                || (ABS(velocity.y) < ABS(velocityThreshold) && ABS(translation.y) < height * 0.5f);
            
            BOOL pullUpDrawer = ((self.isAppearing && self.cancelled)
                || (self.isAppearing == NO && self.cancelled == NO));
            
            // create the animator
            self.animator = [[UIDynamicAnimator alloc]
                initWithReferenceView: containerView];
            self.animator.delegate = self;
            
            // set the dynamic item behavior
            self.bodyBehavior = [[UIDynamicItemBehavior alloc]
                init];
            self.bodyBehavior.elasticity = .3f;
            [self.bodyBehavior addLinearVelocity: velocity
                forItem: dynamicView];
            [self.bodyBehavior addItem: dynamicView];
            
            // set gravity behavior
            self.gravityBehavior = [[UIGravityBehavior alloc]
                initWithItems: @[dynamicView]];
            [self.gravityBehavior setGravityDirection: CGVectorMake(
                0.f,
                pullUpDrawer == YES
                    ? -1.f
                    : 1.f)];
            
            // set the collision behavior
            self.collisionBehavior = [[UICollisionBehavior alloc]
                initWithItems: @[dynamicView]];
            [self.collisionBehavior setTranslatesReferenceBoundsIntoBoundaryWithInsets:
                UIEdgeInsetsMake(
                    -height - 40.f,
                    0.f,
                    0.f,
                    0.f)];
            [self.collisionBehavior addItem: dynamicView];
            
            // add all child dynamic behaviors
            [self addChildBehavior: self.bodyBehavior];
            [self addChildBehavior: self.gravityBehavior];
            [self addChildBehavior: self.collisionBehavior];
            
            MTDrawerTransitionAnimator *weakSelf = self;
            self.action = ^
            {
                // call update on the transition context
                [weakSelf.transitionContext updateInteractiveTransition:
                    [weakSelf percentComplete]];
            };
            
            // start the dynamics animation
            [self.animator addBehavior: self];
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
    // take a snapshot of current screen
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
    
    // set the blurred the UIImage
    _blurredImage = [viewImage applyLightEffect];
    [self.homeController.drawerController useBlurredImage: _blurredImage];
}

- (void)MT_initializeTransition: (id<UIViewControllerContextTransitioning>)transitionContext
{
    NSLog(@"initialize transition");
    _useSimpleAnimation = USE_SIMPLE_ANIMATION == 1;

    self.transitionContext = transitionContext;
    UIViewController *toVC = [transitionContext viewControllerForKey:
        UITransitionContextToViewControllerKey];
    UIView *containerView = [transitionContext containerView];
    CGSize containerViewSize = containerView.frame.size;
    
    if (self.isAppearing)
    {
        _toBeginFrame = CGRectMake(
            0.f,
            -containerViewSize.height,
            containerViewSize.width,
            containerViewSize.height);
        _toEndFrame = [transitionContext finalFrameForViewController: toVC];

#ifdef BLUR_BACKGROUND
        // apply blur
        [self MT_applyBlur];
#endif
    }
}

- (BOOL)MT_panGestureToPullDownDrawer: (UIViewController *)visibleController
    touchPoint: (CGPoint)point
{
    return (([visibleController isKindOfClass: [MTHomeController class]]
        || [visibleController isKindOfClass: [MTLocationController class]])
            && point.y < _navigationBarBottom + UPPER_BOUNDS_FOR_DRAWER_BUTTON);
}

- (BOOL)MT_panGestureToPullUpDrawer: (UIViewController *)visibleController
    touchPoint: (CGPoint)point
{
    return ([visibleController isKindOfClass: [MTDrawerController class]]
        && point.y > self.homeController.navigationController.view.frame.size.height
            - LOWER_BOUNDS_FOR_DRAWER_BUTTON);
}

+ (CGPoint)centerPointForFrame: (CGRect)frame
{
    return CGPointMake(frame.origin.x + frame.size.width * 0.5f,
        frame.origin.y + frame.size.height * 0.5f);
}

@end
