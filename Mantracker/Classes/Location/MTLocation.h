

#pragma mark Class Declaration

@interface MTLocation : NSObject


#pragma mark - Properties

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) UIImage *image;


#pragma mark - Class Methods

+ (id)locationWithName: (NSString *)name
	image: (UIImage *) image;

+ (id)locationWithName: (NSString *)name;

@end  // @interface MTLocation
