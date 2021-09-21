//	Copyright (c) 2009 Stephen Deken
//	All rights reserved.
// 
//	Redistribution and use in source and binary forms, with or without modification,
//	are permitted provided that the following conditions are met:
//
//	*	Redistributions of source code must retain the above copyright notice, this
//		list of conditions and the following disclaimer.
//	*	Redistributions in binary form must reproduce the above copyright notice,
//		this list of conditions and the following disclaimer in the documentation
//		and/or other materials provided with the distribution.
//	*	Neither the name KeyCastr nor the names of its contributors may be used to
//		endorse or promote products derived from this software without specific
//		prior written permission.
//
//	THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
//	AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
//	WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
//	IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
//	INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
//	BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
//	DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
//	LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
//	OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
//	ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


#import "KCController.h"
#import "KCKeyboardTap.h"
#import <Quartz/Quartz.h>

typedef struct _KeyCombo {
    unsigned int flags; // 0 for no flags
    signed short code; // -1 for no code
} KeyCombo;

static NSString* kKCSupplementalAlertText = @"\n\nPlease grant KeyCastr access to the Accessibility API in order to broadcast your keyboard inputs.\n\nWithin the System Preferences application, open the Security & Privacy preferences and add KeyCastr to the Accessibility list within the Privacy tab. If KeyCastr is already listed under the Accessibility menu, please remove it and try again.\n";

@interface KCController ()<KCKeyboardTapDelegate>

@property (nonatomic, assign) KeyCombo toggleKeyCombo;

@end

@implementation KCController {
    /* __weak -- we enforce this, not the compiler, because we are in manual reference counting mode and not ARC. So in manual reference counting mode, putting `__weak` or `__strong` is a compiler error. */ id <KCControllerDelegate> delegate;
	BOOL _isCapturing;
	KCKeyboardTap *keyboardTap;
}

#pragma mark -
#pragma mark Startup Procedures

-(id) init
{
	if (!(self = [super init]))
		return nil;

    keyboardTap = [KCKeyboardTap new];
    keyboardTap.delegate = self;
    
    [self awake];

    return self;
}

- (void)dealloc {
    [keyboardTap release]; // (Will call [keyboardTap removeTap] if this object's ref count is 0 because KCKeyboardTap's dealloc method does this)
    [super dealloc];
}

- (void)awake {
    [self setIsCapturing:NO];
}

- (void)startCapturing {
    [self setIsCapturing:YES];
}

- (void)endCapturing {
    [self setIsCapturing:NO];
    [keyboardTap removeTap];
}

- (void)displayPermissionsAlertWithError:(NSError *)error {
    NSAlert *alert = [[NSAlert new] autorelease];
    [alert addButtonWithTitle:@"Close"];
    [alert addButtonWithTitle:@"Open System Preferences"];
    alert.messageText = @"Additional Permissions Required";
    alert.informativeText = [error.localizedDescription stringByAppendingString:kKCSupplementalAlertText];
    alert.alertStyle = NSCriticalAlertStyle;

    switch ([alert runModal]) {
        case NSAlertFirstButtonReturn:
            [NSApp terminate:nil];
            break;
        case NSAlertSecondButtonReturn: {
            [self openPrefsPane:nil];
            [NSApp terminate:nil];
        }
            break;
    }
}

- (BOOL)installTap {
    NSError *error = nil;
    if (![keyboardTap installTapWithError:&error]) {
        // Only display a custom error message if we're running on macOS < 10.15
        NSOperatingSystemVersion minVersion = { .majorVersion = 10, .minorVersion = 15, .patchVersion = 0 };
        BOOL supportsNewPermissionsAlert = [NSProcessInfo.processInfo isOperatingSystemAtLeastVersion:minVersion];

        if (!supportsNewPermissionsAlert) {
            [self displayPermissionsAlertWithError:error];
        }
        return NO;
    }
    return YES;
}

-(void) keyboardTap:(KCKeyboardTap*)tap noteKeystroke:(KCKeystroke*)keystroke
{
	if ([keystroke keyCode] == self.toggleKeyCombo.code && ([keystroke modifiers] & (NSControlKeyMask | NSCommandKeyMask | NSShiftKeyMask | NSAlternateKeyMask)) == (self.toggleKeyCombo.flags & (NSControlKeyMask | NSCommandKeyMask | NSShiftKeyMask | NSAlternateKeyMask)))
	{
        [self toggleRecording:self];
		return;
	}
	
	if (!_isCapturing)
		return;

	if (delegate != nil)
		[delegate noteKeyEvent:keystroke];
}

-(void) keyboardTap:(KCKeyboardTap*)tap noteFlagsChanged:(uint32_t)flags
{
	if (delegate != nil)
		[delegate noteFlagsChanged:flags];
}

-(void) toggleRecording:(id)sender
{
	[self setIsCapturing:![self isCapturing]];
}

-(void) stopPretending:(id)what
{
	[self toggleRecording:self];
}

-(void) pretendToDoSomethingImportant:(id)sender
{
	[self performSelector:@selector(stopPretending:) withObject:nil afterDelay:0.1];
}

-(id<KCControllerDelegate>) delegate
{
    return delegate;
}

- (void)setDelegate:(id <KCControllerDelegate>)newDelegate {
    delegate = newDelegate; // This file is in manual reference counting (non-ARC) mode. So we have to think about retaining, etc. or not. This `newDelegate` is *not* [retain]'ed because we don't claim ownership of it since it should be owning the KCController, so doing so would create a cyclic reference. Once you [retain] an object, you must do a corresponding [release] at some point (or [autorelease], which adds the object to the current autorelease pool and makes [release] get called later when the current autorelease pool is drained). ( https://www.tomdalling.com/blog/cocoa/an-in-depth-look-at-manual-memory-management-in-objective-c/ )
}

-(BOOL) isCapturing
{
	return _isCapturing;
}

-(void) setIsCapturing:(BOOL)capture
{
    // Install tap if needed
    if (capture && !keyboardTap.tapInstalled) {
        [self installTap];
    }

	_isCapturing = capture;
}

@end
