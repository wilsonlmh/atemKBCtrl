/*
    AppDelegate.m
    Atem Keyboard Control

    Created by Wilson Luniz on 15-1-17.
    Copyright (c) 2015 Luniz Pd. All rights reserved.
 
    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.
 
    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.
 
    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
 
 */

#import "AppDelegate.h"

//Pre-defined const
static NSColor *const onlineColor = [NSColor colorWithRed:0.2 green:1 blue:0.2 alpha:1];
static NSColor *const offlineColor = [NSColor colorWithRed:1 green:0.2 blue:0.2 alpha:1];
static NSImage *const redImage = [NSImage imageNamed:@"redButton"];
static NSImage *const greenImage = [NSImage imageNamed:@"greenButton"];
static NSImage *const yellowImage = [NSImage imageNamed:@"yellowButton"];
static NSImage *const blueImage = [NSImage imageNamed:@"blueButton"];
static NSImage *const blackImage = [NSImage imageNamed:@"blackButton"];
static NSImage *const normalImage = [NSImage imageNamed:@"normalButton"];


static inline bool	operator== (const REFIID& iid1, const REFIID& iid2)
{
    return CFEqual(&iid1, &iid2);
}

// Callback class for monitoring property changes on a mix effect block.
class MixEffectBlockMonitor : public IBMDSwitcherMixEffectBlockCallback
{
public:
    MixEffectBlockMonitor(AppDelegate* uiDelegate) : mUiDelegate(uiDelegate), mRefCount(1) { }
    
protected:
    virtual ~MixEffectBlockMonitor() { }
    
public:
    HRESULT STDMETHODCALLTYPE QueryInterface(REFIID iid, LPVOID *ppv)
    {
        if (!ppv)
            return E_POINTER;
        
        if (iid == IID_IBMDSwitcherMixEffectBlockCallback)
        {
            *ppv = static_cast<IBMDSwitcherMixEffectBlockCallback*>(this);
            AddRef();
            return S_OK;
        }
        
        if (CFEqual(&iid, IUnknownUUID))
        {
            *ppv = static_cast<IUnknown*>(this);
            AddRef();
            return S_OK;
        }
        
        *ppv = NULL;
        return E_NOINTERFACE;
    }
    
    ULONG STDMETHODCALLTYPE AddRef(void)
    {
        return ::OSAtomicIncrement32(&mRefCount);
    }
    
    ULONG STDMETHODCALLTYPE Release(void)
    {
        int newCount = ::OSAtomicDecrement32(&mRefCount);
        if (newCount == 0)
            delete this;
        return newCount;
    }
    
    HRESULT PropertyChanged(BMDSwitcherMixEffectBlockPropertyId propertyId)
    {
        switch (propertyId)
        {
            case bmdSwitcherMixEffectBlockPropertyIdProgramInput:
                [mUiDelegate performSelectorOnMainThread:@selector(updateMixerCurrentStatus) withObject:nil waitUntilDone:YES];
                break;
            case bmdSwitcherMixEffectBlockPropertyIdPreviewInput:
                [mUiDelegate performSelectorOnMainThread:@selector(updateMixerCurrentStatus) withObject:nil waitUntilDone:YES];
                break;
            case bmdSwitcherMixEffectBlockPropertyIdInTransition:
                [mUiDelegate performSelectorOnMainThread:@selector(updateMixerCurrentStatus) withObject:nil waitUntilDone:YES];
                break;
            case bmdSwitcherMixEffectBlockPropertyIdTransitionPosition:
                [mUiDelegate performSelectorOnMainThread:@selector(updateMixerCurrentStatus) withObject:nil waitUntilDone:YES];                break;
            case bmdSwitcherMixEffectBlockPropertyIdTransitionFramesRemaining:
                [mUiDelegate performSelectorOnMainThread:@selector(updateMixerCurrentStatus) withObject:nil waitUntilDone:YES];
                break;
            case bmdSwitcherMixEffectBlockPropertyIdFadeToBlackFramesRemaining:
                [mUiDelegate performSelectorOnMainThread:@selector(updateMixerCurrentStatus) withObject:nil waitUntilDone:YES];
                break;
            default:
                [mUiDelegate performSelectorOnMainThread:@selector(updateMixerCurrentStatus) withObject:nil waitUntilDone:YES];
                break;
        }
        return S_OK;
    }
    
    
private:
    AppDelegate*                    mUiDelegate;
    int								mRefCount;
};

// Monitor the properties on Switcher Inputs.
// In this sample app we're only interested in changes to the Long Name property to update the PopupButton list
class InputMonitor : public IBMDSwitcherInputCallback
{
public:
    InputMonitor(IBMDSwitcherInput* input, AppDelegate* uiDelegate) : mInput(input), mUiDelegate(uiDelegate), mRefCount(1)
    {
        mInput->AddRef();
        mInput->AddCallback(this);
    }
    
protected:
    ~InputMonitor()
    {
        mInput->RemoveCallback(this);
        mInput->Release();
    }
    
public:
    // IBMDSwitcherInputCallback interface
    HRESULT STDMETHODCALLTYPE QueryInterface(REFIID iid, LPVOID *ppv)
    {
        if (!ppv)
            return E_POINTER;
        
        if (iid == IID_IBMDSwitcherInputCallback)
        {
            *ppv = static_cast<IBMDSwitcherInputCallback*>(this);
            AddRef();
            return S_OK;
        }
        
        if (CFEqual(&iid, IUnknownUUID))
        {
            *ppv = static_cast<IUnknown*>(this);
            AddRef();
            return S_OK;
        }
        
        *ppv = NULL;
        return E_NOINTERFACE;
    }
    
    ULONG STDMETHODCALLTYPE AddRef(void)
    {
        return ::OSAtomicIncrement32(&mRefCount);
    }
    
    ULONG STDMETHODCALLTYPE Release(void)
    {
        int newCount = ::OSAtomicDecrement32(&mRefCount);
        if (newCount == 0)
            delete this;
        return newCount;
    }
    
    HRESULT PropertyChanged(BMDSwitcherInputPropertyId propertyId)
    {
        switch (propertyId)
        {
            case bmdSwitcherInputPropertyIdLongName:
                [mUiDelegate performSelectorOnMainThread:@selector(updateMixerCurrentStatus) withObject:nil waitUntilDone:YES];
            default:	// ignore other property changes not used for this sample app
                break;
        }
        
        return S_OK;
    }
    IBMDSwitcherInput* input() { return mInput; }
    
private:
    IBMDSwitcherInput*			mInput;
    AppDelegate*	mUiDelegate;
    int							mRefCount;
};

// Callback class to monitor switcher disconnection
class SwitcherMonitor : public IBMDSwitcherCallback
{
public:
    SwitcherMonitor(AppDelegate* uiDelegate) :	mUiDelegate(uiDelegate), mRefCount(1) { }
    
protected:
    virtual ~SwitcherMonitor() { }
    
public:
    // IBMDSwitcherCallback interface
    HRESULT STDMETHODCALLTYPE QueryInterface(REFIID iid, LPVOID *ppv)
    {
        if (!ppv)
            return E_POINTER;
        
        if (iid == IID_IBMDSwitcherCallback)
        {
            *ppv = static_cast<IBMDSwitcherCallback*>(this);
            AddRef();
            return S_OK;
        }
        
        if (CFEqual(&iid, IUnknownUUID))
        {
            *ppv = static_cast<IUnknown*>(this);
            AddRef();
            return S_OK;
        }
        
        *ppv = NULL;
        return E_NOINTERFACE;
    }
    
    ULONG STDMETHODCALLTYPE AddRef(void)
    {
        return ::OSAtomicIncrement32(&mRefCount);
    }
    
    ULONG STDMETHODCALLTYPE Release(void)
    {
        int newCount = ::OSAtomicDecrement32(&mRefCount);
        if (newCount == 0)
            delete this;
        return newCount;
    }
    
    HRESULT STDMETHODCALLTYPE	Notify(BMDSwitcherEventType eventType) {
        switch(eventType) {
            case bmdSwitcherEventTypeDisconnected:
                [mUiDelegate performSelectorInBackground:@selector(mixerDisconnected) withObject:nil];
                break;
        }
        return S_OK; }
    
    HRESULT STDMETHODCALLTYPE	Disconnected(void)
    {
        
        return S_OK;
    }
    
private:
    AppDelegate*	mUiDelegate;
    int				mRefCount;
};


class TransitionMonitor : public IBMDSwitcherTransitionParametersCallback {
    
public:
    TransitionMonitor(AppDelegate* uiDelegate) :	mUiDelegate(uiDelegate), mRefCount(1) { }
    
protected:
    virtual ~TransitionMonitor() { }
public:
    HRESULT STDMETHODCALLTYPE QueryInterface(REFIID iid, LPVOID *ppv)
    {
        if (!ppv)
            return E_POINTER;
        
        if (iid == IID_IBMDSwitcherTransitionParametersCallback)
        {
            *ppv = static_cast<IBMDSwitcherTransitionParametersCallback*>(this);
            AddRef();
            return S_OK;
        }
        
        if (CFEqual(&iid, IUnknownUUID))
        {
            *ppv = static_cast<IUnknown*>(this);
            AddRef();
            return S_OK;
        }
        
        *ppv = NULL;
        return E_NOINTERFACE;
    }
    
    ULONG STDMETHODCALLTYPE AddRef(void)
    {
        return ::OSAtomicIncrement32(&mRefCount);
    }
    
    ULONG STDMETHODCALLTYPE Release(void)
    {
        int newCount = ::OSAtomicDecrement32(&mRefCount);
        if (newCount == 0)
            delete this;
        return newCount;
    }
    
    HRESULT STDMETHODCALLTYPE	Notify(BMDSwitcherTransitionParametersEventType eventType) {
        [mUiDelegate performSelectorOnMainThread:@selector(updateMixerCurrentStatus) withObject:nil waitUntilDone:YES];
        return S_OK; }
    
private:
    AppDelegate*	mUiDelegate;
    int				mRefCount;
    
};

