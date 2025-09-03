import Foundation
import SwiftUI

// 支持的语言枚举
public enum SupportedLanguage: String, CaseIterable, Identifiable {
    case english = "en"
    case korean = "ko" 
    case traditionalChinese = "zh-Hant"
    
    public var id: String { rawValue }
    
    public var displayName: String {
        switch self {
        case .english:
            return "English"
        case .korean:
            return "한국어"
        case .traditionalChinese:
            return "繁體中文"
        }
    }
    
    public var locale: Locale {
        Locale(identifier: rawValue)
    }
}

// 语言管理器
@MainActor
public class LanguageManager: ObservableObject {
    public static let shared = LanguageManager()
    
    // 使用 AppStorage 存储选中的语言
    @AppStorage("language") public var selectedLanguage: String = SupportedLanguage.english.rawValue
    
    public var currentLanguage: SupportedLanguage {
        get {
            return SupportedLanguage(rawValue: selectedLanguage) ?? .english
        }
        set {
            selectedLanguage = newValue.rawValue
            updateAppLanguage()
        }
    }
    
    private init() {
        // 初始化时确保语言设置正确
        updateAppLanguage()
    }
    
    private func updateAppLanguage() {
        // 更新 UserDefaults 中的语言设置，用于系统级本地化
        UserDefaults.standard.set([selectedLanguage], forKey: "AppleLanguages")
        UserDefaults.standard.synchronize()
    }
    
    public func setLanguage(_ language: SupportedLanguage) {
        guard currentLanguage != language else { return }
        currentLanguage = language
    }
}

