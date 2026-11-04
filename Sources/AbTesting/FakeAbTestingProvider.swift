import Foundation

/// Test fake for `AbTestingProvider`.
///
/// Use in unit tests and local verification without a real backend.
/// `fetchAndActivate` activates values previously set via `setRemoteValues`,
/// simulating a successful remote fetch. Until then, `setDefaults` values are used.
public final class FakeAbTestingProvider: AbTestingProvider, @unchecked Sendable {
    private let lock = NSLock()
    private var defaults: [String: Any] = [:]
    private var remote: [String: Any] = [:]
    private var activated = false

    public init() {}

    /// Simulates remote payload that becomes active after `fetchAndActivate`.
    public func setRemoteValues(_ values: [String: Any]) {
        sync {
            remote = values
        }
    }

    public func setDefaults(_ defaults: [String: Any]) async throws {
        sync {
            self.defaults = defaults
        }
    }

    public func fetchAndActivate() async throws -> Bool {
        sync {
            activated = true
            return true
        }
    }

    public func getBool(key: String, default: Bool) -> Bool {
        read(key: key, default: `default`) { val in
            if let b = val as? Bool { return b }
            if let n = val as? NSNumber { return n.boolValue }
            if let s = val as? String {
                if s.caseInsensitiveCompare("true") == .orderedSame { return true }
                if s.caseInsensitiveCompare("false") == .orderedSame { return false }
            }
            return nil
        }
    }

    public func getString(key: String, default: String) -> String {
        read(key: key, default: `default`) { val in
            if let s = val as? String { return s }
            if let v = val { return String(describing: v) }
            return nil
        }
    }

    public func getLong(key: String, default: Int64) -> Int64 {
        read(key: key, default: `default`) { val in
            if let i = val as? Int64 { return i }
            if let i = val as? Int { return Int64(i) }
            if let n = val as? NSNumber { return n.int64Value }
            if let s = val as? String { return Int64(s) }
            return nil
        }
    }

    public func getDouble(key: String, default: Double) -> Double {
        read(key: key, default: `default`) { val in
            if let d = val as? Double { return d }
            if let f = val as? Float { return Double(f) }
            if let n = val as? NSNumber { return n.doubleValue }
            if let s = val as? String { return Double(s) }
            return nil
        }
    }

    private func read<T>(key: String, default: T, convert: (Any?) -> T?) -> T {
        sync {
            let raw: Any?
            if activated && remote.keys.contains(key) {
                raw = remote[key]
            } else {
                raw = defaults[key]
            }
            return convert(raw) ?? `default`
        }
    }

    private func sync<T>(_ block: () -> T) -> T {
        lock.lock()
        defer { lock.unlock() }
        return block()
    }
}
