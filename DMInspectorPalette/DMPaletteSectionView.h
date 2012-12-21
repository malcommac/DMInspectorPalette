    //
    //  DMPaletteSectionView.h
    //  DMInspectorPalette
    //
    //  Created by Daniele Margutti on 6/26/12.
    //  Copyright (c) 2012 Daniele Margutti. All rights reserved.
    //

#import <Cocoa/Cocoa.h>

enum  {
    DMPaletteStateCollapsed     = 0,    // Section is collpased
    DMPaletteStateExpanded      = 1     // Section is expanded
}; typedef NSUInteger DMPaletteState;

#define kDMPaletteSectionHeaderHeight               20.0f       // Default header height

@class DMPaletteContainer;
@interface DMPaletteSectionView : NSView {
    
}

@property (nonatomic,assign)            DMPaletteState      state;          // Current state of the section (see DMPaletteState)
@property (nonatomic,assign)    NSString*           title;          // Title of the header
@property (nonatomic,assign)    NSUInteger          index;          // Current element index (assign it then use layoutSubviews to rearrange all the other items)
@property (weak)                DMPaletteContainer* container;      // Related section's container
@property (readonly)            NSView*             contentView;    // Section content view

    // Initialize method
- (id)initWithContentView:(NSView *) contentView andTitle:(NSString *) headerTitle;

@end
