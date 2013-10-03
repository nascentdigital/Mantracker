#import "MTHomeLocationAnimator.h"
#import "MTHomeController.h"
#import "MTHomeLocationCell.h"
#import "MTLocationController.h"


#pragma mark Constants

#define MTAnimatorDuration 1.2f
#define CELL_SPLIT_YOFFSET 68
#define LOCATION_TITLE_XOFFSET 5

#pragma mark - Internal Interface

@interface MTHomeLocationAnimator ()
{
	@private CGRect _topSnapStartFrame;
	@private CGRect _topSnapEndFrame;
	@private CGRect _botSnapStartFrame;
	@private CGRect _botSnapEndFrame;
	@private UIView *_topSnapView;
	@private UIView *_botSnapView;
	@private CGFloat _startScale;
}

@end  // @interface MTHomeLocationAnimator ()


#pragma mark - Class Definition

@implementation MTHomeLocationAnimator


#pragma mark - UIViewControllerAnimatedTransitioning Methods

- (NSTimeInterval)transitionDuration: (id<UIViewControllerContextTransitioning>)context
{
    return MTAnimatorDuration;
}

// DEMO: 3c Custom Transitions
- (void)animateTransition: (id<UIViewControllerContextTransitioning>)context
{
	MTHomeController *homeController;
	MTLocationController *locationController;
	BOOL transitionIsForward = YES;

	// resolve controllers
	if ([[context viewControllerForKey: UITransitionContextFromViewControllerKey]
		isKindOfClass: [MTHomeController class]])
	{
		homeController = (MTHomeController *)[context
			viewControllerForKey: UITransitionContextFromViewControllerKey];
		locationController = (MTLocationController *)[context
			viewControllerForKey: UITransitionContextToViewControllerKey];
	}
	else
	{
		locationController = (MTLocationController *)[context
			viewControllerForKey: UITransitionContextFromViewControllerKey];
		homeController = (MTHomeController *)[context
			viewControllerForKey: UITransitionContextToViewControllerKey];
		transitionIsForward = NO;
	}
    
	// get views
	UIView *locationView = locationController.view;
	UIView *homeView = homeController.view;
	locationView.alpha = 0.f;
	
	// transition from home to location
	if (transitionIsForward)
	{
		// bind views to container
		[context.containerView addSubview: homeView];
		[context.containerView addSubview: locationView];
		
		// determine selected cell and frame
		MTHomeLocationCell *cell = (MTHomeLocationCell *)[homeController.collectionView
			cellForItemAtIndexPath: locationController.locationIndexPath];
		CGRect cellFrame = [cell convertRect: cell.bounds
			toView: homeController.view];
		
		// set area we want to snapshot
		CGRect topSnapshotFrame = CGRectMake(
			0, 0,
			homeView.frame.size.width, cellFrame.origin.y + CELL_SPLIT_YOFFSET);

		CGRect botSnapshotFrame = CGRectMake(
			0, cellFrame.origin.y + CELL_SPLIT_YOFFSET,
			homeView.frame.size.width,
			homeView.frame.size.height - topSnapshotFrame.size.height);
		
		// create upper and lower snapshots
		_botSnapView = [homeView resizableSnapshotViewFromRect: botSnapshotFrame
			afterScreenUpdates: NO withCapInsets: UIEdgeInsetsZero];
			
		_topSnapView = [homeView resizableSnapshotViewFromRect: topSnapshotFrame
			afterScreenUpdates: NO withCapInsets: UIEdgeInsetsZero];
		
		// set snapshot initial positions
		_topSnapStartFrame  = CGRectMake(
			0, 0,
			topSnapshotFrame.size.width, topSnapshotFrame.size.height);
			
		_botSnapStartFrame = CGRectMake(
			0, topSnapshotFrame.size.height,
			botSnapshotFrame.size.width, botSnapshotFrame.size.height);
		
		_topSnapView.frame = _topSnapStartFrame;
		_botSnapView.frame = _botSnapStartFrame;
		
		[locationView addSubview: _topSnapView];
		[locationView addSubview: _botSnapView];
		locationView.alpha = 1.f;

		// animate
		[UIView animateKeyframesWithDuration: MTAnimatorDuration
			delay: 0.f
			options: 0
			animations:
			^{
				[UIView addKeyframeWithRelativeStartTime: 0.f relativeDuration: 0.2 animations:^{
					[UIView setAnimationCurve: UIViewAnimationCurveEaseIn];
					_topSnapEndFrame = CGRectMake(
						0, -_topSnapView.frame.size.height + CELL_SPLIT_YOFFSET
							+ locationController.navigationController.navigationBar.frame.size.height
							+ locationController.navigationController.navigationBar.frame.origin.y,
						_topSnapView.frame.size.width, _topSnapView.frame.size.height);
					_topSnapView.frame = _topSnapEndFrame;
						
					_botSnapEndFrame = CGRectMake(0, homeView.frame.size.height,
						_botSnapView.frame.size.width, _botSnapView.frame.size.height);
					_botSnapView.frame = _botSnapEndFrame;
				}];
				
				[UIView addKeyframeWithRelativeStartTime: 0.2f relativeDuration: 0.8f animations:^{
					_topSnapView.alpha = 0.f;
				}];
			}
			completion:
			^(BOOL finished){
				[_topSnapView removeFromSuperview];
				[_botSnapView removeFromSuperview];

                // DEMO: 3d Custom Transitions
				[context completeTransition: finished];
			}];
	}
	// transitiong is from location to home
	else
	{
		// bind views to container
		[context.containerView addSubview: locationView];
		[context.containerView addSubview: homeView];
		
		// set up snapshots
		_topSnapView.frame = _topSnapEndFrame;
		_botSnapView.frame = _botSnapEndFrame;
		
		// create snapshot of location title
		UIView *titleSnap = [locationView resizableSnapshotViewFromRect: locationController.titleImage.frame
			afterScreenUpdates: NO withCapInsets: UIEdgeInsetsZero];
		
		// set title snapshot position
		titleSnap.frame = locationController.titleImage.frame;
		
		// add snapshots to animation container
		[context.containerView addSubview: _topSnapView];
		[context.containerView addSubview: _botSnapView];
		[context.containerView addSubview: titleSnap];
		
		// reset properties
		_topSnapView.alpha = 1.f;
		homeView.alpha = 0;
		locationView.alpha = 1.f;
		
		// animate back to home
		[UIView animateWithDuration: MTAnimatorDuration/2
			delay: 0.f
			options: UIViewAnimationOptionCurveEaseOut
			animations:
			^{
				_topSnapView.frame = _topSnapStartFrame;
				_botSnapView.frame = _botSnapStartFrame;
				titleSnap.frame = CGRectMake(LOCATION_TITLE_XOFFSET,
					_topSnapStartFrame.size.height - CELL_SPLIT_YOFFSET,
					titleSnap.frame.size.width,
					titleSnap.frame.size.height);
				titleSnap.alpha = 0.f;
			}
			completion:
			^(BOOL finished){
				[_topSnapView removeFromSuperview];
				[_botSnapView removeFromSuperview];
				[titleSnap removeFromSuperview];
				homeView.alpha = 1.f;
				[context completeTransition: finished];
                
			}];
	}
	
}


@end  // @implementation MTHomeLocationAnimator
