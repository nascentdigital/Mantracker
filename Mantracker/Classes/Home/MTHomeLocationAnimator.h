

#pragma mark Class Declaration

@class MTHomeController;

@interface MTHomeLocationAnimator : UIPercentDrivenInteractiveTransition
	<UIViewControllerAnimatedTransitioning,
		UIGestureRecognizerDelegate,
		UIViewControllerInteractiveTransitioning,
		UIViewControllerTransitioningDelegate>


@property (nonatomic, weak) MTHomeController *homeController;


- (void) handlePinch: (UIPinchGestureRecognizer *) gesture;


@end  // @interface MTHomeLocationAnimator
