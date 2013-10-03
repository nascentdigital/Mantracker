#import "MTLocation.h"


#pragma mark Class Declaration

@interface MTLocationController : UIViewController
    <UIGestureRecognizerDelegate,
    UIDynamicAnimatorDelegate,
    UICollisionBehaviorDelegate>

#pragma mark - Properties

@property (nonatomic, strong) MTLocation *location;
@property (nonatomic, strong) NSIndexPath *locationIndexPath;
@property (nonatomic, weak) IBOutlet UIImageView *titleImage;

@end  // @interface MTLocationController
