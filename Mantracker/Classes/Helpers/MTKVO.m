//
//  MTKVO.m
//  Mantracker
//
//  Created by Misa Sakamoto on 2013-10-02.
//  Copyright (c) 2013 Nascent. All rights reserved.
//

#import "MTKVO.h"


#pragma mark Internal Data Structures

@interface MTKVOContext : NSObject
{
	@public __weak NSObject *observable;
	@public __strong NSMutableDictionary *keyPathBindings;
}

@end // @interface MTKVOContext

@implementation MTKVOContext

@end // @implementation MTKVOContext

@interface MTKVOBinding : NSObject
{
	@public __weak NSObject *target;
	@public SEL selector;
}

@end  // @interface MTKVOBinding

@implementation MTKVOBinding

@end // @implementation MTKVOBinding


#pragma mark - Class Extension

@interface MTKVO ()
{
	@private __strong NSMutableArray *_contexts;
}

#pragma mark - Methods

- (MTKVOContext *)ND_contextForObservable: (NSObject *)observable;

@end // @interface MTKVO ()


#pragma mark - Class Definition

@implementation MTKVO


#pragma mark - Constructors

- (id)init
{
    // abort if base constructor fails
	if ((self = [super init]) == nil)
	{
		return nil;
	}
	
	// initialize instance variables
    _contexts = [[NSMutableArray alloc]
        init];

    // return initialized instance
	return self;
}


#pragma mark - Destructors

- (void)dealloc 
{
    // remove all remaining contexts
    for (MTKVOContext *context in _contexts)
    {
        // skip context if observable is gone
        NSObject *observable = context->observable;
        if (observable == nil)
        {
            continue;
        }
        
		// remove any active keypath observations
        void *observerContext = (__bridge void *)context;
		NSMutableDictionary *keyPathBindings = context->keyPathBindings;
        for (NSString *keyPath in keyPathBindings)
        {
            [observable removeObserver: self
                forKeyPath: keyPath
                context: observerContext];
        }
    }
}


#pragma mark - Public Methods

- (void)startObserving: (NSObject *)observable
    forKeyPath: (NSString *)keyPath
    options: (NSKeyValueObservingOptions)options
    target: (NSObject *)target
    selector: (SEL)selector
{
    // get observable structure (or create one)
	MTKVOContext *context = [self ND_contextForObservable: observable];
    if (context == nil)
    {
        // create new context
		context = [[MTKVOContext alloc]
			init];
		context->observable = observable;
		context->keyPathBindings = [[NSMutableDictionary alloc]
			initWithCapacity: 2];
        
        // add context to observations
        [_contexts addObject: context];
    }

    // throw if keypath is already bound
    MTKVOBinding *binding = [context->keyPathBindings objectForKey: keyPath];
    if (binding != nil)
    {
        [NSException
            raise: NSInvalidArgumentException
            format: @"Exception for key path '%@' is already bound for observable.",
                keyPath];
        return;
    }
    
    // create binding
    binding = [[MTKVOBinding alloc] 
		init];
    binding->target = target;
	binding->selector = selector;
    
    // bind keypath
    [context->keyPathBindings setObject: binding
        forKey: keyPath];

    // start observing
    void *observerContext = (__bridge void *)context;
    [observable addObserver: self 
        forKeyPath: keyPath 
        options: options
        context: observerContext];    
}

- (void)stopObserving: (NSObject *)observable
    forKeyPath: (NSString *)keyPath
{
    // skip if context isn't mapped
	MTKVOContext *context = [self ND_contextForObservable: observable];
    if (context == nil)
    {
        return;
    }

	// skip if keypath isn't mapped
    NSMutableDictionary *bindings = context->keyPathBindings;
    MTKVOBinding *binding = [bindings objectForKey: keyPath];
    if (binding == nil)
    {
        return;
    }

    // unbind keypath
    [bindings removeObjectForKey: keyPath];    

    // stop observing keypath
    void *observerContext = (__bridge void *)context;
    [observable removeObserver: self 
        forKeyPath: keyPath
        context: observerContext];
    
    // remove mapping
    [bindings removeObjectForKey: keyPath];

    // remove context if no more bindings are mapped
    if ([bindings count] == 0)
    {
        [_contexts removeObject: context];
    }
}


#pragma mark - Overridden Methods

- (void)observeValueForKeyPath: (NSString *)keyPath 
    ofObject: (id)observable 
    change: (NSDictionary *)change 
    context: (void *)unused
{
    // skip if context isn't mapped
	MTKVOContext *context = [self ND_contextForObservable: observable];
    if (context == nil)
    {
        return;
    }
    
    // skip if keypath isn't mapped
    NSMutableDictionary *bindings = context->keyPathBindings;
    MTKVOBinding *binding = [bindings objectForKey: keyPath];
    if (binding == nil)
    {
        return;
    }
    
    // stop observing keypath if target is deallocated
    NSObject *target = binding->target;
    if (target == nil)
    {
        // stop observing keypath
        void *observerContext = (__bridge void *)context;
        [observable removeObserver: self 
            forKeyPath: keyPath
            context: observerContext];
        
        // remove mapping
        [bindings removeObjectForKey: keyPath];

        // remove context if no more bindings are mapped
        if ([bindings count] == 0)
        {
            [_contexts removeObject: context];
        }
    }
    
    // or notify target
    else
    {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [target performSelector: binding->selector
            withObject: change
            withObject: observable];
#pragma clang diagnostic pop
    }
}


#pragma mark - Helper Methods

- (MTKVOContext *)ND_contextForObservable: (NSObject *)observable
{
    // find context, pruning dead contexts along the way
    MTKVOContext *context = nil;
    for (NSInteger i = [_contexts count] - 1; i >= 0; --i)
    {
        // delete context if dead
        MTKVOContext *nextContext = [_contexts objectAtIndex: i];
        NSObject *nextObservable = nextContext->observable;
        if (nextObservable == nil)
        {
            [_contexts removeObjectAtIndex: i];
        }
        
        // or match observable
        else if (nextObservable == observable)
        {
            context = nextContext;
        }
    }
    
    // return result
    return context;
}

@end
