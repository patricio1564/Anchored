import SwiftUI
import SwiftData

struct TopicsView: View {

    @EnvironmentObject private var premiumManager: PremiumManager

    @Query(sort: \LessonProgress.completedAt, order: .reverse)
    private var progressRows: [LessonProgress]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                // Header
                VStack(alignment: .leading, spacing: 0) {
                    Text("Walk through")
                        .font(.custom("Newsreader", size: 13).weight(.regular).italic())
                        .foregroundStyle(AnchoredColors.inkSoft)
                    Text("Scripture")
                        .font(.custom("Newsreader", size: 36).weight(.regular))
                        .tracking(-0.72)
                        .foregroundStyle(AnchoredColors.ink)
                }
                .padding(.bottom, 8)

                ForEach(TopicsCatalog.all) { topic in
                    topicRow(for: topic)
                }
            }
            .padding(.top, 58)
            .padding(.bottom, 24)
            .screenPadding()
        }
        .appBackground()
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .sheet(isPresented: $premiumManager.isShowingPaywall) {
            PaywallSheet()
        }
        .navigationDestination(for: Topic.self) { topic in
            TopicDetailView(topic: topic)
        }
        .navigationDestination(for: LessonDestination.self) { destination in
            LessonView(topic: destination.topic, lesson: destination.lesson)
        }
    }

    // MARK: - Topic Row

    @ViewBuilder
    private func topicRow(for topic: Topic) -> some View {
        let completed = completedCount(for: topic)
        let total = topic.lessons.count
        let isAccessible = topic.isFree || premiumManager.isPremium

        if isAccessible {
            NavigationLink(value: topic) {
                rowBody(topic: topic, completed: completed, total: total, locked: false)
            }
            .buttonStyle(.plain)
        } else {
            Button {
                premiumManager.presentPaywall()
            } label: {
                rowBody(topic: topic, completed: completed, total: total, locked: true)
            }
            .buttonStyle(.plain)
        }
    }

    private func rowBody(topic: Topic, completed: Int, total: Int, locked: Bool) -> some View {
        let accentColors = topicAccentColors(for: topic)
        let c1 = accentColors.0

        return HStack(spacing: 14) {
            // Glyph icon tile — white bg, accent border, first letter serif italic
            ZStack {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(.white)
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(c1.opacity(0.33), lineWidth: 1)
                Text(String(topic.title.prefix(1)))
                    .font(.custom("Newsreader", size: 24).weight(.medium).italic())
                    .foregroundStyle(c1)
            }
            .frame(width: 54, height: 54)
            .shadow(color: c1.opacity(0.15), radius: 6, x: 0, y: 4)
            .opacity(locked ? 0.55 : 1.0)

            VStack(alignment: .leading, spacing: 2) {
                Text(topic.title)
                    .font(.custom("Newsreader", size: 17).weight(.medium))
                    .foregroundStyle(AnchoredColors.ink)
                Text(topic.description)
                    .font(.custom("Outfit", size: 12).weight(.medium))
                    .foregroundStyle(AnchoredColors.inkSoft)
                    .lineLimit(1)
                    .truncationMode(.tail)

                if !locked {
                    HStack(spacing: 8) {
                        // Progress mini-bar
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                Capsule()
                                    .fill(AnchoredColors.lineSoft)
                                    .frame(height: 4)
                                Capsule()
                                    .fill(
                                        LinearGradient(
                                            colors: [accentColors.0, accentColors.1],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .frame(
                                        width: total > 0 ? geo.size.width * CGFloat(completed) / CGFloat(total) : 0,
                                        height: 4
                                    )
                            }
                        }
                        .frame(height: 4)

                        Text("\(completed)/\(total)")
                            .font(.custom("Outfit", size: 11).weight(.semibold))
                            .monospacedDigit()
                            .foregroundStyle(AnchoredColors.inkSoft)
                    }
                    .padding(.top, 6)
                }
            }

            Spacer(minLength: 0)

            Image(systemName: locked ? "lock.fill" : "chevron.right")
                .font(.system(size: 14))
                .foregroundStyle(locked ? AnchoredColors.coral : AnchoredColors.inkMute)
        }
        .glassCard(padding: 14, cornerRadius: 20)
    }

    // MARK: - Topic accent colors

    private func topicAccentColors(for topic: Topic) -> (Color, Color) {
        let stops = topic.gradient.hexStops
        return (Color(hex: stops.start), Color(hex: stops.end))
    }

    // MARK: - Progress aggregation

    private func completedCount(for topic: Topic) -> Int {
        let completedIDs = Set(progressRows.filter(\.completed).map(\.lessonId))
        return topic.lessons.reduce(0) { count, lesson in
            count + (completedIDs.contains(lesson.id) ? 1 : 0)
        }
    }
}

