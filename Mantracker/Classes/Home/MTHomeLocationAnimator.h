

#pragma mark Class Declaration

@class MTHomeController;

@interface MTHomeLocationAnimator : NSObject
	<UIViewControllerAnimatedTransitioning,
		UIGestureRecognizerDelegate,
		UIViewControllerTransitioningDelegate>


@property (nonatomic, weak) MTHomeController *homeController;


@end  // @interface MTHomeLocationAnimator
