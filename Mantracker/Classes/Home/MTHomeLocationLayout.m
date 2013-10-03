//
//  MTHomeLocationLayout.m
//  Mantracker
//
//  Created by Misa Sakamoto on 2013-10-01.
//  Copyright (c) 2013 Nascent. All rights reserved.
//

#import "MTHomeLocationLayout.h"

@interface MTHomeLocationLayout ()
{
    @private __strong UIDynamicAnimator *_dynamicAnimator;
}
@end

@implementation MTHomeLocationLayout


- (void)prepareLayout
{
    [super prepareLayout];
    
    if (_dynamicAnimator == nil)
    {
        _dynamicAnimator = [[UIDynamicAnimator alloc]
            initWithCollectionViewLayout: self];
        
        CGSize contentSize = [self collectionViewContentSize];
        
        
        // note: if there's a lot of items,
        // might want to use tile instead of loading all into memory at once
        // create UICollectionViewLayoutAttributes
        NSArray *items = [super layoutAttributesForElementsInRect: CGRectMake(
            0.f,
            0.f,
            contentSize.width,
            contentSize.height)];
        
        // create UIDynamicAnimator and UIAttachmentBehaviors
        for (UICollectionViewLayoutAttributes *item in items)
        {
            UIAttachmentBehavior *spring = [[UIAttachmentBehavior alloc]
                initWithItem: item
                attachedToAnchor: [item
                    center]];
            
            spring.length = 0.f;
            spring.damping = 0.5f;
            spring.frequency = 0.8f;
            
            [_dynamicAnimator addBehavior: spring];
        }
    }
}

- (NSArray *)layoutAttributesForElementsInRect: (CGRect)rect
{
    // tell what items are currently visible in the rect
    return [_dynamicAnimator itemsInRect: rect];
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath: (NSIndexPath *)indexPath
{
    return [_dynamicAnimator layoutAttributesForCellAtIndexPath: indexPath];
}


// because the bounds of the scrollview changes everytime the content offset changes
// grab the scrollview to find out how much just scrolled
// and go through all the springs and stretch them by the amount that we just scrolled
- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
    UIScrollView *scrollview = self.collectionView;
    CGFloat scrollDelta = newBounds.origin.y - scrollview.bounds.origin.y;
    
    // figure out where the finger touched scrollview
    CGPoint touchLocation = [scrollview.panGestureRecognizer locationInView: scrollview];
    
    // shift layout attribute positions by delta
    // notify UIDynamicAnimator
    for (UIAttachmentBehavior *spring in _dynamicAnimator.behaviors)
    {
        // use touch location to figure out how far that touch location is from each individual spring
        CGPoint anchorPoint = spring.anchorPoint; // cell's resting position
        CGFloat distanceFromTouch = fabs(touchLocation.y - anchorPoint.y);
        CGFloat scrollResistance = distanceFromTouch / 500.f; // the more scroll resistance, the bouncier
        
        UICollectionViewLayoutAttributes *item = [spring.items firstObject];
        CGPoint center = item.center;
        center.y += MIN(scrollDelta, scrollDelta * scrollResistance);
        item.center = center;
        
        [_dynamicAnimator updateItemUsingCurrentState: item];
    }
    
    return NO;
}

@end
