//
//  MTKVO.h
//  Mantracker
//
//  Created by Misa Sakamoto on 2013-10-02.
//  Copyright (c) 2013 Nascent. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MTKVO : NSObject

- (void)startObserving: (NSObject *)observable
    forKeyPath: (NSString *)keyPath
    options: (NSKeyValueObservingOptions)options
    target: (NSObject *)target
    selector: (SEL)selector;

- (void)stopObserving: (NSObject *)observable
    forKeyPath: (NSString *)keyPath;

@end
