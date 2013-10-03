#import "MTSettingsManager.h"
#include <libkern/OSAtomic.h>


#pragma mark - Class Extension

@interface MTSettingsManager ()

@end // @interface MTSettingsManager ()


#pragma mark - Class Variables

static MTSettingsManager *_sharedInstance = nil;
static BOOL _classInitialized = NO;


#pragma mark - Class Definition

@implementation MTSettingsManager


#pragma mark - Properties


#pragma mark - Constructors

+ (void)initialize
{
	// initialize class (use double-checked locking)
	OSMemoryBarrier();
	if (_classInitialized == NO)
	{
		@synchronized(self)
		{
			if (_classInitialized == NO)
			{
				// initialize class variables
                _sharedInstance = [[MTSettingsManager alloc]
                    init];
                
				// close double-checked lock
				OSMemoryBarrier();
				_classInitialized = YES;
			}
		}
	}
}

- (id)init
{
    if ((self = [super init]) != nil)
    {
        // initialize instance variables

    }
    return self;
}


#pragma mark - Public Methods

+ (MTSettingsManager *)sharedInstance
{
	return _sharedInstance;
}


#pragma mark - Overridden Methods

- (id)copyWithZone: (NSZone *)zone
{
	return self;
}


#pragma mark - Private Methods


@end // @implementation MTSettingsManager