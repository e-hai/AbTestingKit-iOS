import Foundation

/// Errors thrown by the AbTesting framework.
public enum AbTestingError: LocalizedError, Equatable {
    case notInstalled

    public var errorDescription: String? {
        switch self {
        case .notInstalled:
            return "AbTestingClient is not installed. Call AbTestingClient.install(...) first."
        }
    }
}
