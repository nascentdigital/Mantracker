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


@interface MTDrawerTransitionAnimator()
{
    @private CGRect _toBeginFrame;
    @private CGRect _toEndFrame;
    @private CGPoint _startingCenter;
}

@property (nonatomic, strong) id<UIViewControllerContextTransitioning>transitionContext;
@property (nonatomic, assign, getter = isAppearing) BOOL appearing;
@property (nonatomic, assign, getter = isCancelled) BOOL cancelled;
@property (nonatomic, assign) float percentComplete;

@property (nonatomic, strong) UIDynamicAnimator *animator;
@property (nonatomic, strong) UIDynamicItemBehavior *bodyBehavior;
@property (nonatomic, strong) UICollisionBehavior *collisionBehavior;
@property (nonatomic, strong) UIAttachmentBehavior *attachBehavior;

@property (nonatomic, weak) UIView *containerView;
@property (nonatomic, weak) UIView *dynamicView;

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
    return self;
}

- (id <UIViewControllerInteractiveTransitioning>)interactionControllerForDismissal:
    (id <UIViewControllerAnimatedTransitioning>)animator
{
    return self;
}


#pragma mark

- (NSTimeInterval)transitionDuration:
    (id<UIViewControllerContextTransitioning>)transitionContext
{
    return 0.3f;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    NSLog(@"starting animation transtion");
    
    UIViewController *fromVC = [transitionContext viewControllerForKey: UITransitionContextFromViewControllerKey];
    UIViewController *toVC = [transitionContext viewControllerForKey: UITransitionContextToViewControllerKey];
    UIView *containerView = [transitionContext containerView];
    
    [UIView animateWithDuration: [self transitionDuration: transitionContext] animations:^{
        if (self.isAppearing)
        {
            toVC.view.frame = _toEndFrame;
        }
        else
        {
            fromVC.view.frame = _toEndFrame;
        }
    } completion:^(BOOL finished) {
       
            BOOL cancelled = [[toVC transitionCoordinator]
                isCancelled];
            [transitionContext completeTransition: cancelled == NO];
    }];
}

- (void)startInteractiveTransition: (id<UIViewControllerContextTransitioning>)transitionContext
{
    NSLog(@"starting interactive transtion");
    _transitionContext = transitionContext;
    UIViewController *fromVC = [transitionContext viewControllerForKey: UITransitionContextFromViewControllerKey];
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
        toVC.view.frame = _toBeginFrame;
        [containerView addSubview: toVC.view];
        _startingCenter = toVC.view.center;
        self.dynamicView = toVC.view;
    }
    else
    {
        [containerView insertSubview: toVC.view
            belowSubview: fromVC.view];
        _startingCenter = fromVC.view.center;
        self.dynamicView = fromVC.view;
    }
}


#pragma mark - UIGestureRecognizerDelegate Methods

- (BOOL)gestureRecognizerShouldBegin: (UIGestureRecognizer *)recognizer
{
    CGPoint point =  [recognizer locationInView:
        self.homeController.navigationController.view];
    CGRect navigationBarFrame = self.homeController.navigationController.navigationBar.frame;
    
    UIViewController *visibleController =
        self.homeController.navigationController.visibleViewController;
            
    if ([visibleController isKindOfClass: [MTHomeController class]]
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
        [self.homeController.drawerController dismissViewControllerAnimated: YES
            completion: nil];
        return YES;
    }
    
    return NO;
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
                || ABS(translation.y) < height * 0.5f;
            
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

#pragma mark - UIDynamicAnimatorDelegate Methods

- (void)dynamicAnimatorDidPause: (UIDynamicAnimator *)animator
{
    NSLog(@"pause");
    CGPoint velocity = [self.bodyBehavior linearVelocityForItem: self.dynamicView];
    if(velocity.y < .5
        && [[animator behaviors] count] > 0)
    {
        NSLog(@"complete");
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

@end