class DSKMonitor : public IBMDSwitcherDownstreamKeyCallback {
    
public:
    DSKMonitor(AppDelegate* uiDelegate) :	mUiDelegate(uiDelegate), mRefCount(1) { }
    
protected:
    virtual ~DSKMonitor() { }
public:
    HRESULT STDMETHODCALLTYPE QueryInterface(REFIID iid, LPVOID *ppv)
    {
        if (!ppv)
            return E_POINTER;
        
        if (iid == IID_IBMDSwitcherDownstreamKeyCallback)
        {
            *ppv = static_cast<IBMDSwitcherDownstreamKeyCallback*>(this);
            AddRef();
            return S_OK;
        }
        
        if (CFEqual(&iid, IUnknownUUID))
        {
            *ppv = static_cast<IUnknown*>(this);
            AddRef();
            return S_OK;
        }
        
        *ppv = NULL;
        return E_NOINTERFACE;
    }
    
    ULONG STDMETHODCALLTYPE AddRef(void)
    {
        return ::OSAtomicIncrement32(&mRefCount);
    }
    
    ULONG STDMETHODCALLTYPE Release(void)
    {
        int newCount = ::OSAtomicDecrement32(&mRefCount);
        if (newCount == 0)
            delete this;
        return newCount;
    }
    
    HRESULT STDMETHODCALLTYPE	Notify(BMDSwitcherTransitionParametersEventType eventType) {
        [mUiDelegate performSelectorOnMainThread:@selector(updateMixerCurrentStatus) withObject:nil waitUntilDone:YES];
        return S_OK; }
    
private:
    AppDelegate*	mUiDelegate;
    int			mRefCount;
    
};

@implementation AppDelegate

-(void)setupValues {
    isKBControlling = false;
    kbShortName = makeEmptyNSStringNSArray(150);
    cmdKBMapping = makeEmptyNSStringNSArray(150);
    mixerCurrentStatus = {false,@"",@"",0,0,1,2,3,4,5,6,7,8,0,0,0,false,0,0,0,0,0,0,@"",@"",false,false,0,0,false,false,0,0};
    {
        kbShortName[0]=@"a";
        kbShortName[11]=@"b";
        kbShortName[8]=@"c";
        kbShortName[2]=@"d";
        kbShortName[14]=@"e";
        kbShortName[3]=@"f";
        kbShortName[5]=@"g";
        kbShortName[4]=@"h";
        kbShortName[34]=@"i";
        kbShortName[38]=@"j";
        kbShortName[40]=@"k";
        kbShortName[37]=@"l";
        kbShortName[46]=@"m";
        kbShortName[45]=@"n";
        kbShortName[31]=@"o";
        kbShortName[35]=@"p";
        kbShortName[12]=@"q";
        kbShortName[15]=@"r";
        kbShortName[1]=@"s";
        kbShortName[17]=@"t";
        kbShortName[32]=@"u";
        kbShortName[9]=@"v";
        kbShortName[13]=@"w";
        kbShortName[7]=@"x";
        kbShortName[16]=@"y";
        kbShortName[6]=@"z";
        kbShortName[29]=@"0";
        kbShortName[18]=@"1";
        kbShortName[19]=@"2";
        kbShortName[20]=@"3";
        kbShortName[21]=@"4";
        kbShortName[23]=@"5";
        kbShortName[22]=@"6";
        kbShortName[26]=@"7";
        kbShortName[28]=@"8";
        kbShortName[25]=@"9";
        kbShortName[27]=@"-";
        kbShortName[24]=@"=";
        kbShortName[33]=@"[";
        kbShortName[30]=@"]";
        kbShortName[42]=@"\\";
        kbShortName[41]=@";";
        kbShortName[39]=@"‘";
        kbShortName[43]=@",";
        kbShortName[47]=@".";
        kbShortName[44]=@"/";
        kbShortName[50]=@"`";
        kbShortName[49]=@"Space";
        kbShortName[126]=@"Up";
        kbShortName[125]=@"Down";
        kbShortName[123]=@"Left";
        kbShortName[124]=@"Right";
        kbShortName[71]=@"NLock";
        kbShortName[82]=@"Num0";
        kbShortName[83]=@"Num1";
        kbShortName[84]=@"Num2";
        kbShortName[85]=@"Num3";
        kbShortName[86]=@"Num3";
        kbShortName[87]=@"Num4";
        kbShortName[88]=@"Num5";
        kbShortName[89]=@"Num6";
        kbShortName[90]=@"Num7";
        kbShortName[91]=@"Num8";
        kbShortName[92]=@"Num9";
        kbShortName[78]=@"Num-";
        kbShortName[69]=@"Num+";
        kbShortName[67]=@"Num*";
        kbShortName[75]=@"Num/";
        kbShortName[81]=@"Num=";
        kbShortName[65]=@"Num.";
        kbShortName[51]=@"BKSP";
        kbShortName[117]=@"Del";
        kbShortName[55]=@"⌘";
        kbShortName[36]=@"↩";
        kbShortName[76]=@"Num↩";
        kbShortName[48]=@"Tab";
        kbShortName[59]=@"^";
        kbShortName[58]=@"⌥";
        kbShortName[56]=@"⇧";
        kbShortName[54]=@"R⌘";
        kbShortName[60]=@"R⇧";
        kbShortName[62]=@"R^";
        kbShortName[61]=@"R⌥";
        kbShortName[57]=@"CLock";
        kbShortName[63]=@"Fn";
    }
    
    mSwitcherDiscovery = NULL;
    mSwitcher = NULL;
    mMixEffectBlock = NULL;
    
    mSwitcherMonitor = new SwitcherMonitor(self);
    mMixEffectBlockMonitor = new MixEffectBlockMonitor(self);
    mTransitionMonitor = new TransitionMonitor(self);
    mDSKMonitor = new DSKMonitor(self);
    
    mMoveSliderDownwards = false;
    mCurrentTransitionReachedHalfway = false;
    
    mSwitcherDiscovery = CreateBMDSwitcherDiscoveryInstance();
    if (!mSwitcherDiscovery)
    {
        NSLog(@"Cannot create mSwitcherDiscovery instance!");
    }
    
    [self updateKBMappings];
    
}

-(void)setupUI {
    textInput.stringValue = @"";
    textKB.hidden = true;
    window.backgroundColor = [NSColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:1];
    logTextArea.textColor = [NSColor whiteColor];
    preBG.hidden = true;
    [self performSelectorOnMainThread:@selector(toggleAllMappingKBNameTextField) withObject:nil waitUntilDone:YES];
}

