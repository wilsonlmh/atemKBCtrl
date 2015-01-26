//
//  preferenceWindow.m
//  Atem Keyboard Control
//
//  Created by Wilson Luniz on 15-1-26.
//  Copyright (c) 2015 Luniz Pd. All rights reserved.
//

#import "preferenceWindow.h"

@implementation preferenceWindow



- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

- (void)clickedCancelButton:(id)sender {
    isClickedApplyButton = false;
    [self close];
}

- (void)clickedApplyButton:(id)sender {
    if (isMixerConnected) {
        isClickedApplyButton = true;
        mappingConfig[0] = (int)popupBlack.selectedTag;
        mappingConfig[1] = (int)popupCh1.selectedTag;
        mappingConfig[2] = (int)popupCh2.selectedTag;
        mappingConfig[3] = (int)popupCh3.selectedTag;
        mappingConfig[4] = (int)popupCh4.selectedTag;
        mappingConfig[5] = (int)popupCh5.selectedTag;
        mappingConfig[6] = (int)popupCh6.selectedTag;
        mappingConfig[7] = (int)popupColorA.selectedTag;
        mappingConfig[8] = (int)popupColorB.selectedTag;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"preferenceWindowClickedApplyButton" object:self];
    } else {
        isClickedApplyButton = false;
    }

    [self close];
}

- (void)refreshConfig:(NSMutableArray*)channels label:(NSMutableArray*)label config:(NSArray*)config isConnected:(BOOL)isConnected {
    isMixerConnected = isConnected;
    isClickedApplyButton = false;
    if (isMixerConnected) {
        popupBlack.enabled = true;
        popupCh1.enabled = true;
        popupCh2.enabled = true;
        popupCh3.enabled = true;
        popupCh4.enabled = true;
        popupCh5.enabled = true;
        popupCh6.enabled = true;
        popupColorA.enabled = true;
        popupColorB.enabled = true;
        [popupBlack removeAllItems];
        [popupCh1 removeAllItems];
        [popupCh2 removeAllItems];
        [popupCh3 removeAllItems];
        [popupCh4 removeAllItems];
        [popupCh5 removeAllItems];
        [popupCh6 removeAllItems];
        [popupColorA removeAllItems];
        [popupColorB removeAllItems];
        for (int i = 0; i < label.count; i++) {
            NSString *strTag = [channels objectAtIndex:i];
            int intTag = strTag.intValue;
            [popupBlack addItemWithTitle:[label objectAtIndex:i]];
            [[popupBlack lastItem] setTag:intTag];
            [popupCh1 addItemWithTitle:[label objectAtIndex:i]];
            [[popupCh1 lastItem] setTag:intTag];
            [popupCh2 addItemWithTitle:[label objectAtIndex:i]];
            [[popupCh2 lastItem] setTag:intTag];
            [popupCh3 addItemWithTitle:[label objectAtIndex:i]];
            [[popupCh3 lastItem] setTag:intTag];
            [popupCh4 addItemWithTitle:[label objectAtIndex:i]];
            [[popupCh4 lastItem] setTag:intTag];
            [popupCh5 addItemWithTitle:[label objectAtIndex:i]];
            [[popupCh5 lastItem] setTag:intTag];
            [popupCh6 addItemWithTitle:[label objectAtIndex:i]];
            [[popupCh6 lastItem] setTag:intTag];
            [popupColorA addItemWithTitle:[label objectAtIndex:i]];
            [[popupColorA lastItem] setTag:intTag];
            [popupColorB addItemWithTitle:[label objectAtIndex:i]];
            [[popupColorB lastItem] setTag:intTag];
        }
        
        
        
        if (config) {
            NSString *strTag0 = [config objectAtIndex:0];
            int intTag0 = strTag0.intValue;
            NSString *strTag1 = [config objectAtIndex:1];
            int intTag1 = strTag1.intValue;
            NSString *strTag2 = [config objectAtIndex:2];
            int intTag2 = strTag2.intValue;
            NSString *strTag3 = [config objectAtIndex:3];
            int intTag3 = strTag3.intValue;
            NSString *strTag4 = [config objectAtIndex:4];
            int intTag4 = strTag4.intValue;
            NSString *strTag5 = [config objectAtIndex:5];
            int intTag5 = strTag5.intValue;
            NSString *strTag6 = [config objectAtIndex:6];
            int intTag6 = strTag6.intValue;
            NSString *strTag7 = [config objectAtIndex:7];
            int intTag7 = strTag7.intValue;
            NSString *strTag8 = [config objectAtIndex:8];
            int intTag8 = strTag8.intValue;
            
            [popupBlack selectItemWithTag:intTag0];
            [popupCh1 selectItemWithTag:intTag1];
            [popupCh2 selectItemWithTag:intTag2];
            [popupCh3 selectItemWithTag:intTag3];
            [popupCh4 selectItemWithTag:intTag4];
            [popupCh5 selectItemWithTag:intTag5];
            [popupCh6 selectItemWithTag:intTag6];
            [popupColorA selectItemWithTag:intTag7];
            [popupColorB selectItemWithTag:intTag8];

        }
    } else {
        popupBlack.enabled = false;
        popupCh1.enabled = false;
        popupCh2.enabled = false;
        popupCh3.enabled = false;
        popupCh4.enabled = false;
        popupCh5.enabled = false;
        popupCh6.enabled = false;
        popupColorA.enabled = false;
        popupColorB.enabled = false;
    }
}

- (void)windowWillClose:(NSNotification *)notification {

}
@end
