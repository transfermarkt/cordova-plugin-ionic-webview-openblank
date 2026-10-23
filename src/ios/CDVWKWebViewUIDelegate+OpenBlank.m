//
//  CDVWKWebViewUIDelegate+OpenBlank.m
//  Nyheder
//
//  Created by Alejandro Paredes Alva on 09/03/16.
//  Updated by Gloria Fuchs on 10/15/26
//

#import "CDVWKWebViewUIDelegate+OpenBlank.h"

@interface TMOpenBlankNavigationProxy : NSObject <WKNavigationDelegate>
@property (nonatomic, strong) id<WKNavigationDelegate> originalDelegate;
@end

@implementation TMOpenBlankNavigationProxy

- (BOOL)respondsToSelector:(SEL)selector
{
    return [super respondsToSelector:selector] ||
           [self.originalDelegate respondsToSelector:selector];
}

- (id)forwardingTargetForSelector:(SEL)selector
{
    if ([self.originalDelegate respondsToSelector:selector]) {
        return self.originalDelegate;
    }

    return [super forwardingTargetForSelector:selector];
}

- (BOOL)blocksNavigation:(WKNavigationAction *)action
{
    NSString *scheme = action.request.URL.scheme.lowercaseString;

    return action.targetFrame != nil &&
           action.targetFrame.isMainFrame &&
           ([scheme isEqualToString:@"http"] ||
            [scheme isEqualToString:@"https"]);
}

- (void)webView:(WKWebView *)webView
    decidePolicyForNavigationAction:(WKNavigationAction *)action
    decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
    if ([self blocksNavigation:action]) {
        // App-Hauptdokument erhalten. Nicht zusätzlich extern öffnen:
        // OpenBlank könnte den Werbeklick bereits geöffnet haben.
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }

    if ([self.originalDelegate respondsToSelector:_cmd]) {
        [self.originalDelegate webView:webView
            decidePolicyForNavigationAction:action
                            decisionHandler:decisionHandler];
    } else {
        decisionHandler(WKNavigationActionPolicyAllow);
    }
}

// WebKit bevorzugt diesen Callback, wenn der Delegate ihn anbietet.
- (void)webView:(WKWebView *)webView
    decidePolicyForNavigationAction:(WKNavigationAction *)action
    preferences:(WKWebpagePreferences *)preferences
    decisionHandler:(void (^)(WKNavigationActionPolicy,
                              WKWebpagePreferences *))decisionHandler
    API_AVAILABLE(ios(13.0))
{
    if ([self blocksNavigation:action]) {
        decisionHandler(WKNavigationActionPolicyCancel, preferences);
        return;
    }

    if ([self.originalDelegate respondsToSelector:_cmd]) {
        [self.originalDelegate webView:webView
            decidePolicyForNavigationAction:action
                                preferences:preferences
                            decisionHandler:decisionHandler];
    } else {
        [self webView:webView
            decidePolicyForNavigationAction:action
                            decisionHandler:^(WKNavigationActionPolicy policy) {
            decisionHandler(policy, preferences);
        }];
    }
}

@end

@interface TMOpenBlankNavigationGuard ()
@property (nonatomic, strong) TMOpenBlankNavigationProxy *navigationProxy;
@property (nonatomic, weak) WKWebView *guardedWebView;
@end

@implementation TMOpenBlankNavigationGuard

- (void)pluginInitialize
{
    [super pluginInitialize];

    UIView *engineView = self.webViewEngine.engineWebView;
    if (![engineView isKindOfClass:[WKWebView class]]) {
        return;
    }

    WKWebView *webView = (WKWebView *)engineView;

    self.navigationProxy = [[TMOpenBlankNavigationProxy alloc] init];
    self.navigationProxy.originalDelegate = webView.navigationDelegate;
    self.guardedWebView = webView;

    webView.navigationDelegate = self.navigationProxy;
}

- (void)dispose
{
    WKWebView *webView = self.guardedWebView;

    if (webView.navigationDelegate == self.navigationProxy) {
        webView.navigationDelegate = self.navigationProxy.originalDelegate;
    }

    self.navigationProxy = nil;

    [super dispose];
}

@end

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

