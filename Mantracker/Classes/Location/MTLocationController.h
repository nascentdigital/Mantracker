#import "MTLocation.h"


#pragma mark Class Declaration

@interface MTLocationController : UIViewController
    <UIGestureRecognizerDelegate>

#pragma mark - Properties

@property (nonatomic, strong) MTLocation *location;
@property (nonatomic, strong) NSIndexPath *locationIndexPath;

@end  // @interface MTLocationController
