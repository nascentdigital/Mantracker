@class MTDrawerController;

#pragma mark Class Declaration

@interface MTHomeController : UICollectionViewController<
    UIGestureRecognizerDelegate,
    UINavigationControllerDelegate>

@property (nonatomic, readonly) MTDrawerController *drawerController;

@end  // @interface MTHomeController
