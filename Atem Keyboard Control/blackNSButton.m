//
//  blackButton.m
//  Atem Keyboard Control
//
//  Created by Wilson Luniz on 15-2-16.
//  Copyright (c) 2015 Luniz Pd. All rights reserved.
//

#import "blackNSButton.h"

@implementation blackNSButtonWhiteText

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    
    // Drawing code here.
}

-(BOOL)wantsUpdateLayer {
    return YES;
}

-(void)updateLayer {
    NSColor *color = [NSColor colorWithRed:1.0 green:0.77647058823529 blue:0.0 alpha:1.0];
    color = [NSColor whiteColor];
    NSMutableAttributedString *colorTitle = [[NSMutableAttributedString alloc] initWithAttributedString:[self attributedTitle]];
    NSRange titleRange = NSMakeRange(0, [colorTitle length]);
    [colorTitle addAttribute:NSForegroundColorAttributeName value:color range:titleRange];
    [self setAttributedTitle:colorTitle];
    
    self.layer.contentsCenter = CGRectMake(0.5, 0.5, 0, 0);
    if ([self.cell isHighlighted]) {
        self.layer.contents = [NSImage imageNamed:@"blackNSButtonClicked"];
    } else {
        self.layer.contents = [NSImage imageNamed:@"blackNSButton"];
    }}

@end


@implementation blackNSButtonYellowText

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    
    // Drawing code here.
}

-(BOOL)wantsUpdateLayer {
    return YES;
}

-(void)updateLayer {
    NSColor *color = [NSColor colorWithRed:1.0 green:0.77647058823529 blue:0.0 alpha:1.0];
    NSMutableAttributedString *colorTitle = [[NSMutableAttributedString alloc] initWithAttributedString:[self attributedTitle]];
    NSRange titleRange = NSMakeRange(0, [colorTitle length]);
    [colorTitle addAttribute:NSForegroundColorAttributeName value:color range:titleRange];
    [self setAttributedTitle:colorTitle];
    self.layer.contentsCenter = CGRectMake(0.5, 0.5, 0, 0);
    if ([self.cell isHighlighted]) {
        self.layer.contents = [NSImage imageNamed:@"blackNSButtonClicked"];
    } else {
        self.layer.contents = [NSImage imageNamed:@"blackNSButton"];
    }
}

@end
