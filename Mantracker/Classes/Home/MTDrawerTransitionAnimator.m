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
#import "MTSettingsManager.h"

//#define USE_DEFAULT_TRANSITION

#define UPPER_BOUNDS_FOR_DRAWER_BUTTON 0.f
#define LOWER_BOUNDS_FOR_DRAWER_BUTTON 300.f
#define VELOCITY_THRESHOLD 600.f

#define BOUNDARY_OFFSET 1.f

static NSString * const CeilingBoundaryIdentifier = @"ceilingBoundary";
static NSString * const GroundBoundaryIdentifier = @"groundBoundary";

@interface MTDrawerTransitionAnimator()
{
    @private CGFloat _navigationBarBottom;
    @private CGRect _toBeginFrame;
    @private CGRect _toEndFrame;
    @private UIImage *_blurredImage;
    @private BOOL _useCustomTransition;
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
    if (_useCustomTransition)
    {
        self.appearing = YES;
        return self;
    }
    else
    {
        return nil;
    }
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:
    (UIViewController *)dismissed
{
    if (_useCustomTransition)
    {
        self.appearing = NO;
        return self;
    }
    else
    {
        return nil;
    }
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
    return 1.f;
}

// DEMO: 2a Blurring
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

    [UIView animateWithDuration: [self transitionDuration: transitionContext]
        delay: 0.f
        usingSpringWithDamping: self.isAppearing == YES
            ? 0.8f
            : 0.3f
        initialSpringVelocity: 1.f
        options: UIViewAnimationOptionCurveLinear
        animations: ^
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
        }
        completion: ^(BOOL finished)
        {
            [transitionContext completeTransition: YES];
        }];
}


#pragma mark - UIViewControllerInteractiveTransitioning Methods

// DEMO: 2b Blurring
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
    MTSettingsManager *settingsManager = [MTSettingsManager sharedInstance];
    if (settingsManager.interactiveTransitions == NO
        || settingsManager.customTransitions == NO)
    {
        return NO;
    }
    
    _useCustomTransition = YES;

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


#pragma mark - UICollisionDelegate Methods

- (void)collisionBehavior: (UICollisionBehavior *)behavior
    beganContactForItem: (id<UIDynamicItem>)item
    withBoundaryIdentifier: (id<NSCopying>)identifier
    atPoint: (CGPoint)p
{
    if (identifier != nil)
    {
        if ([(NSString *)identifier isEqualToString: CeilingBoundaryIdentifier] == YES
            || [(NSString *)identifier isEqualToString: GroundBoundaryIdentifier] == YES)
        {
            CGPoint velocity = [self.bodyBehavior linearVelocityForItem: self.dynamicView];
            CGFloat magnitude = 5.f * fabs(velocity.y) * .001f;
            [self.gravityBehavior setMagnitude: fmaxf(1.f, magnitude)];
        }
    }
}


#pragma mark - Public Methods

- (void)handleGesture:(UIPanGestureRecognizer *)recognizer
{
    CGPoint translation = [recognizer translationInView: recognizer.view];

    UIGestureRecognizerState state = recognizer.state;
    switch (state)
    {
        case UIGestureRecognizerStateBegan:
        {
            // set the interactive flag
            self.interactive = YES;
            
            // determine whether we are presenting or dismissing the drawer and start the transition
            CGPoint point =  [recognizer locationInView:
                recognizer.view];

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
            
            CGPoint velocity = [recognizer velocityInView: recognizer.view];
            CGPoint point =  [recognizer locationInView:
                            recognizer.view];

            // determine whether the transition should be cancelled
            self.cancelled = state == UIGestureRecognizerStateCancelled
                || state == UIGestureRecognizerStateFailed
                || (self.isAppearing
                    && velocity.y < VELOCITY_THRESHOLD
                    && point.y < height * 0.5f)
                || (self.isAppearing == NO
                    && velocity.y > -VELOCITY_THRESHOLD
                    && point.y > height * 0.5f);
            
            BOOL pullUpDrawer = ((self.isAppearing
                    && self.cancelled)
                || (self.isAppearing == NO
                    && self.cancelled == NO));
            
            // create the animator
            self.animator = [[UIDynamicAnimator alloc]
                initWithReferenceView: containerView];
            self.animator.delegate = self;
            
            // set the dynamic item behavior
            self.bodyBehavior = [[UIDynamicItemBehavior alloc]
                initWithItems: @[dynamicView]];
            self.bodyBehavior.density = pullUpDrawer == YES
                ? 5.f
                : 1.f;
            self.bodyBehavior.elasticity = 0.f;
            self.bodyBehavior.allowsRotation = NO;
            [self.bodyBehavior addLinearVelocity: CGPointMake(0.f, velocity.y)
                forItem: dynamicView];
            
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
            self.collisionBehavior.collisionDelegate = self;
            CGFloat ceiling = - height - BOUNDARY_OFFSET;
            [self.collisionBehavior setTranslatesReferenceBoundsIntoBoundaryWithInsets:
                UIEdgeInsetsMake(
                    ceiling,
                    0.f,
                    -BOUNDARY_OFFSET,
                    0.f)];
            if (pullUpDrawer == YES)
            {
                [self.collisionBehavior addBoundaryWithIdentifier: CeilingBoundaryIdentifier
                    fromPoint: CGPointMake(0.f, ceiling)
                    toPoint: CGPointMake(frame.size.width, ceiling)];
            }
            else
            {
                [self.collisionBehavior addBoundaryWithIdentifier: GroundBoundaryIdentifier
                    fromPoint: CGPointMake(0.f, height + BOUNDARY_OFFSET)
                    toPoint: CGPointMake(frame.size.width, height + BOUNDARY_OFFSET)];
            }
            [self.collisionBehavior addItem: dynamicView];
            
            // add all child dynamic behaviors
            [self addChildBehavior: self.bodyBehavior];
            [self addChildBehavior: self.gravityBehavior];
            [self addChildBehavior: self.collisionBehavior];
            
            __weak MTDrawerTransitionAnimator *weakSelf = self;
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
        _useCustomTransition = [MTSettingsManager sharedInstance].customTransitions;
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

- (void)applyBlur
{
    [self MT_applyBlur];
}


#pragma mark - Private Methods

- (void)MT_applyBlur
{
    // DEMO: 2c Blurring
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

        if ([MTSettingsManager sharedInstance].blurBackground)
        {
            // apply blur
            [self MT_applyBlur];
        }
        else
        {
            [self.homeController.drawerController useBlurredImage: nil];
        }
    }
}

- (BOOL)MT_panGestureToPullDownDrawer: (UIViewController *)visibleController
    touchPoint: (CGPoint)point
{
    return (([visibleController isKindOfClass: [MTHomeController class]]
        || [visibleController isKindOfClass: [MTLocationController class]])
            && point.y <= _navigationBarBottom + UPPER_BOUNDS_FOR_DRAWER_BUTTON);
}

- (BOOL)MT_panGestureToPullUpDrawer: (UIViewController *)visibleController
    touchPoint: (CGPoint)point
{
    return ([visibleController isKindOfClass: [MTDrawerController class]]
        && point.y >= self.homeController.navigationController.view.frame.size.height
            - LOWER_BOUNDS_FOR_DRAWER_BUTTON);
}

+ (CGPoint)centerPointForFrame: (CGRect)frame
{
    return CGPointMake(frame.origin.x + frame.size.width * 0.5f,
        frame.origin.y + frame.size.height * 0.5f);
}

@end
