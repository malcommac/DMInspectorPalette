//
//  DMPaletteContainer.m
//  DMInspectorPalette
//
//  Created by Daniele Margutti on 6/26/12.
//  Copyright (c) 2012 Daniele Margutti. All rights reserved.
//

#import "DMPaletteContainer.h"

#define kDMPaletteContainerAnimationDuration    0.10f

@implementation DMPaletteBaseView
- (BOOL) isFlipped { return YES; }
@end


@interface DMFlippedClipView : NSView
@end

@implementation DMFlippedClipView
- (BOOL) isFlipped { return YES; }
@end

@interface DMPaletteContainer() {
    DMFlippedClipView*      contentView;
    NSArray*                contentSectionViews;
    BOOL                    useAnimations;
}

- (CGRect) boundsForContent;

@end

@implementation DMPaletteContainer

@synthesize sectionViews;
@synthesize useAnimations;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.wantsLayer = YES;
        self.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
        contentView = [[DMFlippedClipView alloc] initWithFrame:self.bounds];
        [self setDocumentView:contentView];
        [self setHasVerticalScroller:YES];
        [self setHasHorizontalScroller:YES];
    }
    
    return self;
}

- (void) setSectionViews:(NSArray *)newSectionViews {
    [contentSectionViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    contentSectionViews = newSectionViews;
    
    [contentSectionViews enumerateObjectsUsingBlock:^(DMPaletteSectionView *paletteSection, NSUInteger idx, BOOL *stop) {
        paletteSection.autoresizingMask = NSViewWidthSizable;
        paletteSection.container = self;
        paletteSection.index = idx;
        [contentView addSubview:paletteSection];
    }];
    [self layoutSubviewsAnimated:NO];
}

#pragma mark - Geometry Managment (Internals)

- (BOOL) isFlipped {
    return YES;
}

// Return the correct bound for our container based upon the size of each section(+ it's header)
- (CGRect) boundsForContent
{
	// take frame of bottom item and extend to origin
	CGRect frame = [self frameForSectionAtIndex:[contentSectionViews count]-1];
	frame.size.height += frame.origin.y;
	frame.origin = NSZeroPoint;
	return frame;
}

-(void) layout {
    [super layout];
    // Fixes a small  bug in the DMInspectorPalette that was keeping the subviews/DMPaletteSectionViews from resizing when autolayout is used.
    // Thanks to Owen Hildreth
    [self layoutSubviewsAnimated:NO];
}

- (NSRect)frameForSectionAtIndex:(NSUInteger)index
{
	__block NSRect frame = NSMakeRect(0.0f,
												 0.0f,
												 NSWidth(self.frame),
												 0.0f);
	
	[contentSectionViews enumerateObjectsUsingBlock:^(DMPaletteSectionView *paletteSection, NSUInteger idx, BOOL *stop)
	{
		
		BOOL followingSectionShiftedUp = NO;
		
		if (paletteSection.state == DMPaletteStateCollapsed)
		{
			frame.size.height = kDMPaletteSectionHeaderHeight;
			followingSectionShiftedUp= YES;
		}
		else
		{
			frame.size.height = kDMPaletteSectionHeaderHeight + NSHeight(paletteSection.contentView.frame);;
		}
		
		if (idx == index)
		{
			*stop = YES;
		}
		else
		{
			frame.origin.y = NSMaxY(frame);
			
			if (followingSectionShiftedUp)
			{
				frame.origin.y--;
			}
		}
	}];
	
	return frame;
}

- (void)layoutSubviewsAnimated:(BOOL)animated
{
	if (animated)
	{
		[NSAnimationContext beginGrouping];
    	[[NSAnimationContext currentContext] setDuration:kDMPaletteContainerAnimationDuration];
	}
	
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"index" ascending:YES];
    contentSectionViews = [contentSectionViews sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    NSRect contentRect = [self boundsForContent];
    [[self documentView] setFrame:contentRect];
        
    [contentSectionViews enumerateObjectsUsingBlock:^(DMPaletteSectionView* paletteSection, NSUInteger idx, BOOL *stop) {
		 if (animated)
		 {
			 [[paletteSection animator] setFrame:[self frameForSectionAtIndex:idx]];
		 }
		 else
		 {
			 paletteSection.frame = [self frameForSectionAtIndex:idx];
		 }
    }];
	
	if (animated)
	{
		[NSAnimationContext endGrouping];
	}
}

#pragma mark - Manage sections

- (void) expandSectionView:(DMPaletteSectionView *) sectionView {
    [self setState:DMPaletteStateExpanded forSection:sectionView animated:useAnimations];
}

- (void) collapseSectionView:(DMPaletteSectionView *) sectionView {
    [self setState:DMPaletteStateCollapsed forSection:sectionView animated:useAnimations];
}

- (DMPaletteState) toggleStateFor:(DMPaletteSectionView *) sectionView {
    DMPaletteState newState = (sectionView.state == DMPaletteStateCollapsed ? DMPaletteStateExpanded : DMPaletteStateCollapsed);
    [self setState:newState
        forSection:sectionView
          animated:useAnimations];
    return newState;
}

- (void) setState:(DMPaletteState)state forSection:(DMPaletteSectionView *) targetSection animated:(BOOL)animate {
    [self setState:state
       forSections:[NSIndexSet indexSetWithIndex:[contentSectionViews indexOfObject:targetSection]]
          animated:YES];
}   

- (void) setState:(DMPaletteState) state forSections:(NSIndexSet *) indexSet animated:(BOOL) animate
{
	// update model state first
	[contentSectionViews enumerateObjectsUsingBlock:^(DMPaletteSectionView* sectionView, NSUInteger idx, BOOL *stop) {
		if ([indexSet containsIndex:idx])
		{
			sectionView.state = state;
		}
	}];
	
	[self layoutSubviewsAnimated:animate];
}


@end
