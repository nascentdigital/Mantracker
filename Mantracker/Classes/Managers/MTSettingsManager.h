#pragma mark Constants


#pragma mark - Enumerations


#pragma mark - Class Interface

@interface MTSettingsManager : NSObject


#pragma mark - Properties

@property (nonatomic, assign) BOOL enableParallax;
@property (nonatomic, assign) BOOL blurBackground;
@property (nonatomic, assign) BOOL customTransitions;
@property (nonatomic, assign) BOOL interactiveTransitions;
@property (nonatomic, assign) BOOL environmentalFeedback;
@property (nonatomic, assign) BOOL lifeAnimations;


#pragma mark - Constructors


#pragma mark - Static Methods

+ (MTSettingsManager *)sharedInstance;


#pragma mark - Instance Methods


@end // @interface MTSettingsManager