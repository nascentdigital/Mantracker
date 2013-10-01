#import "MTHomeController.h"
#import "MTHomeLocationCell.h"
#import "MTLocationController.h"
#import "MTLocation.h"
#import "MTDrawerController.h"
#import "MTDrawerTransitionAnimator.h"
#import "MTNavigationBar.h"


#pragma mark Internal Interface

@interface MTHomeController ()
{
    @private NSMutableArray *_locations;
    @private UIPanGestureRecognizer *_panGestureRecognizer;
    @private MTDrawerTransitionAnimator *_drawerTransitionAnimator;
}


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
		UIImage *iconImage = [UIImage imageNamed: @"home"];
		_locations = [NSMutableArray arrayWithObjects:
			[MTLocation locationWithName: @"My place" image: iconImage],
			[MTLocation locationWithName: @"His place" image: iconImage],
			[MTLocation locationWithName: @"My office" image: iconImage],
			[MTLocation locationWithName: @"His office" image: iconImage],
			[MTLocation locationWithName: @"His parents" image: iconImage],
			[MTLocation locationWithName: @"Mike's house" image: iconImage],
			nil];
    }
    
    // return instance
    return self;
}

- (void) viewDidLoad
{
//	// create upper and lower snapshots
//	UIView *bottomSnapshot = [self.view resizableSnapshotViewFromRect: CGRectMake(
//			0, self.view.bounds.size.height/2,
//			self.view.bounds.size.width,
//			self.view.bounds.size.height/2)
//		afterScreenUpdates: YES withCapInsets: UIEdgeInsetsZero];
//		
//	UIView *topSnapshot = [self.view resizableSnapshotViewFromRect: CGRectMake(
//			0, 0,
//			self.view.bounds.size.width,
//			self.view.bounds.size.height/2)
//		afterScreenUpdates: YES withCapInsets: UIEdgeInsetsZero];
		
//	[self.view addSubview: topSnapshot];
}

#pragma mark - Overridden Methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // instantiate the drawer controller
    _drawerController = [self.storyboard instantiateViewControllerWithIdentifier: @"MTDrawerControllerID"];

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
    
    if ([self.navigationController.navigationBar isKindOfClass: [MTNavigationBar class]])
    {
        [((MTNavigationBar *)self.navigationController.navigationBar).centerButton
            addTarget: _drawerTransitionAnimator
            action: @selector(showDrawer)
            forControlEvents: UIControlEventTouchUpInside];
    }
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



@end  // @implementation MTHomeController