// MARK: - Paywall placeholder

struct PaywallSheet: View {
    @EnvironmentObject private var premiumManager: PremiumManager
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            AnchoredColors.backgroundGradient.ignoresSafeArea()

            VStack(spacing: 24) {
                VStack(spacing: 12) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 44))
                        .foregroundStyle(AnchoredColors.coral)

                    Text("Anchored Premium")
                        .font(.custom("Newsreader", size: 28).weight(.regular))
                        .foregroundStyle(AnchoredColors.ink)

                    Text("Unlock all 35 topics, 176 lessons, every translation, and the Verse Recommender.")
                        .font(.custom("Outfit", size: 14.5).weight(.medium))
                        .foregroundStyle(AnchoredColors.inkSoft)
                        .multilineTextAlignment(.center)
                }

                VStack(alignment: .leading, spacing: 12) {
                    featureRow("34 premium topics")
                    featureRow("5 Bible translations")
                    featureRow("Verse Recommender")
                    featureRow("All future content")
                }
                .padding(.vertical, 4)

                if case .failed(let message) = premiumManager.purchaseState {
                    Text(message)
                        .font(.custom("Outfit", size: 12).weight(.medium))
                        .foregroundStyle(AnchoredColors.error)
                        .multilineTextAlignment(.center)
                }

                Button {
                    Task { await premiumManager.purchase() }
                } label: {
                    ZStack {
                        if premiumManager.purchaseState == .purchasing {
                            ProgressView().tint(.white)
                        } else {
                            HStack(spacing: 6) {
                                Text("Subscribe")
                                if let price = premiumManager.product?.displayPrice {
                                    Text("· \(price)/yr")
                                        .opacity(0.8)
                                }
                            }
                            .font(.custom("Outfit", size: 15.5).weight(.semibold))
                        }
                    }
                    .frame(maxWidth: .infinity, minHeight: 52)
                    .background(AnchoredColors.gradientPrimary)
                    .foregroundStyle(.white)
                    .clipShape(Capsule())
                    .shadow(color: AnchoredColors.coral.opacity(0.4), radius: 15, x: 0, y: 12)
                }
                .disabled(premiumManager.purchaseState == .purchasing || premiumManager.product == nil)

                VStack(spacing: 8) {
                    Button("Restore purchases") {
                        Task { await premiumManager.restorePurchases() }
                    }
                    .font(.custom("Outfit", size: 14.5).weight(.semibold))
                    .foregroundStyle(AnchoredColors.coral)

                    Button("Maybe later") { dismiss() }
                        .font(.custom("Outfit", size: 12).weight(.medium))
                        .foregroundStyle(AnchoredColors.inkSoft)
                }
            }
            .padding(24)
        }
        .presentationDetents([.medium, .large])
    }

    private func featureRow(_ text: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(AnchoredColors.coral)
            Text(text)
                .font(.custom("Outfit", size: 14.5).weight(.medium))
                .foregroundStyle(AnchoredColors.ink)
        }
    }
}

// MARK: - Preview

#Preview("Free user") {
    NavigationStack { TopicsView() }
        .environmentObject(AuthManager.preview)
        .environmentObject(PremiumManager.preview)
        .modelContainer(PreviewContainer.shared)
}

#Preview("Premium unlocked") {
    NavigationStack { TopicsView() }
        .environmentObject(AuthManager.preview)
        .environmentObject(PremiumManager.previewPremium)
        .modelContainer(PreviewContainer.shared)
}

#Preview("Paywall") {
    PaywallSheet()
        .environmentObject(PremiumManager.preview)
}
