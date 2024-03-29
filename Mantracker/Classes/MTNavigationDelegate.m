#import "MTNavigationDelegate.h"
#import "MTHomeController.h"
#import "MTLocationController.h"
#import "MTHomeLocationAnimator.h"
#import "MTSettingsManager.h"


#pragma mark Internal Interface

@interface MTNavigationDelegate ()
{
	@private __strong MTHomeLocationAnimator *_homeLocationAnimator;
}

@end  // @interface MTNavigationDelegate ()


#pragma mark - Class Definition

@implementation MTNavigationDelegate

#pragma mark - Delegate Methods

- (id <UIViewControllerAnimatedTransitioning>)navigationController: (UINavigationController *)navigationController
    animationControllerForOperation: (UINavigationControllerOperation)operation
    fromViewController: (UIViewController *)srcController
    toViewController: (UIViewController *)dstController
{
    // disable transition if not set
    if ([MTSettingsManager sharedInstance].customTransitions == NO)
    {
        return nil;
    }

    // DEMO: 3b Custom Transitions
    // push operations
    if (operation == UINavigationControllerOperationPush)
    {
        // handle pushing to location from home
        if ([dstController isMemberOfClass: [MTLocationController class]])
        {
            _homeLocationAnimator = [[MTHomeLocationAnimator alloc]
                init];
			return _homeLocationAnimator;
        }
    }
    
    // pop operations
    else if (operation == UINavigationControllerOperationPop)
    {
        // handle poping from location to home
        if ([srcController isMemberOfClass: [MTLocationController class]]
            && [dstController isMemberOfClass: [MTHomeController class]])
        {
			return _homeLocationAnimator;
        }
    }
    
    // otherwise, do not use custom animations
    return nil;
}


@end  // @implementation MTNavigationDelegate
