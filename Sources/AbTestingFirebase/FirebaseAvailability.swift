import Foundation
import FirebaseCore

/// Returns true when a default `FirebaseApp` has been configured in this process.
public func isFirebaseInitialized() -> Bool {
    return FirebaseApp.app() != nil
}
