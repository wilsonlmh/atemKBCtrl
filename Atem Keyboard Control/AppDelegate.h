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
#import <string>
#import <libkern/OSAtomic.h>
#import "preferenceWindow.h"
#import "virtualKeyboard.h"


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
    IBOutlet NSTextField*   textTRANSDuration;
    IBOutlet NSTextField*	textTRANSMix;
    IBOutlet NSTextField*	textTRANSMixDuration;
    IBOutlet NSTextField*	textTRANSDip;
    IBOutlet NSTextField*	textTRANSDipDuration;
    IBOutlet NSTextField*	textTRANSWipe;
    IBOutlet NSTextField*	textTRANSWipeDuration;
    IBOutlet NSTextField*	textTRANSDve;
    IBOutlet NSTextField*	textTRANSDveDuration;
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
    bool                    isReversedSlider;
    NSMutableArray*         kbShortName;
    NSMutableArray*         cmdKBMapping;
    NSEvent*                kbLocalDownHandle;
    NSEvent*                kbLocalUpHandle;
    NSEvent*                kbLocalFlagsHandle;
    NSEvent*                kbGlobalDownHandle;
    NSEvent*                kbGlobalUpHandle;
    NSEvent*                kbGlobalFlagsHandle;
    NSEvent*                mouseLocalMoveHandle;
    NSTimer*                timerFadeOut;
    CGFloat                 lastMouseY;
    CGFloat                 lastOnlineMouseY;
    float                   floatFadeOutCount;
    double                  lastTransitionStage;
    preferenceWindow*       PreferenceWindow;
    virtualKeyboard*        VirtualKeyboard;
    
    //preference
    NSMutableArray*         preferenceLabel;
    NSMutableArray*         preferenceChannels;
    
    
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
    IBMDSwitcherTransitionMixParameters* mTransitionMixParameters;
    IBMDSwitcherTransitionWipeParameters* mTransitionWipeParameters;
    IBMDSwitcherTransitionDipParameters* mTransitionDipParameters;
    IBMDSwitcherTransitionDVEParameters* mTransitionDVEParameters;
    
    
    config currentConfig;
    
    struct mixerCurrentStatus {
        bool Connected;
        __unsafe_unretained NSString* IP;
        __unsafe_unretained NSString* Name;
        int frameRate;
        
        int PGMCh; //0:Black,1-6:Ch,7-8:ColorA/B
        int PRVCh; //0:Black,1-6:Ch,7-8:ColorA/B
        double TRANSStage; //0:Begin, 1:End
        bool TRANSPreviewing;
        uint32_t TRANSDuration;
        int64_t TRANSRollingFrames; // <0:Not rolling
        uint32_t TRANSMixDuration;
        uint32_t TRANSWipeDuration;
        uint32_t TRANSDipDuration;
        uint32_t TRANSDveDuration;
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
        //{false,@"",@"",0,0,false,0,0,0,0,0,0,@"",@"",false,false,0,0,false,false,0,0};

    }mixerCurrentStatus;
    
}

//@property (assign) IBOutlet NSWindow *window;

//UI IBAction Methods
-(IBAction)clickedUIMappingButton:(NSButton*)sender;
-(IBAction)changeUIMappingTransitionSlider:(id)sender;
-(IBAction)clickedUIClearLogs:(id)sender;
-(IBAction)clickedUIToggleAction:(id)sender;
-(IBAction)clickedReverseSlider:(id)sender;
-(IBAction)clickedChangeIP:(id)sender;
-(IBAction)clickedUpArraow:(NSButton*)sender;
-(IBAction)clickedDownArraow:(NSButton*)sender;
-(IBAction)changedDuration:(NSTextField*)sender;
-(IBAction)clickedMenuPreferences:(id)sender;
-(IBAction)clickedBGButton:(id)sender;
-(IBAction)focusedMappingText:(NSTextField*)sender;
-(IBAction)changedTextKeys:(id)sender;

//ATEM Methods
-(void)updateUIbetweenMixer;
-(void)mixerDisconnected;
-(void)connectMixer;
-(void)updateMixerCurrentStatus;
-(int)nsStringDurationToInt:(NSString*)duration;
-(NSString*)intDurationToNSString:(int)duration;
-(void)mouseMoving;

//UI <-> AppDelegate Methods
-(void)setupNSUserDefaults;
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
-(void)windowLostFocus;
-(void)preferenceWindowClickedApplyButton;
-(void)saveNSUserDefaults;
//-(void)appLog:(NSString*)content;


@end


@interface MappingText : NSTextField {
    
}


@end
