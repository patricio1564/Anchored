// ────────────────────────────────────────────────────────────────────────────
// VerseRecommenderSheet.swift
//
// Modal sheet where users type how they're feeling and receive curated
// Bible verse recommendations. Uses VerseRecommenderService (Foundation
// Models on iOS 26+ with FeelingMap fallback — see that file for details).
//
// UX:
//  • 8 preset feeling chips for quick access (FeelingMap categories)
//  • Free-text field for anything not in the presets
//  • Loading state while the service runs
//  • Results: compassionate summary, then verse cards each with reference,
//    text, explanation, and a collapsible first-person prayer
//  • Each verse can be saved directly from the result to SavedVerses
// ────────────────────────────────────────────────────────────────────────────

import SwiftUI
import SwiftData

struct VerseRecommenderSheet: View {

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    // MARK: - State

    @State private var inputText: String = ""
    @State private var selectedFeeling: Feeling?
    @State private var phase: Phase = .idle

    enum Phase {
        case idle
        case loading
        case results(VerseRecommendation)
        case error(String)
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ZStack {
                AnchoredColors.parchment.ignoresSafeArea()
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        switch phase {
                        case .idle:
                            idleContent
                        case .loading:
                            loadingContent
                        case .results(let recommendation):
                            resultsContent(recommendation)
                        case .error(let message):
                            errorContent(message)
                        }
                        Spacer(minLength: 40)
                    }
                    .padding(.top, 8)
                    .screenPadding()
                }
            }
            .navigationTitle("Find Verses")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
                if case .results = phase {
                    ToolbarItem(placement: .primaryAction) {
                        Button("Start over") {
                            withAnimation { phase = .idle; inputText = ""; selectedFeeling = nil }
                        }
                        .foregroundStyle(AnchoredColors.amber)
                    }
                }
            }
        }
    }

    // MARK: - Idle / Input

    private var idleContent: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 6) {
                Text("What's on your heart?")
                    .anchoredStyle(.h2)
                    .foregroundStyle(AnchoredColors.navy)
                Text("Share how you're feeling and we'll find scripture that speaks to you.")
                    .anchoredStyle(.body)
                    .foregroundStyle(AnchoredColors.muted)
            }

            feelingChips

            textInput

            findButton
        }
    }

    private var feelingChips: some View {
        LazyVGrid(
            columns: [GridItem(.flexible()), GridItem(.flexible())],
            spacing: 10
        ) {
            ForEach(Feeling.allCases, id: \.self) { feeling in
                feelingChip(feeling)
            }
        }
    }

    private func feelingChip(_ feeling: Feeling) -> some View {
        let isSelected = selectedFeeling == feeling
        return Button {
            if isSelected {
                selectedFeeling = nil
                inputText = ""
            } else {
                selectedFeeling = feeling
                inputText = feeling.chipLabel
            }
        } label: {
            Text(feeling.shortLabel)
                .anchoredStyle(.bodyMd)
                .foregroundStyle(isSelected ? .white : AnchoredColors.navy)
                .frame(maxWidth: .infinity, minHeight: 44)
                .background(isSelected ? AnchoredColors.navy : AnchoredColors.card)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(isSelected ? Color.clear : AnchoredColors.border, lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }

    private var textInput: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Or describe in your own words")
                .anchoredStyle(.label)
                .foregroundStyle(AnchoredColors.muted)

            TextEditor(text: $inputText)
                .scrollContentBackground(.hidden)
                .background(AnchoredColors.card)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(AnchoredColors.border, lineWidth: 1)
                )
                .frame(minHeight: 100)
                .onChange(of: inputText) { _, _ in
                    // Deselect preset chip if user edits text manually
                    if let f = selectedFeeling, inputText != f.chipLabel {
                        selectedFeeling = nil
                    }
                }
                .overlay(alignment: .topLeading) {
                    if inputText.isEmpty {
                        Text("e.g. \"I'm anxious about a big decision…\"")
                            .anchoredStyle(.body)
                            .foregroundStyle(AnchoredColors.muted)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 14)
                            .allowsHitTesting(false)
                    }
                }
        }
    }

    private var findButton: some View {
        Button {
            Task { await findVerses() }
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "sparkles")
                Text("Find verses")
                    .anchoredStyle(.bodyMd)
            }
            .frame(maxWidth: .infinity, minHeight: 52)
            .background(inputText.trimmingCharacters(in: .whitespacesAndNewlines).count >= 3
                        ? AnchoredColors.navy : AnchoredColors.border)
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
        .buttonStyle(.plain)
        .disabled(inputText.trimmingCharacters(in: .whitespacesAndNewlines).count < 3)
    }

    // MARK: - Loading

    private var loadingContent: some View {
        VStack(spacing: 20) {
            Spacer(minLength: 60)
            ProgressView()
                .scaleEffect(1.4)
            Text("Finding scripture for you…")
                .anchoredStyle(.body)
                .foregroundStyle(AnchoredColors.muted)
            Spacer(minLength: 60)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Results

    private func resultsContent(_ recommendation: VerseRecommendation) -> some View {
        VStack(alignment: .leading, spacing: 20) {
            // Summary card
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 6) {
                    Image(systemName: "sparkles")
                        .foregroundStyle(AnchoredColors.amber)
                    Text("For you")
                        .anchoredStyle(.label)
                        .foregroundStyle(AnchoredColors.amber)
                }
                Text(recommendation.summary)
                    .anchoredStyle(.body)
                    .foregroundStyle(AnchoredColors.navy)
            }
            .amberCard()

            // Verse cards
            ForEach(recommendation.verses, id: \.reference) { verse in
                VerseResultCard(verse: verse, onSave: { saveVerse(verse) }, onSavePrayer: { savePrayer(verse) })
            }

            // Closing encouragement
            if !recommendation.closingEncouragement.isEmpty {
                Text(recommendation.closingEncouragement)
                    .anchoredStyle(.body)
                    .foregroundStyle(AnchoredColors.muted)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 8)
            }
        }
    }

    // MARK: - Error

    private func errorContent(_ message: String) -> some View {
        VStack(spacing: 16) {
            Spacer(minLength: 40)
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 36))
                .foregroundStyle(AnchoredColors.error)
            Text(message)
                .anchoredStyle(.body)
                .foregroundStyle(AnchoredColors.navy)
                .multilineTextAlignment(.center)
            Button("Try again") {
                withAnimation { phase = .idle }
            }
            .foregroundStyle(AnchoredColors.amber)
            Spacer(minLength: 40)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Actions

    private func findVerses() async {
        let query = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard query.count >= 3 else { return }
        withAnimation { phase = .loading }
        let result = await VerseRecommenderService.shared.recommend(for: query)
        withAnimation { phase = .results(result) }
    }

    private func saveVerse(_ verse: RecommendedVerse) {
        let saved = SavedVerse(
            reference: verse.reference,
            text: verse.text,
            translation: "WEB"
        )
        modelContext.insert(saved)
        try? modelContext.save()
    }

    private func savePrayer(_ verse: RecommendedVerse) {
        let prayer = Prayer(
            title: "\(verse.reference) — Prayer",
            content: verse.prayer,
            linkedVerse: verse.reference
        )
        modelContext.insert(prayer)
        try? modelContext.save()
    }
}

