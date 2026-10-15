//
//  CDVWKWebViewUIDelegate+OpenBlank.m
//  Nyheder
//
//  Created by Alejandro Paredes Alva on 09/03/16.
//  Updated by Gloria Fuchs on 10/15/26
//

#import "CDVWKWebViewUIDelegate+OpenBlank.h"

@implementation CDVWKWebViewUIDelegate (OpenBlank)

- (WKWebView *)webView:(WKWebView *)webView
    createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration
              forNavigationAction:(WKNavigationAction *)navigationAction
                   windowFeatures:(WKWindowFeatures *)windowFeatures
{
    // Nur Anforderungen für neue Fenster extern behandeln.
    if (navigationAction.targetFrame != nil) {
        return nil;
    }

    NSURL *url = navigationAction.request.URL;
    if (url == nil) {
        return nil;
    }

    UIApplication *application = [UIApplication sharedApplication];

    if ([application canOpenURL:url]) {
        if (@available(iOS 10.0, *)) {
            [application openURL:url
                        options:@{}
              completionHandler:nil];
        } else {
            [application openURL:url];
        }
    }

    // Keine neue WebView erstellen und die bestehende App-Seite erhalten.
    return nil;
}

@end

