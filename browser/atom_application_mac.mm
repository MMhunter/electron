// Copyright (c) 2013 GitHub, Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "browser/atom_application_mac.h"

#include "base/auto_reset.h"
#include "base/strings/sys_string_conversions.h"
#include "browser/browser.h"

@implementation AtomApplication

+ (AtomApplication*)sharedApplication {
  return (AtomApplication*)[super sharedApplication];
}

- (BOOL)isHandlingSendEvent {
  return handlingSendEvent_;
}

- (void)sendEvent:(NSEvent*)event {
  base::AutoReset<BOOL> scoper(&handlingSendEvent_, YES);
  [super sendEvent:event];
}

- (void)setHandlingSendEvent:(BOOL)handlingSendEvent {
  handlingSendEvent_ = handlingSendEvent;
}

- (void)awakeFromNib {
  [[NSAppleEventManager sharedAppleEventManager]
      setEventHandler:self
          andSelector:@selector(handleURLEvent:withReplyEvent:)
        forEventClass:kInternetEventClass
           andEventID:kAEGetURL];
}

- (IBAction)closeAllWindows:(id)sender {
  atom::Browser::Get()->Quit();
}

- (void)handleURLEvent:(NSAppleEventDescriptor*)event
        withReplyEvent:(NSAppleEventDescriptor*)replyEvent {
  NSString* url = [
      [event paramDescriptorForKeyword:keyDirectObject] stringValue];
  atom::Browser::Get()->OpenURL(base::SysNSStringToUTF8(url));
}

@end
