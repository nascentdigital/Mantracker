#import "MTHomeController.h"
#import "MTHomeLocationCell.h"
#import "MTLocationController.h"
#import "MTLocation.h"
#import "MTDrawerController.h"
#import "MTDrawerTransitionAnimator.h"
#import "MTHomeLocationAnimator.h"


#pragma mark Internal Interface

@interface MTHomeController ()
{
    @private UITapGestureRecognizer *_tapGestureRecognizer;
    @private UIPanGestureRecognizer *_panGestureRecognizer;
    @private MTDrawerTransitionAnimator *_drawerTransitionAnimator;
	@private MTHomeLocationAnimator *_homeLocationAnimator;
	@private NSMutableArray *_fadedCellImages;
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
		_fadedCellImages = [[NSMutableArray alloc] initWithObjects:
			[UIImage imageNamed: @"main-kingsbar"],
			[UIImage imageNamed: @"main-work"],
			[UIImage imageNamed: @"main-myplace"],
			[UIImage imageNamed: @"main-mystery"],
			[UIImage imageNamed: @"main-mikes"], nil];
			
		_sameCellImages = [[NSMutableArray alloc] initWithObjects:
			[UIImage imageNamed: @"samecolour-kingsbar"],
			[UIImage imageNamed: @"samecolour-work"],
			[UIImage imageNamed: @"samecolour-myplace"],
			[UIImage imageNamed: @"samecolour-mystery"],
			[UIImage imageNamed: @"samecolour-mikes"], nil];
			
        // initialize locations
		_locations = [NSMutableArray arrayWithObjects:
		  [MTLocation locationWithName: @"Kings Bar"
			image: _sameCellImages[0]],
		  [MTLocation locationWithName: @"Work"
			image: _sameCellImages[1]],
		  [MTLocation locationWithName: @"My place"
			image: _sameCellImages[2]],
		  [MTLocation locationWithName: @"Mystery"
			image: _sameCellImages[3]],
		  [MTLocation locationWithName: @"Mike's"
			image: _sameCellImages[4]], nil];
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
	
	UIImage *backgroundImage = [UIImage imageNamed: @"common-blur-bg"];
	UIImageView *bgImageView = [[UIImageView alloc]
        initWithImage: backgroundImage];
	bgImageView.layer.zPosition = -1;
	[self.view addSubview: bgImageView];
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
