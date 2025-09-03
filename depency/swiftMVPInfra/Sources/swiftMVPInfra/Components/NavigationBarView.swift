import SwiftUI

// 添加新的 NavigationBarView 组件
struct NavigationBarView: View {
    let title: String
    let onDismiss: () -> Void
    
    var body: some View {
        HStack {
            Button(action: onDismiss) {
                Image(systemName: "chevron.left")
                    .foregroundColor(.white)
                    .padding(12)
                    .background(Circle().fill(Color.white.opacity(0.2)))
            }
            
            Spacer()
            
            Text(title)
                .font(.title2)
                .bold()
                .foregroundColor(.white)
            
            Spacer()
            
            
        }
        .padding()
    }
}