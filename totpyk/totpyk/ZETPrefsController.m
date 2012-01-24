//
//  ZETPrefsController.m
//  totpyk
//
//  Created by Stephen Lombardo on 1/14/12.
//  Copyright (c) 2012 Zetetic LLC. All rights reserved.
//

#import "ZETPrefsController.h"
#import "ZETAppDelegate.h"

@implementation ZETPrefsController

@synthesize recorderControl, stepTextField, digitsTextField, digitsStepper, keySlotPopUp;

- (void)dealloc
{
    [recorderControl release];
    [stepTextField release];
    [digitsTextField release];
    [digitsStepper release];
    [keySlotPopUp release];
    [super dealloc];
}

- (id)init
{
    self = [super initWithWindowNibName:@"ZETPrefsController"];
    return self;
}

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) { }
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    [self loadUserDefaults];
}

- (void) windowWillClose:(NSNotification *)notification
{
    [self saveUserDefaults];
}

- (BOOL)shortcutRecorder:(SRRecorderControl *)aRecorder 
               isKeyCode:(signed short)keyCode 
           andFlagsTaken:(unsigned int)flags 
                  reason:(NSString **)aReason {
    
    NSLog(@"shortcutRecorder isKeyCode");
    return NO;
}

- (void)shortcutRecorder:(SRRecorderControl *)aRecorder keyComboDidChange:(KeyCombo)newKeyCombo 
{
    NSLog(@"shortcutRecorder keyComboDidChange");
    ZETAppDelegate *delegate = (ZETAppDelegate *)[NSApp delegate];
    NSUInteger flags = [aRecorder cocoaToCarbonFlags:newKeyCombo.flags];
    [delegate registerHotKey:newKeyCombo.code modifiers:flags];
}

- (IBAction)preferenceChanged:(id)sender
{
    [self saveUserDefaults];
}

- (IBAction)digitsChanged:(id)sender
{
    int value = [sender intValue];
    [digitsTextField setIntValue:value];
    [digitsStepper setIntValue:value];
    [self preferenceChanged:sender];
}

- (void) loadUserDefaults
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [stepTextField setIntValue:(int)[defaults integerForKey:kTimeStep]];
    [digitsTextField setIntValue:(int)[defaults integerForKey:kDigits]];
    [digitsStepper setIntValue:(int)[defaults integerForKey:kDigits]];
    [keySlotPopUp selectItemAtIndex:(int)([defaults integerForKey:kKeySlot] - 1)];
}

- (void) saveUserDefaults
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    int value = [digitsTextField intValue];
    if(value > 0 && value < 9) {
        [defaults setInteger:value forKey:kDigits];
    }
    
    value = [stepTextField intValue];
    if(value > 0 && value < 3600) {
        [defaults setInteger:value forKey:kTimeStep];
    }
    
    [defaults setInteger:[keySlotPopUp indexOfSelectedItem]+1 forKey:kKeySlot];
    [self loadUserDefaults]; // load back settings we just saved, in case there were any preference changes that were ignored
}

@end