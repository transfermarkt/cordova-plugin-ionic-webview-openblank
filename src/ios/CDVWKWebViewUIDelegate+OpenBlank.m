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
        NSURL *url = navigationAction.request.URL;
        
        // Debugging: URL ausgeben
        NSLog(@"Öffne URL im externen Browser: %@", url.absoluteString);
        
        UIApplication *application = [UIApplication sharedApplication];
        if ([application canOpenURL:url]) {
            if (@available(iOS 10.0, *)) {
                [application openURL:url options:@{} completionHandler:^(BOOL success) {
                    if (success) {
                        NSLog(@"URL wurde im externen Browser geöffnet.");
                    } else {
                        NSLog(@"Fehler beim Öffnen der URL.");
                    }
                }];
            } else {
                [application openURL:url];
            }
            
            // Explizites Stoppen der Navigation im WebView
            [webView loadHTMLString:@"" baseURL:nil]; // Setzt den WebView-Inhalt auf leer
            return nil;
        }
    }
    return nil;
}
@end

