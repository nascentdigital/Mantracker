#import "MTLocationController.h"


#pragma mark Constants

#define MTFaceVelocityMax           2.f
#define MTFaceVelocityMultiplier    0.005f
#define MTFacePlayTimeoutSeconds    2.0


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
@property (nonatomic, weak) IBOutlet UIImageView *cloud1Image;
@property (nonatomic, weak) IBOutlet UIImageView *cloud2Image;
@property (nonatomic, weak) IBOutlet UIImageView *checkInImage;
@property (nonatomic, weak) IBOutlet UIImageView *avgTimeImage;
@property (nonatomic, weak) IBOutlet UIImageView *noteImage;
@property (nonatomic, weak) IBOutlet UIImageView *skyImage;
@property (nonatomic, weak) IBOutlet UIImageView *houseImage;

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
    
    // create animator
    _dynamicAnimator = [[UIDynamicAnimator alloc]
        initWithReferenceView: self.view];
    _dynamicAnimator.delegate = self;
	
	[self addParallaxEffectTo: self.houseImage withXOffset: 10.f yOffset: 20.f];
	[self addParallaxEffectTo: self.skyImage withXOffset: 10.f yOffset: 20.f];
	[self addParallaxEffectTo: self.cloud1Image withXOffset: 10.f yOffset: 20.f];
	[self addParallaxEffectTo: self.cloud2Image withXOffset: 10.f yOffset: 20.f];
	[self addParallaxEffectTo:self.faceImage withXOffset: 5.f yOffset: 10.f];
}

- (void) viewDidAppear:(BOOL)animated
{
	[self animateCloud: self.cloud1Image
		withDuration: 45.f toX: -90 resetX: 365];
	[self animateCloud: self.cloud2Image
		withDuration: 30.f toX: -85 resetX: 320];
}


#pragma mark - Helper Methods

-(void) addParallaxEffectTo: (UIView *) view
	withXOffset: (CGFloat) xOffset
	yOffset: (CGFloat) yOffset
{
    UIInterpolatingMotionEffect *xAxis = [[UIInterpolatingMotionEffect alloc]
		initWithKeyPath: @"center.x"
		type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
    xAxis.minimumRelativeValue = [NSNumber numberWithFloat: -xOffset];
    xAxis.maximumRelativeValue = [NSNumber numberWithFloat: xOffset];
    
    
    UIInterpolatingMotionEffect *yAxis = [[UIInterpolatingMotionEffect alloc]
		initWithKeyPath: @"center.y"
		type: UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
    yAxis.minimumRelativeValue = [NSNumber numberWithFloat: -yOffset];
    yAxis.maximumRelativeValue = [NSNumber numberWithFloat: yOffset];
    
    UIMotionEffectGroup *group = [[UIMotionEffectGroup alloc] init];
    group.motionEffects = @[yAxis, xAxis];
	
	[view addMotionEffect: group];
}

- (void) animateCloud: (UIImageView *) cloud
	withDuration: (CGFloat) duration
	toX: (CGFloat) toX resetX: (CGFloat) resetX
{
	[UIView animateWithDuration: 0.1
		delay: 0.f
		options: 0
		animations: nil
		completion:
		^(BOOL finished){
			[UIView animateWithDuration: duration
				delay: 0.f
				options: UIViewAnimationOptionCurveLinear
				animations:
				^{
					cloud.frame = CGRectMake(
						toX,
						cloud.frame.origin.y,
						cloud.frame.size.width,
						cloud.frame.size.height);
				}
				completion:
				^(BOOL finished){
					cloud.frame = CGRectMake(
						resetX,
						cloud.frame.origin.y,
						cloud.frame.size.width,
						cloud.frame.size.height);
						
					[self animateCloud: cloud
						withDuration: duration toX: toX resetX: resetX];
				}];
		}];
}

- (void)beginFaceDynamicsWithVelocity: (CGPoint)velocity
{
    // stop previous dynamics (if any)
    [self cancelFaceDynamics];

    // TODO: make gravity responsive to accelerometer or motion effects
    // add gravity
    UIGravityBehavior *gravity = [[UIGravityBehavior alloc]
        initWithItems: @[_faceImage ]];
    [_dynamicAnimator addBehavior: gravity];
    
    // add collision components
    UICollisionBehavior *collision = [[UICollisionBehavior alloc]
        initWithItems: @[ _faceImage ]];
    //[collision addBoundaryWithIdentifier: @"title"
    //    forPath: [UIBezierPath bezierPathWithRect: _titleLabel.frame]];
	[collision addBoundaryWithIdentifier: @"checkIn"
        forPath: [UIBezierPath bezierPathWithRect: _checkInImage.frame]];
	[collision addBoundaryWithIdentifier: @"note"
        forPath: [UIBezierPath bezierPathWithRect: _noteImage.frame]];
    collision.translatesReferenceBoundsIntoBoundary = YES;
    collision.collisionDelegate = self;
    [_dynamicAnimator addBehavior: collision];

    // add dynamics behavior for initial velocity
    UIDynamicItemBehavior *properties = [[UIDynamicItemBehavior alloc]
        initWithItems: @[_faceImage]];
    [properties addLinearVelocity: velocity
        forItem: _faceImage];
    [_dynamicAnimator addBehavior: properties];
}

- (void)cancelFaceDynamics
{
    // cancel any existing timer
    [NSObject cancelPreviousPerformRequestsWithTarget: self
        selector: @selector(endFaceDynamics)
        object: nil];

    // tear down animator
    [_dynamicAnimator removeAllBehaviors];
}

- (void)endFaceDynamics
{
    // cancel any previous dynamics
    [self cancelFaceDynamics];
    
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


#pragma mark - UIDynamicAnimatorDelegate Methods

- (void)dynamicAnimatorWillResume: (UIDynamicAnimator*)animator
{
}

- (void)dynamicAnimatorDidPause: (UIDynamicAnimator*)animator
{
    // snap back if not at center
    CGPoint facePosition = _faceImage.center;
    if (facePosition.x != _faceStartLocation.x
        || facePosition.y != _faceStartLocation.y)
    {
        // cancel any existing timer
        [NSObject cancelPreviousPerformRequestsWithTarget: self
            selector: @selector(endFaceDynamics)
            object: nil];
        
        // restart timer
        [self performSelector: @selector(endFaceDynamics)
            withObject: nil
            afterDelay: MTFacePlayTimeoutSeconds];
    }
}


#pragma mark - UICollisionBehaviorDelegate Methods

- (void)collisionBehavior: (UICollisionBehavior *)behavior
    beganContactForItem: (id <UIDynamicItem>)item
    withBoundaryIdentifier: (id <NSCopying>)identifier
    atPoint: (CGPoint)position
{
    // TODO: animate face collision
}


@end  // @implementation MTLocationController
