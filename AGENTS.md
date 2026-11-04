# AGENTS.md

给在本仓库工作的 AI Agent 的项目约定。人类说明见 [README.md](README.md)。

## 项目目标

封装 A/B Testing / Remote Config，降低 iOS / Apple 平台业务切换具体后端的成本。业务代码只依赖 `AbTesting` 模块的 `AbTestingClient`；具体后端放在独立实现模块（当前为 `AbTestingFirebase`）。

## 模块边界（必须遵守）

| Target / Product | 可依赖 | 禁止 |
|------------------|--------|------|
| `AbTesting` (Core) | Swift 标准库、Foundation | 任何第三方 / 供应商 SDK（如 Firebase）；勿把 Fake 当生产实现 |
| `AbTestingFirebase` | `AbTesting`、`firebase-ios-sdk` (`FirebaseRemoteConfig`) | 改动 Core API 语义来迁就 Firebase |
| `AbTestingDemo` (Sample) | `AbTesting` | 把演示专用逻辑塞进 library |

新增后端（如 GrowthBook、自研）时：新建 `AbTesting<Vendor>` Target，实现 `AbTestingProvider`，不要把 vendor SDK 引进 Core。

## API 约定

- 对外门面：`AbTestingClient`（`install` + `setDefaults` + `fetchAndActivate` + `getBool` / `getString` / `getLong` / `getInt` / `getDouble`）
- 扩展点：`AbTestingProvider`（协议）
- 配置：`AbTestingConfig`（目前主要是 `minimumFetchIntervalInSeconds`）
- 本地/测试：`FakeAbTestingProvider`（测试替身，含 `setRemoteValues` 模拟远端）
- Firebase：`FirebaseAbTestingProvider`；可用性用 `isFirebaseInitialized()`
- **不要**在库内调用 `FirebaseApp.configure()`；由宿主负责

v1 不要擅自加入：variant 模型、Analytics 曝光、Flow/AsyncSequence 监听、多 Provider 路由——除非用户明确要求。

## 代码与并发风格

- 核心门面 `AbTestingClient` 使用线程安全锁（`NSLock`）保护全局 Provider。
- 类型与协议遵循 Swift 6 `Sendable` 规范。
- 保持 API 面小；新增 public 类型前先确认是否能放在现有类型上扩展。
- 测试：Core 行为用 `FakeAbTestingProvider` + `AbTestingClient.reset()` 隔离。

## 常用命令

```bash
swift test --filter AbTestingTests
xcodegen generate
```

## 验证清单（改 API 或 Provider 时）

1. `AbTesting` Core 模块不出现任何 Firebase import
2. `AbTestingClient` 未 install 时安全回退并输出警告或抛出明确错误
3. `swift test --filter AbTestingTests` 全部通过
4. Sample 在无 `GoogleService-Info.plist` 时仍能编译并用 `FakeAbTestingProvider` 跑通流程
