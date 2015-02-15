//
//  virtualKeyboard.h
//  Atem Keyboard Control
//
//  Created by Wilson Luniz on 15-1-26.
//  Copyright (c) 2015 Luniz Pd. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface virtualKeyboard : NSWindowController <NSWindowDelegate> {
    NSString*               lastClickedKeyName;
    NSTextField*            mainMenuSender;
    NSMutableArray*         kbShortName;
    NSMutableArray*         cmdKBMapping;
    IBOutlet NSTextField*   labelAlert;
    
}
-(void)hideAlert;
-(int)arraySearch:(NSMutableArray*)arrayToSearch obj:(NSString*)obj;
-(void)showWindow:(NSTextField*)sender cmdKBMapping:(NSMutableArray*)pCmdKBMapping kbShortName:(NSMutableArray*)pKbShortName;
-(IBAction)clickedKeyButton:(NSButton*)sender;

@end

@interface blackNSButtonCell : NSButtonCell {
    
}


@end