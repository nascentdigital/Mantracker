//
//  MTNavigationBar.m
//  Mantracker
//
//  Created by Misa Sakamoto on 2013-10-01.
//  Copyright (c) 2013 Nascent. All rights reserved.
//

#import "MTNavigationBar.h"

#define CENTER_BUTTON_WIDTH 50.f

@implementation MTNavigationBar

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder: aDecoder];
    if (self) {
        // Initialization code
    }
    
    _centerButton = [UIButton buttonWithType: UIButtonTypeCustom];
    _centerButton.frame = CGRectMake((self.bounds.size.width - CENTER_BUTTON_WIDTH) * .5f, 0.f, CENTER_BUTTON_WIDTH, self.bounds.size.height);
    [_centerButton setImage: [UIImage imageNamed: @"arrow"] forState: UIControlStateNormal];
    [_centerButton setImageEdgeInsets: UIEdgeInsetsMake(30.f, 10.f, 0.f, 10.f)];
    [self addSubview: _centerButton];
    
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
