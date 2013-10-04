#import "MTHomeController.h"
#import "MTHomeLocationCell.h"
#import "MTLocationController.h"
#import "MTLocation.h"
#import "MTDrawerController.h"
#import "MTDrawerTransitionAnimator.h"
#import "MTHomeLocationAnimator.h"
#import "MTSettingsManager.h"


#pragma mark Internal Interface

@interface MTHomeController ()
{
    @private UITapGestureRecognizer *_tapGestureRecognizer;
    @private UIPanGestureRecognizer *_panGestureRecognizer;
    @private MTDrawerTransitionAnimator *_drawerTransitionAnimator;
	@private MTHomeLocationAnimator *_homeLocationAnimator;
	@private NSMutableArray *_sameCellImages;
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

    // create the transition animators
    _drawerTransitionAnimator = [[MTDrawerTransitionAnimator alloc]
        init];
    _drawerTransitionAnimator.homeController = self;
	_homeLocationAnimator = [[MTHomeLocationAnimator alloc] init];
	_homeLocationAnimator.homeController = self;
	
    // set up pan gesture recognizer
    _panGestureRecognizer = [[UIPanGestureRecognizer alloc]
        initWithTarget: _drawerTransitionAnimator
        action: @selector(handleGesture:)];
    _drawerController.transitioningDelegate = _drawerTransitionAnimator;
    _panGestureRecognizer.delegate = _drawerTransitionAnimator;
    
    // set up tap gesture recognizer
    _tapGestureRecognizer = [[UITapGestureRecognizer alloc]
        initWithTarget: _drawerTransitionAnimator
        action: @selector(showDrawer)];
    _tapGestureRecognizer.delegate = _drawerTransitionAnimator;
    
    // add pan and tap gesture recognizers
    UIView *window = [UIApplication sharedApplication].delegate.window;
    [window addGestureRecognizer: _panGestureRecognizer];
    [window addGestureRecognizer: _tapGestureRecognizer];
    
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

- (void) viewWillAppear:(BOOL)animated
{
	if ([MTSettingsManager sharedInstance].environmentalFeedback)
	{
		_locations = [NSMutableArray arrayWithObjects:
		  [MTLocation locationWithName: @"Kings Bar"
			image: [UIImage imageNamed: @"main-kingsbar"]],
		  [MTLocation locationWithName: @"Work"
			image: [UIImage imageNamed: @"main-work"]],
		  [MTLocation locationWithName: @"My place"
			image: [UIImage imageNamed: @"main-myplace"]],
		  [MTLocation locationWithName: @"Mystery"
			image: [UIImage imageNamed: @"main-mystery"]],
		  [MTLocation locationWithName: @"Mike's"
			image: [UIImage imageNamed: @"main-mikes"]], nil];
	}
	else
	{
		_locations = [NSMutableArray arrayWithObjects:
		  [MTLocation locationWithName: @"Kings Bar"
			image: [UIImage imageNamed: @"samecolour-kingsbar"]],
		  [MTLocation locationWithName: @"Work"
			image: [UIImage imageNamed: @"samecolour-work"]],
		  [MTLocation locationWithName: @"My place"
			image: [UIImage imageNamed: @"samecolour-myplace"]],
		  [MTLocation locationWithName: @"Mystery"
			image: [UIImage imageNamed: @"samecolour-mystery"]],
		  [MTLocation locationWithName: @"Mike's"
			image: [UIImage imageNamed: @"samecolour-mikes"]], nil];
	}
	
	[self.collectionView reloadData];
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
