import Foundation

public final class ServiceContainer: @unchecked Sendable {
    public static let shared = ServiceContainer()
    
    private var services: [String: Any] = [:]
    private let lock = NSLock()
    
    private init() {}
    
    public func register<T>(_ type: T.Type, factory: @escaping () -> T) {
        lock.withLock {
            services[String(describing: type)] = factory
        }
    }
    
    public func register<T>(_ type: T.Type, instance: T) {
        lock.withLock {
            services[String(describing: type)] = instance
        }
    }
    
    public func resolve<T>(_ type: T.Type) -> T? {
        lock.withLock {
            let key = String(describing: type)
            
            if let instance = services[key] as? T {
                return instance
            }
            
            if let factory = services[key] as? () -> T {
                let instance = factory()
                services[key] = instance
                return instance
            }
            
            return nil
        }
    }
    
    public func requireService<T>(_ type: T.Type) -> T {
        guard let service = resolve(type) else {
            fatalError("Service of type \(type) is not registered")
        }
        return service
    }
    
    public func clear() {
        lock.withLock {
            services.removeAll()
        }
    }
}

public extension ServiceContainer {
    static func registerDefaultServices(apiKey: String) {
        let container = ServiceContainer.shared
        
        let config = DefaultAPIConfiguration(apiKey: apiKey)
        container.register(ConfigurationProtocol.self, instance: config)
        
        let networkService = DefaultNetworkService()
        container.register(NetworkServiceProtocol.self, instance: networkService)
        
        let urlBuilder = DefaultURLRequestBuilder(configuration: config)
        container.register(URLRequestBuilderProtocol.self, instance: urlBuilder)
        
        let chatService = DefaultChatService(
            configuration: config,
            networkService: networkService,
            urlBuilder: urlBuilder
        )
        container.register(ChatServiceProtocol.self, instance: chatService)
        
        let speechService = DefaultSpeechService(
            configuration: config,
            networkService: networkService,
            urlBuilder: urlBuilder
        )
        container.register(SpeechServiceProtocol.self, instance: speechService)
        
        let homeService = DefaultHomeService(
            configuration: config,
            networkService: networkService,
            urlBuilder: urlBuilder
        )
        container.register(HomeServiceProtocol.self, instance: homeService)
    }
}