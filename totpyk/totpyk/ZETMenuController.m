//
//  ZETMenuController.m
//  totpyk
//
//  Created by Stephen Lombardo on 12/31/11.
//  Copyright (c) 2011 Zetetic LLC. All rights reserved.
//

#import <Carbon/Carbon.h>
#include <ApplicationServices/ApplicationServices.h>
#import "ZETYkTOTP.h"
#import "ZETMenuController.h"
#import "ZETAppDelegate.h"


@implementation ZETMenuController
@synthesize statusMenu, statusItem, prefsController;

- (id)init
{
    self = [super init];
    if (self) {
        statusItem = [[[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength] retain];
        statusItem.highlightMode = YES;
        //statusItem.title = @"TOTPYk";
        statusItem.enabled = YES;
        statusItem.image = [NSImage imageNamed:@"Menu"];
        statusItem.alternateImage = [NSImage imageNamed:@"MenuHighlighted"];
        if([NSBundle loadNibNamed:@"ZETMenuController" owner:self]) {
            statusItem.menu = self.statusMenu;
        }
    }
    
    return self;
}

- (IBAction)insert:(id)sender {
    ZETYkTOTP *totp = [[[ZETYkTOTP alloc] init] autorelease];
    ZETPrefs *prefs = [[[ZETPrefs alloc] init] autorelease];
    
    totp.step = prefs.timeStep;
    totp.digits = prefs.digits;
    totp.key.slot = prefs.keySlot;
    
    NSString *otp = [totp totpChallenge];
    if(otp != nil && !totp.key.error) {
        
        CGEventSourceRef eventSource = CGEventSourceCreate(kCGEventSourceStateHIDSystemState); 
        CGEventRef event = CGEventCreateKeyboardEvent(eventSource, 0, true); 

        for(int i = 0; i < otp.length; i++) {
            unichar c = [otp characterAtIndex:i];
            event = CGEventCreateKeyboardEvent(eventSource, 1, true);
            CGEventKeyboardSetUnicodeString(event, 1, &c);
            CGEventPost(kCGHIDEventTap, event);
            CFRelease(event);
        }

        if(prefs.typeReturnKey) {
            CGEventCreateKeyboardEvent(NULL, 76, true); // 76 is RETURN key (extracted from SRKeyCodeTransformer)
            CGEventPost(kCGHIDEventTap, event);
            CFRelease(event);
        }
        
        CFRelease(eventSource);
    } else {
        NSAlert *alert= [NSAlert alertWithMessageText:@"Error"
                               defaultButton:@"OK"
                             alternateButton:nil
                                 otherButton:nil
                   informativeTextWithFormat:[NSString stringWithFormat:@"Unable to challenge Yubikey: %@", totp.key.errorMessage]];
        
        NSApplication *thisApp = [NSApplication sharedApplication];
        [thisApp activateIgnoringOtherApps:YES];
        [alert runModal];
    }
    
}

- (void) insertHotKey:(id)sender {
    usleep(500000); // sleep to allow hotkey press to release
    [self insert:sender];
}

- (IBAction)showPrefWindow:(id)sender {
    [prefsController release];
	prefsController = [[ZETPrefsController alloc] init];
    
    NSApplication *thisApp = [NSApplication sharedApplication];
    [thisApp activateIgnoringOtherApps:YES];
    [prefsController.window makeKeyAndOrderFront:nil];
}

- (void)dealloc
{
    [[NSStatusBar systemStatusBar] removeStatusItem:statusItem];
    [statusItem release];
    [statusMenu release];
    [prefsController release];
    [super dealloc];
}

@end
