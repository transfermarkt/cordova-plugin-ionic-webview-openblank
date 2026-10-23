#import "CDVWKWebViewUIDelegate.h"
#import <Cordova/CDVPlugin.h>

@interface CDVWKWebViewUIDelegate (OpenBlank)
@end

// Hält den Navigation-Proxy während der Plugin-Laufzeit.
@interface TMOpenBlankNavigationGuard : CDVPlugin
@end
