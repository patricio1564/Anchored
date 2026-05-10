import SwiftUI
import SwiftData

// MARK: - BiblePassageView

struct BiblePassageView: View {
    @State private var currentRef: BiblePassageRef

    init(ref: BiblePassageRef) {
        _currentRef = State(initialValue: ref)
    }

    @EnvironmentObject private var premiumManager: PremiumManager
    @Environment(\.modelContext) private var modelContext

    @AppStorage("lastBibleApiReference") private var lastBibleApiReference: String = ""
    @AppStorage("preferredBibleTranslation") private var translation: BibleTranslation = .web

    @Query private var savedVerses: [SavedVerse]

    @State private var passage: BiblePassage?
    @State private var errorMessage: String?
    @State private var isLoading = false
    @State private var selectedVerses: Set<BibleVerse> = []
    @State private var noteVerses: [BibleVerse] = []
    @State private var showSavedToast = false
    @State private var showColorPicker = false

    // MARK: - Highlight map for this chapter

    private var highlightMap: [String: HighlightColor] {
        var map: [String: HighlightColor] = [:]
        let prefix = "\(currentRef.book) \(currentRef.chapter):"
        for sv in savedVerses {
            guard sv.reference.hasPrefix(prefix),
                  let colorStr = sv.highlightColor,
                  let color = HighlightColor(rawValue: colorStr) else { continue }
            let refPart = String(sv.reference.dropFirst(prefix.count))
            let parts = refPart.split(separator: "-").compactMap { Int($0) }
            let start = parts.first ?? 0
            let end = parts.last ?? start
            guard start > 0 else { continue }
            for v in start...end { map["\(prefix)\(v)"] = color }
        }
        return map
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                translationPicker
                content
                // Chapter navigation arrows at bottom of content
                if passage != nil {
                    chapterNavBar
                }
                Spacer(minLength: MainTabView.tabBarHeight + 10)
            }
            .padding(.top, 8)
            .screenPadding()
        }
        .safeAreaInset(edge: .bottom) {
            if !selectedVerses.isEmpty {
                selectionBar
                    .padding(.bottom, MainTabView.tabBarHeight)
            }
        }
        .background(AnchoredColors.parchment.ignoresSafeArea())
        .navigationTitle(currentRef.apiReference)
        .navigationBarTitleDisplayMode(.inline)
        .task(id: currentRef.apiReference + translation.rawValue) { await loadPassage() }
        .sheet(isPresented: $premiumManager.isShowingPaywall) { PaywallSheet() }
        .sheet(isPresented: Binding(
            get: { !noteVerses.isEmpty },
            set: { if !$0 { noteVerses = [] } }
        )) {
            NoteComposeSheet(verses: noteVerses) { body in saveNote(for: noteVerses, body: body) }
        }
        .overlay(alignment: .bottom) {
            if showSavedToast { toast }
        }
    }

    // MARK: - Chapter navigation bar

    private var chapterNavBar: some View {
        HStack {
            if let prev = BibleCatalog.previous(before: currentRef) {
                Button {
                    navigateTo(prev)
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 13, weight: .semibold))
                        Text(prev.apiReference)
                            .anchoredStyle(.caption)
                            .lineLimit(1)
                    }
                    .foregroundStyle(AnchoredColors.amber)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(AnchoredColors.card)
                    .clipShape(Capsule())
                    .overlay(Capsule().stroke(AnchoredColors.border, lineWidth: 1))
                }
                .buttonStyle(.plain)
            }
            Spacer()
            if let next = BibleCatalog.next(after: currentRef) {
                Button {
                    navigateTo(next)
                } label: {
                    HStack(spacing: 6) {
                        Text(next.apiReference)
                            .anchoredStyle(.caption)
                            .lineLimit(1)
                        Image(systemName: "chevron.right")
                            .font(.system(size: 13, weight: .semibold))
                    }
                    .foregroundStyle(AnchoredColors.amber)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(AnchoredColors.card)
                    .clipShape(Capsule())
                    .overlay(Capsule().stroke(AnchoredColors.border, lineWidth: 1))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.top, 8)
    }

    private func navigateTo(_ ref: BiblePassageRef) {
        withAnimation(.easeInOut(duration: 0.2)) {
            passage = nil
            selectedVerses.removeAll()
            showColorPicker = false
            currentRef = ref
        }
    }

    // MARK: - Selection action bar

    private var selectionBar: some View {
        VStack(spacing: 0) {
            if showColorPicker {
                colorPickerRow
                Divider()
            }
            HStack(spacing: 12) {
                Text("\(selectedVerses.count) verse\(selectedVerses.count == 1 ? "" : "s")")
                    .anchoredStyle(.bodyMd)
                    .foregroundStyle(AnchoredColors.navy)
                Spacer()
                Button(showColorPicker ? "Cancel" : "Highlight & Save") {
                    withAnimation(.easeInOut(duration: 0.2)) { showColorPicker.toggle() }
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(AnchoredColors.amber)
                .foregroundStyle(.white)
                .clipShape(Capsule())
                if !showColorPicker {
                    Button("Add Note") { openNoteForSelection() }
                        .buttonStyle(.plain)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(AnchoredColors.card)
                        .foregroundStyle(AnchoredColors.navy)
                        .clipShape(Capsule())
                        .overlay(Capsule().stroke(AnchoredColors.border, lineWidth: 1))
                }
                Button {
                    showColorPicker = false
                    selectedVerses.removeAll()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(AnchoredColors.muted)
                        .font(.system(size: 20))
                }
                .buttonStyle(.plain)
            }
            .screenPadding()
            .padding(.vertical, 12)
        }
        .background(.ultraThinMaterial)
        .animation(.easeInOut(duration: 0.2), value: showColorPicker)
    }

    private var colorPickerRow: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Choose a highlight color (or save without one)")
                .anchoredStyle(.caption)
                .foregroundStyle(AnchoredColors.muted)
            HStack(spacing: 14) {
                ForEach(HighlightColor.allCases) { hc in
                    Button {
                        saveSelectedVerses(highlightColor: hc.rawValue)
                        withAnimation { showColorPicker = false }
                    } label: {
                        Circle()
                            .fill(hc.color)
                            .frame(width: 32, height: 32)
                            .overlay(Circle().stroke(Color.white, lineWidth: 2))
                            .shadow(color: hc.color.opacity(0.4), radius: 3, x: 0, y: 1)
                    }
                    .buttonStyle(.plain)
                }
                // Save without highlight
                Button {
                    saveSelectedVerses(highlightColor: nil)
                    withAnimation { showColorPicker = false }
                } label: {
                    ZStack {
                        Circle()
                            .fill(AnchoredColors.card)
                            .frame(width: 32, height: 32)
                            .overlay(Circle().stroke(AnchoredColors.border, lineWidth: 1.5))
                        Image(systemName: "bookmark.fill")
                            .font(.system(size: 11))
                            .foregroundStyle(AnchoredColors.muted)
                    }
                }
                .buttonStyle(.plain)
            }
        }
        .screenPadding()
        .padding(.vertical, 10)
    }

    // MARK: - Translation picker

    private var translationPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(BibleTranslation.allCases) { option in
                    translationChip(option)
                }
            }
        }
    }

    private func translationChip(_ option: BibleTranslation) -> some View {
        let isSelected = translation == option
        let isLocked = !option.isFree && !premiumManager.isPremium

        return Button {
            if isLocked {
                premiumManager.presentPaywall()
            } else {
                translation = option
            }
        } label: {
            HStack(spacing: 4) {
                if isLocked {
                    Image(systemName: "lock.fill").font(.system(size: 10))
                }
                Text(option.shortLabel).anchoredStyle(.label)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isSelected ? AnchoredColors.navy : AnchoredColors.card)
            .foregroundStyle(isSelected ? .white : AnchoredColors.navy)
            .clipShape(Capsule())
            .overlay(Capsule().stroke(AnchoredColors.border, lineWidth: isSelected ? 0 : 1))
        }
        .buttonStyle(.plain)
    }

    // MARK: - Content states

    @ViewBuilder
    private var content: some View {
        if isLoading {
            loadingState
        } else if let errorMessage {
            errorState(errorMessage)
        } else if let passage {
            passageView(passage)
        }
    }

    private var loadingState: some View {
        VStack(spacing: 10) {
            ProgressView()
            Text("Looking up passage…")
                .anchoredStyle(.caption)
                .foregroundStyle(AnchoredColors.muted)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 40)
    }

    private func errorState(_ message: String) -> some View {
        VStack(spacing: 10) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 32))
                .foregroundStyle(AnchoredColors.error)
            Text(message)
                .anchoredStyle(.body)
                .foregroundStyle(AnchoredColors.navy)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 40)
    }

    private func passageView(_ passage: BiblePassage) -> some View {
        let map = highlightMap
        return VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text(passage.reference)
                    .anchoredStyle(.h2)
                    .foregroundStyle(AnchoredColors.navy)
                Spacer()
                Text(passage.translationID.uppercased())
                    .anchoredStyle(.label)
                    .foregroundStyle(AnchoredColors.amber)
            }

            VStack(alignment: .leading, spacing: 12) {
                ForEach(passage.verses, id: \.self) { verse in
                    let key = "\(verse.bookName) \(verse.chapter):\(verse.verse)"
                    let savedHighlight = map[key]
                    let isSelected = selectedVerses.contains(verse)
                    Button {
                        if isSelected {
                            selectedVerses.remove(verse)
                        } else {
                            selectedVerses.insert(verse)
                        }
                    } label: {
                        verseRow(verse, isSelected: isSelected, savedHighlight: savedHighlight)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.white)
        )
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    private func verseRow(_ verse: BibleVerse, isSelected: Bool, savedHighlight: HighlightColor?) -> some View {
        let bgColor: Color = {
            if isSelected { return AnchoredColors.amber.opacity(0.15) }
            if let h = savedHighlight { return h.color.opacity(0.18) }
            return Color.clear
        }()
        let accentColor: Color? = isSelected ? AnchoredColors.amber : savedHighlight?.color

        return HStack(alignment: .firstTextBaseline, spacing: 10) {
            Text("\(verse.verse)")
                .anchoredStyle(.label)
                .foregroundStyle(accentColor ?? AnchoredColors.amber)
                .frame(minWidth: 20, alignment: .trailing)
            Text(verse.text.trimmingCharacters(in: .whitespacesAndNewlines))
                .anchoredStyle(.scripture)
                .foregroundStyle(AnchoredColors.navy)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(8)
        .background(bgColor)
        .overlay(alignment: .leading) {
            if let accent = accentColor {
                Rectangle()
                    .fill(accent)
                    .frame(width: 3)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
        .animation(.easeInOut(duration: 0.15), value: isSelected)
    }

    private var toast: some View {
        Text("Saved")
            .anchoredStyle(.bodyMd)
            .foregroundStyle(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(AnchoredColors.navy)
            .clipShape(Capsule())
            .padding(.bottom, 32)
            .transition(.opacity.combined(with: .move(edge: .bottom)))
    }

    // MARK: - Actions

    private func loadPassage() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let result = try await BibleAPIService.shared.fetch(
                reference: currentRef.apiReference,
                translation: translation
            )
            passage = result
            lastBibleApiReference = currentRef.apiReference
        } catch let apiError as BibleAPIError {
            passage = nil
            errorMessage = apiError.errorDescription
        } catch {
            passage = nil
            errorMessage = "Something went wrong. Please try again."
        }
    }

    private func saveSelectedVerses(highlightColor: String? = nil) {
        let sorted = selectedVerses.sorted { $0.verse < $1.verse }
        guard let first = sorted.first, let last = sorted.last else { return }
        let reference = sorted.count == 1
            ? "\(first.bookName) \(first.chapter):\(first.verse)"
            : "\(first.bookName) \(first.chapter):\(first.verse)-\(last.verse)"
        let combinedText = sorted
            .map { $0.text.trimmingCharacters(in: .whitespacesAndNewlines) }
            .joined(separator: "\n")
        let saved = SavedVerse(reference: reference, text: combinedText, translation: translation.rawValue, highlightColor: highlightColor)
        modelContext.insert(saved)
        try? modelContext.save()
        selectedVerses.removeAll()
        fireToast()
    }

    private func openNoteForSelection() {
        noteVerses = selectedVerses.sorted { $0.verse < $1.verse }
        selectedVerses.removeAll()
    }

    private func saveNote(for verses: [BibleVerse], body: String) {
        guard let first = verses.first,
              !body.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        let combinedText = verses
            .map { $0.text.trimmingCharacters(in: .whitespacesAndNewlines) }
            .joined(separator: "\n")
        let note = BibleNote(
            book: first.bookName,
            chapter: first.chapter,
            verse: first.verse,
            verseText: combinedText,
            note: body
        )
        modelContext.insert(note)
        try? modelContext.save()
        fireToast()
    }

    private func fireToast() {
        withAnimation { showSavedToast = true }
        Task {
            try? await Task.sleep(for: .seconds(1.5))
            await MainActor.run { withAnimation { showSavedToast = false } }
        }
    }
}

// MARK: - NoteComposeSheet

struct NoteComposeSheet: View {
    let verses: [BibleVerse]
    let onSave: (String) -> Void

    @State private var noteText: String = ""
    @Environment(\.dismiss) private var dismiss

    private var combinedReference: String {
        guard let first = verses.first, let last = verses.last else { return "" }
        return verses.count == 1
            ? "\(first.bookName) \(first.chapter):\(first.verse)"
            : "\(first.bookName) \(first.chapter):\(first.verse)-\(last.verse)"
    }

    private var combinedText: String {
        verses.map { $0.text.trimmingCharacters(in: .whitespacesAndNewlines) }.joined(separator: "\n")
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AnchoredColors.parchment.ignoresSafeArea()

                VStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(combinedReference)
                            .anchoredStyle(.reference)
                            .foregroundStyle(AnchoredColors.amber)
                        Text(combinedText)
                            .anchoredStyle(.scripture)
                            .foregroundStyle(AnchoredColors.navy)
                    }
                    .amberCard()

                    TextEditor(text: $noteText)
                        .scrollContentBackground(.hidden)
                        .background(AnchoredColors.card)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .stroke(AnchoredColors.border, lineWidth: 1)
                        )
                        .frame(minHeight: 180)
                        .overlay(alignment: .topLeading) {
                            if noteText.isEmpty {
                                Text("What does this verse mean to you?")
                                    .anchoredStyle(.body)
                                    .foregroundStyle(AnchoredColors.muted)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 14)
                                    .allowsHitTesting(false)
                            }
                        }

                    Spacer()
                }
                .screenPadding()
                .padding(.top, 12)
            }
            .navigationTitle("Add Note")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { onSave(noteText); dismiss() }
                        .disabled(noteText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    let ref = BiblePassageRef(apiReference: "John 3", book: "John", chapter: 3)
    return NavigationStack {
        BiblePassageView(ref: ref)
    }
    .environmentObject(AuthManager.preview)
    .environmentObject(PremiumManager.preview)
    .modelContainer(PreviewContainer.shared)
}
