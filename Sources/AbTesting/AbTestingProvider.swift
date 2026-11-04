import Foundation

/// Backend contract for A/B testing / remote config providers on Apple platforms.
public protocol AbTestingProvider: AnyObject, Sendable {
    /// Registers local default values for when keys are missing or unactivated.
    func setDefaults(_ defaults: [String: Any]) async throws

    /// Fetches remote configurations and activates them into the active store.
    func fetchAndActivate() async throws -> Bool

    /// Reads a boolean value for the specified key.
    func getBool(key: String, default: Bool) -> Bool

    /// Reads a string value for the specified key.
    func getString(key: String, default: String) -> String

    /// Reads a 64-bit integer value for the specified key.
    func getLong(key: String, default: Int64) -> Int64

    /// Reads a double-precision floating-point value for the specified key.
    func getDouble(key: String, default: Double) -> Double
}

public extension AbTestingProvider {
    /// Convenience helper to read a standard Swift integer.
    func getInt(key: String, default: Int) -> Int {
        Int(getLong(key: key, default: Int64(`default`)))
    }
}
