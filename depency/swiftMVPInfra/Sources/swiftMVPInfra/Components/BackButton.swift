import SwiftUI

// MARK: - Reusable Back Button Component
struct BackButton: View {
    let action: () -> Void
    var text: String? = nil
    var iconColor: Color = .black.opacity(0.8)
    var backgroundColor: Color = .white.opacity(0.6)
    var shadowColor: Color = .black.opacity(0.1)
    
    var body: some View {
        Button(action: action) {
            if let text = text {
                // Back button with text
                HStack(spacing: 8) {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .foregroundColor(iconColor)
                    
                    Text(text)
                        .font(.body)
                        .foregroundColor(iconColor)
                }
            } else {
                // Icon-only back button
                Image(systemName: "chevron.left")
                    .foregroundColor(iconColor)
                    .font(.title2)
                    .padding(12)
                    .background(
                        Circle()
                            .fill(backgroundColor)
                            .shadow(color: shadowColor, radius: 2, x: 0, y: 1)
                    )
            }
        }
    }
}

// MARK: - Custom Navigation Bar with Back Button
struct CustomNavigationBar: View {
    let title: String
    let onBack: () -> Void
    var backButtonText: String? = nil
    var titleColor: Color = .black.opacity(0.8)
    var backButtonIconColor: Color = .black.opacity(0.8)
    var backButtonBackgroundColor: Color = .white.opacity(0.6)
    
    var body: some View {
        HStack {
            BackButton(
                action: onBack,
                text: backButtonText,
                iconColor: backButtonIconColor,
                backgroundColor: backButtonBackgroundColor
            )
            
            Spacer()
            
            Text(title)
                .font(.title2)
                .bold()
                .foregroundColor(titleColor)
            
            Spacer()
            
            // 占位空间保持标题居中（当有back text时）
            if backButtonText != nil {
                BackButton(
                    action: {},
                    text: backButtonText,
                    iconColor: backButtonIconColor
                )
                .opacity(0)
                .disabled(true)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }
}

// MARK: - Convenience Extensions for Different Themes
extension CustomNavigationBar {
    // For theme yellow background
    static func theme(title: String, backText: String? = nil, onBack: @escaping () -> Void) -> CustomNavigationBar {
        return CustomNavigationBar(
            title: title,
            onBack: onBack,
            backButtonText: backText,
            titleColor: .black.opacity(0.8),
            backButtonIconColor: .black.opacity(0.8),
            backButtonBackgroundColor: .white.opacity(0.6)
        )
    }
    
    // For dark background
    static func dark(title: String, backText: String? = nil, onBack: @escaping () -> Void) -> CustomNavigationBar {
        return CustomNavigationBar(
            title: title,
            onBack: onBack,
            backButtonText: backText,
            titleColor: .white,
            backButtonIconColor: .white,
            backButtonBackgroundColor: .white.opacity(0.2)
        )
    }
}

#Preview {
    VStack(spacing: 20) {
        // Icon-only navigation bar for theme background
        CustomNavigationBar.theme(title: "Transcription") {
            print("Back tapped")
        }
        .background(AppTheme.Colors.themeYellow)
        
        // Navigation bar with back text for theme background
        CustomNavigationBar.theme(title: "Quiz", backText: "Back") {
            print("Back tapped")
        }
        .background(AppTheme.Colors.themeYellow)
        
        // Dark navigation bar
        CustomNavigationBar.dark(title: "Settings", backText: "Back") {
            print("Back tapped")
        }
        .background(.black)
        
        Spacer()
    }
}
