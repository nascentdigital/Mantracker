#import "MTNavigationDelegate.h"
#import "MTHomeController.h"
#import "MTLocationController.h"
#import "MTHomeLocationAnimator.h"


#pragma mark Internal Interface

@interface MTNavigationDelegate ()
{
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
    // push operations
    if (operation == UINavigationControllerOperationPush)
    {
        // handle pushing to location from home
        if ([dstController isMemberOfClass: [MTLocationController class]])
        {
            return [[MTHomeLocationAnimator alloc]
                init];
        }
    }
    
    // pop operations
    else if (operation == UINavigationControllerOperationPop)
    {
        // handle poping from location to home
        if ([srcController isMemberOfClass: [MTLocationController class]]
            && [dstController isMemberOfClass: [MTHomeController class]])
        {
        }
    }
    
    // otherwise, do not use custom animations
    return nil;
}


@end  // @implementation MTNavigationDelegate
