import SwiftUI
import Foundation
import WebKit

public protocol Routable: Hashable {
    var identifier: String { get }
    var title: String? { get }
}

@MainActor
public class RouterPath<Destination: Routable>: ObservableObject {
    @Published public var path: [Destination] = []
    
    public init() {}
    
    public func navigate(to destination: Destination) {
        print("导航至: \(destination.identifier)")
        path.append(destination)
    }

    public func pop() {
        guard !path.isEmpty else {
            print("警告: 试图从空路径中弹出")
            return
        }
        path.removeLast()
    }

    public func popToRoot() {
        path.removeAll()
    }
}


public extension View {
    /**
     注册应用的路由组件 - 需要外部提供具体的路由视图实现
     */
    public func withRouter<Destination: Routable>(
        @ViewBuilder destination: @escaping (Destination) -> some View
    ) -> some View {
        navigationDestination(for: Destination.self, destination: destination)
    }
}

/**
 public enum AppRoute: Routable {
     case home
     case settings
     case profile(userId: String)
     case productDetail(productId: String, title: String)
     case webView(url: String, title: String)
     
     public var identifier: String {
         switch self {
         case .home:
             return "home"
         case .settings:
             return "settings"
         case .profile(let userId):
             return "profile_\(userId)"
         case .productDetail(let productId, _):
             return "product_\(productId)"
         case .webView(let url, _):
             return "webview_\(url.hashValue)"
         }
     }
     
     public var title: String? {
         switch self {
         case .home:
             return "Home"
         case .settings:
             return "Settings"
         case .profile:
             return "Profile"
         case .productDetail(_, let title):
             return title
         case .webView(_, let title):
             return title
         }
     }
 }

 // MARK: - Usage Example

 struct ExampleAppView: View {
     @StateObject private var router = RouterPath<AppRoute>()
     
     var body: some View {
         NavigationStack(path: $router.path) {
             VStack(spacing: 20) {
                 Text("Router Example")
                     .font(.title)
                 
                 Button("Go to Settings") {
                     router.navigate(to: .settings)
                 }
                 
                 Button("Go to Profile") {
                     router.navigate(to: .profile(userId: "user123"))
                 }
                 
                 Button("Go to Product") {
                     router.navigate(to: .productDetail(productId: "prod456", title: "Amazing Product"))
                 }
             }
             .padding()
         }
         .withRouter { route in
             routeView(for: route)
         }
     }
     
     @ViewBuilder
     private func routeView(for route: AppRoute) -> some View {
         switch route {
         case .home:
             Text("Home View")
                 .navigationTitle(route.title ?? "")
                 
         case .settings:
             VStack {
                 Text("Settings View")
                 Button("Go Back") {
                     router.pop()
                 }
             }
             .navigationTitle(route.title ?? "")
             
         case .profile(let userId):
             VStack {
                 Text("Profile View")
                 Text("User ID: \(userId)")
                 Button("Go to Root") {
                     router.popToRoot()
                 }
             }
             .navigationTitle(route.title ?? "")
             
         case .productDetail(let productId, _):
             VStack {
                 Text("Product Detail")
                 Text("Product ID: \(productId)")
             }
             .navigationTitle(route.title ?? "")
             
         case .webView(let url, _):
             Text("Web View: \(url)")
                 .navigationTitle(route.title ?? "")
         }
     }
 }

 // MARK: - Advanced Example with Multiple Route Types

 public enum ModalRoute: Routable {
     case alert(message: String)
     case sheet(content: String)
     
     public var identifier: String {
         switch self {
         case .alert: return "alert"
         case .sheet: return "sheet"
         }
     }
     
     public var title: String? {
         switch self {
         case .alert: return "Alert"
         case .sheet: return "Sheet"
         }
     }
 }

 struct AdvancedExampleView: View {
     @StateObject private var navigationRouter = RouterPath<AppRoute>()
     @StateObject private var modalRouter = RouterPath<ModalRoute>()
     
     var body: some View {
         NavigationStack(path: $navigationRouter.path) {
             VStack {
                 Text("Advanced Router Example")
                 
                 Button("Navigate") {
                     navigationRouter.navigate(to: .settings)
                 }
                 
                 Button("Show Modal") {
                     modalRouter.navigate(to: .sheet(content: "Modal Content"))
                 }
             }
         }
         .withRouter { route in
             // Handle navigation routes
             Text("Navigation: \(route.identifier)")
         }
         .sheet(
             isPresented: .constant(!modalRouter.path.isEmpty),
             onDismiss: { modalRouter.popToRoot() }
         ) {
             if let modalRoute = modalRouter.path.last {
                 Text("Modal: \(modalRoute.identifier)")
             }
         }
     }
 }
 */
