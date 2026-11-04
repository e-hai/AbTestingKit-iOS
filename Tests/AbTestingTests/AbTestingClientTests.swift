import XCTest
@testable import AbTesting

final class AbTestingClientTests: XCTestCase {

    override func tearDown() {
        super.tearDown()
        AbTestingClient.reset()
    }

    func testInstallAndReadDefaults() async throws {
        let provider = FakeAbTestingProvider()
        AbTestingClient.install(provider)
        try await AbTestingClient.setDefaults([
            "feature_x": true,
            "title": "default",
            "count": Int64(3),
            "ratio": 1.5
        ])

        XCTAssertTrue(AbTestingClient.isInstalled)
        XCTAssertTrue(AbTestingClient.getBool("feature_x", default: false))
        XCTAssertTrue(AbTestingClient.getBoolean("feature_x", default: false))
        XCTAssertEqual(AbTestingClient.getString("title", default: ""), "default")
        XCTAssertEqual(AbTestingClient.getLong("count", default: 0), 3)
        XCTAssertEqual(AbTestingClient.getInt("count", default: 0), 3)
        XCTAssertEqual(AbTestingClient.getDouble("ratio", default: 0.0), 1.5, accuracy: 0.0001)
    }

    func testFetchAndActivateUsesRemoteOverDefaults() async throws {
        let provider = FakeAbTestingProvider()
        provider.setRemoteValues([
            "feature_x": true,
            "title": "remote"
        ])
        AbTestingClient.install(provider)
        try await AbTestingClient.setDefaults([
            "feature_x": false,
            "title": "default"
        ])

        XCTAssertFalse(AbTestingClient.getBool("feature_x", default: true))
        XCTAssertEqual(AbTestingClient.getString("title", default: ""), "default")

        let activated = try await AbTestingClient.fetchAndActivate()
        XCTAssertTrue(activated)
        XCTAssertTrue(AbTestingClient.getBool("feature_x", default: false))
        XCTAssertEqual(AbTestingClient.getString("title", default: ""), "remote")
    }

    func testGettersFallBackToMethodDefaultWhenKeyMissing() async throws {
        AbTestingClient.install(FakeAbTestingProvider())
        try await AbTestingClient.setDefaults([:])
        _ = try await AbTestingClient.fetchAndActivate()

        XCTAssertFalse(AbTestingClient.getBool("missing_bool", default: false))
        XCTAssertEqual(AbTestingClient.getString("missing_str", default: "fallback"), "fallback")
        XCTAssertEqual(AbTestingClient.getLong("missing_long", default: 99), 99)
        XCTAssertEqual(AbTestingClient.getInt("missing_int", default: 42), 42)
        XCTAssertEqual(AbTestingClient.getDouble("missing_double", default: 2.5), 2.5, accuracy: 0.0001)
    }

    func testOperationsWithoutInstallThrows() async {
        XCTAssertFalse(AbTestingClient.isInstalled)
        do {
            try await AbTestingClient.setDefaults(["k": "v"])
            XCTFail("Expected notInstalled error")
        } catch let error as AbTestingError {
            XCTAssertEqual(error, .notInstalled)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }

        do {
            _ = try await AbTestingClient.fetchAndActivate()
            XCTFail("Expected notInstalled error")
        } catch let error as AbTestingError {
            XCTAssertEqual(error, .notInstalled)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testResetClearsProvider() {
        AbTestingClient.install(FakeAbTestingProvider())
        XCTAssertTrue(AbTestingClient.isInstalled)
        AbTestingClient.reset()
        XCTAssertFalse(AbTestingClient.isInstalled)
    }
}
