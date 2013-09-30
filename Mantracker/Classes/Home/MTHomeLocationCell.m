#import "MTHomeLocationCell.h"


#pragma mark Internal Interface

@interface MTHomeLocationCell ()
{
}

#pragma mark - Properties

@property (nonatomic, weak) IBOutlet UILabel *titleLabel;


@end  // @interface MTHomeLocationCell ()


#pragma mark - Class Definition

@implementation MTHomeLocationCell

#pragma mark - Public Methods

- (void)bindToLocation: (MTLocation *)location
{
    _titleLabel.text = location.name;
}


@end  // @implementation MTHomeLocationCell