// MARK: - Feeling short label (for chip display)

private extension Feeling {
    var shortLabel: String {
        switch self {
        case .anxiety:     return "Anxious"
        case .grief:       return "Grieving"
        case .loneliness:  return "Lonely"
        case .forgiveness: return "Forgiveness"
        case .doubt:       return "Doubt"
        case .overwhelm:   return "Overwhelmed"
        case .gratitude:   return "Grateful"
        case .guidance:    return "Need guidance"
        }
    }
}

// MARK: - Verse result card

private struct VerseResultCard: View {
    let verse: RecommendedVerse
    let onSave: () -> Void
    let onSavePrayer: () -> Void

    @State private var showPrayer = false
    @State private var saved = false
    @State private var prayerSaved = false

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Reference + save button
            HStack(alignment: .top) {
                Text(verse.reference)
                    .anchoredStyle(.reference)
                    .foregroundStyle(AnchoredColors.amber)
                Spacer()
                Button {
                    guard !saved else { return }
                    onSave()
                    withAnimation { saved = true }
                } label: {
                    Image(systemName: saved ? "bookmark.fill" : "bookmark")
                        .foregroundStyle(saved ? AnchoredColors.amber : AnchoredColors.muted)
                        .font(.system(size: 18))
                }
                .buttonStyle(.plain)
            }

            // Verse text
            Text(verse.text)
                .anchoredStyle(.scripture)
                .foregroundStyle(AnchoredColors.navy)

            // Explanation
            Text(verse.explanation)
                .anchoredStyle(.body)
                .foregroundStyle(AnchoredColors.navy.opacity(0.8))

            // Collapsible prayer
            HStack(spacing: 0) {
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) { showPrayer.toggle() }
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "hands.sparkles")
                            .font(.system(size: 13))
                        Text(showPrayer ? "Hide prayer" : "Pray this verse")
                            .anchoredStyle(.label)
                        Spacer()
                        Image(systemName: showPrayer ? "chevron.up" : "chevron.down")
                            .font(.system(size: 11))
                    }
                    .foregroundStyle(AnchoredColors.amber)
                }
                .buttonStyle(.plain)

                Button {
                    guard !prayerSaved else { return }
                    onSavePrayer()
                    withAnimation { prayerSaved = true }
                } label: {
                    Image(systemName: prayerSaved ? "bookmark.fill" : "bookmark")
                        .foregroundStyle(prayerSaved ? AnchoredColors.amber : AnchoredColors.muted)
                        .font(.system(size: 15))
                }
                .buttonStyle(.plain)
                .padding(.leading, 12)
            }

            if showPrayer {
                Text(verse.prayer)
                    .anchoredStyle(.body)
                    .foregroundStyle(AnchoredColors.navy.opacity(0.8))
                    .padding(.top, 4)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .cardSurface(padding: 16)
    }
}

// MARK: - Preview

#Preview {
    VerseRecommenderSheet()
        .modelContainer(PreviewContainer.shared)
}
