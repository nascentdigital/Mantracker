#import "MTLocationController.h"


#pragma mark Internal Interface

@interface MTLocationController ()
{
}

#pragma mark - Properties

@property (nonatomic, weak) IBOutlet UILabel *titleLabel;


@end  // @interface MTLocationController ()



#pragma mark - Class Definition

@implementation MTLocationController


#pragma mark - Constructors

- (id)initWithCoder: (NSCoder *)decoder
{
    // initialize instance
    if ((self = [super initWithCoder: decoder]) != nil)
    {
    }
    
    // return instance
    return self;
}


#pragma mark - Overridden Methods

- (void)viewDidLoad
{
    // call base implementation
    [super viewDidLoad];
    
    // initialize label with location
    _titleLabel.text = _location.name;
}

@end  // @implementation MTLocationController
