//
//  DMAppDelegate.m
//  DMInspectorPalette
//
//  Created by Daniele Margutti on 6/26/12.
//  Copyright (c) 2012 Daniele Margutti. All rights reserved.
//

#import "DMAppDelegate.h"
#import "DMPaletteContainer.h"
#import "DMPaletteSectionView.h"

@interface DMAppDelegate() {
    DMPaletteContainer*     container;
    IBOutlet    NSView *palette_1;
    IBOutlet    NSView *palette_2;
    IBOutlet    NSView *palette_3;
    IBOutlet    NSView *palette_4;
}

@end

@implementation DMAppDelegate

float randFloat() {
    return (random() % 1001) / 1000.0f;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
   /* palette_1.wantsLayer = YES;
    palette_2.wantsLayer = YES;
    palette_3.wantsLayer = YES;
    
     CGColorRef color1 = CGColorCreateGenericRGB(randFloat(), randFloat(), randFloat(), 1);
    CGColorRef color2 = CGColorCreateGenericRGB(randFloat(), randFloat(), randFloat(), 1);
    CGColorRef color3 = CGColorCreateGenericRGB(randFloat(), randFloat(), randFloat(), 1);
    palette_1.layer.backgroundColor = color1;
    palette_2.layer.backgroundColor = color2;
    palette_3.layer.backgroundColor = color3;
    
    */
    NSView* destinationView = ((NSView*)self.window.contentView);
    NSRect bound = NSMakeRect(20, 20, NSWidth(destinationView.frame)-50.0f, NSHeight(destinationView.frame)-80.0f);
    
    container = [[DMPaletteContainer alloc] initWithFrame:bound];
    [destinationView addSubview:container];
    
    container.sectionViews = [NSArray arrayWithObjects:
                              [[DMPaletteSectionView alloc] initWithContentView:palette_1 andTitle:@"Geometry"],[[DMPaletteSectionView alloc] initWithContentView:palette_2 andTitle:@"Title Elements"],
                              [[DMPaletteSectionView alloc] initWithContentView:palette_3 andTitle:@"Bounds"],
                               [[DMPaletteSectionView alloc] initWithContentView:palette_4 andTitle:@"Actions"],nil];
}

@end
