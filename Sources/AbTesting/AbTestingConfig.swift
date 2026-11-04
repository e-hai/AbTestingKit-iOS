import Foundation

/// Shared configuration applied by providers supporting fetch intervals.
public struct AbTestingConfig: Sendable, Equatable {
    /// Minimum interval (in seconds) between remote fetches.
    ///
    /// Use a small value (e.g. 0) in debug builds; production typically uses 3600+.
    public var minimumFetchIntervalInSeconds: TimeInterval

    public init(minimumFetchIntervalInSeconds: TimeInterval = 3600) {
        self.minimumFetchIntervalInSeconds = minimumFetchIntervalInSeconds
    }
}
