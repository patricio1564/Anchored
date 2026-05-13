import SwiftUI

@main
struct AnchoredAppClipApp: App {
    var body: some Scene {
        WindowGroup {
            AppClipContentView()
        }
    }
}

struct AppClipContentView: View {
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "book.fill")
                .font(.system(size: 60))
                .foregroundStyle(.orange)

            Text("Anchored")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("Learn the Bible, one verse at a time.")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding()
    }
}

#Preview {
    AppClipContentView()
}
