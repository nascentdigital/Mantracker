#import "MTHomeLocationSegue.h"


#pragma mark Internal Interface

@interface MTHomeLocationSegue ()
{
}

@end  // @interface MTHomeLocationSegue ()


#pragma mark - Class Definition

@implementation MTHomeLocationSegue

#pragma mark - Overridden Methods

- (void)perform
{
    UIViewController *srcController = self.sourceViewController;
    UIViewController *dstController = self.destinationViewController;
    [srcController.navigationController pushViewController: dstController
        animated: YES];
}


@end  // @implementation MTHomeLocationSegue
