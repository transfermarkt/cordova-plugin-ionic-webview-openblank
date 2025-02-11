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
      UIApplication *application = [UIApplication sharedApplication];
      if ([application canOpenURL:url]) {
        if (@available(iOS 10.0, *)) {
          [application openURL:url options:@{} completionHandler:nil];
        } else {
          [application openURL:url];
        }
      }
    }
    return nil;
}
@end
