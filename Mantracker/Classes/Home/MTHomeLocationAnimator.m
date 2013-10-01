#import "MTHomeLocationAnimator.h"
#import "MTHomeController.h"
#import "MTHomeLocationCell.h"
#import "MTLocationController.h"


#pragma mark Constants

#define MTAnimatorDuration 2.f
#define CELL_SPLIT_YOFFSET 50

#pragma mark - Internal Interface

@interface MTHomeLocationAnimator ()
{
}

@end  // @interface MTHomeLocationAnimator ()


#pragma mark - Class Definition

@implementation MTHomeLocationAnimator


#pragma mark - UIViewControllerAnimatedTransitioning Methods

- (NSTimeInterval)transitionDuration: (id<UIViewControllerContextTransitioning>)context
{
    return MTAnimatorDuration;
}

- (void)animateTransition: (id<UIViewControllerContextTransitioning>)context
{
    // resolve controllers/views
    MTHomeController *homeController = (MTHomeController *)[context
        viewControllerForKey: UITransitionContextFromViewControllerKey];
    UIView *homeView = homeController.view;
    MTLocationController *locationController = (MTLocationController *)[context
        viewControllerForKey: UITransitionContextToViewControllerKey];
    UIView *locationView = locationController.view;
    locationView.alpha = 0.f;
    
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
		
	NSLog(@"home height is: %f \ntop frame height: %f \nbot frame height %f", homeView.frame.size.height, topSnapshotFrame.size.height, botSnapshotFrame.size.height);
	
	// create upper and lower snapshots
	UIView *bottomSnapshot = [homeView resizableSnapshotViewFromRect: botSnapshotFrame
		afterScreenUpdates: NO withCapInsets: UIEdgeInsetsZero];
		
	UIView *topSnapshot = [homeView resizableSnapshotViewFromRect: topSnapshotFrame
		afterScreenUpdates: NO withCapInsets: UIEdgeInsetsZero];
	
	// set snapshot initial positions
	topSnapshot.frame = CGRectMake(
		0, 0,
		topSnapshotFrame.size.width, topSnapshotFrame.size.height);
		
	bottomSnapshot.frame = CGRectMake(
		0, topSnapshotFrame.size.height,
		botSnapshotFrame.size.width, botSnapshotFrame.size.height);
	
	[locationView addSubview: topSnapshot];
	[locationView addSubview: bottomSnapshot];
	locationView.alpha = 1.f;

	// animate
	[UIView animateKeyframesWithDuration: MTAnimatorDuration
		delay: 0.f
		options: 0
		animations:
		^{
			[UIView addKeyframeWithRelativeStartTime: 0.f relativeDuration: 0.3 animations:^{
				topSnapshot.frame = CGRectMake(
					0, -topSnapshot.frame.size.height + CELL_SPLIT_YOFFSET
						+ locationController.navigationController.navigationBar.frame.size.height
						+ locationController.navigationController.navigationBar.frame.origin.y,
					topSnapshot.frame.size.width, topSnapshot.frame.size.height);
					
				bottomSnapshot.frame = CGRectMake(0, homeView.frame.size.height,
					bottomSnapshot.frame.size.width, bottomSnapshot.frame.size.height);
			}];
			
			[UIView addKeyframeWithRelativeStartTime: 0.4f relativeDuration: 0.6f animations:^{
				topSnapshot.alpha = 0.f;
			}];
		}
		completion:
		^(BOOL finished){
			[topSnapshot removeFromSuperview];
			[bottomSnapshot removeFromSuperview];
			[context completeTransition: finished];
		}];
}

@end  // @implementation MTHomeLocationAnimator