-(void) updateKBMappings{
    cmdKBMapping = makeEmptyNSStringNSArray(150);
    if ([self kbShortNameSearch:kbShortName obj:textPGMBlack.stringValue]!= -1) {
        cmdKBMapping[[self kbShortNameSearch:kbShortName obj:textPGMBlack.stringValue]] = @"PGMBlack";
    }
    if ([self kbShortNameSearch:kbShortName obj:textPGMCh1.stringValue]!= -1) {
        cmdKBMapping[[self kbShortNameSearch:kbShortName obj:textPGMCh1.stringValue]] = @"PGMCh1";
    }
    if ([self kbShortNameSearch:kbShortName obj:textPGMCh2.stringValue]!= -1) {
        cmdKBMapping[[self kbShortNameSearch:kbShortName obj:textPGMCh2.stringValue]] = @"PGMCh2";
    }
    if ([self kbShortNameSearch:kbShortName obj:textPGMCh3.stringValue]!= -1) {
        cmdKBMapping[[self kbShortNameSearch:kbShortName obj:textPGMCh3.stringValue]] = @"PGMCh3";
    }
    if ([self kbShortNameSearch:kbShortName obj:textPGMCh4.stringValue]!= -1) {
        cmdKBMapping[[self kbShortNameSearch:kbShortName obj:textPGMCh4.stringValue]] = @"PGMCh4";
    }
    if ([self kbShortNameSearch:kbShortName obj:textPGMCh5.stringValue]!= -1) {
        cmdKBMapping[[self kbShortNameSearch:kbShortName obj:textPGMCh5.stringValue]] = @"PGMCh5";
    }
    if ([self kbShortNameSearch:kbShortName obj:textPGMCh6.stringValue]!= -1) {
        cmdKBMapping[[self kbShortNameSearch:kbShortName obj:textPGMCh6.stringValue]] = @"PGMCh6";
    }
    if ([self kbShortNameSearch:kbShortName obj:textPGMColorA.stringValue]!= -1) {
        cmdKBMapping[[self kbShortNameSearch:kbShortName obj:textPGMColorA.stringValue]] = @"PGMColorA";
    }
    if ([self kbShortNameSearch:kbShortName obj:textPGMColorB.stringValue]!= -1) {
        cmdKBMapping[[self kbShortNameSearch:kbShortName obj:textPGMColorB.stringValue]] = @"PGMColorB";
    }
    if ([self kbShortNameSearch:kbShortName obj:textPGMBlack.stringValue]!= -1) {
        cmdKBMapping[[self kbShortNameSearch:kbShortName obj:textPRVBlack.stringValue]] = @"PRVBlack";
    }
    if ([self kbShortNameSearch:kbShortName obj:textPRVCh1.stringValue]!= -1) {
        cmdKBMapping[[self kbShortNameSearch:kbShortName obj:textPRVCh1.stringValue]] = @"PRVCh1";
    }
    if ([self kbShortNameSearch:kbShortName obj:textPRVCh2.stringValue]!= -1) {
        cmdKBMapping[[self kbShortNameSearch:kbShortName obj:textPRVCh2.stringValue]] = @"PRVCh2";
    }
    if ([self kbShortNameSearch:kbShortName obj:textPRVCh3.stringValue]!= -1) {
        cmdKBMapping[[self kbShortNameSearch:kbShortName obj:textPRVCh3.stringValue]] = @"PRVCh3";
    }
    if ([self kbShortNameSearch:kbShortName obj:textPRVCh4.stringValue]!= -1) {
        cmdKBMapping[[self kbShortNameSearch:kbShortName obj:textPRVCh4.stringValue]] = @"PRVCh4";
    }
    if ([self kbShortNameSearch:kbShortName obj:textPRVCh5.stringValue]!= -1) {
        cmdKBMapping[[self kbShortNameSearch:kbShortName obj:textPRVCh5.stringValue]] = @"PRVCh5";
    }
    if ([self kbShortNameSearch:kbShortName obj:textPRVCh6.stringValue]!= -1) {
        cmdKBMapping[[self kbShortNameSearch:kbShortName obj:textPRVCh6.stringValue]] = @"PRVCh6";
    }
    if ([self kbShortNameSearch:kbShortName obj:textPRVColorA.stringValue]!= -1) {
        cmdKBMapping[[self kbShortNameSearch:kbShortName obj:textPRVColorA.stringValue]] = @"PRVColorA";
    }
    if ([self kbShortNameSearch:kbShortName obj:textPRVColorB.stringValue]!= -1) {
        cmdKBMapping[[self kbShortNameSearch:kbShortName obj:textPRVColorB.stringValue]] = @"PRVColorB";
    }
    if ([self kbShortNameSearch:kbShortName obj:textTRANSHold.stringValue]!= -1) {
        cmdKBMapping[[self kbShortNameSearch:kbShortName obj:textTRANSHold.stringValue]] = @"TRANSHold";
    }
    if ([self kbShortNameSearch:kbShortName obj:textTRANSAuto.stringValue]!= -1) {
        cmdKBMapping[[self kbShortNameSearch:kbShortName obj:textTRANSAuto.stringValue]] = @"TRANSAuto";
    }
    if ([self kbShortNameSearch:kbShortName obj:textTRANSCut.stringValue]!= -1) {
        cmdKBMapping[[self kbShortNameSearch:kbShortName obj:textTRANSCut.stringValue]] = @"TRANSCut";
    }
    if ([self kbShortNameSearch:kbShortName obj:textTRANSPreview.stringValue]!= -1) {
        cmdKBMapping[[self kbShortNameSearch:kbShortName obj:textTRANSPreview.stringValue]] = @"TRANSPreview";
    }
    if ([self kbShortNameSearch:kbShortName obj:textTRANSMix.stringValue]!= -1) {
        cmdKBMapping[[self kbShortNameSearch:kbShortName obj:textTRANSMix.stringValue]] = @"TRANSMix";
    }
    if ([self kbShortNameSearch:kbShortName obj:textTRANSDip.stringValue]!= -1) {
        cmdKBMapping[[self kbShortNameSearch:kbShortName obj:textTRANSDip.stringValue]] = @"TRANSDip";
    }
    if ([self kbShortNameSearch:kbShortName obj:textTRANSWipe.stringValue]!= -1) {
        cmdKBMapping[[self kbShortNameSearch:kbShortName obj:textTRANSWipe.stringValue]] = @"TRANSWipe";
    }
    if ([self kbShortNameSearch:kbShortName obj:textTRANSDve.stringValue]!= -1) {
        cmdKBMapping[[self kbShortNameSearch:kbShortName obj:textTRANSDve.stringValue]] = @"TRANSDve";
    }
    if ([self kbShortNameSearch:kbShortName obj:textDSK1Preview.stringValue]!= -1) {
        cmdKBMapping[[self kbShortNameSearch:kbShortName obj:textDSK1Preview.stringValue]] = @"DSK1Preview";
    }
    if ([self kbShortNameSearch:kbShortName obj:textDSK1On.stringValue]!= -1) {
        cmdKBMapping[[self kbShortNameSearch:kbShortName obj:textDSK1On.stringValue]] = @"DSK1On";
    }
    if ([self kbShortNameSearch:kbShortName obj:textDSK1Auto.stringValue]!= -1) {
        cmdKBMapping[[self kbShortNameSearch:kbShortName obj:textDSK1Auto.stringValue]] = @"DSK1Auto";
    }
    if ([self kbShortNameSearch:kbShortName obj:textDSK2Preview.stringValue]!= -1) {
        cmdKBMapping[[self kbShortNameSearch:kbShortName obj:textDSK2Preview.stringValue]] = @"DSK2Preview";
    }
    if ([self kbShortNameSearch:kbShortName obj:textDSK2On.stringValue]!= -1) {
        cmdKBMapping[[self kbShortNameSearch:kbShortName obj:textDSK2On.stringValue]] = @"DSK2On";
    }
    if ([self kbShortNameSearch:kbShortName obj:textDSK2Auto.stringValue]!= -1) {
        cmdKBMapping[[self kbShortNameSearch:kbShortName obj:textDSK2Auto.stringValue]] = @"DSK2Auto";
    }
}

-(void)textInputStartFadeOut {
    floatFadeOutCount = 0;
    if (timerFadeOut) {
        [timerFadeOut invalidate];
    }
    timerFadeOut = NULL;
    timerFadeOut = [NSTimer scheduledTimerWithTimeInterval:0.02 target:self selector:@selector(textInputFadingOut) userInfo:nil repeats:YES];
}

-(void)textInputFadingOut {
    textInput.alphaValue = 1-floatFadeOutCount;
    floatFadeOutCount = floatFadeOutCount + 0.02;
    if (floatFadeOutCount >= 1) {
        [timerFadeOut invalidate];
    }
    
}

NSMutableArray* makeEmptyNSStringNSArray(int size) {
    NSMutableArray *ret = [NSMutableArray arrayWithCapacity:(size)];
    for (int i=0; i< size; i++) {
        [ret addObject:(@"")];
    }
    return ret;
}

-(int)kbShortNameSearch:(NSMutableArray*)arrayToSearch obj:(NSString*)obj {
    for (int i=0; i<[arrayToSearch count]; i++) {
        if ([obj isEqual:arrayToSearch[i]]) {
            return i;
        }
    }
    return -1;//nil changed to -1
}

-(void)triggerKB:(int)keyCode isDown:(bool)isDown {
    if ((isDown) && (![cmdKBMapping[keyCode]  isEqual: @"TRANSHold"]) && (![cmdKBMapping[keyCode]  isEqual: @""])) {
        [textKB becomeFirstResponder];
        textInput.stringValue = kbShortName[keyCode];
        [self textInputStartFadeOut];
        [self executeCmd:cmdKBMapping[keyCode]];
    } else if ([cmdKBMapping[keyCode]  isEqual: @"TRANSHold"])  {
        textInput.stringValue = kbShortName[keyCode];
        [self textInputStartFadeOut];
        if (isDown) { [self executeCmd:@"TRANSHoldDown"]; } else { [self executeCmd:@"TRANSHoldUp"]; }
    }
}

