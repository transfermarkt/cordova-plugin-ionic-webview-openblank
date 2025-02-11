//
//  CDVWKWebViewUIDelegate+OpenBlank.m
//  Nyheder
//
//  Created by Alejandro Paredes Alva on 09/03/16.
//
//

#import "CDVWKWebViewUIDelegate+OpenBlank.h"

@implementation CDVWKWebViewUIDelegate (OpenBlank)
- (WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures {
    if (!navigationAction.targetFrame.isMainFrame) {
      NSURL *url = [[navigationAction request] URL];

      // Debugausgabe der URL in der Konsole
      NSLog(@"Öffne URL im externen Browser: %@", url.absoluteString);

      UIApplication *application = [UIApplication sharedApplication];
      if ([application canOpenURL:url]) {
        if (@available(iOS 10.0, *)) {
          [application openURL:url options:@{} completionHandler:nil];
        } else {
          [application openURL:url];
        }
        // Abbrechen der Navigation im WebView
        return nil;
      }
    }
    return nil;
}
@end

