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
    [self layoutSubviews];
}

#pragma mark - Geometry Managment (Internals)

- (BOOL) isFlipped {
    return YES;
}

// Return the correct bound for our container based upon the size of each section(+ it's header)
- (CGRect) boundsForContent {
    __block CGFloat height = 0.0;
    [contentSectionViews enumerateObjectsUsingBlock:^(DMPaletteSectionView *paletteSection, NSUInteger idx, BOOL *stop) {
        height+=NSHeight(paletteSection.frame);
    }];
        
    NSRect frame = NSMakeRect(0.0f,
                              0.0f,
                              NSWidth(self.frame),
                              height);
    NSClipView *clipView = [[self enclosingScrollView]contentView];
    if (clipView != nil)
        frame.size.width = [clipView documentRect].size.width;
    return frame;
}

-(void) layout {
    [super layout];
    // Fixes a small  bug in the DMInspectorPalette that was keeping the subviews/DMPaletteSectionViews from resizing when autolayout is used.
    // Thanks to Owen Hildreth
    [self layoutSubviews];
}

- (void)layoutSubviews {
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"index" ascending:YES];
    contentSectionViews = [contentSectionViews sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    NSRect contentRect = [self boundsForContent];
    [[self documentView] setFrame:contentRect];
        
    __block BOOL collapsed = NO;
    __block NSRect frame = NSMakeRect(0.0f,
                                      0.0f,
                                      NSWidth(self.frame),
                                      0.0f);
    [contentSectionViews enumerateObjectsUsingBlock:^(DMPaletteSectionView* paletteSection, NSUInteger idx, BOOL *stop) {
        if (collapsed)
            frame.origin.y -= 1.0f;
        frame.size.height = NSHeight(paletteSection.frame);
        [paletteSection setFrame:frame];
        
        frame.origin.y += NSHeight(frame);
        collapsed = (paletteSection.state == DMPaletteStateCollapsed);
    }];
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

- (void) setState:(DMPaletteState) state forSections:(NSIndexSet *) indexSet animated:(BOOL) animate {
    __block CGFloat offsetY = 0.0f;
    if (animate) {
        [NSAnimationContext beginGrouping];
    [[NSAnimationContext currentContext] setDuration:kDMPaletteContainerAnimationDuration];
    }
    [contentSectionViews enumerateObjectsUsingBlock:^(DMPaletteSectionView* sectionView, NSUInteger idx, BOOL *stop) {
        NSRect sectionRect = NSMakeRect(NSMinX(self.bounds),
                                        offsetY,
                                        NSWidth(self.bounds),
                                        NSHeight(sectionView.bounds));
        if ([indexSet containsIndex:idx])
            sectionRect.size.height = (state == DMPaletteStateCollapsed ?
                                       kDMPaletteSectionHeaderHeight :
                                       NSHeight(sectionView.contentView.frame)+kDMPaletteSectionHeaderHeight);
        
        offsetY += NSHeight(sectionRect);
        if (animate)
            [[sectionView animator] setFrame:sectionRect];
        else [sectionView setFrame:sectionRect];
    }];
    
    if (animate)
        [NSAnimationContext endGrouping];
}


@end
