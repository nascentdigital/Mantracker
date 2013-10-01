#import "MTLocation.h"


#pragma mark Class Definition

@implementation MTLocation


#pragma mark - Public Methods

+ (id)locationWithName: (NSString *)name
	image: (UIImage *) image
{
    MTLocation *location = [[MTLocation alloc]
        init];
    location.name = name;
	location.iconImage = image;
    return location;
}


@end  // @implementation MTLocation
