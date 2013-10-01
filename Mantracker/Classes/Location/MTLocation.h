

#pragma mark Class Declaration

@interface MTLocation : NSObject


#pragma mark - Properties

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) UIImage *iconImage;

#pragma mark - Class Methods

+ (id)locationWithName: (NSString *)name
	image: (UIImage *) image;



@end  // @interface MTLocation
