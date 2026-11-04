import Foundation
import os

/// Process-wide facade for A/B testing and remote config.
/// Install an [AbTestingProvider] once at app startup,
/// then read values through this client so call sites stay backend-agnostic.
public final class AbTestingClient: @unchecked Sendable {
    private static let lock = NSLock()
    private static var provider: (any AbTestingProvider)?

    private init() {}

    /// Installs the global provider implementation.
    public static func install(_ provider: any AbTestingProvider) {
        lock.lock()
        defer { lock.unlock() }
        self.provider = provider
    }

    /// Whether a provider has been installed.
    public static var isInstalled: Bool {
        lock.lock()
        defer { lock.unlock() }
        return provider != nil
    }

    /// Registers in-app default values.
    public static func setDefaults(_ defaults: [String: Any]) async throws {
        try await requireProvider().setDefaults(defaults)
    }

    /// Fetches remote configurations and activates them into the active config.
    public static func fetchAndActivate() async throws -> Bool {
        try await requireProvider().fetchAndActivate()
    }

    /// Reads a boolean value with fallback.
    public static func getBool(_ key: String, default: Bool) -> Bool {
        guard let p = currentProvider else {
            #if DEBUG
            assertionFailure("AbTestingClient is not installed. Call AbTestingClient.install(...) first.")
            #endif
            return `default`
        }
        return p.getBool(key: key, default: `default`)
    }

    /// Alias for `getBool` to match Kotlin/Android naming conventions.
    public static func getBoolean(_ key: String, default: Bool) -> Bool {
        getBool(key, default: `default`)
    }

    /// Reads a string value with fallback.
    public static func getString(_ key: String, default: String) -> String {
        guard let p = currentProvider else {
            #if DEBUG
            assertionFailure("AbTestingClient is not installed. Call AbTestingClient.install(...) first.")
            #endif
            return `default`
        }
        return p.getString(key: key, default: `default`)
    }

    /// Reads a 64-bit integer value with fallback.
    public static func getLong(_ key: String, default: Int64) -> Int64 {
        guard let p = currentProvider else {
            #if DEBUG
            assertionFailure("AbTestingClient is not installed. Call AbTestingClient.install(...) first.")
            #endif
            return `default`
        }
        return p.getLong(key: key, default: `default`)
    }

    /// Reads a standard integer value with fallback.
    public static func getInt(_ key: String, default: Int) -> Int {
        guard let p = currentProvider else {
            #if DEBUG
            assertionFailure("AbTestingClient is not installed. Call AbTestingClient.install(...) first.")
            #endif
            return `default`
        }
        return p.getInt(key: key, default: `default`)
    }

    /// Reads a double-precision floating-point value with fallback.
    public static func getDouble(_ key: String, default: Double) -> Double {
        guard let p = currentProvider else {
            #if DEBUG
            assertionFailure("AbTestingClient is not installed. Call AbTestingClient.install(...) first.")
            #endif
            return `default`
        }
        return p.getDouble(key: key, default: `default`)
    }

    /// Clears the installed provider. Intended for unit tests.
    public static func reset() {
        lock.lock()
        defer { lock.unlock() }
        provider = nil
    }

    private static var currentProvider: (any AbTestingProvider)? {
        lock.lock()
        defer { lock.unlock() }
        return provider
    }

    private static func requireProvider() throws -> any AbTestingProvider {
        lock.lock()
        defer { lock.unlock() }
        guard let p = provider else {
            throw AbTestingError.notInstalled
        }
        return p
    }
}
