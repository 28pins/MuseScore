// TouchBarBridge.h
#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

#ifdef __cplusplus
extern "C" {
#endif

typedef void (*tb_callback_t)(const char* actionCode, void* userData);

void tb_bridge_create(void);
void tb_bridge_set_callback(tb_callback_t cb, void* userData);
void tb_bridge_add_button(const char* actionCode, const char* title, const void* pngBytes, size_t len);
void tb_bridge_remove_button(const char* actionCode);
void tb_bridge_set_enabled(const char* actionCode, bool enabled);
void tb_bridge_show_for_window(void* nsWindowPtr); // pass NSWindow* as void*

#ifdef __cplusplus
}
#endif
