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


@interface MTDrawerTransitionAnimator()
{
    @private CGRect _toBeginFrame;
    @private CGRect _toEndFrame;
    @private CGPoint _startingCenter;
    @private UIImage *_blurredImage;
}

@property (nonatomic, weak) UIView *containerView;
@property (nonatomic, weak) UIView *dynamicView;

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

@end

@implementation MTDrawerTransitionAnimator



#pragma mark - UIViewControllerTransitioningDelegate Methods

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:
    (UIViewController *)presented
    presentingController: (UIViewController *)presenting
    sourceController:(UIViewController *)source
{
    return self;
}


- (id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:
    (UIViewController *)dismissed
{
    return self;
}

- (id <UIViewControllerInteractiveTransitioning>)interactionControllerForPresentation:
    (id <UIViewControllerAnimatedTransitioning>)animator
{
    if (self.isInteractive)
        return self;
    else
        return nil;
}

- (id <UIViewControllerInteractiveTransitioning>)interactionControllerForDismissal:
    (id <UIViewControllerAnimatedTransitioning>)animator
{
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
    self.containerView = nil;
    self.dynamicView = nil;
    self.cancelled = NO;
}

- (NSTimeInterval)transitionDuration:
    (id<UIViewControllerContextTransitioning>)transitionContext
{
    return 0.3f;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    NSLog(@"starting animation transtion");
    
    _transitionContext = transitionContext;
    UIViewController *fromVC = [transitionContext viewControllerForKey:
        UITransitionContextFromViewControllerKey];
    UIViewController *toVC = [transitionContext viewControllerForKey:
        UITransitionContextToViewControllerKey];
    UIView *containerView = [transitionContext containerView];
    CGSize containerViewSize = containerView.frame.size;
    self.containerView = containerView;
    
    if (self.isAppearing)
    {
        CGRect navigationBarFrame = self.homeController.navigationController.navigationBar.frame;
    
        _toBeginFrame = CGRectMake(
            0.f,
            -containerViewSize.height + navigationBarFrame.origin.y + navigationBarFrame.size.height,
            containerViewSize.width,
            containerViewSize.height);
        _toEndFrame = [transitionContext finalFrameForViewController: toVC];

        
        toVC.view.frame = _toBeginFrame;
        [containerView addSubview: toVC.view];
    }
    else
    {
        CGRect toStart = [transitionContext initialFrameForViewController: toVC];
        CGRect toEnd = [transitionContext finalFrameForViewController: toVC];
        CGRect fromStart = [transitionContext initialFrameForViewController: fromVC];
        CGRect fromEnd = [transitionContext finalFrameForViewController: fromVC];
        
        toVC.view.frame = [transitionContext initialFrameForViewController: fromVC];
        fromVC.view.frame = [transitionContext initialFrameForViewController: fromVC];
        
        [containerView insertSubview: toVC.view
            belowSubview: fromVC.view];
    }
    
    [UIView animateWithDuration: [self transitionDuration: transitionContext]
        animations: ^
        {
            if (self.isAppearing)
            {
                toVC.view.frame = [transitionContext finalFrameForViewController: toVC];
            }
            else
            {
                [containerView insertSubview: toVC.view
                    belowSubview: fromVC.view];
                fromVC.view.frame = _toBeginFrame;
            }
        }
        completion: ^(BOOL finished)
        {
            [transitionContext completeTransition: YES];
            self.appearing = NO;
        }];
}


#pragma mark - UIViewControllerInteractiveTransitioning Methods

- (void)startInteractiveTransition: (id<UIViewControllerContextTransitioning>)transitionContext
{
    NSLog(@"starting interactive transtion");

    _transitionContext = transitionContext;
    UIViewController *fromVC = [transitionContext viewControllerForKey:
        UITransitionContextFromViewControllerKey];
    UIViewController *toVC = [transitionContext viewControllerForKey:
        UITransitionContextToViewControllerKey];
    UIView *containerView = [transitionContext containerView];
    CGSize containerViewSize = containerView.frame.size;
    self.containerView = containerView;
    
    if (self.isAppearing)
    {
        CGRect navigationBarFrame = self.homeController.navigationController.navigationBar.frame;
    
        _toBeginFrame = CGRectMake(
            0.f,
            -containerViewSize.height + navigationBarFrame.origin.y + navigationBarFrame.size.height,
            containerViewSize.width,
            containerViewSize.height);
        _toEndFrame = [transitionContext finalFrameForViewController: toVC];
    }
    
    if ([toVC isKindOfClass: [MTDrawerController class]])
    {
        // apply blur
//        [self MT_applyBlur];
    
        toVC.view.frame = _toBeginFrame;
        [containerView addSubview: toVC.view];
        _startingCenter = toVC.view.center;
        self.dynamicView = toVC.view;
    }
    else
    {
        toVC.view.frame = [transitionContext finalFrameForViewController: toVC];
        [containerView insertSubview: toVC.view
            belowSubview: fromVC.view];
        _startingCenter = fromVC.view.center;
        self.dynamicView = fromVC.view;
    }
}


#pragma mark - UIGestureRecognizerDelegate Methods

- (BOOL)gestureRecognizerShouldBegin: (UIGestureRecognizer *)recognizer
{
    if (_transitionContext != nil)
    {
        return NO;
    }

    self.interactive = YES;

    CGPoint point =  [recognizer locationInView:
        self.homeController.navigationController.view];
    CGRect navigationBarFrame = self.homeController.navigationController.navigationBar.frame;
    
    UIViewController *visibleController =
        self.homeController.navigationController.visibleViewController;
            
    if (([visibleController isKindOfClass: [MTHomeController class]]
        || [visibleController isKindOfClass: [MTLocationController class]])
            && point.y < navigationBarFrame.origin.y + navigationBarFrame.size.height)
    {
        NSLog(@"presenting drawer");
        self.appearing = YES;
        [self.homeController presentViewController: self.homeController.drawerController
            animated: YES completion: nil];
        return YES;
    }
    else if ([visibleController isKindOfClass: [MTDrawerController class]]
        && point.y > self.homeController.navigationController.view.frame.size.height - 50.f)
    {
        NSLog(@"dismissing drawer");
        self.appearing = NO;
        [self.homeController dismissViewControllerAnimated: YES
            completion: nil];
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
    
            
        [self.dynamicAnimator removeAllBehaviors];
        [self removeChildBehavior: self.attachBehavior];
        [self removeChildBehavior: self.collisionBehavior];
        [self removeChildBehavior: self.bodyBehavior];
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
        case UIGestureRecognizerStateChanged:
        {
            UIViewController *fromVC = [_transitionContext viewControllerForKey: UITransitionContextFromViewControllerKey];
            UIViewController *toVC = [_transitionContext viewControllerForKey: UITransitionContextToViewControllerKey];

            UIView *view = self.isAppearing == YES
                ? toVC.view
                : fromVC.view;
            
            view.center = CGPointMake(
                _startingCenter.x,
                _startingCenter.y + translation.y);
        
            self.percentComplete = (translation.y / _toEndFrame.size.height);
            [_transitionContext updateInteractiveTransition: self.percentComplete];
        }
        break;

        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        {
            UIView *containerView = [_transitionContext containerView];
            UIView *dynamicView = self.dynamicView;
            CGRect frame = dynamicView.frame;
            float height = frame.size.height;
        
            self.animator = [[UIDynamicAnimator alloc]
                initWithReferenceView: containerView];
            self.animator.delegate = self;
            
            self.cancelled = state == UIGestureRecognizerStateCancelled
                || ABS(translation.y) < height * 0.3f;
            
            self.bodyBehavior = [[UIDynamicItemBehavior alloc]
                init];
            self.bodyBehavior.elasticity = .3;
            [self.bodyBehavior addItem: dynamicView];
            
            self.collisionBehavior = [[UICollisionBehavior alloc]
                initWithItems: @[dynamicView]];
            [self.collisionBehavior setTranslatesReferenceBoundsIntoBoundaryWithInsets:
                UIEdgeInsetsMake(
                    -height,
                    0.f,
                    0.f,
                    0.f)];
            [self.collisionBehavior addItem: dynamicView];
            
            CGPoint anchor = ((self.isAppearing && self.cancelled)
                || (self.isAppearing == NO && self.cancelled == NO))
                    ? CGPointMake(dynamicView.center.x, -1 * height)
                    : CGPointMake(dynamicView.center.x, 0.f);
                
            self.attachBehavior = [[UIAttachmentBehavior alloc]
                initWithItem: dynamicView
                attachedToAnchor: anchor];
            self.attachBehavior.damping = .1;
            self.attachBehavior.frequency = 3.0;
            self.attachBehavior.length = .5 * frame.size.height;
            
            self.gravityBehavior = [[UIGravityBehavior alloc]
                initWithItems: @[dynamicView]];
            [self.gravityBehavior setMagnitude: 3.f];
            
            [self addChildBehavior: self.attachBehavior];
            [self addChildBehavior: self.collisionBehavior];
            [self addChildBehavior: self.bodyBehavior];
            
            MTDrawerTransitionAnimator *weakSelf = self;
            self.action = ^
            {
                [weakSelf.transitionContext updateInteractiveTransition:
                [weakSelf percentComplete]];
            };
            [self.animator addBehavior:self];
        }
        break;

        default:
        break;
    }
}

- (void)showDrawer
{
    self.appearing = YES;
    [self.homeController presentViewController: self.homeController.drawerController
        animated: YES
        completion: nil];
}

- (void)hideDrawer
{
    if (self.percentComplete == 0.f)
    {
        self.appearing = NO;
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
    
    [self.homeController.navigationController.view drawViewHierarchyInRect: CGRectMake(0.f, self.homeController.view.frame.origin.y, size.width, size.height) afterScreenUpdates: NO];
    
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    // blur the UIImage
    _blurredImage = [viewImage applyLightEffect];

    self.homeController.drawerController.bkgImage.image = _blurredImage;
}

@end
