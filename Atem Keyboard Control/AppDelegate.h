//
//  AppDelegate.h
//  Atem Keyboard Control
//
//  Created by Wilson Luniz on 15-1-17.
//  Copyright (c) 2015 Luniz Pd. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "BMDSwitcherAPI.h"
#import <list>
#include <string>
#include <libkern/OSAtomic.h>

class MixEffectBlockMonitor;
class SwitcherMonitor;
class InputMonitor;
class TransitionMonitor;
class DSKMonitor;

@interface AppDelegate : NSObject <NSApplicationDelegate> {
    IBOutlet NSWindow *window;
    
    
    IBOutlet NSTextView*	logTextArea;
    IBOutlet NSTextField*	preBG;
    
    //Outlets: Connection Section
    IBOutlet NSTextField*   textStatusColor;
    IBOutlet NSTextField*	textIP;
    IBOutlet NSTextField*	textName;
    IBOutlet NSButton*		buttonConnectionState;
    
    
    //Outlets: Live Status Section
    IBOutlet NSTextField*	textKB;
    IBOutlet NSTextField*   textInput;
    
    //Outlets: Mapping Section
    
    IBOutlet NSButton*	buttonPGMBlack;
    IBOutlet NSButton*	buttonPGMCh1;
    IBOutlet NSButton*	buttonPGMCh2;
    IBOutlet NSButton*	buttonPGMCh3;
    IBOutlet NSButton*	buttonPGMCh4;
    IBOutlet NSButton*	buttonPGMCh5;
    IBOutlet NSButton*	buttonPGMCh6;
    IBOutlet NSButton*	buttonPGMColorA;
    IBOutlet NSButton*	buttonPGMColorB;
    IBOutlet NSButton*	buttonPRVBlack;
    IBOutlet NSButton*	buttonPRVCh1;
    IBOutlet NSButton*	buttonPRVCh2;
    IBOutlet NSButton*	buttonPRVCh3;
    IBOutlet NSButton*	buttonPRVCh4;
    IBOutlet NSButton*	buttonPRVCh5;
    IBOutlet NSButton*	buttonPRVCh6;
    IBOutlet NSButton*	buttonPRVColorA;
    IBOutlet NSButton*	buttonPRVColorB;
    IBOutlet NSButton*	buttonTRANSHold;
    IBOutlet NSButton*	buttonTRANSAuto;
    IBOutlet NSButton*	buttonTRANSCut;
    IBOutlet NSButton*	buttonTRANSPreview;
    IBOutlet NSButton*	buttonTRANSMix;
    IBOutlet NSButton*	buttonTRANSDip;
    IBOutlet NSButton*	buttonTRANSWipe;
    IBOutlet NSButton*	buttonTRANSDve;
    IBOutlet NSButton*	buttonDSK1Preview;
    IBOutlet NSButton*	buttonDSK1On;
    IBOutlet NSButton*	buttonDSK1Auto;
    IBOutlet NSButton*	buttonDSK2Preview;
    IBOutlet NSButton*	buttonDSK2On;
    IBOutlet NSButton*	buttonDSK2Auto;
    
    IBOutlet NSSlider*	sliderTRANS;
    
    IBOutlet NSTextField*	textPGMBlack;
    IBOutlet NSTextField*	textPGMCh1;
    IBOutlet NSTextField*	textPGMCh2;
    IBOutlet NSTextField*	textPGMCh3;
    IBOutlet NSTextField*	textPGMCh4;
    IBOutlet NSTextField*	textPGMCh5;
    IBOutlet NSTextField*	textPGMCh6;
    IBOutlet NSTextField*	textPGMColorA;
    IBOutlet NSTextField*	textPGMColorB;
    IBOutlet NSTextField*	textPRVBlack;
    IBOutlet NSTextField*	textPRVCh1;
    IBOutlet NSTextField*	textPRVCh2;
    IBOutlet NSTextField*	textPRVCh3;
    IBOutlet NSTextField*	textPRVCh4;
    IBOutlet NSTextField*	textPRVCh5;
    IBOutlet NSTextField*	textPRVCh6;
    IBOutlet NSTextField*	textPRVColorA;
    IBOutlet NSTextField*	textPRVColorB;
    IBOutlet NSTextField*	textTRANSHold;
    IBOutlet NSTextField*	textTRANSAuto;
    IBOutlet NSTextField*	textTRANSCut;
    IBOutlet NSTextField*	textTRANSPreview;
    IBOutlet NSTextField*	textTRANSMix;
    IBOutlet NSTextField*	textTRANSDip;
    IBOutlet NSTextField*	textTRANSWipe;
    IBOutlet NSTextField*	textTRANSDve;
    IBOutlet NSTextField*	textDSK1Preview;
    IBOutlet NSTextField*	textDSK1On;
    IBOutlet NSTextField*	textDSK1Auto;
    IBOutlet NSTextField*	textDSK1Duration;
    IBOutlet NSTextField*	textDSK2Duration;
    IBOutlet NSTextField*	textDSK2Preview;
    IBOutlet NSTextField*	textDSK2On;
    IBOutlet NSTextField*	textDSK2Auto;
    
    
    
