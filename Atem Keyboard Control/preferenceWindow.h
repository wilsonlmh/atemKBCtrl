//
//  preferenceWindow.h
//  Atem Keyboard Control
//
//  Created by Wilson Luniz on 15-1-26.
//  Copyright (c) 2015 Luniz Pd. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface preferenceWindow : NSWindowController <NSWindowDelegate> {
    @public BOOL            isClickedApplyButton;
    @public BOOL            isMixerConnected;
    
    @public struct config {
        int64_t Black; //typdef int64_t BMDSwitcherInputId
        int64_t Ch1;
        int64_t Ch2;
        int64_t Ch3;
        int64_t Ch4;
        int64_t Ch5;
        int64_t Ch6;
        int64_t ColorA;
        int64_t ColorB;
        int slidingRate; //as pixel per stage
        //{0,1,2,3,4,5,6,2001,2002,300}
    }preferenceConfig;
    
    IBOutlet NSPopUpButton*     popupBlack;
    IBOutlet NSPopUpButton*     popupCh1;
    IBOutlet NSPopUpButton*     popupCh2;
    IBOutlet NSPopUpButton*     popupCh3;
    IBOutlet NSPopUpButton*     popupCh4;
    IBOutlet NSPopUpButton*     popupCh5;
    IBOutlet NSPopUpButton*     popupCh6;
    IBOutlet NSPopUpButton*     popupColorA;
    IBOutlet NSPopUpButton*     popupColorB;
    IBOutlet NSTextField*       textSlidingRate;
    IBOutlet NSSlider*          sliderSlidingRate;
    
}

- (IBAction)clickedCancelButton:(id)sender;
- (IBAction)clickedApplyButton:(id)sender;
- (IBAction)changedSliderSlidingRate:(id)sender;
- (IBAction)changedTextSlidingRate:(id)sender;

- (void)refreshConfig:(NSMutableArray*)channels label:(NSMutableArray*)label config:(struct config)currentConfig isConnected:(BOOL)isConnected; //To read config or obtain mapping from mixer
- (void)windowWillClose:(NSNotification *)notification;

@end


