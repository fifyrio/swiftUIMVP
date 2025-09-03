import Foundation
import SwiftUI

// 本地化帮助器
public struct L {
    private static var targetBundle: Bundle = Bundle.main
    
    // 配置目标bundle，只需要在app启动时调用一次
    public static func configure(bundle: Bundle = Bundle.main) {
        targetBundle = bundle
    }
    
    public static func string(_ key: String, currentLanguage: String, comment: String = "") -> String {
        if let languageBundle = targetBundle.bundleForLanguage(currentLanguage) {
            return NSLocalizedString(key, bundle: languageBundle, comment: comment)
        }
        return NSLocalizedString(key, bundle: targetBundle, comment: comment)
    }
    
    public static func string(_ key: String, currentLanguage: String, _ args: CVarArg..., comment: String = "") -> String {
        let format = L.string(key, currentLanguage: currentLanguage, comment: comment)
        return String(format: format, arguments: args)
    }
}

// 基于 AppStorage 的本地化 View Modifier
public struct LocalizedView<Content: View>: View {
    @AppStorage("language") private var language = LanguageManager.shared.selectedLanguage
    private let content: Content
    
    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    public var body: some View {
        content
            
    }
}

// Bundle 扩展，用于动态获取特定语言的 Bundle
public extension Bundle {
    func bundleForLanguage(_ language: String) -> Bundle? {
        guard let path = self.path(forResource: language, ofType: "lproj"),
              let bundle = Bundle(path: path) else {
            return nil
        }
        return bundle
    }
}

// SwiftUI Text 扩展，用于更方便的本地化
public extension Text {
    init(localized key: String, currentLanguage: String, comment: String = "") {
        self.init(L.string(key, currentLanguage: currentLanguage, comment: comment))
    }
    
    init(localized key: String, currentLanguage: String, _ args: CVarArg..., comment: String = "") {
        self.init(L.string(key, currentLanguage: currentLanguage, args, comment: comment))
    }
}

// String 扩展，用于简化本地化调用
public extension String {
    func localized(currentLanguage: String, comment: String = "") -> String {
        return L.string(self, currentLanguage: currentLanguage, comment: comment)
    }
    
    func localized(currentLanguage: String, _ args: CVarArg..., comment: String = "") -> String {
        return L.string(self, currentLanguage: currentLanguage, args, comment: comment)
    }
}

// View 扩展，用于添加语言监听
public extension View {
    func withLanguageObserver() -> some View {
        LocalizedView {
            self
        }
    }
}