    //App-level var
    bool                    isKBControlling;
    bool                    isMouseControlling;
    bool                    isReverseSlider;
    NSMutableArray*         kbShortName;
    NSMutableArray*         cmdKBMapping;
    NSEvent*                kbLocalDownHandle;
    NSEvent*                kbLocalUpHandle;
    NSEvent*                kbLocalFlagsHandle;
    NSEvent*                kbGlobalDownHandle;
    NSEvent*                kbGlobalUpHandle;
    NSEvent*                kbGlobalFlagsHandle;
    NSTimer*                timerFadeOut;
    float                   floatFadeOutCount;
    
    
    //ATEM var
    IBMDSwitcherDiscovery*		mSwitcherDiscovery;
    IBMDSwitcher*				mSwitcher;
    IBMDSwitcherMixEffectBlock*	mMixEffectBlock;
    MixEffectBlockMonitor*		mMixEffectBlockMonitor;
    SwitcherMonitor*			mSwitcherMonitor;
    std::list<InputMonitor*>	mInputMonitors;
    bool						mMoveSliderDownwards;
    bool						mCurrentTransitionReachedHalfway;
    IBMDSwitcherTransitionParameters* mTransitionParameters;
    std::list<IBMDSwitcherDownstreamKey*> mDSK;
    TransitionMonitor*          mTransitionMonitor;
    DSKMonitor*                 mDSKMonitor;
    
    
    struct mixerCurrentStatus {
        bool Connected;
        __unsafe_unretained NSString* IP;
        __unsafe_unretained NSString* Name;
        BMDSwitcherInputId Black; //typdef int64_t BMDSwitcherInputId
        BMDSwitcherInputId Ch1;
        BMDSwitcherInputId Ch2;
        BMDSwitcherInputId Ch3;
        BMDSwitcherInputId Ch4;
        BMDSwitcherInputId Ch5;
        BMDSwitcherInputId Ch6;
        BMDSwitcherInputId ColorA;
        BMDSwitcherInputId ColorB;
        int PGMCh; //0:Black,1-6:Ch,7-8:ColorA/B
        int PRVCh; //0:Black,1-6:Ch,7-8:ColorA/B
        double TRANSStage; //0:Begin, 1:End
        bool TRANSPreviewing;
        long TRANSDuration;
        int64_t TRANSRollingFrames; // <0:Not rolling
        __unsafe_unretained NSString* TRANSNextMode;
        __unsafe_unretained NSString* TRANSCurrentMode;
        bool DSK1Preview;
        bool DSK1On;
        uint32_t DSK1RollingFrames; // <0:Not rolling
        uint32_t DSK1Duration;
        bool DSK2Preview;
        bool DSK2On;
        uint32_t DSK2RollingFrames; // <0:Not rolling
        uint32_t DSK2Duration;
        //{false,@"192.168.2.250",@"",0,1,2,3,4,5,6,7,8,0,0,0,false,0,0,@"",@"",false,false,0,0,false,false,0,0};

    }mixerCurrentStatus;
    
}

//@property (assign) IBOutlet NSWindow *window;

//UI IBAction Methods
- (IBAction)clickedUIMappingButton:(id)sender;
- (IBAction)changeUIMappingTransitionSlider:(id)sender;
- (IBAction)clickedUIClearLogs:(id)sender;
- (IBAction)clickedUIToggleAction:(id)sender;
- (IBAction)clickedReverseSlider:(id)sernder;
- (IBAction)clickedChangeIP:(id)sender;


//ATEM Methods
-(void)updateUIbetweenMixer;
-(void)mixerDisconnected;
-(void)connectMixer;
-(void)updateMixerCurrentStatus;


//UI <-> AppDelegate Methods
-(void)toggleMouseMonitor;
-(void)toggleAllMappingKBNameTextField;
-(void)toggleUIConnectionAllTextField;
-(void)setupValues;
-(void)setupUI;
-(void)updateKBMappings;
-(int)kbShortNameSearch:(NSMutableArray*)arrayToSearch obj:(NSString*)obj;
-(void)triggerKB:(int)keyCode isDown:(bool)isDown;
-(void)executeCmd:(NSString*)shortName;
-(void)toggleKeyListening:(int)type;
-(void)appLog:(NSString*)content;


@end

