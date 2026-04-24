//
//  TopicsView.swift
//  Anchored
//
//  The "Learn" tab. Vertical list of all 35 topics as gradient cards
//  with progress toward completion. Free topics are tappable; premium
//  topics show a lock and present the paywall when tapped.
//
//  ───── Layout notes ─────
//  • Each topic card uses the topic's own `TopicGradient` for the icon
//    tile — this gives the list visual variety without needing per-topic
//    asset catalogs.
//  • Progress is computed once per appear, from a single SwiftData fetch
//    over LessonProgress. No per-card query.
//  • Premium gating is a soft gate: tapping a locked topic flips the
//    paywall modal, it doesn't navigate. The navigation link is wrapped
//    in a Button when locked so we control the action.
//
//  ───── Navigation ─────
//  Two destinations are registered on this stack:
//    • Topic              → TopicDetailView (lesson list)
//    • LessonDestination  → LessonView      (teaching + quiz + results)
//  TopicDetailView pushes LessonDestination values internally.
//

import SwiftUI
import SwiftData

struct TopicsView: View {

    @EnvironmentObject private var premiumManager: PremiumManager

    /// Live query of every lesson progress row. Drives the progress
    /// rings on each topic card.
    @Query(sort: \LessonProgress.completedAt, order: .reverse)
    private var progressRows: [LessonProgress]

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 14) {
                ForEach(TopicsCatalog.all) { topic in
                    topicCard(for: topic)
                }
            }
            .padding(.top, 8)
            .padding(.bottom, 24)
            .screenPadding()
        }
        .background(AnchoredColors.parchment.ignoresSafeArea())
        .navigationTitle("Learn")
        .navigationBarTitleDisplayMode(.large)
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

    // MARK: - Cards

    @ViewBuilder
    private func topicCard(for topic: Topic) -> some View {
        let completed = completedCount(for: topic)
        let total = topic.lessons.count
        let isAccessible = topic.isFree || premiumManager.isPremium

        if isAccessible {
            NavigationLink(value: topic) {
                cardBody(topic: topic, completed: completed, total: total, locked: false)
            }
            .buttonStyle(.plain)
        } else {
            Button {
                premiumManager.presentPaywall()
            } label: {
                cardBody(topic: topic, completed: completed, total: total, locked: true)
            }
            .buttonStyle(.plain)
        }
    }

    /// The inner card layout, shared by both free and locked variants.
    private func cardBody(topic: Topic, completed: Int, total: Int, locked: Bool) -> some View {
        HStack(spacing: 14) {
            // Icon tile with the topic's gradient.
            ZStack {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(topic.gradient.linearGradient)
                Text(topic.icon)
                    .font(.system(size: 28))
            }
            .frame(width: 56, height: 56)
            .opacity(locked ? 0.55 : 1.0)

            VStack(alignment: .leading, spacing: 4) {
                Text(topic.title)
                    .anchoredStyle(.h3)
                    .foregroundStyle(AnchoredColors.navy)
                Text(topic.description)
                    .anchoredStyle(.caption)
                    .foregroundStyle(AnchoredColors.muted)
                    .lineLimit(2)

                // Progress line — hidden when locked to reduce clutter
                // (locked topics can't have any progress anyway).
                if !locked {
                    progressLine(completed: completed, total: total)
                        .padding(.top, 4)
                }
            }

            Spacer(minLength: 0)

            // Lock icon for premium-gated topics, chevron otherwise.
            Image(systemName: locked ? "lock.fill" : "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(locked ? AnchoredColors.amber : AnchoredColors.muted)
        }
        .cardSurface(padding: 14)
    }

    private func progressLine(completed: Int, total: Int) -> some View {
        HStack(spacing: 8) {
            // A thin progress bar with the lesson count beside it.
            ProgressView(value: Double(completed), total: Double(max(total, 1)))
                .progressViewStyle(.linear)
                .tint(AnchoredColors.amber)
                .frame(maxWidth: 120)
            Text("\(completed) / \(total)")
                .anchoredStyle(.caption)
                .foregroundStyle(AnchoredColors.muted)
        }
    }

    // MARK: - Progress aggregation

    /// Count of completed lessons within a topic. O(n) per topic but
    /// n is small (≤176 total rows even if the user completes everything).
    private func completedCount(for topic: Topic) -> Int {
        let completedIDs = Set(progressRows.filter(\.completed).map(\.lessonId))
        return topic.lessons.reduce(0) { count, lesson in
            count + (completedIDs.contains(lesson.id) ? 1 : 0)
        }
    }
}

// MARK: - Paywall placeholder

/// "Coming Soon" modal. StoreKit 2 products wire up in a later pass —
/// this sheet is what the PRD's IAP stub gate presents today.
struct PaywallSheet: View {
    @EnvironmentObject private var premiumManager: PremiumManager
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            AnchoredColors.parchment.ignoresSafeArea()

            VStack(spacing: 24) {
                // Header
                VStack(spacing: 12) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 44))
                        .foregroundStyle(AnchoredColors.amber)

                    Text("Anchored Premium")
                        .anchoredStyle(.h1)
                        .foregroundStyle(AnchoredColors.navy)

                    Text("Unlock all 35 topics, 176 lessons, every translation, and the Verse Recommender.")
                        .anchoredStyle(.body)
                        .foregroundStyle(AnchoredColors.muted)
                        .multilineTextAlignment(.center)
                }

                // Feature list
                VStack(alignment: .leading, spacing: 12) {
                    featureRow("34 premium topics")
                    featureRow("5 Bible translations")
                    featureRow("Verse Recommender")
                    featureRow("All future content")
                }
                .padding(.vertical, 4)

                // Error message
                if case .failed(let message) = premiumManager.purchaseState {
                    Text(message)
                        .anchoredStyle(.caption)
                        .foregroundStyle(AnchoredColors.error)
                        .multilineTextAlignment(.center)
                }

                // Purchase button
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
                            .anchoredStyle(.bodyMd)
                        }
                    }
                    .frame(maxWidth: .infinity, minHeight: 52)
                    .background(AnchoredColors.navy)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
                .disabled(premiumManager.purchaseState == .purchasing || premiumManager.product == nil)

                // Secondary actions
                VStack(spacing: 8) {
                    Button("Restore purchases") {
                        Task { await premiumManager.restorePurchases() }
                    }
                    .foregroundStyle(AnchoredColors.amber)
                    .anchoredStyle(.bodyMd)

                    Button("Maybe later") { dismiss() }
                        .foregroundStyle(AnchoredColors.muted)
                        .anchoredStyle(.caption)
                }
            }
            .padding(24)
        }
        .presentationDetents([.medium, .large])
    }

    private func featureRow(_ text: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(AnchoredColors.amber)
            Text(text)
                .anchoredStyle(.body)
                .foregroundStyle(AnchoredColors.navy)
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
