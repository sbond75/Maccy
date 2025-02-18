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



#import <Cocoa/Cocoa.h>
#import "KCKeyboardTap.h"
#import "KCKeystroke.h"

@protocol KCControllerDelegate <NSObject>

-(void) noteKeyEvent:(KCKeystroke*)keystroke;
-(void) noteFlagsChanged:(uint32_t)flags;

@end

// Based on KCAppController from keycastr/keycastr/KCAppController.m which is from https://github.com/keycastr/keycastr
@interface KCController : NSObject

// Starts capturing.
- (void)startCapturing;
// Stops capturing completely (as opposed to merely pausing it). [startCapturing] will start it back up again.
- (void)endCapturing;

-(BOOL) isCapturing;
// Starts or pauses capturing.
-(void) setIsCapturing:(BOOL)capture;

-(id<KCControllerDelegate>) delegate;
-(void) setDelegate:(id<KCControllerDelegate>)newDelegate;

-(void) keyboardTap:(KCKeyboardTap*)tap noteKeystroke:(KCKeystroke*)keystroke;
-(void) keyboardTap:(KCKeyboardTap*)tap noteFlagsChanged:(uint32_t)flags;

@end
