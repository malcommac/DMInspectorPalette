//
//  DMPaletteContainer.h
//  DMInspectorPalette
//
//  Created by Daniele Margutti on 6/26/12.
//  Copyright (c) 2012 Daniele Margutti. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DMPaletteSectionView.h"

@interface DMPaletteContainer : NSScrollView {
    
}

@property (nonatomic,assign)    NSArray*    sectionViews;       // list of DMPaletteSectionView object (.contentView to see your passed view)
@property (assign)              BOOL        useAnimations;      // YES to use layer and animations

@property (strong)              NSColor*    sectionHeaderDashColor;
@property (strong)              NSColor*    sectionHeaderGradientStartColor;
@property (strong)              NSColor*    sectionHeaderGradientEndColor;

#pragma mark - Manage section's states

// Expand or collapse a section (if useAnimations = YES it will be animated)
- (void) expandSectionView:(DMPaletteSectionView *) sectionView;
- (void) collapseSectionView:(DMPaletteSectionView *) sectionView;

// Change the state for a list of sections or a single section forcing animation property
- (void) setState:(DMPaletteState) state forSections:(NSIndexSet *) indexSet animated:(BOOL) animate;
- (void) setState:(DMPaletteState) state forSection:(DMPaletteSectionView *) targetSection animated:(BOOL)animate;

// Toggle the state of a section view (if useAnimations = YES it will be animated)
- (DMPaletteState) toggleStateFor:(DMPaletteSectionView *) sectionView;

#pragma mark - Other Utils

// Relayout items
- (void) layoutSubviewsAnimated:(BOOL)animated;

@end


@interface DMPaletteBaseView : NSView { }
@end