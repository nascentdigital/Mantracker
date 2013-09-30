#import "MTLocation.h"


#pragma mark Class Declaration

@interface MTHomeLocationCell : UICollectionViewCell


#pragma mark - Properties

@property (nonatomic, weak) IBOutlet UIImageView *backgroundImage;


#pragma mark - Methods

- (void)bindToLocation: (MTLocation *)location;

@end  // @interface MTHomeLocationCell
