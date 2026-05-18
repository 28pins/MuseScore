//
//  touchbarbridge.mm
//  MuseScore
//
//  Created by Sam Clark on 5/18/26.
//

#import "TouchBarBridge.h"
#import "appshell-bridging-header.h"
#import "MuseScore-Swift.h"

@interface TouchBarBridgeObjC : NSObject <TouchBarDelegate>
@property (nonatomic, strong) TouchBarController *controller;
@property (atomic) tb_callback_t callback;
@property (atomic) void *callbackUserData;
@end

@implementation TouchBarBridgeObjC
- (instancetype)init {
	if ((self = [super init])) {
		self.controller = [[TouchBarController alloc] initWithDelegate:self];
		self.callback = NULL;
		self.callbackUserData = NULL;
	}
	return self;
}
- (void)touchBarButtonPressed:(NSString *)actionCode {
	tb_callback_t cb = self.callback;
	void *ud = self.callbackUserData;
	if (cb) {
		// call on main thread (AppKit context)
		dispatch_async(dispatch_get_main_queue(), ^{
			cb(actionCode.UTF8String, ud);
		});
	}
}
@end

static TouchBarBridgeObjC *gBridge = nil;

void tb_bridge_create(void) {
	dispatch_sync(dispatch_get_main_queue(), ^{
		if (!gBridge) gBridge = [[TouchBarBridgeObjC alloc] init];
	});
}

void tb_bridge_set_callback(tb_callback_t cb, void* userData) {
	if (!gBridge) tb_bridge_create();
	gBridge.callback = cb;
	gBridge.callbackUserData = userData;
}

void tb_bridge_add_button(const char* actionCode, const char* title, const void* pngBytes, size_t len) {
	if (!gBridge) tb_bridge_create();
	NSData *data = nil;
	if (pngBytes && len > 0) data = [NSData dataWithBytes:pngBytes length:len];
	NSString *act = actionCode ? [NSString stringWithUTF8String:actionCode] : @"";
	NSString *t = title ? [NSString stringWithUTF8String:title] : @"";
	dispatch_async(dispatch_get_main_queue(), ^{
		[gBridge.controller addButtonWithActionCode:act title:t imageData:data];
	});
}

void tb_bridge_remove_button(const char* actionCode) {
	if (!gBridge) tb_bridge_create();
	NSString *act = actionCode ? [NSString stringWithUTF8String:actionCode] : @"";
	dispatch_async(dispatch_get_main_queue(), ^{
		[gBridge.controller removeButtonWithActionCode:act];
	});
}

void tb_bridge_set_enabled(const char* actionCode, bool enabled) {
	if (!gBridge) tb_bridge_create();
	NSString *act = actionCode ? [NSString stringWithUTF8String:actionCode] : @"";
	dispatch_async(dispatch_get_main_queue(), ^{
		[gBridge.controller setEnabledWithActionCode:act enabled:enabled];
	});
}

void tb_bridge_show_for_window(void* nsWindowPtr) {
	if (!gBridge) tb_bridge_create();
	NSWindow *w = (__bridge NSWindow *)nsWindowPtr;
	dispatch_async(dispatch_get_main_queue(), ^{
		[gBridge.controller showForWindow:w];
	});
}
