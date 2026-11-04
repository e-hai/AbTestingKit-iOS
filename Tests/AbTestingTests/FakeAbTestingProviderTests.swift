import XCTest
@testable import AbTesting

final class FakeAbTestingProviderTests: XCTestCase {

    func testDefaultsUsedBeforeFetch() async throws {
        let provider = FakeAbTestingProvider()
        try await provider.setDefaults(["flag": true, "name": "local"])

        XCTAssertTrue(provider.getBool(key: "flag", default: false))
        XCTAssertEqual(provider.getString(key: "name", default: ""), "local")
    }

    func testRemoteOverridesDefaultsAfterActivate() async throws {
        let provider = FakeAbTestingProvider()
        try await provider.setDefaults(["flag": false, "count": Int64(1)])
        provider.setRemoteValues(["flag": true, "count": Int64(7)])

        XCTAssertFalse(provider.getBool(key: "flag", default: true))
        XCTAssertEqual(provider.getLong(key: "count", default: 0), 1)

        let activated = try await provider.fetchAndActivate()
        XCTAssertTrue(activated)
        XCTAssertTrue(provider.getBool(key: "flag", default: false))
        XCTAssertEqual(provider.getLong(key: "count", default: 0), 7)
    }

    func testRemoteKeyMissingFallsBackToDefaultsAfterActivate() async throws {
        let provider = FakeAbTestingProvider()
        try await provider.setDefaults(["only_default": "kept"])
        provider.setRemoteValues(["other": "remote"])
        _ = try await provider.fetchAndActivate()

        XCTAssertEqual(provider.getString(key: "only_default", default: "fallback"), "kept")
        XCTAssertEqual(provider.getString(key: "other", default: ""), "remote")
    }
}
