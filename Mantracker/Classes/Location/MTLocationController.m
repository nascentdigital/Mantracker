#import "MTLocationController.h"


#pragma mark Internal Interface

@interface MTLocationController ()
{
    @private CGPoint _faceOffset;
}

#pragma mark - Properties

@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UIImageView *faceImage;


#pragma mark - Methods

- (IBAction)onFacePan: (UIGestureRecognizer *)recognizer;


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


#pragma mark - Helper Methods

- (IBAction)onFacePan: (UIGestureRecognizer *)recognizer
{
    switch (recognizer.state)
    {
case UIGestureRecognizerStateBegan:
{

    break;
}
default:
break;
}
    CGPoint location = [recognizer locationOfTouch: 0
        inView: recognizer.view];
    location.x += _faceOffset.x;
    location.y += _faceOffset.y;
    _faceImage.center = location;
}


#pragma mark - UIGestureRecognizerDelegate Methods

- (BOOL)gestureRecognizerShouldBegin: (UIGestureRecognizer *)recognizer
{
    // determine touch point
    UIView *view = recognizer.view;
    CGPoint location = [recognizer locationOfTouch: 0
        inView: view];
    
    // start tracking if face is touched
    BOOL faceTouched = CGRectContainsPoint(_faceImage.frame, location);
    if (faceTouched)
    {
        CGPoint faceCenter = _faceImage.center;
        _faceOffset = CGPointMake(faceCenter.x - location.x,
            faceCenter.y - location.y);
        return YES;
    }
    
    // or cancel gesture recognizing
    else
    {
        return NO;
    }
}


@end  // @implementation MTLocationController
