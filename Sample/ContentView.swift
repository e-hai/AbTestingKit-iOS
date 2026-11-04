import SwiftUI
import AbTesting

public struct ContentView: View {
    @State private var providerName = "unknown"
    @State private var activated = false
    @State private var featureX = false
    @State private var welcomeMessage = ""
    @State private var maxItems: Int = 0
    @State private var scoreThreshold: Double = 0.0
    @State private var fetchCount = 0
    @State private var isBooting = true
    @State private var isRefreshing = false
    @State private var toastMessage: String?

    private let demoDefaults: [String: Any] = [
        "feature_x": false,
        "welcome_message": "Hello from in-app defaults",
        "max_items": 10,
        "score_threshold": 0.75
    ]

    public init() {}

    public var body: some View {
        ZStack {
            LinearGradient(
                colors: [AbTestingTheme.backgroundTop, AbTestingTheme.backgroundBottom],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            if isBooting {
                bootingView
            } else {
                mainContentView
            }
        }
        .task {
            await bootstrap()
        }
    }

    private var bootingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)
            Text("Installing provider…")
                .font(.headline)
                .foregroundColor(AbTestingTheme.textPrimary)
            Text("setDefaults → fetchAndActivate")
                .font(.subheadline)
                .foregroundColor(AbTestingTheme.textSecondary)
        }
    }

    private var mainContentView: some View {
        ScrollView {
            VStack(spacing: 20) {
                headerView

                providerCard

                welcomeHeroCard

                featureFlagCard

                metricsCard

                refreshButton

                if let toast = toastMessage {
                    Text(toast)
                        .font(.footnote)
                        .foregroundColor(AbTestingTheme.textSecondary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.white.opacity(0.85))
                        .clipShape(Capsule())
                        .shadow(color: Color.black.opacity(0.05), radius: 4, y: 2)
                        .transition(.opacity)
                }
            }
            .padding()
        }
    }

    private var headerView: some View {
        VStack(spacing: 4) {
            Text("AbTestingKit")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(AbTestingTheme.textPrimary)
            Text("Remote Config Playground (iOS)")
                .font(.subheadline)
                .foregroundColor(AbTestingTheme.textSecondary)
        }
        .padding(.top, 8)
    }

    private var providerCard: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 6) {
                    Circle()
                        .fill(activated ? AbTestingTheme.success : AbTestingTheme.danger)
                        .frame(width: 10, height: 10)
                    Text(providerName.uppercased())
                        .font(.caption.weight(.bold))
                        .foregroundColor(AbTestingTheme.primary)
                }
                Text(activated ? "Remote Activated" : "Defaults Active")
                    .font(.headline)
                    .foregroundColor(AbTestingTheme.textPrimary)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 2) {
                Text("Fetches")
                    .font(.caption2)
                    .foregroundColor(AbTestingTheme.textSecondary)
                Text("\(fetchCount)")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(AbTestingTheme.textPrimary)
            }
        }
        .padding(16)
        .background(AbTestingTheme.cardBackground)
        .cornerRadius(16)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(AbTestingTheme.cardBorder, lineWidth: 1))
    }

    private var welcomeHeroCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("WELCOME MESSAGE")
                .font(.caption.weight(.bold))
                .foregroundColor(AbTestingTheme.textSecondary)
            Text(welcomeMessage)
                .font(.title3.weight(.semibold))
                .foregroundColor(AbTestingTheme.textPrimary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(AbTestingTheme.cardBackground)
        .cornerRadius(16)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(AbTestingTheme.cardBorder, lineWidth: 1))
    }

    private var featureFlagCard: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("FEATURE FLAG (feature_x)")
                    .font(.caption.weight(.bold))
                    .foregroundColor(AbTestingTheme.textSecondary)
                Text(featureX ? "Enabled" : "Disabled")
                    .font(.headline)
                    .foregroundColor(featureX ? AbTestingTheme.success : AbTestingTheme.textPrimary)
            }
            Spacer()
            Image(systemName: featureX ? "checkmark.circle.fill" : "xmark.circle.fill")
                .font(.system(size: 28))
                .foregroundColor(featureX ? AbTestingTheme.success : AbTestingTheme.secondary)
        }
        .padding(16)
        .background(AbTestingTheme.cardBackground)
        .cornerRadius(16)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(AbTestingTheme.cardBorder, lineWidth: 1))
    }

    private var metricsCard: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text("MAX ITEMS")
                    .font(.caption.weight(.bold))
                    .foregroundColor(AbTestingTheme.textSecondary)
                Text("\(maxItems)")
                    .font(.title2.weight(.bold))
                    .foregroundColor(AbTestingTheme.primary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
            .background(AbTestingTheme.cardBackground)
            .cornerRadius(16)
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(AbTestingTheme.cardBorder, lineWidth: 1))

            VStack(alignment: .leading, spacing: 4) {
                Text("THRESHOLD")
                    .font(.caption.weight(.bold))
                    .foregroundColor(AbTestingTheme.textSecondary)
                Text(String(format: "%.2f", scoreThreshold))
                    .font(.title2.weight(.bold))
                    .foregroundColor(AbTestingTheme.accent)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
            .background(AbTestingTheme.cardBackground)
            .cornerRadius(16)
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(AbTestingTheme.cardBorder, lineWidth: 1))
        }
    }

    private var refreshButton: some View {
        Button(action: {
            Task {
                await refresh()
            }
        }) {
            HStack {
                if isRefreshing {
                    ProgressView()
                        .tint(.white)
                } else {
                    Image(systemName: "arrow.clockwise")
                    Text("Fetch & Activate")
                }
            }
            .font(.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(AbTestingTheme.primary)
            .cornerRadius(14)
        }
        .disabled(isRefreshing)
    }

    private func bootstrap() async {
        let name = setupProvider()
        providerName = name
        do {
            try await AbTestingClient.setDefaults(demoDefaults)
            let result = try await AbTestingClient.fetchAndActivate()
            activated = result
            fetchCount = 1
            readValues()
        } catch {
            readValues()
        }
        isBooting = false
    }

    private func refresh() async {
        guard !isRefreshing else { return }
        isRefreshing = true
        do {
            let result = try await AbTestingClient.fetchAndActivate()
            activated = result
            fetchCount += 1
            readValues()
            toastMessage = result ? "Fetch & activate succeeded" : "Fetch finished (no new activation)"
        } catch {
            toastMessage = "Fetch failed: \(error.localizedDescription)"
        }
        isRefreshing = false
    }

    private func readValues() {
        featureX = AbTestingClient.getBool("feature_x", default: false)
        welcomeMessage = AbTestingClient.getString("welcome_message", default: "")
        maxItems = AbTestingClient.getInt("max_items", default: 0)
        scoreThreshold = AbTestingClient.getDouble("score_threshold", default: 0.0)
    }

    private func setupProvider() -> String {
        // Fallback: FakeAbTestingProvider simulates a remote server payload.
        let fake = FakeAbTestingProvider()
        fake.setRemoteValues([
            "feature_x": true,
            "welcome_message": "Hello from Fake remote (iOS)",
            "max_items": 42,
            "score_threshold": 0.90
        ])
        AbTestingClient.install(fake)
        return "FakeProvider"
    }
}
