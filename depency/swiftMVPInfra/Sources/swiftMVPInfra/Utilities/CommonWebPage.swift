//
//  CommonWebPage.swift
//  AINoteTaker
//
//  Created by 吴伟 on 11/19/24.
//

import SwiftUI
import WebKit
import UIKit

struct CommonWebPage: UIViewRepresentable {
    let url: URL
    let title: String
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        
        let request = URLRequest(url: url)
        webView.load(request)
        
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        // No updates needed
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: CommonWebPage
        
        init(_ parent: CommonWebPage) {
            self.parent = parent
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            print("WebView loaded: \(parent.title)")
        }
        
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            print("WebView failed to load: \(error.localizedDescription)")
        }
    }
}

struct WebPageView: View {
    @Environment(\.dismiss) private var dismiss
    let url: URL
    let title: String
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    AppTheme.Colors.themeAccent.opacity(0.5),
                    AppTheme.Colors.themeYellow.opacity(0.7),
                    AppTheme.Colors.themeYellowDark.opacity(0.4)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // 使用 CustomNavigationBar 替代重复的导航栏代码
                CustomNavigationBar.theme(title: title) {
                    dismiss()
                }
                
                // WebView content
                CommonWebPage(url: url, title: title)
                    .background(Color.white)
            }
        }
        .navigationBarHidden(true)
    }
}
