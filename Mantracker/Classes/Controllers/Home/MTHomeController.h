@class MTDrawerController;

#pragma mark Class Declaration

@interface MTHomeController : UICollectionViewController<
    UIGestureRecognizerDelegate,
    UINavigationControllerDelegate>

@property (nonatomic, readonly) MTDrawerController *drawerController;
@property (nonatomic, strong) NSMutableArray *locations;

@end  // @interface MTHomeController