-(void)executeCmd:(NSString*)shortName {
    if ((mixerCurrentStatus.Connected) && (isKBControlling)) {
        //switch statement with NSString in another way:
        //Ref:http://stackoverflow.com/questions/19067785/switch-case-on-nsstring-in-objective-c
        
        void (^selectedCase)() = @{
                                   @"TRANSHoldDown" : ^ {
                                       if (!isMouseControlling) {
                                           isMouseControlling = true;
                                           [self performSelectorOnMainThread:@selector(updateUIbetweenMixer) withObject:nil waitUntilDone:YES];
                                           [self performSelectorOnMainThread:@selector(toggleMouseMonitor) withObject:nil waitUntilDone:YES];
                                       }
                                   },
                                   @"TRANSHoldUp" : ^ {
                                       if (isMouseControlling) {
                                           isMouseControlling = false;
                                           [self performSelectorOnMainThread:@selector(updateUIbetweenMixer) withObject:nil waitUntilDone:YES];
                                           [self performSelectorOnMainThread:@selector(toggleMouseMonitor) withObject:nil waitUntilDone:YES];
                                       }
                                   },
                                   @"PGMBlack" : ^ {
                                       mMixEffectBlock->SetInt(bmdSwitcherMixEffectBlockPropertyIdProgramInput, mixerCurrentStatus.Black);
                                   },
                                   @"PGMCh1" : ^ {
                                       mMixEffectBlock->SetInt(bmdSwitcherMixEffectBlockPropertyIdProgramInput, mixerCurrentStatus.Ch1);
                                   },
                                   @"PGMCh2" : ^ {
                                       mMixEffectBlock->SetInt(bmdSwitcherMixEffectBlockPropertyIdProgramInput, mixerCurrentStatus.Ch2);
                                   },
                                   @"PGMCh3" : ^ {
                                       mMixEffectBlock->SetInt(bmdSwitcherMixEffectBlockPropertyIdProgramInput, mixerCurrentStatus.Ch3);
                                   },
                                   @"PGMCh4" : ^ {
                                       mMixEffectBlock->SetInt(bmdSwitcherMixEffectBlockPropertyIdProgramInput, mixerCurrentStatus.Ch4);
                                   },
                                   @"PGMCh5" : ^ {
                                       mMixEffectBlock->SetInt(bmdSwitcherMixEffectBlockPropertyIdProgramInput, mixerCurrentStatus.Ch5);
                                   },
                                   @"PGMCh6" : ^ {
                                       mMixEffectBlock->SetInt(bmdSwitcherMixEffectBlockPropertyIdProgramInput, mixerCurrentStatus.Ch6);
                                   },
                                   @"PGMColorA" : ^ {
                                       mMixEffectBlock->SetInt(bmdSwitcherMixEffectBlockPropertyIdProgramInput, mixerCurrentStatus.ColorA);
                                   },
                                   @"PGMColorB" : ^ {
                                       mMixEffectBlock->SetInt(bmdSwitcherMixEffectBlockPropertyIdProgramInput, mixerCurrentStatus.ColorB);
                                   },
                                   @"PRVBlack" : ^ {
                                       mMixEffectBlock->SetInt(bmdSwitcherMixEffectBlockPropertyIdPreviewInput, mixerCurrentStatus.Black);
                                   },
                                   @"PRVCh1" : ^ {
                                       mMixEffectBlock->SetInt(bmdSwitcherMixEffectBlockPropertyIdPreviewInput, mixerCurrentStatus.Ch1);
                                   },
                                   @"PRVCh2" : ^ {
                                       mMixEffectBlock->SetInt(bmdSwitcherMixEffectBlockPropertyIdPreviewInput, mixerCurrentStatus.Ch2);
                                   },
                                   @"PRVCh3" : ^ {
                                       mMixEffectBlock->SetInt(bmdSwitcherMixEffectBlockPropertyIdPreviewInput, mixerCurrentStatus.Ch3);
                                   },
                                   @"PRVCh4" : ^ {
                                       mMixEffectBlock->SetInt(bmdSwitcherMixEffectBlockPropertyIdPreviewInput, mixerCurrentStatus.Ch4);
                                   },
                                   @"PRVCh5" : ^ {
                                       mMixEffectBlock->SetInt(bmdSwitcherMixEffectBlockPropertyIdPreviewInput, mixerCurrentStatus.Ch5);
                                   },
                                   @"PRVCh6" : ^ {
                                       mMixEffectBlock->SetInt(bmdSwitcherMixEffectBlockPropertyIdPreviewInput, mixerCurrentStatus.Ch6);
                                   },
                                   @"PRVColorA" : ^ {
                                       mMixEffectBlock->SetInt(bmdSwitcherMixEffectBlockPropertyIdPreviewInput, mixerCurrentStatus.ColorA);
                                   },
                                   @"PRVColorB" : ^ {
                                       mMixEffectBlock->SetInt(bmdSwitcherMixEffectBlockPropertyIdPreviewInput, mixerCurrentStatus.ColorB);
                                   },
                                   @"TRANSAuto" : ^ {
                                       mMixEffectBlock->PerformAutoTransition();
                                   },
                                   @"TRANSCut" : ^ {
                                       mMixEffectBlock->PerformCut();
                                   },
                                   @"TRANSPreview" : ^ {                                    
                                        mMixEffectBlock->SetFlag(bmdSwitcherMixEffectBlockPropertyIdPreviewTransition, !mixerCurrentStatus.TRANSPreviewing);
                                   },
                                   @"TRANSMix" : ^ {
                                       mTransitionParameters->SetNextTransitionStyle(bmdSwitcherTransitionStyleMix);
                                   },
                                   @"TRANSDip" : ^ {
                                       mTransitionParameters->SetNextTransitionStyle(bmdSwitcherTransitionStyleDip);
                                   },
                                   @"TRANSWipe" : ^ {
                                       mTransitionParameters->SetNextTransitionStyle(bmdSwitcherTransitionStyleWipe);
                                   },
                                   @"TRANSDve" : ^ {
                                       mTransitionParameters->SetNextTransitionStyle(bmdSwitcherTransitionStyleDVE);
                                   },
                                   @"DSK1Preview" : ^ {
                                       int t = 1;
                                       std::list<IBMDSwitcherDownstreamKey*>::iterator iter = mDSK.begin();
                                       std::advance(iter, t-1);
                                       IBMDSwitcherDownstreamKey * key = *iter;
                                       bool isTie;
                                       isTie = false;
                                       key->GetTie(&isTie);
                                       key->SetTie(!isTie);
                                   },
                                   @"DSK1On" : ^ {
                                       int t = 1;
                                       std::list<IBMDSwitcherDownstreamKey*>::iterator iter = mDSK.begin();
                                       std::advance(iter, t-1);
                                       IBMDSwitcherDownstreamKey * key = *iter;
                                       bool isOnAir;
                                       key->GetOnAir(&isOnAir);
                                       key->SetOnAir(!isOnAir);
                                   },
                                   @"DSK1Auto" : ^ {
                                       int t = 1;
                                       std::list<IBMDSwitcherDownstreamKey*>::iterator iter = mDSK.begin();
                                       std::advance(iter, t-1);
                                       IBMDSwitcherDownstreamKey * key = *iter;
                                       bool isTransitioning;
                                       key->IsAutoTransitioning(&isTransitioning);
                                       if (!isTransitioning) key->PerformAutoTransition();//Transition means turn off->on or on->off
                                   },
                                   @"DSK2Preview" : ^ {
                                       int t = 2;
                                       std::list<IBMDSwitcherDownstreamKey*>::iterator iter = mDSK.begin();
                                       std::advance(iter, t-1);
                                       IBMDSwitcherDownstreamKey * key = *iter;
                                       bool isTie;
                                       isTie = false;
                                       key->GetTie(&isTie);
                                       key->SetTie(!isTie);
                                   },
                                   @"DSK2On" : ^ {
                                       int t = 2;
                                       std::list<IBMDSwitcherDownstreamKey*>::iterator iter = mDSK.begin();
                                       std::advance(iter, t-1);
                                       IBMDSwitcherDownstreamKey * key = *iter;
                                       bool isOnAir;
                                       key->GetOnAir(&isOnAir);
                                       key->SetOnAir(!isOnAir);
                                   },
                                   @"DSK2Auto" : ^ {
                                       int t = 2;
                                       std::list<IBMDSwitcherDownstreamKey*>::iterator iter = mDSK.begin();
                                       std::advance(iter, t-1);
                                       IBMDSwitcherDownstreamKey * key = *iter;
                                       bool isTransitioning;
                                       key->IsAutoTransitioning(&isTransitioning);
                                       if (!isTransitioning) key->PerformAutoTransition();//Transition means turn off->on or on->off
                                   },
                                   }[shortName];
        if (selectedCase !=nil) selectedCase();
        

    }
}

-(void)toggleMouseMonitor {
    if (mouseLocalMoveHandle) {
        [NSEvent removeMonitor:mouseLocalMoveHandle];
        mouseLocalMoveHandle = NULL;
    }
    
    if (isMouseControlling) {
        lastMouseY = [NSEvent mouseLocation].y;
        mouseLocalMoveHandle = [NSEvent addGlobalMonitorForEventsMatchingMask:NSMouseMovedMask handler:^(NSEvent * event) {
            [self mouseMoving];
        }];
        //Add Montior
        //Note: The montior must verify if connected to mixer or not
    }
}

-(void)mouseMoving {
    if ((mouseLocalMoveHandle) && (isMouseControlling) && (mixerCurrentStatus.Connected)) {
        CGFloat currentMouseY = [NSEvent mouseLocation].y;
        double deltaMouseY;
        mMixEffectBlock->GetFloat(bmdSwitcherMixEffectBlockPropertyIdTransitionPosition, &deltaMouseY);
        deltaMouseY = (double)((currentMouseY - lastMouseY)/200);
        if (isReverseSlider) { deltaMouseY =  -deltaMouseY; };
        if (deltaMouseY > 1) { deltaMouseY = 1; }
        if (deltaMouseY < 0) { deltaMouseY = 0; }
        mMixEffectBlock->SetFloat(bmdSwitcherMixEffectBlockPropertyIdTransitionPosition, deltaMouseY);
        if ((deltaMouseY == 1) || (deltaMouseY == 0)) {
            [self performSelectorOnMainThread:@selector(toggleMouseMonitor) withObject:nil waitUntilDone:YES];
        }
    }
}

-(void)toggleKeyListening:(int)type {
    if (kbLocalDownHandle) {
        [NSEvent removeMonitor:kbLocalDownHandle];
        kbLocalDownHandle = nil;
    }
    if (kbLocalUpHandle) {
        [NSEvent removeMonitor:kbLocalUpHandle];
        kbLocalUpHandle = nil;
    }
    if (kbLocalFlagsHandle) {
        [NSEvent removeMonitor:kbLocalFlagsHandle];
        kbLocalFlagsHandle = nil;
    }
    if (kbGlobalDownHandle) {
        [NSEvent removeMonitor:kbGlobalDownHandle];
        kbGlobalDownHandle = nil;
    }
    if (kbGlobalUpHandle) {
        [NSEvent removeMonitor:kbGlobalUpHandle];
        kbGlobalUpHandle = nil;
    }
    if (kbGlobalFlagsHandle) {
        [NSEvent removeMonitor:kbGlobalFlagsHandle];
        kbGlobalFlagsHandle = nil;
    }
    
    if ((mixerCurrentStatus.Connected) && (isKBControlling)) {
        kbLocalDownHandle = [NSEvent addLocalMonitorForEventsMatchingMask:NSKeyDownMask handler:^NSEvent *(NSEvent *event) {
            textKB.stringValue = @"";
            [self triggerKB:(int)event.keyCode isDown:true];
            return event;
        }];
        kbLocalUpHandle = [NSEvent addLocalMonitorForEventsMatchingMask:NSKeyUpMask handler:^NSEvent *(NSEvent *event) {
            textKB.stringValue = @"";
            [self triggerKB:(int)event.keyCode isDown:false];
            return event;
        }];
        kbLocalFlagsHandle = [NSEvent addLocalMonitorForEventsMatchingMask:NSFlagsChangedMask handler:^NSEvent *(NSEvent *event) {
            textKB.stringValue = @"";
            bool localIsDown = false;
            switch ((int)event.keyCode) {
                case 55:
                case 54:
                    if (event.modifierFlags & NSCommandKeyMask) {
                        localIsDown = 1;
                    }
                    break;
                    
                case 62:
                case 59:
                    if (event.modifierFlags & NSControlKeyMask) {
                        localIsDown = 1;
                    }
                    break;
                    
                case 61:
                case 58:
                    if (event.modifierFlags & NSAlternateKeyMask) {
                        localIsDown = 1;
                    }
                    break;
                    
                case 60:
                case 56:
                    if (event.modifierFlags & NSShiftKeyMask) {
                        localIsDown = 1;
                    }
                    break;
                    
                case 63:
                    if (event.modifierFlags & NSFunctionKeyMask) {
                        localIsDown = 1;
                    }
                    break;
                    
                case 57:
                    if (event.modifierFlags & NSAlphaShiftKeyMask) {
                        localIsDown = 1;
                    }
                    break;
            }
            [self triggerKB:(int)event.keyCode isDown:localIsDown];
            return event;
        }];
        if (type == 1) {
            kbGlobalDownHandle = [NSEvent addGlobalMonitorForEventsMatchingMask:NSKeyDownMask handler:^(NSEvent *event) {
                textKB.stringValue = @"";
                [self triggerKB:(int)event.keyCode isDown:true];
            }];
            kbGlobalUpHandle = [NSEvent addGlobalMonitorForEventsMatchingMask:NSKeyUpMask handler:^(NSEvent *event) {
                textKB.stringValue = @"";
                [self triggerKB:(int)event.keyCode isDown:false];
            }];
            kbGlobalFlagsHandle = [NSEvent addGlobalMonitorForEventsMatchingMask:NSFlagsChangedMask handler:^(NSEvent *event) {
                textKB.stringValue = @"";
                bool localIsDown = false;
                switch ((int)event.keyCode) {
                    case 55:
                    case 54:
                        if (event.modifierFlags & NSCommandKeyMask) {
                            localIsDown = 1;
                        }
                        break;
                        
                    case 62:
                    case 59:
                        if (event.modifierFlags & NSControlKeyMask) {
                            localIsDown = 1;
                        }
                        break;
                        
                    case 61:
                    case 58:
                        if (event.modifierFlags & NSAlternateKeyMask) {
                            localIsDown = 1;
                        }
                        break;
                        
                    case 60:
                    case 56:
                        if (event.modifierFlags & NSShiftKeyMask) {
                            localIsDown = 1;
                        }
                        break;
                        
                    case 63:
                        if (event.modifierFlags & NSFunctionKeyMask) {
                            localIsDown = 1;
                        }
                        break;
                        
                    case 57:
                        if (event.modifierFlags & NSAlphaShiftKeyMask) {
                            localIsDown = 1;
                        }
                        break;
                }
                [self triggerKB:(int)event.keyCode isDown:localIsDown];
            }];
        }
    }
    
}

