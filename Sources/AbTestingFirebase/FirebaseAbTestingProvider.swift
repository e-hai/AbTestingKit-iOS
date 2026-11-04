import Foundation
import AbTesting
import FirebaseCore
import FirebaseRemoteConfig

/// `AbTestingProvider` backed by Firebase Remote Config.
///
/// The host app must initialize Firebase (e.g. via `FirebaseApp.configure()`)
/// before installing this provider.
public final class FirebaseAbTestingProvider: AbTestingProvider, @unchecked Sendable {
    private let remoteConfig: RemoteConfig

    public init(
        config: AbTestingConfig = AbTestingConfig(),
        remoteConfig: RemoteConfig = RemoteConfig.remoteConfig()
    ) {
        self.remoteConfig = remoteConfig
        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = config.minimumFetchIntervalInSeconds
        remoteConfig.configSettings = settings
    }

    public func setDefaults(_ defaults: [String: Any]) async throws {
        var nsDefaults: [String: NSObject] = [:]
        for (key, val) in defaults {
            if let nsVal = val as? NSObject {
                nsDefaults[key] = nsVal
            }
        }
        remoteConfig.setDefaults(nsDefaults)
    }

    public func fetchAndActivate() async throws -> Bool {
        let status = try await remoteConfig.fetchAndActivate()
        return status == .successFetchedFromRemote || status == .successUsingPreFetchedData
    }

    public func getBool(key: String, default: Bool) -> Bool {
        let value = remoteConfig.configValue(forKey: key)
        return value.source == .static ? `default` : value.boolValue
    }

    public func getString(key: String, default: String) -> String {
        let value = remoteConfig.configValue(forKey: key)
        return value.source == .static ? `default` : value.stringValue
    }

    public func getLong(key: String, default: Int64) -> Int64 {
        let value = remoteConfig.configValue(forKey: key)
        return value.source == .static ? `default` : value.numberValue.int64Value
    }

    public func getDouble(key: String, default: Double) -> Double {
        let value = remoteConfig.configValue(forKey: key)
        return value.source == .static ? `default` : value.numberValue.doubleValue
    }
}
