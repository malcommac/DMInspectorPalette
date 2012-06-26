    //
    //  DMPaletteSectionView.m
    //  DMInspectorPalette
    //
    //  Created by Daniele Margutti on 6/26/12.
    //  Copyright (c) 2012 Daniele Margutti. All rights reserved.
    //

#import "DMPaletteSectionView.h"
#import "DMPaletteContainer.h"

@interface DMPaletteSectionView() {
    NSView*             contentView;
    
    NSButton *          disclosureTriangle;
    NSTextField *       nameField;
    
    NSColor *           dashColor;
    NSColor *           gradientStartColor;
    NSColor *           gradientEndColor;
    
    DMPaletteState      state;
}
- (void) setupDisclosureBar;
@end

@implementation DMPaletteSectionView

@synthesize state,index;
@synthesize title;
@synthesize container,contentView;

- (id)initWithContentView:(NSView *) sectContentView andTitle:(NSString *) headerTitle
{
    self = [super initWithFrame:NSZeroRect];
    if (self) {
        state = DMPaletteStateExpanded;
        [self setupDisclosureBar];
        
        self.title = headerTitle;
        contentView = sectContentView;
        [super setFrame:NSMakeRect(NSMinX(self.frame),
                                   NSMinY(self.frame),
                                   NSWidth(contentView.frame),
                                   NSHeight(contentView.frame)+kDMPaletteSectionHeaderHeight)];
        contentView.frame = NSMakeRect(0.0f,
                                       kDMPaletteSectionHeaderHeight,
                                       NSWidth(contentView.frame),
                                       NSHeight(contentView.frame));
        [self addSubview:contentView];
        self.autoresizingMask = NSViewWidthSizable;
        contentView.autoresizingMask = NSViewWidthSizable;
    }
    
    return self;
}

- (BOOL) isOpaque {
    return NO;
}

- (void) setupDisclosureBar {
    dashColor = [NSColor colorWithCalibratedRed:0.502 green:0.502 blue:0.502 alpha:0.5];
    gradientStartColor = [NSColor colorWithCalibratedRed:0.922 green:0.925 blue:0.976 alpha:1.0];
    gradientEndColor = [NSColor colorWithCalibratedRed:0.741 green:0.749 blue:0.831 alpha:1.0];
    
    disclosureTriangle = [[NSButton alloc] initWithFrame:NSMakeRect(5.0, 4.0, 13.0, 13.0)];
    [disclosureTriangle setBezelStyle:NSDisclosureBezelStyle];
    [disclosureTriangle setButtonType: NSPushOnPushOffButton];
    [disclosureTriangle setTitle:nil];
    [disclosureTriangle highlight:NO];
    [disclosureTriangle setTarget:self];
    [disclosureTriangle setAction:@selector(disclosureClicked:)];
    disclosureTriangle.state = (state == DMPaletteStateExpanded ? NSOnState : NSOffState);
    
    nameField = [[NSTextField alloc] initWithFrame:NSMakeRect(20.0, 3.0, [self bounds].size.width - 8.0, 15.0)];
    [nameField setEditable:NO];
    [nameField setBackgroundColor:[NSColor clearColor]];
    [nameField setBezeled:NO];
    [nameField setFont:[NSFont boldSystemFontOfSize:11.0]];
    [nameField setTextColor:[NSColor colorWithCalibratedRed:0.220 green:0.224 blue:0.231 alpha:1.0]];
    nameField.autoresizingMask = NSViewWidthSizable;
    
    [self addSubview:disclosureTriangle];
    [self addSubview:nameField];
}

- (void) setTitle:(NSString *)newTitle {
    [nameField setStringValue:(newTitle != nil ? newTitle : @"")];
}

- (NSString *) title {
    return [nameField stringValue];
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
        // Transparent background
    [[NSColor clearColor] set];
    NSRectFillUsingOperation(dirtyRect, NSCompositeCopy);
    
    NSRect gradientFrame = NSMakeRect(0, 0, dirtyRect.size.width, kDMPaletteSectionHeaderHeight);
    NSGradient *gradient = [[NSGradient alloc] initWithStartingColor:gradientStartColor endingColor:gradientEndColor];
    [gradient drawInRect:gradientFrame angle:-90.0];
    
    [dashColor set];
    
    NSRect dashRect = [self bounds];
    dashRect.origin.x -= 1.0;
    dashRect.size.width += 2.0;
    dashRect.size.height = kDMPaletteSectionHeaderHeight-0.5;
    
    NSBezierPath *path = [NSBezierPath bezierPathWithRect:dashRect];
    [path setLineWidth:1];
    [path setLineCapStyle:NSButtLineCapStyle];
    [path stroke];
}

- (BOOL) isFlipped {
    return YES;
}

- (void) viewWillMoveToSuperview:(NSView *)newSuperview {
    
}

- (NSComparisonResult)compare:(DMPaletteSectionView *)otherView {
    if(otherView.index > index)
        return NSGreaterThanComparison;
    
    if(otherView.index < index)
        return NSLessThanComparison;
    
    return NSEqualToComparison;
}

-(void)disclosureClicked:(id)sender {
    state = [container toggleStateFor:self];
}

@end