/*-(void)appLog:(NSString*)content {
    logTextArea.string = [logTextArea.string stringByAppendingString:content];
    logTextArea.string = [logTextArea.string stringByAppendingString:@"\n"];
}*/

-(void)toggleAllMappingKBNameTextField {
    if (isKBControlling) {
        textPGMBlack.enabled = false;
        textPGMCh1.enabled = false;
        textPGMCh2.enabled = false;
        textPGMCh3.enabled = false;
        textPGMCh4.enabled = false;
        textPGMCh5.enabled = false;
        textPGMCh6.enabled = false;
        textPGMColorA.enabled = false;
        textPGMColorB.enabled = false;
        textPRVBlack.enabled = false;
        textPRVCh1.enabled = false;
        textPRVCh2.enabled = false;
        textPRVCh3.enabled = false;
        textPRVCh4.enabled = false;
        textPRVCh5.enabled = false;
        textPRVCh6.enabled = false;
        textPRVColorA.enabled = false;
        textPRVColorB.enabled = false;
        textTRANSHold.enabled = false;
        textTRANSAuto.enabled = false;
        textTRANSCut.enabled = false;
        textTRANSPreview.enabled = false;
        textTRANSDuration.enabled = false;
        textTRANSMix.enabled = false;
        textTRANSMixDuration.enabled = false;
        textTRANSDip.enabled = false;
        textTRANSDipDuration.enabled = false;
        textTRANSWipe.enabled = false;
        textTRANSWipeDuration.enabled = false;
        textTRANSDve.enabled = false;
        textTRANSDveDuration.enabled = false;
        textDSK1Preview.enabled = false;
        textDSK1On.enabled = false;
        textDSK1Auto.enabled = false;
        textDSK1Duration.enabled = false;
        textDSK2Preview.enabled = false;
        textDSK2On.enabled = false;
        textDSK2Auto.enabled = false;
        textDSK2Duration.enabled = false;
    } else {
        textPGMBlack.enabled = true;
        textPGMCh1.enabled = true;
        textPGMCh2.enabled = true;
        textPGMCh3.enabled = true;
        textPGMCh4.enabled = true;
        textPGMCh5.enabled = true;
        textPGMCh6.enabled = true;
        textPGMColorA.enabled = true;
        textPGMColorB.enabled = true;
        textPRVBlack.enabled = true;
        textPRVCh1.enabled = true;
        textPRVCh2.enabled = true;
        textPRVCh3.enabled = true;
        textPRVCh4.enabled = true;
        textPRVCh5.enabled = true;
        textPRVCh6.enabled = true;
        textPRVColorA.enabled = true;
        textPRVColorB.enabled = true;
        textTRANSHold.enabled = true;
        textTRANSAuto.enabled = true;
        textTRANSCut.enabled = true;
        textTRANSPreview.enabled = true;
        textTRANSDuration.enabled = true;
        textTRANSMix.enabled = true;
        textTRANSMixDuration.enabled = true;
        textTRANSDip.enabled = true;
        textTRANSDipDuration.enabled = true;
        textTRANSWipe.enabled = true;
        textTRANSWipeDuration.enabled = true;
        textTRANSDve.enabled = true;
        textTRANSDveDuration.enabled = true;
        textDSK1Preview.enabled = true;
        textDSK1On.enabled = true;
        textDSK1Auto.enabled = true;
        textDSK1Duration.enabled = true;
        textDSK2Preview.enabled = true;
        textDSK2On.enabled = true;
        textDSK2Auto.enabled = true;
        textDSK2Duration.enabled = true;
    }
}

-(void)toggleUIConnectionAllTextField {
    if ((isKBControlling) && (mixerCurrentStatus.Connected)) {
        if (textIP.enabled) {
            textIP.enabled = NO;
        }
    } else {
        textIP.enabled = YES;
    }
}



- (IBAction)clickedUIMappingButton:(NSButton*)sender {
    if (mixerCurrentStatus.Connected) {
        if ((![sender.alternateTitle  isEqual: @"TRANSHoldUp"]) && (![sender.alternateTitle  isEqual: @"TRANSHoldDown"])) {
            [self executeCmd:sender.alternateTitle];
        }
    }
}

- (IBAction)changeUIMappingTransitionSlider:(id)sender{
    
}

- (IBAction)clickedUIClearLogs:(NSButton*)sender {
    //[logTextArea setString:@""];
}

- (IBAction)clickedUIToggleAction:(NSButton*)sender {
    if (isKBControlling) {
        isKBControlling = !isKBControlling;
        [self performSelectorOnMainThread:@selector(toggleAllMappingKBNameTextField) withObject:nil waitUntilDone:YES];
        [self performSelectorOnMainThread:@selector(toggleUIConnectionAllTextField) withObject:nil waitUntilDone:YES];
        [self toggleKeyListening:0];
        sender.title = @"Push to Action!";
    } else {
        isKBControlling = !isKBControlling;
        [self performSelectorOnMainThread:@selector(toggleAllMappingKBNameTextField) withObject:nil waitUntilDone:YES];
        [self performSelectorOnMainThread:@selector(toggleUIConnectionAllTextField) withObject:nil waitUntilDone:YES];
        [self updateKBMappings];
        [self toggleKeyListening:0];
        [textKB becomeFirstResponder];
        sender.title = @"In-Action!";
    }
    
}

- (IBAction)clickedReverseSlider:(id)sernder {
    isReverseSlider = !isReverseSlider;
    [self performSelectorOnMainThread:@selector(updateUIbetweenMixer) withObject:nil waitUntilDone:YES];
}

- (IBAction)clickedChangeIP:(id)sender {
    mixerCurrentStatus.IP = textIP.stringValue;
    [self mixerDisconnected];
}

- (IBAction)clickedUpArraow:(NSButton*)sender {
    if (mixerCurrentStatus.Connected) {
        void (^selectedCase)() = @{
                                   @"DSK1": ^{
                                       if ((mixerCurrentStatus.DSK1RollingFrames == mixerCurrentStatus.DSK1Duration) && (mixerCurrentStatus.DSK1Duration > 0)){
                                           std::list<IBMDSwitcherDownstreamKey*>::iterator iter = mDSK.begin();
                                           std::advance(iter, 0); // t-1
                                           IBMDSwitcherDownstreamKey* key = *iter;
                                           key->SetRate(mixerCurrentStatus.DSK1Duration+1);
                                           key=NULL;
                                       }
                                   },
                                   @"DSK2": ^{
                                       if ((mixerCurrentStatus.DSK2RollingFrames == mixerCurrentStatus.DSK2Duration) && (mixerCurrentStatus.DSK2Duration > 0)){
                                           std::list<IBMDSwitcherDownstreamKey*>::iterator iter = mDSK.begin();
                                           std::advance(iter, 1); // t-1
                                           IBMDSwitcherDownstreamKey* key = *iter;
                                           key->SetRate(mixerCurrentStatus.DSK2Duration+1);
                                           key=NULL;
                                       }
                                   },
                                   @"TRANSMix": ^{
                                       uint32_t CRATE;
                                       mTransitionMixParameters->GetRate(&CRATE);
                                       mTransitionMixParameters->SetRate(CRATE+1);
                                   },
                                   @"TRANSDip": ^{
                                       uint32_t CRATE;
                                       mTransitionDipParameters->GetRate(&CRATE);
                                       mTransitionDipParameters->SetRate(CRATE+1);
                                   },
                                   @"TRANSWipe": ^{
                                       uint32_t CRATE;
                                       mTransitionWipeParameters->GetRate(&CRATE);
                                       mTransitionWipeParameters->SetRate(CRATE+1);
                                   },
                                   @"TRANSDve": ^{
                                       uint32_t CRATE;
                                       if (mTransitionDVEParameters) {
                                           mTransitionDVEParameters->GetRate(&CRATE);
                                           mTransitionDVEParameters->SetRate(CRATE+1);
                                       }
                                   },
                                   }[sender.alternateTitle];
        if (selectedCase !=nil) selectedCase();
        [self performSelector:@selector(updateMixerCurrentStatus) withObject:nil afterDelay:0.1];
    }
}

