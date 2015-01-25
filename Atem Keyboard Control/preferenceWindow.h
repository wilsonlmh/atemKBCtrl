//
//  preferenceWindow.h
//  Atem Keyboard Control
//
//  Created by Wilson Luniz on 15-1-26.
//  Copyright (c) 2015 Luniz Pd. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface preferenceWindow : NSWindowController <NSWindowDelegate> {
    @public int             mappingConfig[21];
    @public BOOL            isClickedApplyButton;
    @public BOOL            isMixerConnected;
    
    IBOutlet NSPopUpButton*     popupBlack;
    IBOutlet NSPopUpButton*     popupCh1;
    IBOutlet NSPopUpButton*     popupCh2;
    IBOutlet NSPopUpButton*     popupCh3;
    IBOutlet NSPopUpButton*     popupCh4;
    IBOutlet NSPopUpButton*     popupCh5;
    IBOutlet NSPopUpButton*     popupCh6;
    IBOutlet NSPopUpButton*     popupColorA;
    IBOutlet NSPopUpButton*     popupColorB;
    
}

- (IBAction)clickedCancelButton:(id)sender;
- (IBAction)clickedApplyButton:(id)sender;


- (void)refreshConfig:(NSMutableArray*)channels label:(NSMutableArray*)label config:(NSArray*)config isConnected:(BOOL)isConnected; //To read config or obtain mapping from mixer
- (void)windowWillClose:(NSNotification *)notification;

@end


