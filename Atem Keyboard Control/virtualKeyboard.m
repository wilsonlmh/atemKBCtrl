//
//  virtualKeyboard.m
//  Atem Keyboard Control
//
//  Created by Wilson Luniz on 15-1-26.
//  Copyright (c) 2015 Luniz Pd. All rights reserved.
//

#import "virtualKeyboard.h"

@interface virtualKeyboard ()

@end

@implementation virtualKeyboard

-(int)arraySearch:(NSMutableArray*)arrayToSearch obj:(NSString*)obj {
    for (int i=0; i<[arrayToSearch count]; i++) {
        if ([obj isEqual:arrayToSearch[i]]) {
            return i;
        }
    }
    return -1;//nil changed to -1
}

- (void)windowDidLoad {
    lastClickedKeyName = nil;
    [super windowDidLoad];
}

-(void)hideAlert {
    labelAlert.hidden = true;
}

-(IBAction)clickedKeyButton:(NSButton*)sender {
    NSString* CURRENT = [cmdKBMapping objectAtIndex:[self arraySearch:kbShortName obj:sender.alternateTitle]];
    if ((!CURRENT) || ([CURRENT  isEqual: @""]) || (CURRENT == sender.alternateTitle)) {
        [mainMenuSender setStringValue:sender.alternateTitle];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"shouldUpdateKeyMapping" object:self];
    } else {
        labelAlert.hidden = false;
        [self performSelector:@selector(hideAlert) withObject:nil afterDelay:2.0];
    }
    
}

-(void)showWindow:(NSTextField*)sender cmdKBMapping:(NSMutableArray*)pCmdKBMapping kbShortName:(NSMutableArray*)pKbShortName {
    kbShortName = pKbShortName;
    cmdKBMapping = pCmdKBMapping;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"virtualKeyboardShowing" object:self];
    [super showWindow:nil];
    mainMenuSender = sender;
}
@end