- (IBAction)clickedDownArraow:(NSButton*)sender {
    if (mixerCurrentStatus.Connected) {
        void (^selectedCase)() = @{
                                   @"DSK1": ^{
                                       if ((mixerCurrentStatus.DSK1RollingFrames == mixerCurrentStatus.DSK1Duration) && (mixerCurrentStatus.DSK1Duration > 0)) {
                                           std::list<IBMDSwitcherDownstreamKey*>::iterator iter = mDSK.begin();
                                           std::advance(iter, 0); // t-1
                                           IBMDSwitcherDownstreamKey* key = *iter;
                                           key->SetRate(mixerCurrentStatus.DSK1Duration-1);
                                           key=NULL;
                                       }
                                   },
                                   @"DSK2": ^{
                                       if ((mixerCurrentStatus.DSK2RollingFrames == mixerCurrentStatus.DSK2Duration) && (mixerCurrentStatus.DSK2Duration > 0)){
                                           std::list<IBMDSwitcherDownstreamKey*>::iterator iter = mDSK.begin();
                                           std::advance(iter, 1); // t-1
                                           IBMDSwitcherDownstreamKey* key = *iter;
                                           key->SetRate(mixerCurrentStatus.DSK2Duration-1);
                                           key=NULL;
                                       }
                                   },
                                   @"TRANSMix": ^{
                                       uint32_t CRATE;
                                       mTransitionMixParameters->GetRate(&CRATE);
                                       mTransitionMixParameters->SetRate(CRATE-1);
                                   },
                                   @"TRANSDip": ^{
                                       uint32_t CRATE;
                                       mTransitionDipParameters->GetRate(&CRATE);
                                       mTransitionDipParameters->SetRate(CRATE-1);
                                   },
                                   @"TRANSWipe": ^{
                                       uint32_t CRATE;
                                       mTransitionWipeParameters->GetRate(&CRATE);
                                       mTransitionWipeParameters->SetRate(CRATE-1);
                                   },
                                   @"TRANSDve": ^{
                                       uint32_t CRATE;
                                       mTransitionDVEParameters->GetRate(&CRATE);
                                       mTransitionDVEParameters->SetRate(CRATE-1);
                                   },
                                   }[sender.alternateTitle];
        if (selectedCase !=nil) selectedCase();
        [self performSelector:@selector(updateMixerCurrentStatus) withObject:nil afterDelay:0.1];
    }
}

-(IBAction)changedDuration:(NSTextField*)sender {
    if (mixerCurrentStatus.Connected) {
        int convertedDuration = [self nsStringDurationToInt:sender.stringValue];
        void (^selectedCase)() = @{
                                   @"DSK1": ^{
                                       if (convertedDuration > 0) {
                                           std::list<IBMDSwitcherDownstreamKey*>::iterator iter = mDSK.begin();
                                           std::advance(iter, 0); // t-1
                                           IBMDSwitcherDownstreamKey* key = *iter;
                                           key->SetRate(convertedDuration);
                                           key=NULL;
                                       }
                                   },
                                   @"DSK2": ^{
                                       if (convertedDuration > 0) {
                                           std::list<IBMDSwitcherDownstreamKey*>::iterator iter = mDSK.begin();
                                           std::advance(iter, 1); // t-1
                                           IBMDSwitcherDownstreamKey* key = *iter;
                                           key->SetRate(convertedDuration);
                                           key=NULL;
                                       }
                                   },
                                   @"TRANSMix": ^{
                                       mTransitionMixParameters->SetRate(convertedDuration);
                                   },
                                   @"TRANSDip": ^{
                                       mTransitionDipParameters->SetRate(convertedDuration);
                                   },
                                   @"TRANSWipe": ^{
                                       mTransitionWipeParameters->SetRate(convertedDuration);
                                   },
                                   @"TRANSDve": ^{
                                       if (mTransitionDVEParameters) { mTransitionDVEParameters->SetRate(convertedDuration); }
                                   },
                                   }[[[sender cell] placeholderString]];
        if (selectedCase !=nil) selectedCase();
    }
}

-(void)updateMixerCurrentStatus {
    if (mixerCurrentStatus.Connected) {
        /*
     x    bool Connected;
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
      -   int PGMCh; //0:Black,1-6:Ch,7-8:ColorA/B
      -   int PRVCh; //0:Black,1-6:Ch,7-8:ColorA/B
         float TRANSStage; //0:PGM, 1:PRV
      -   bool TRANSPreviewing;
         int TRANSRollingFrames; // <0:Not rolling
      -   __unsafe_unretained NSString* TRANSMode;
         bool DSK1Preview;
         bool DSK1On;
         int DSK1RollingFrames; // <0:Not rolling
         int DSK1Duration;
         bool DSK2Preview;
         bool DSK2On;
         int DSK2RollingFrames; // <0:Not rolling
         int DSK2Duration;
         */
        BMDSwitcherInputId PGM;
        BMDSwitcherInputId PRV;
        BMDSwitcherTransitionStyle NTRANS;
        BMDSwitcherTransitionStyle CTRANS;
        BMDSwitcherVideoMode VM;

        mMixEffectBlock->GetInt(bmdSwitcherMixEffectBlockPropertyIdProgramInput, &PGM);
        mMixEffectBlock->GetInt(bmdSwitcherMixEffectBlockPropertyIdPreviewInput, &PRV);
        mMixEffectBlock->GetFlag(bmdSwitcherMixEffectBlockPropertyIdPreviewTransition, &mixerCurrentStatus.TRANSPreviewing);
        mTransitionParameters->GetNextTransitionStyle(&NTRANS);
        mTransitionParameters->GetTransitionStyle(&CTRANS);
        mSwitcher->GetVideoMode(&VM);
        
        switch (VM) {
            case bmdSwitcherVideoMode1080i50:
            case bmdSwitcherVideoMode1080p25:
            case bmdSwitcherVideoMode4KHDp25:
            case bmdSwitcherVideoMode625i50Anamorphic:
            case bmdSwitcherVideoMode625i50PAL:
                mixerCurrentStatus.frameRate = 25;
                break;
            case bmdSwitcherVideoMode1080i5994:
            case bmdSwitcherVideoMode1080p2997:
            case bmdSwitcherVideoMode525i5994Anamorphic:
            case bmdSwitcherVideoMode525i5994NTSC:
            case bmdSwitcherVideoMode4KHDp2997:
                mixerCurrentStatus.frameRate = 30;
                break;
            case bmdSwitcherVideoMode1080p24:
            case bmdSwitcherVideoMode1080p2398:
            case bmdSwitcherVideoMode4KHDp2398:
            case bmdSwitcherVideoMode4KHDp24:
                mixerCurrentStatus.frameRate = 24;
                break;
            case bmdSwitcherVideoMode1080p50:
            case bmdSwitcherVideoMode720p50:
                mixerCurrentStatus.frameRate = 50;
                break;
            case bmdSwitcherVideoMode720p5994:
            case bmdSwitcherVideoMode1080p5994:
                mixerCurrentStatus.frameRate = 60;
                break;
                
            default:
                break;
        }
        
        if (PRV == mixerCurrentStatus.Black) {
            mixerCurrentStatus.PRVCh = 0;
        } else if (PRV == mixerCurrentStatus.Ch1) {
            mixerCurrentStatus.PRVCh = 1;
        } else if (PRV == mixerCurrentStatus.Ch2) {
            mixerCurrentStatus.PRVCh = 2;
        } else if (PRV == mixerCurrentStatus.Ch3) {
            mixerCurrentStatus.PRVCh = 3;
        } else if (PRV == mixerCurrentStatus.Ch4) {
            mixerCurrentStatus.PRVCh = 4;
        } else if (PRV == mixerCurrentStatus.Ch5) {
            mixerCurrentStatus.PRVCh = 5;
        } else if (PRV == mixerCurrentStatus.Ch6) {
            mixerCurrentStatus.PRVCh = 6;
        } else if (PRV == mixerCurrentStatus.ColorA) {
            mixerCurrentStatus.PRVCh = 7;
        } else if (PRV == mixerCurrentStatus.ColorB) {
            mixerCurrentStatus.PRVCh = 8;
        }
        
        if (PGM == mixerCurrentStatus.Black) {
            mixerCurrentStatus.PGMCh = 0;
        } else if (PGM == mixerCurrentStatus.Ch1) {
            mixerCurrentStatus.PGMCh = 1;
        } else if (PGM == mixerCurrentStatus.Ch2) {
            mixerCurrentStatus.PGMCh = 2;
        } else if (PGM == mixerCurrentStatus.Ch3) {
            mixerCurrentStatus.PGMCh = 3;
        } else if (PGM == mixerCurrentStatus.Ch4) {
            mixerCurrentStatus.PGMCh = 4;
        } else if (PGM == mixerCurrentStatus.Ch5) {
            mixerCurrentStatus.PGMCh = 5;
        } else if (PGM == mixerCurrentStatus.Ch6) {
            mixerCurrentStatus.PGMCh = 6;
        } else if (PGM == mixerCurrentStatus.ColorA) {
            mixerCurrentStatus.PGMCh = 7;
        } else if (PGM == mixerCurrentStatus.ColorB) {
            mixerCurrentStatus.PGMCh = 8;
        }
        
        
        mTransitionMixParameters->GetRate(&mixerCurrentStatus.TRANSMixDuration);
        mTransitionDipParameters->GetRate(&mixerCurrentStatus.TRANSDipDuration);
        mTransitionWipeParameters->GetRate(&mixerCurrentStatus.TRANSWipeDuration);
        if (mTransitionDVEParameters) { mTransitionDVEParameters->GetRate(&mixerCurrentStatus.TRANSDveDuration); }
        
        if (CTRANS == bmdSwitcherTransitionStyleMix) {
            mTransitionMixParameters->GetRate(&mixerCurrentStatus.TRANSDuration);
            mixerCurrentStatus.TRANSCurrentMode = @"mix";
        } else if (CTRANS == bmdSwitcherTransitionStyleWipe) {
            mTransitionWipeParameters->GetRate(&mixerCurrentStatus.TRANSDuration);
            mixerCurrentStatus.TRANSCurrentMode = @"wipe";
        } else if (CTRANS == bmdSwitcherTransitionStyleDip) {
            mTransitionDipParameters->GetRate(&mixerCurrentStatus.TRANSDuration);
            mixerCurrentStatus.TRANSCurrentMode = @"dip";
        } else if (CTRANS == bmdSwitcherTransitionStyleDVE) {
            mTransitionDVEParameters->GetRate(&mixerCurrentStatus.TRANSDuration);
            mixerCurrentStatus.TRANSCurrentMode = @"dve";
        }
        
        if (NTRANS == bmdSwitcherTransitionStyleMix) {
            mixerCurrentStatus.TRANSNextMode = @"mix";
        } else if (NTRANS == bmdSwitcherTransitionStyleWipe) {
            mixerCurrentStatus.TRANSNextMode = @"wipe";
        } else if (NTRANS == bmdSwitcherTransitionStyleDip) {
            mixerCurrentStatus.TRANSNextMode = @"dip";
        } else if (NTRANS == bmdSwitcherTransitionStyleDVE) {
            mixerCurrentStatus.TRANSNextMode = @"dve";
        }
        
        mMixEffectBlock->GetFloat(bmdSwitcherMixEffectBlockPropertyIdTransitionPosition, &mixerCurrentStatus.TRANSStage);
        mMixEffectBlock->GetInt(bmdSwitcherMixEffectBlockPropertyIdTransitionFramesRemaining, &mixerCurrentStatus.TRANSRollingFrames);
        mMixEffectBlock->GetFlag(bmdSwitcherMixEffectBlockPropertyIdPreviewTransition, &mixerCurrentStatus.TRANSPreviewing);
        
        
        
        //DSK
        IBMDSwitcherDownstreamKey * key;
        std::list<IBMDSwitcherDownstreamKey*>::iterator iter;
        
        //DSK1
        iter = mDSK.begin();
        std::advance(iter, 0); // t-1
        key = *iter;
        key->GetTie(&mixerCurrentStatus.DSK1Preview);
        key->GetOnAir(&mixerCurrentStatus.DSK1On);
        key->GetFramesRemaining(&mixerCurrentStatus.DSK1RollingFrames);
        key->GetRate(&mixerCurrentStatus.DSK1Duration);
        key = NULL;
        
        //DSK1
        iter = mDSK.begin();
        std::advance(iter, 1); // t-1
        key = *iter;
        key->GetTie(&mixerCurrentStatus.DSK2Preview);
        key->GetOnAir(&mixerCurrentStatus.DSK2On);
        key->GetFramesRemaining(&mixerCurrentStatus.DSK2RollingFrames);
        key->GetRate(&mixerCurrentStatus.DSK2Duration);
        key = NULL;
        
        
    } else {
        //Honestly, nothing need to do
        
    }
    [self performSelectorOnMainThread:@selector(updateUIbetweenMixer) withObject:nil waitUntilDone:YES];
}

