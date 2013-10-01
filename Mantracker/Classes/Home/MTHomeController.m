#import "MTHomeController.h"
#import "MTHomeLocationCell.h"
#import "MTLocationController.h"
#import "MTLocation.h"
#import "MTDrawerController.h"
#import "MTDrawerTransitionAnimator.h"


#pragma mark Internal Interface

@interface MTHomeController ()
{
    @private NSMutableArray *_locations;
    @private UIPanGestureRecognizer *_panGestureRecognizer;
#ifdef USE_OS7_API
    @private MTDrawerTransitionAnimator *_drawerTransitionAnimator;
#else
    @private CGPoint _drawerStartCenter;
#endif
}

#ifndef USE_OS7_API
- (IBAction)MT_handlePan:(id)sender;
#endif

@end  // @interface MTHomeController ()



#pragma mark - Class Definition

@implementation MTHomeController


#pragma mark - Constructors

- (id)initWithCoder: (NSCoder *)decoder
{
    // initialize instance
    if ((self = [super initWithCoder: decoder]) != nil)
    {
        // initialize locations
        _locations = [NSMutableArray arrayWithObjects:
            [MTLocation locationWithName: @"My place"],
            [MTLocation locationWithName: @"His place"],
            [MTLocation locationWithName: @"My office"],
            [MTLocation locationWithName: @"His office"],
            [MTLocation locationWithName: @"His parents"],
            [MTLocation locationWithName: @"Mike's house"],
            nil];
    }
    
    // return instance
    return self;
}


#pragma mark - Overridden Methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // instantiate the drawer controller
    _drawerController = [self.storyboard instantiateViewControllerWithIdentifier: @"MTDrawerControllerID"];
#ifdef USE_OS7_API

    // create the transition animator
    _drawerTransitionAnimator = [[MTDrawerTransitionAnimator alloc]
        init];
    _drawerTransitionAnimator.homeController = self;
    
    // set up pan gesture recognizer
    _panGestureRecognizer = [[UIPanGestureRecognizer alloc]
        initWithTarget: _drawerTransitionAnimator
        action: @selector(handleGesture:)];
    _drawerController.transitioningDelegate = _drawerTransitionAnimator;
    _panGestureRecognizer.delegate = _drawerTransitionAnimator;
    
    // add pan gesture recognizer
    [[UIApplication sharedApplication].delegate.window addGestureRecognizer: _panGestureRecognizer];
    
    // set the transition delegate on the drawer controller
    _drawerController.transitioningDelegate = _drawerTransitionAnimator;
#else
    // set up pan gesture recognizer
    _panGestureRecognizer = [[UIPanGestureRecognizer alloc]
        initWithTarget: self
        action: @selector(MT_handlePan:)];
    _panGestureRecognizer.delegate = self;
    
    // add pan gesture recognizer and drawer view
    UIWindow *window = [UIApplication sharedApplication].delegate.window;
    CGSize windowSize = window.frame.size;
    self.drawerView.frame = CGRectMake(0.f, -windowSize.height + 70, windowSize.width, windowSize.height);
    self.drawerView.alpha = 0.f;
    [window addSubview: self.drawerView];
    [window addGestureRecognizer: _panGestureRecognizer];
#endif
}

- (NSInteger)collectionView: (UICollectionView *)collectionView
    numberOfItemsInSection: (NSInteger)section
{
    return _locations.count;
}

- (UICollectionViewCell *)collectionView: (UICollectionView *)collectionView
    cellForItemAtIndexPath: (NSIndexPath *)indexPath
{
    // fetch cell
    MTHomeLocationCell *cell = [collectionView
        dequeueReusableCellWithReuseIdentifier: @"MTHomeLocationCell"
        forIndexPath: indexPath];
    NSAssert(cell != nil, @"Expected reusable cell to be available.");
    
    // bind data to cell
    MTLocation *location = _locations[indexPath.row];
    [cell bindToLocation: location];
    
    // return cell
    return cell;
}

- (void)prepareForSegue: (UIStoryboardSegue *)segue
    sender: (id)sender
{
    if ([segue.identifier isEqualToString: @"locationSelected"])
    {
        // determine selection
        NSArray *indexPaths = [self.collectionView indexPathsForSelectedItems];
        NSIndexPath *indexPath = [indexPaths objectAtIndex: 0];
        
        // pass selected location
        MTLocationController *destinationController =
            segue.destinationViewController;
        destinationController.location = _locations[indexPath.row];
        destinationController.locationIndexPath = indexPath;
        
        // deselect selection
        [self.collectionView deselectItemAtIndexPath: indexPath
            animated: NO];
    }
}


#pragma mark - UINavigationControllerDelegate Methods












#ifndef USE_OS7_API
#pragma mark - UIGestureRecognizerDelegate Methods

- (BOOL)gestureRecognizerShouldBegin: (UIGestureRecognizer *)recognizer
{
    // recognizer should begin only if
    // gesture began from navigation bar and drawer view is not shown,
    // or gesture began from bottom of the screen and drawer view is shown
    CGPoint point =  [recognizer locationInView: self.view];
    CGRect navigationBarFrame = self.navigationController.navigationBar.frame;
    BOOL shouldBegin = ((self.drawerView.alpha == 0
        && point.y < navigationBarFrame.origin.y + navigationBarFrame.size.height)
            || (self.drawerView.alpha == 1
                && point.y > self.view.frame.size.height - 50.f));
    if (shouldBegin == YES)
    {
        _drawerStartCenter = self.drawerView.center;
    }
    return shouldBegin;
}


#pragma mark - Private Methods

- (IBAction)MT_handlePan: (UIPanGestureRecognizer *)recognizer
{
    CGPoint translation = [recognizer translationInView: self.view];
    CGPoint newCenter = CGPointMake(
        _drawerStartCenter.x,
        _drawerStartCenter.y + translation.y);

    UIGestureRecognizerState state = recognizer.state;
    switch (state)
    {
        case UIGestureRecognizerStateBegan:
        {
            self.drawerView.alpha = 0.5f;
            self.drawerView.center = newCenter;
        }
        break;

        case UIGestureRecognizerStateChanged:
        {
            self.drawerView.center = newCenter;
            self.drawerView.alpha = 0.9f;
        }
        break;

        case UIGestureRecognizerStateEnded:
        {
            self.drawerView.alpha = 1.f;
            CGRect drawerFrame = self.drawerView.frame;
            drawerFrame.origin = CGPointMake(0.f, 0.f);
            self.drawerView.frame = drawerFrame;
        }
        break;

        default:
        break;
    }
}
#endif

@end  // @implementation MTHomeController
