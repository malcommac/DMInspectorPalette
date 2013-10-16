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
        contentView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
        [self setDocumentView:contentView];
        [self setHasVerticalScroller:YES];
        [self setHasHorizontalScroller:YES];
        
        self.sectionHeaderDashColor = [NSColor colorWithCalibratedRed:0.502 green:0.502 blue:0.502 alpha:0.5];
        self.sectionHeaderGradientStartColor = [NSColor colorWithCalibratedRed:0.922 green:0.925 blue:0.976 alpha:1.0];
        self.sectionHeaderGradientEndColor = [NSColor colorWithCalibratedRed:0.741 green:0.749 blue:0.831 alpha:1.0];
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

- (NSArray *)sectionViews
{
	return contentSectionViews;
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

- (void)_updateContentSizeIfNecessary
{
    CGRect boundsForContent = [self boundsForContent];
    
    if (!CGRectEqualToRect(boundsForContent, contentView.frame))
    {
        [contentView setFrame:boundsForContent];
    }
}

- (void)layout
{
    // do not update frames of subviews here or else this messes up layout widths using auto layout
    [self _updateContentSizeIfNecessary];
    
    [super layout];
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
		// temporarily set the document view frame to the entire contianer, to avoid flicker at bottom section
		[[self documentView] setFrame:self.bounds];
		
		[NSAnimationContext beginGrouping];
    	[[NSAnimationContext currentContext] setDuration:kDMPaletteContainerAnimationDuration];
		[[NSAnimationContext currentContext] setCompletionHandler:^{
            
			[self _updateContentSizeIfNecessary];
		}];
	}
	
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"index" ascending:YES];
    contentSectionViews = [contentSectionViews sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];

    
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
	else
	{
		[self _updateContentSizeIfNecessary];
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
