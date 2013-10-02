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
    @private BOOL _facePositionTracking;
}

#pragma mark - Properties

@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UIImageView *faceImage;
@property (nonatomic, weak) IBOutlet UIImageView *cloud1Image;
@property (nonatomic, weak) IBOutlet UIImageView *cloud2Image;
@property (nonatomic, weak) IBOutlet UIImageView *checkInImage;
@property (nonatomic, weak) IBOutlet UIImageView *avgTimeImage;
@property (nonatomic, weak) IBOutlet UIImageView *noteImage;


#pragma mark - Methods

- (void)beginFaceDynamicsWithVelocity: (CGPoint)velocity;
- (void)cancelFaceDynamics;
- (void)endFaceDynamics;


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

- (void) viewWillAppear:(BOOL)animated
{
	// animate clouds
	[UIView animateWithDuration: 1.f
		delay: 2.f
		options: 0//UIViewAnimationOptionRepeat
		animations:
		^{
			self.cloud1Image.frame = CGRectMake(0.f, self.cloud1Image.frame.origin.y, self.cloud1Image.frame.size.width, self.cloud1Image.frame.size.height);
			self.cloud2Image.frame = CGRectMake(0.f, self.cloud2Image.frame.origin.y, self.cloud2Image.frame.size.width, self.cloud2Image.frame.size.height);
			self.noteImage.frame = CGRectMake(100, 100, 200, 200);
		}
		completion:
		^(BOOL finished){
			if (!finished)
			{
				NSLog(@"not finished");
			}
			else
			{
				NSLog(@"finished");
			}
		}];
}

- (void)observeValueForKeyPath: (NSString *)keyPath
    ofObject: (id)object
    change: (NSDictionary *)change
    context: (void *)context
{
    // handle center changes
    if (object == _faceImage)
    {
        // cancel any existing timer
        [NSObject cancelPreviousPerformRequestsWithTarget: self
            selector: @selector(endFaceDynamics)
            object: nil];
        
        // restart timer
        [self performSelector: @selector(endFaceDynamics)
            withObject: nil
            afterDelay: 1.0];
    }
}

#pragma mark - Helper Methods

- (void)beginFaceDynamicsWithVelocity: (CGPoint)velocity
{
    // stop previous dynamics (if any)
    [self cancelFaceDynamics];

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
    
    // start observing animations
    [_faceImage addObserver: self
        forKeyPath: @"center"
        options: NSKeyValueObservingOptionNew
        context: NULL];
    _facePositionTracking = YES;
}

- (void)cancelFaceDynamics
{
    if (_dynamicAnimator != nil)
    {
        // cancel any existing timer
        [NSObject cancelPreviousPerformRequestsWithTarget: self
            selector: @selector(endFaceDynamics)
            object: nil];

        // stop observing
        if (_facePositionTracking)
        {
            _facePositionTracking = NO;
            [_faceImage removeObserver: self
                forKeyPath: @"center"];
        }
    
        // tear down animator
        [_dynamicAnimator removeAllBehaviors];
        _dynamicAnimator = nil;
    }
}

- (void)endFaceDynamics
{
    // cancel any previous dynamics
    [self cancelFaceDynamics];
    
    // create animator
    _dynamicAnimator = [[UIDynamicAnimator alloc]
        initWithReferenceView: self.view];

    // add snap
    UISnapBehavior *snap = [[UISnapBehavior alloc]
        initWithItem: _faceImage
        snapToPoint: _faceStartLocation];        
    [_dynamicAnimator addBehavior: snap];
}

- (IBAction)onFacePan: (UIPanGestureRecognizer *)recognizer
{
    // handle gesture
    switch (recognizer.state)
    {
        case UIGestureRecognizerStateBegan:
        {
            // cancel any previous "snap back"
            [self cancelFaceDynamics];
        
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
            [self beginFaceDynamicsWithVelocity: velocity];
            
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
