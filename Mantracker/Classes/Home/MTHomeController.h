@class MTDrawerController;

#define USE_OS7_API

#pragma mark Class Declaration

@interface MTHomeController : UICollectionViewController<
#ifndef USE_OS7_API
    UIGestureRecognizerDelegate,
    UINavigationControllerDelegate>
#else
    UINavigationControllerDelegate>

@property (nonatomic, readonly) MTDrawerController *drawerController;
#endif
@end  // @interface MTHomeController
