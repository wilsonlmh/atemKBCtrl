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
    } else {
        isClickedApplyButton = false;
    }

    preferenceConfig.Black = (int)popupBlack.selectedTag;
    preferenceConfig.Ch1 = (int)popupCh1.selectedTag;
    preferenceConfig.Ch2 = (int)popupCh2.selectedTag;
    preferenceConfig.Ch3 = (int)popupCh3.selectedTag;
    preferenceConfig.Ch4 = (int)popupCh4.selectedTag;
    preferenceConfig.Ch5 = (int)popupCh5.selectedTag;
    preferenceConfig.Ch6 = (int)popupCh6.selectedTag;
    preferenceConfig.ColorA = (int)popupColorA.selectedTag;
    preferenceConfig.ColorB = (int)popupColorB.selectedTag;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"preferenceWindowClickedApplyButton" object:self];
    
    [self close];
}

- (IBAction)changedSliderSlidingRate:(id)sender {
    preferenceConfig.slidingRate = (int)sliderSlidingRate.integerValue;
    textSlidingRate.stringValue = [NSString stringWithFormat:@"%d",preferenceConfig.slidingRate];
}


- (IBAction)changedTextSlidingRate:(id)sender {
    if ((textSlidingRate.intValue <= 1000) && (textSlidingRate.intValue >= 100)) {
        preferenceConfig.slidingRate = textSlidingRate.intValue;
    }
    textSlidingRate.stringValue = [NSString stringWithFormat:@"%d",preferenceConfig.slidingRate];
    [sliderSlidingRate setDoubleValue:(double)preferenceConfig.slidingRate];
    
}

- (void)refreshConfig:(NSMutableArray*)channels label:(NSMutableArray*)label config:(struct config)currentConfig isConnected:(BOOL)isConnected {
    isMixerConnected = isConnected;
    isClickedApplyButton = false;
    preferenceConfig = currentConfig;
    [sliderSlidingRate setDoubleValue:(double)preferenceConfig.slidingRate];
    textSlidingRate.stringValue = [NSString stringWithFormat:@"%d",preferenceConfig.slidingRate];
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
        
        [popupBlack selectItemWithTag:preferenceConfig.Black];
        [popupCh1 selectItemWithTag:preferenceConfig.Ch1];
        [popupCh2 selectItemWithTag:preferenceConfig.Ch2];
        [popupCh3 selectItemWithTag:preferenceConfig.Ch3];
        [popupCh4 selectItemWithTag:preferenceConfig.Ch4];
        [popupCh5 selectItemWithTag:preferenceConfig.Ch5];
        [popupCh6 selectItemWithTag:preferenceConfig.Ch6];
        [popupColorA selectItemWithTag:preferenceConfig.ColorA];
        [popupColorB selectItemWithTag:preferenceConfig.ColorB];
        
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