-(int)nsStringDurationToInt:(NSString*)duration{
    int ret=0;
    if (duration) {
        NSArray *a = [duration componentsSeparatedByString:@":"];
        if (a.count == 1) {
            ret = [[a objectAtIndex:0] intValue] * mixerCurrentStatus.frameRate;
        } else if (a.count == 2) {
            ret = [[a objectAtIndex:0] intValue] * mixerCurrentStatus.frameRate + [[a objectAtIndex:1] intValue];
        }
    }
    return ret;
}

-(NSString*)intDurationToNSString:(int)duration {
    NSString* ret=@"";
    if ((duration >= 0) && (mixerCurrentStatus.frameRate != 0)){
        int s,f;
        s = duration / mixerCurrentStatus.frameRate;
        f = duration - (s*mixerCurrentStatus.frameRate);
        ret = [NSString stringWithFormat:@"%d:%02d",s,f];
    }
    return ret;
}

-(void)mixerDisconnected {
    
    
    for (std::list<InputMonitor*>::iterator it = mInputMonitors.begin(); it != mInputMonitors.end(); ++it)
    {
        (*it)->Release();
    }
    
    mInputMonitors.clear();
    
    if (mMixEffectBlock)
    {
        mMixEffectBlock->RemoveCallback(mMixEffectBlockMonitor);
        mMixEffectBlock->Release();
        mMixEffectBlock = NULL;
    }
    
    if (mSwitcher)
    {
        mSwitcher->RemoveCallback(mSwitcherMonitor);
        mSwitcher->Release();
        mSwitcher = NULL;
    }
    
    if (mTransitionParameters) {
        mTransitionParameters->RemoveCallback(mTransitionMonitor);
        mTransitionParameters->Release();
        mTransitionParameters = NULL;
    }
    
    if (mTransitionMixParameters) {
        mTransitionMixParameters->Release();
        mTransitionMixParameters = NULL;
    }
    
    if (mTransitionWipeParameters) {
        mTransitionWipeParameters->Release();
        mTransitionWipeParameters = NULL;
    }
    
    if (mTransitionDipParameters) {
        mTransitionDipParameters->Release();
        mTransitionDipParameters = NULL;
    }
    
    if (mTransitionDVEParameters) {
        mTransitionDVEParameters->Release();
        mTransitionDVEParameters = NULL;
    }
    
    mixerCurrentStatus.Connected = false;
    [self performSelectorOnMainThread:@selector(toggleUIConnectionAllTextField) withObject:nil waitUntilDone:YES];
    [self performSelectorOnMainThread:@selector(toggleAllMappingKBNameTextField) withObject:nil waitUntilDone:YES];
    [self performSelectorOnMainThread:@selector(updateMixerCurrentStatus) withObject:nil waitUntilDone:YES];
    [self connectMixer];
}


-(void)connectMixer {
    BMDSwitcherConnectToFailure			failReason;
    HRESULT hr = mSwitcherDiscovery->ConnectTo((__bridge CFStringRef)mixerCurrentStatus.IP, &mSwitcher, &failReason);
    
    //Merged -(void)mixerConnected
    
    if (SUCCEEDED(hr))
    {
        HRESULT result;
        IBMDSwitcherMixEffectBlockIterator* iterator = NULL;
        IBMDSwitcherInputIterator* inputIterator = NULL;
        CFStringRef productName;
        if (FAILED(mSwitcher->GetProductName(&productName)))
        {
            return;
        }
        
        mixerCurrentStatus.Name = (__bridge NSString *) productName;
        
        mSwitcher->AddCallback(mSwitcherMonitor);
        
        
        // Create an InputMonitor for each input so we can catch any changes to input names
        result = mSwitcher->CreateIterator(IID_IBMDSwitcherInputIterator, (void**)&inputIterator);
        if (SUCCEEDED(result))
        {
            IBMDSwitcherInput* input = NULL;
            
            // For every input, install a callback to monitor property changes on the input
            while (S_OK == inputIterator->Next(&input))
            {
                InputMonitor* inputMonitor = new InputMonitor(input, self);
                input->Release();
                mInputMonitors.push_back(inputMonitor);
            }
            inputIterator->Release();
            inputIterator = NULL;
        }
        
        // Get the mix effect block iterator
        result = mSwitcher->CreateIterator(IID_IBMDSwitcherMixEffectBlockIterator, (void**)&iterator);
        if (FAILED(result))
        {
            NSLog(@"Could not create IBMDSwitcherMixEffectBlockIterator iterator");
            goto finish;
        }
        
        // Use the first Mix Effect Block
        if (S_OK != iterator->Next(&mMixEffectBlock))
        {
            NSLog(@"Could not get the first IBMDSwitcherMixEffectBlock");
            goto finish;
        }
        
        mMixEffectBlock->AddCallback(mMixEffectBlockMonitor);
        
        
        //Transition
        mTransitionParameters = NULL;
        mTransitionMixParameters = NULL;
        mTransitionWipeParameters = NULL;
        mTransitionDipParameters = NULL;
        mTransitionDVEParameters = NULL;
        
        mMixEffectBlock->QueryInterface(IID_IBMDSwitcherTransitionParameters, (void**)&mTransitionParameters);
        mMixEffectBlock->QueryInterface(IID_IBMDSwitcherTransitionMixParameters, (void**)&mTransitionMixParameters);
        mMixEffectBlock->QueryInterface(IID_IBMDSwitcherTransitionWipeParameters, (void**)&mTransitionWipeParameters);
        mMixEffectBlock->QueryInterface(IID_IBMDSwitcherTransitionDipParameters, (void**)&mTransitionDipParameters);
        mMixEffectBlock->QueryInterface(IID_IBMDSwitcherTransitionDVEParameters, (void**)&mTransitionDVEParameters);
        mTransitionParameters->AddCallback(mTransitionMonitor);

        //DSK
        mDSK.clear();//Not sure if ne
        IBMDSwitcherDownstreamKeyIterator* tmpDskIterator;
        mSwitcher->CreateIterator(IID_IBMDSwitcherDownstreamKeyIterator, (void**)&tmpDskIterator);
        IBMDSwitcherDownstreamKey* tmpDSK;
        
        while (S_OK == tmpDskIterator->Next(&tmpDSK)) {
            tmpDSK->AddCallback(mDSKMonitor);
            mDSK.push_back(tmpDSK);
            
        }
        
        mixerCurrentStatus.Connected = true;
        [self performSelectorOnMainThread:@selector(updateUIbetweenMixer) withObject:nil waitUntilDone:YES];
        [self performSelectorOnMainThread:@selector(updateMixerCurrentStatus) withObject:nil waitUntilDone:YES];
        
        finish: if (iterator) iterator->Release();
        
    } else {
        NSString* reason;
        switch (failReason)
        {
            case bmdSwitcherConnectToFailureNoResponse:
                reason = @"No response from Mixer";
                break;
            case bmdSwitcherConnectToFailureIncompatibleFirmware:
                reason = @"Mixer has incompatible firmware";
                break;
            default:
                reason = @"Connection failed for unknown reason";
        }
        double delayInSeconds = 2.0;
        
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0),
                       ^(void){
                           [self performSelectorInBackground:@selector(mixerDisconnected) withObject:nil];
                       });
    }
}

