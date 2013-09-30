#import "MTHomeLocationAnimator.h"
#import "MTHomeController.h"
#import "MTHomeLocationCell.h"
#import "MTLocationController.h"


#pragma mark Constants

#define MTAnimatorDuration 0.5


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
    
    // calculate animation values
    CGRect homeBounds = homeController.view.bounds;
    CGFloat scale = homeBounds.size.width / cellFrame.size.width;
    CGFloat dx = (homeBounds.size.width / 2.f) - (cellFrame.origin.x
        + cellFrame.size.width / 2.f);
    CGFloat dy = (homeBounds.size.height / 2.f) - (cellFrame.origin.y
        + cellFrame.size.height / 2.f);
    NSLog(@"animation (%.2f, %.2f, %.2f)", scale, dx, dy);

    // animate
    [UIView animateWithDuration: MTAnimatorDuration
        delay: 0.f
        options: UIViewAnimationOptionCurveEaseOut
        animations: ^
        {
            CGAffineTransform transform = CGAffineTransformMakeScale(
                scale, scale);
            transform = CGAffineTransformTranslate(transform, dx, dy);
            homeView.transform = transform;
            
            cell.backgroundImage.alpha = 0.f;
        }
        completion: ^(BOOL finished)
        {
            [context completeTransition: finished];
            
            // reset transform
            homeView.alpha = 1.f;
            homeView.transform = CGAffineTransformIdentity;
            
            cell.backgroundImage.alpha = 1.f;
        }];
    [UIView animateWithDuration: MTAnimatorDuration * 0.4
        delay: MTAnimatorDuration * 0.6
        options: UIViewAnimationOptionCurveEaseIn
        animations: ^
        {
            locationView.alpha = 1.f;
        }
        completion: ^(BOOL finished)
        {
        }];
}

@end  // @implementation MTHomeLocationAnimator
