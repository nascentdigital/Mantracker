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
- (void)animateFaceCollision;

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
}


-(void) VC_parallaxEffect
{
    //Parallax effect on home background image
    CGFloat parallaxBoundaryOffset = 20.0f;
    UIInterpolatingMotionEffect *xAxis = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.x" type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
    xAxis.minimumRelativeValue = [NSNumber numberWithFloat:-parallaxBoundaryOffset];
    xAxis.maximumRelativeValue = [NSNumber numberWithFloat:parallaxBoundaryOffset];
    
    
    UIInterpolatingMotionEffect *yAxis = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.y" type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
    yAxis.minimumRelativeValue = [NSNumber numberWithFloat:parallaxBoundaryOffset];
    yAxis.maximumRelativeValue = [NSNumber numberWithFloat:-parallaxBoundaryOffset];
    
    UIMotionEffectGroup *group = [[UIMotionEffectGroup alloc] init];
    group.motionEffects = @[yAxis,xAxis];
    
    [self.houseImage addMotionEffect:group];
	[self.skyImage addMotionEffect: group];
}

- (void) animateCloud1
{
	[UIView animateWithDuration: 0.1
		delay: 0.f
		options: 0
		animations: nil
		completion:
		^(BOOL finished){
			[UIView animateWithDuration: 45.f
				delay: 0.f
				options: UIViewAnimationOptionCurveLinear //UIViewAnimationOptionCurveEaseIn
				animations:
				^{
					self.cloud1Image.frame = CGRectMake(
						-90,
						self.cloud1Image.frame.origin.y,
						self.cloud1Image.frame.size.width,
						self.cloud1Image.frame.size.height);
				}
				completion:
				^(BOOL finished){
					self.cloud1Image.frame = CGRectMake(
						365,
						self.cloud1Image.frame.origin.y,
						self.cloud1Image.frame.size.width,
						self.cloud1Image.frame.size.height);
					[self animateCloud1];
				}];
		}];
		
	
}

- (void) animateCloud2
{
	[UIView animateWithDuration: 0.1
		delay: 0.f
		options: 0
		animations: nil
		completion:
		^(BOOL finished){
			[UIView animateWithDuration: 30.f
				delay: 0.f
				options: UIViewAnimationOptionCurveLinear//UIViewAnimationOptionCurveEaseIn
				animations:
				^{
					self.cloud2Image.frame = CGRectMake(
						-85,
						self.cloud2Image.frame.origin.y,
						self.cloud2Image.frame.size.width,
						self.cloud2Image.frame.size.height);
				}
				completion:
				^(BOOL finished){
					self.cloud2Image.frame = CGRectMake(
						320,
						self.cloud2Image.frame.origin.y,
						self.cloud2Image.frame.size.width,
						self.cloud2Image.frame.size.height);
					[self animateCloud2];
				}];
		}];
}

- (void) viewDidAppear:(BOOL)animated
{
	[self animateCloud1];
	[self animateCloud2];
}

#pragma mark - Helper Methods

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

- (void)animateFaceCollision
{
    NSLog(@"TODO: animate face collision");

    // cancel any existing timer
    [NSObject cancelPreviousPerformRequestsWithTarget: self
        selector: @selector(endFaceDynamics)
        object: nil];
    
    // restart timer
    [self performSelector: @selector(endFaceDynamics)
        withObject: nil
        afterDelay: MTFacePlayTimeoutSeconds];
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


#pragma mark - UICollisionBehaviorDelegate Methods

- (void)collisionBehavior: (UICollisionBehavior *)behavior
    beganContactForItem: (id <UIDynamicItem>)item
    withBoundaryIdentifier: (id <NSCopying>)identifier
    atPoint: (CGPoint)position
{
    [self animateFaceCollision];
}


@end  // @implementation MTLocationController