-(void)updateUIbetweenMixer {
    [self performSelectorOnMainThread:@selector(toggleUIConnectionAllTextField) withObject:nil waitUntilDone:YES];
    [self performSelectorOnMainThread:@selector(toggleAllMappingKBNameTextField) withObject:nil waitUntilDone:YES];
    [self toggleKeyListening:0];
    textName.stringValue = mixerCurrentStatus.Name;
    if (mixerCurrentStatus.Connected) {
        textStatusColor.backgroundColor = [NSColor clearColor];
        textStatusColor.backgroundColor = onlineColor;
        
        buttonPGMBlack.image = normalImage;
        buttonPGMCh1.image = normalImage;
        buttonPGMCh2.image = normalImage;
        buttonPGMCh3.image = normalImage;
        buttonPGMCh4.image = normalImage;
        buttonPGMCh5.image = normalImage;
        buttonPGMCh6.image = normalImage;
        buttonPGMColorA.image = normalImage;
        buttonPGMColorB.image = normalImage;
        buttonTRANSAuto.image = normalImage;
        buttonTRANSCut.image = normalImage;
        buttonTRANSPreview.image = normalImage;
        buttonTRANSMix.image = normalImage;
        buttonTRANSWipe.image = normalImage;
        buttonTRANSDip.image = normalImage;
        buttonTRANSDve.image = normalImage;
        buttonPRVBlack.image = normalImage;
        buttonPRVCh1.image = normalImage;
        buttonPRVCh2.image = normalImage;
        buttonPRVCh3.image = normalImage;
        buttonPRVCh4.image = normalImage;
        buttonPRVCh5.image = normalImage;
        buttonPRVCh6.image = normalImage;
        buttonPRVColorA.image = normalImage;
        buttonPRVColorB.image = normalImage;
        buttonTRANSHold.image = normalImage;
        buttonDSK1Preview.image = normalImage;
        buttonDSK1Auto.image = normalImage;
        buttonDSK1On.image = normalImage;
        buttonDSK2Preview.image = normalImage;
        buttonDSK2Auto.image = normalImage;
        buttonDSK2On.image = normalImage;
        
        
        //PGM Block
        switch (mixerCurrentStatus.PGMCh) {
            case 0:
                buttonPGMBlack.image = redImage;
                break;
            case 1:
                buttonPGMCh1.image = redImage;
                break;
            case 2:
                buttonPGMCh2.image = redImage;
                break;
            case 3:
                buttonPGMCh3.image = redImage;
                break;
            case 4:
                buttonPGMCh4.image = redImage;
                break;
            case 5:
                buttonPGMCh5.image = redImage;
                break;
            case 6:
                buttonPGMCh6.image = redImage;
                break;
            case 7:
                buttonPGMColorA.image = redImage;
                break;
            case 8:
                buttonPGMColorB.image = redImage;
                break;
            default:
                NSLog(@"");
        }
        
        
        //PRV Block
        NSImage* PRVImage = greenImage;
        if (mixerCurrentStatus.TRANSStage != 0) { PRVImage = redImage; }
        switch (mixerCurrentStatus.PRVCh) {
            case 0:
                buttonPRVBlack.image = PRVImage;
                break;
            case 1:
                buttonPRVCh1.image = PRVImage;
                break;
            case 2:
                buttonPRVCh2.image = PRVImage;
                break;
            case 3:
                buttonPRVCh3.image = PRVImage;
                break;
            case 4:
                buttonPRVCh4.image = PRVImage;
                break;
            case 5:
                buttonPRVCh5.image = PRVImage;
                break;
            case 6:
                buttonPRVCh6.image = PRVImage;
                break;
            case 7:
                buttonPRVColorA.image = PRVImage;
                break;
            case 8:
                buttonPRVColorB.image = PRVImage;
                break;
            default:
                NSLog(@"");
        }
        
        //TRANSHold
        if (isMouseControlling) {
            buttonTRANSHold.image = blueImage;
        }
        
        //TRANS Mode
        if (mixerCurrentStatus.TRANSNextMode == mixerCurrentStatus.TRANSCurrentMode) {
            void (^selectedCase)() = @{
                                       @"mix": ^{
                                       buttonTRANSMix.image = yellowImage;
                                       },
                                       @"wipe": ^{
                                           buttonTRANSWipe.image = yellowImage;
                                       },
                                       @"dip": ^{
                                           buttonTRANSDip.image = yellowImage;
                                       },
                                       @"dve": ^{
                                           buttonTRANSDve.image = yellowImage;
                                       },
                                       }[mixerCurrentStatus.TRANSNextMode];
            if (selectedCase !=nil) selectedCase();
        } else {
            void (^selectedCase)() = @{
                                       @"mix": ^{
                                           buttonTRANSMix.image = yellowImage;
                                       },
                                       @"wipe": ^{
                                           buttonTRANSWipe.image = yellowImage;
                                       },
                                       @"dip": ^{
                                           buttonTRANSDip.image = yellowImage;
                                       },
                                       @"dve": ^{
                                           buttonTRANSDve.image = yellowImage;
                                       },
                                       }[mixerCurrentStatus.TRANSNextMode];
            if (selectedCase !=nil) selectedCase();
            
            
            void (^selectedCase2)() = @{
                                       @"mix": ^{
                                           buttonTRANSMix.image = blueImage;
                                       },
                                       @"wipe": ^{
                                           buttonTRANSWipe.image = blueImage;
                                       },
                                       @"dip": ^{
                                           buttonTRANSDip.image = blueImage;
                                       },
                                       @"dve": ^{
                                           buttonTRANSDve.image = blueImage;
                                       },
                                       }[mixerCurrentStatus.TRANSCurrentMode];
            if (selectedCase !=nil) selectedCase2();
        }
        
        //TRANSSlider
        if ((mixerCurrentStatus.TRANSStage == 1) && (sliderTRANS.doubleValue != 0) && (sliderTRANS.doubleValue != 1)) {
            isReverseSlider = !isReverseSlider;
        }
        
        if (isReverseSlider) {
            sliderTRANS.doubleValue = 1 - mixerCurrentStatus.TRANSStage;
            
        } else {
            sliderTRANS.doubleValue = mixerCurrentStatus.TRANSStage;
        }
        
        //TRANSPreview
        if (mixerCurrentStatus.TRANSPreviewing) {
            buttonTRANSPreview.image = redImage;
        } else {
            buttonTRANSPreview.image = normalImage;
        }
        
        //TRANSAuto
        if (mixerCurrentStatus.TRANSStage != 0) {
            buttonTRANSAuto.image = redImage;
        } else {
            buttonTRANSAuto.image = normalImage;
        }
        
        //TRANSDuration
        textTRANSDuration.stringValue = [self intDurationToNSString:mixerCurrentStatus.TRANSRollingFrames];
        textTRANSMixDuration.stringValue = [self intDurationToNSString:mixerCurrentStatus.TRANSMixDuration];
        textTRANSDipDuration.stringValue = [self intDurationToNSString:mixerCurrentStatus.TRANSDipDuration];
        textTRANSWipeDuration.stringValue = [self intDurationToNSString:mixerCurrentStatus.TRANSWipeDuration];
        textTRANSDveDuration.stringValue = [self intDurationToNSString:mixerCurrentStatus.TRANSDveDuration];
        
        //DSK1
        if (mixerCurrentStatus.DSK1On) {
            buttonDSK1On.image = redImage;
        }
        if (mixerCurrentStatus.DSK1Preview) {
            buttonDSK1Preview.image = yellowImage;
        }
        if (mixerCurrentStatus.DSK1Duration != mixerCurrentStatus.DSK1RollingFrames) {
            buttonDSK1Auto.image = redImage;
            textDSK1Duration.stringValue = [self intDurationToNSString:mixerCurrentStatus.DSK1RollingFrames];
        } else {
            textDSK1Duration.stringValue = [self intDurationToNSString:mixerCurrentStatus.DSK1Duration];
        }
        
        //DSK2
        if (mixerCurrentStatus.DSK2On) {
            buttonDSK2On.image = redImage;
        }
        if (mixerCurrentStatus.DSK2Preview) {
            buttonDSK2Preview.image = yellowImage;
        }
        if (mixerCurrentStatus.DSK2Duration != mixerCurrentStatus.DSK2RollingFrames) {
            buttonDSK2Auto.image = redImage;
            textDSK2Duration.stringValue = [self intDurationToNSString:mixerCurrentStatus.DSK2RollingFrames];
        } else {
            textDSK2Duration.stringValue = [self intDurationToNSString:mixerCurrentStatus.DSK2Duration];
        }
        
    } else {
        textStatusColor.backgroundColor = [NSColor clearColor];
        textStatusColor.backgroundColor = offlineColor;
        
        buttonPGMBlack.image = blackImage;
        buttonPGMCh1.image = blackImage;
        buttonPGMCh2.image = blackImage;
        buttonPGMCh3.image = blackImage;
        buttonPGMCh4.image = blackImage;
        buttonPGMCh5.image = blackImage;
        buttonPGMCh6.image = blackImage;
        buttonPGMColorA.image = blackImage;
        buttonPGMColorB.image = blackImage;
        buttonTRANSAuto.image = blackImage;
        buttonTRANSCut.image = blackImage;
        buttonTRANSPreview.image = blackImage;
        buttonTRANSMix.image = blackImage;
        buttonTRANSWipe.image = blackImage;
        buttonTRANSDip.image = blackImage;
        buttonTRANSDve.image = blackImage;
        buttonPRVBlack.image = blackImage;
        buttonPRVCh1.image = blackImage;
        buttonPRVCh2.image = blackImage;
        buttonPRVCh3.image = blackImage;
        buttonPRVCh4.image = blackImage;
        buttonPRVCh5.image = blackImage;
        buttonPRVCh6.image = blackImage;
        buttonPRVColorA.image = blackImage;
        buttonPRVColorB.image = blackImage;
        buttonTRANSHold.image = blackImage;
        buttonDSK1Preview.image = blackImage;
        buttonDSK1Auto.image = blackImage;
        buttonDSK1On.image = blackImage;
        buttonDSK2Preview.image = blackImage;
        buttonDSK2Auto.image = blackImage;
        buttonDSK2On.image = blackImage;
    }
  
    
    
}

-(void)windowLostFocus {
    [self executeCmd:@"TRANSHoldUp"];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    [self setupUI];
    [self setupValues];
    
    [self mixerDisconnected];
    //
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowLostFocus) name:NSWindowDidResignMainNotification object:window];

    [window becomeFirstResponder];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

@end
