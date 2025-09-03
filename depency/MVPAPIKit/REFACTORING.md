# WWChatGPTSwift 重构文档

## 架构重构概述

该重构采用了面向协议编程和依赖注入的设计模式，使WWChatGPTSwift包更加通用、可测试和可维护。

## 核心设计原则

### 1. 面向协议编程 (Protocol-Oriented Programming)
- `ChatServiceProtocol`: 聊天服务核心接口
- `SpeechServiceProtocol`: 语音服务接口  
- `HomeServiceProtocol`: 主页数据服务接口
- `NetworkServiceProtocol`: 网络请求抽象接口
- `ConfigurationProtocol`: 配置管理接口

### 2. 依赖注入 (Dependency Injection)
- `ServiceContainer`: 服务容器，管理所有服务实例
- `ServiceFactory`: 服务工厂，便捷创建服务实例
- 支持运行时和编译时依赖替换

### 3. Mock支持
- 所有服务都有对应的Mock实现
- 支持模拟错误、延迟、数据等测试场景
- 便于单元测试和集成测试

## 新架构使用方法

### 基础用法
```swift
// 1. 创建ChatGPT客户端
let client = ChatGPTClient(apiKey: "your-api-key")

// 2. 发送消息
let response = try await client.sendMessage("Hello!")
print(response)

// 3. 流式对话
let stream = client.sendStreamMessage("Tell me a story")
for try await chunk in stream {
    print(chunk, terminator: "")
}

// 4. 生成语音
let audioUrl = try await client.textToSpeech(text: "Hello world")

// 5. 生成图片
let imageUrl = try await client.generateImage(prompt: "A sunset")
```

### Mock测试用法
```swift
// 创建Mock客户端用于测试
let mockClient = ChatGPTClient.createMockClient(
    responses: ["测试响应1", "测试响应2"],
    delay: 0.1
)

// 使用与真实客户端相同的API
let response = try await mockClient.sendMessage("测试消息")
```

### 依赖注入高级用法
```swift
// 1. 注册自定义服务
ServiceContainer.shared.register(ChatServiceProtocol.self) {
    CustomChatService()
}

// 2. 替换网络层用于测试
ServiceContainer.shared.register(NetworkServiceProtocol.self, instance: MockNetworkService())

// 3. 解析服务
let chatService: ChatServiceProtocol = ServiceContainer.shared.requireService(ChatServiceProtocol.self)
```

## 向后兼容性

旧代码可以通过`LegacyWWChatGPTAPIV3`继续工作：

```swift
// 旧方式（已弃用但仍可用）
let api = LegacyWWChatGPTAPIV3(apiKey: "your-key")
let response = try await api.sendMessage(message)

// 新方式（推荐）
let client = ChatGPTClient(apiKey: "your-key")
let response = try await client.sendMessage("Hello")
```

## 测试策略

### 单元测试
- 每个服务都有独立的Mock实现
- 支持错误场景、延迟模拟等
- 使用依赖注入隔离测试

### 集成测试
- 验证服务间协作
- 测试真实网络请求（可选）
- 验证数据流完整性

## 架构优势

1. **可测试性**: 完全的Mock支持，便于单元测试
2. **可扩展性**: 面向协议设计，易于添加新功能
3. **解耦**: 依赖注入实现松耦合
4. **通用性**: 服务可在不同上下文中复用
5. **维护性**: 清晰的职责分离和接口定义
6. **向后兼容**: 保留旧API的可用性

## 文件结构
```
Sources/WWChatGPTSwift/
├── Protocols/           # 协议定义
├── Implementations/     # 默认实现
├── Mocks/              # Mock实现
├── Services/           # 服务工厂
├── DI/                 # 依赖注入容器
├── Extensions/         # 扩展方法
├── Legacy/             # 向后兼容层
└── ChatGPTClient.swift # 统一客户端接口
```