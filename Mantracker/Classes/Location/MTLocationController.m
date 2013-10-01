#import "MTLocationController.h"


#pragma mark Constants

#define MTFaceVelocityMax           2.f
#define MTFaceVelocityMultiplier    0.005f


#pragma mark - Internal Interface

@interface MTLocationController ()
{
    @private __strong UIDynamicAnimator *_dynamicAnimator;
    @private CGPoint _faceStartLocation;
    @private CGPoint _faceOffset;
}

#pragma mark - Properties

@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UIImageView *faceImage;


#pragma mark - Methods

- (void)beginFaceDynamicWithVelocity: (CGPoint)velocity;
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
    
    // track initial face location
    _faceStartLocation = _faceImage.center;
    
    // initialize label with location
    _titleLabel.text = _location.name;
}


#pragma mark - Helper Methods

- (void)beginFaceDynamicWithVelocity: (CGPoint)velocity
{
    // stop previous dynamics (if any)
    if (_dynamicAnimator != nil)
    {
        [_dynamicAnimator removeAllBehaviors];
        _dynamicAnimator = nil;
    }

    // create animator
    _dynamicAnimator = [[UIDynamicAnimator alloc]
        initWithReferenceView: self.view];

    // TODO: make gravity responsive to accelerometer or motion effects
    // add gravity
    UIGravityBehavior *gravity = [[UIGravityBehavior alloc]
        initWithItems: @[_faceImage ]];
    [_dynamicAnimator addBehavior: gravity];
    
    // add collision components
    UICollisionBehavior *collision = [[UICollisionBehavior alloc]
        initWithItems: @[ _faceImage ]];
    [collision addBoundaryWithIdentifier: @"title"
        forPath: [UIBezierPath bezierPathWithRect: _titleLabel.frame]];
    collision.translatesReferenceBoundsIntoBoundary = YES;
    [_dynamicAnimator addBehavior: collision];

    // normalize and clamp velocity
    velocity.x = MAX(-MTFaceVelocityMax, MIN(MTFaceVelocityMax,
        velocity.x * MTFaceVelocityMultiplier));
    velocity.y = MAX(-MTFaceVelocityMax, MIN(MTFaceVelocityMax,
        velocity.y * MTFaceVelocityMultiplier));

    // add push
    UIPushBehavior *push = [[UIPushBehavior alloc]
        initWithItems: @[_faceImage]
        mode: UIPushBehaviorModeInstantaneous];
    push.pushDirection = CGVectorMake(velocity.x, velocity.y);
    [_dynamicAnimator addBehavior: push];
    
    NSLog(@"started face animation with velocity: (%.2f, %.2f)",
        velocity.x, velocity.y);
}

- (IBAction)onFacePan: (UIPanGestureRecognizer *)recognizer
{
    // handle gesture
    switch (recognizer.state)
    {
        case UIGestureRecognizerStateBegan:
        {
            // capture relative offset on drag start
            CGPoint location = [recognizer locationOfTouch: 0
                inView: recognizer.view];
            CGPoint faceCenter = _faceImage.center;
            _faceOffset = CGPointMake(faceCenter.x - location.x,
                faceCenter.y - location.y);
            
            break;
        }

        case UIGestureRecognizerStateChanged:
        {
            // determine touch location
            CGPoint location = [recognizer locationOfTouch: 0
                inView: recognizer.view];

            // update face position (accounting for initial offset)
            location.x += _faceOffset.x;
            location.y += _faceOffset.y;
            _faceImage.center = location;
            
            break;
        }

        case UIGestureRecognizerStateCancelled:
        {
            break;
        }

        case UIGestureRecognizerStateEnded:
        {
            // determine velocity
            CGPoint velocity = [recognizer velocityInView: recognizer.view];
            
            // start animating based on current velocity
            [self beginFaceDynamicWithVelocity: velocity];
            
            break;
        }

        default:
            break;
    }
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
    return faceTouched;
}


@end  // @implementation MTLocationController
