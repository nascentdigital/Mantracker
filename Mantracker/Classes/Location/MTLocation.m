#import "MTLocation.h"


#pragma mark Class Definition

@implementation MTLocation


#pragma mark - Public Methods

+ (id)locationWithName: (NSString *)name
{
    MTLocation *location = [[MTLocation alloc]
        init];
    location.name = name;
    return location;
}


@end  // @implementation MTLocation
