import Foundation

/// Errors thrown by the AbTesting framework.
public enum AbTestingError: LocalizedError, Equatable {
    case notInstalled

    public var errorDescription: String? {
        switch self {
        case .notInstalled:
            return "AbTestingClient 尚未安装，请先调用 AbTestingClient.install(...)。"
        }
    }
}
