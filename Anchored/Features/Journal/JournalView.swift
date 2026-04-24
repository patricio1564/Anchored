//
//  JournalView.swift
//  Anchored
//
//  The "Journal" tab. Two segments:
//  - Scripture: merged list of SavedVerses (with optional notes/highlights)
//    and BibleNotes created from the Bible reading flow, sorted by date.
//  - Prayers: Prayer entries, composable from scratch here.
//

import SwiftUI
import SwiftData

struct JournalView: View {

    enum Segment: String, CaseIterable, Identifiable {
        case scripture = "Scripture"
        case prayers = "Prayers"
        var id: String { rawValue }
    }

    @State private var segment: Segment = .scripture

    @Query(sort: \BibleNote.updatedAt, order: .reverse)  private var notes: [BibleNote]
    @Query(sort: \Prayer.updatedAt, order: .reverse)      private var prayers: [Prayer]
    @Query(sort: \SavedVerse.savedAt, order: .reverse)    private var verses: [SavedVerse]

    @Environment(\.modelContext) private var modelContext

    @State private var isComposingPrayer = false
    @State private var selectedVerse: SavedVerse?

    // Unified scripture item — merges SavedVerse and BibleNote sorted by date.
    private enum ScriptureItem: Identifiable {
        case verse(SavedVerse)
        case note(BibleNote)

        var id: String {
            switch self {
            case .verse(let v): return "v-\(v.reference)-\(v.savedAt.timeIntervalSince1970)"
            case .note(let n):  return "n-\(n.book)\(n.chapter)\(n.verse)-\(n.createdAt.timeIntervalSince1970)"
            }
        }

        var date: Date {
            switch self {
            case .verse(let v): return v.savedAt
            case .note(let n):  return n.updatedAt
            }
        }
    }

    private var scriptureItems: [ScriptureItem] {
        let verseItems = verses.map { ScriptureItem.verse($0) }
        let noteItems = notes.map { ScriptureItem.note($0) }
        return (verseItems + noteItems).sorted { $0.date > $1.date }
    }

    var body: some View {
        VStack(spacing: 0) {
            Picker("Segment", selection: $segment) {
                ForEach(Segment.allCases) { s in
                    Text(s.rawValue).tag(s)
                }
            }
            .pickerStyle(.segmented)
            .screenPadding()
            .padding(.top, 8)
            .padding(.bottom, 12)

            content
        }
        .background(AnchoredColors.parchment.ignoresSafeArea())
        .navigationTitle("Journal")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            if segment == .prayers {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        isComposingPrayer = true
                    } label: {
                        Image(systemName: "square.and.pencil")
                    }
                    .accessibilityLabel("New prayer")
                }
            }
        }
        .sheet(isPresented: $isComposingPrayer) {
            PrayerComposeSheet { title, body, verse in
                savePrayer(title: title, body: body, linkedVerse: verse)
            }
        }
        .sheet(item: $selectedVerse) { verse in
            SavedVerseDetailSheet(verse: verse)
        }
    }

    // MARK: - Segmented content

    @ViewBuilder
    private var content: some View {
        switch segment {
        case .scripture: scriptureList
        case .prayers:   prayersList
        }
    }

    private var scriptureList: some View {
        Group {
            if scriptureItems.isEmpty {
                emptyState(
                    icon: "book.closed.fill",
                    title: "No scripture yet",
                    message: "Tap verses in the Bible tab to save them here."
                )
            } else {
                ScrollView {
                    LazyVStack(spacing: 10) {
                        ForEach(scriptureItems) { item in
                            switch item {
                            case .verse(let v):
                                Button { selectedVerse = v } label: {
                                    savedVerseCard(v)
                                }
                                .buttonStyle(.plain)
                            case .note(let n):
                                noteCard(n)
                            }
                        }
                    }
                    .padding(.top, 4)
                    .padding(.bottom, 24)
                    .screenPadding()
                }
            }
        }
    }

    private var prayersList: some View {
        Group {
            if prayers.isEmpty {
                emptyState(
                    icon: "hands.and.sparkles.fill",
                    title: "Your prayer journal is empty",
                    message: "Tap the compose button to write your first prayer."
                )
            } else {
                ScrollView {
                    LazyVStack(spacing: 10) {
                        ForEach(prayers) { prayer in
                            prayerCard(prayer)
                        }
                    }
                    .padding(.top, 4)
                    .padding(.bottom, 24)
                    .screenPadding()
                }
            }
        }
    }

    // MARK: - Cards

    private func savedVerseCard(_ verse: SavedVerse) -> some View {
        let highlight = verse.highlightColor.flatMap { HighlightColor(rawValue: $0) }
        return VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(verse.reference)
                    .anchoredStyle(.reference)
                    .foregroundStyle(AnchoredColors.amber)
                Spacer()
                Text(verse.translation.uppercased())
                    .anchoredStyle(.label)
                    .foregroundStyle(AnchoredColors.muted)
            }
            Text(verse.text)
                .anchoredStyle(.scripture)
                .foregroundStyle(AnchoredColors.navy)
            if let note = verse.note, !note.isEmpty {
                Text(note)
                    .anchoredStyle(.body)
                    .foregroundStyle(AnchoredColors.navy.opacity(0.75))
                    .italic()
                    .lineLimit(2)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(
            highlight.map { $0.color.opacity(0.12) } ?? AnchoredColors.card
        )
        .overlay(alignment: .leading) {
            if let highlight {
                Rectangle()
                    .fill(highlight.color)
                    .frame(width: 4)
                    .clipShape(RoundedRectangle(cornerRadius: 2))
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(highlight.map { $0.color.opacity(0.3) } ?? AnchoredColors.border, lineWidth: 1)
        )
        .contextMenu {
            Button(role: .destructive) {
                delete(verse)
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }

    private func noteCard(_ note: BibleNote) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(note.reference)
                    .anchoredStyle(.reference)
                    .foregroundStyle(AnchoredColors.amber)
                Spacer()
                Text(note.updatedAt.formatted(date: .abbreviated, time: .omitted))
                    .anchoredStyle(.caption)
                    .foregroundStyle(AnchoredColors.muted)
            }
            Text(note.verseText)
                .anchoredStyle(.scripture)
                .foregroundStyle(AnchoredColors.navy.opacity(0.85))
                .lineLimit(2)
            Text(note.note)
                .anchoredStyle(.body)
                .foregroundStyle(AnchoredColors.navy)
                .lineLimit(3)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardSurface()
        .contextMenu {
            Button(role: .destructive) {
                delete(note)
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }

    private func prayerCard(_ prayer: Prayer) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                statusChip(for: prayer.status)
                Spacer()
                Text(prayer.updatedAt.formatted(date: .abbreviated, time: .omitted))
                    .anchoredStyle(.caption)
                    .foregroundStyle(AnchoredColors.muted)
            }
            Text(prayer.title)
                .anchoredStyle(.h3)
                .foregroundStyle(AnchoredColors.navy)
            Text(prayer.content)
                .anchoredStyle(.body)
                .foregroundStyle(AnchoredColors.navy.opacity(0.85))
                .lineLimit(3)
            if let linked = prayer.linkedVerse, !linked.isEmpty {
                Text("— \(linked)")
                    .anchoredStyle(.reference)
                    .foregroundStyle(AnchoredColors.amber)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardSurface()
        .contextMenu {
            if prayer.status == .active {
                Button {
                    markAnswered(prayer)
                } label: {
                    Label("Mark answered", systemImage: "checkmark.circle")
                }
            }
            Button(role: .destructive) {
                delete(prayer)
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }

    private func statusChip(for status: PrayerStatus) -> some View {
        let color: Color = switch status {
        case .active:   AnchoredColors.amber
        case .answered: AnchoredColors.success
        case .archived: AnchoredColors.muted
        }
        return Text(status.displayName)
            .anchoredStyle(.label)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(color.opacity(0.15))
            .foregroundStyle(color)
            .clipShape(Capsule())
    }

    // MARK: - Empty state

    private func emptyState(icon: String, title: String, message: String) -> some View {
        VStack(spacing: 12) {
            Spacer()
            Image(systemName: icon)
                .font(.system(size: 44))
                .foregroundStyle(AnchoredColors.amber)
            Text(title)
                .anchoredStyle(.h2)
                .foregroundStyle(AnchoredColors.navy)
            Text(message)
                .anchoredStyle(.body)
                .foregroundStyle(AnchoredColors.muted)
                .multilineTextAlignment(.center)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .screenPadding()
    }

    // MARK: - Mutations

    private func savePrayer(title: String, body: String, linkedVerse: String?) {
        let prayer = Prayer(
            title: title,
            content: body,
            linkedVerse: linkedVerse?.isEmpty == false ? linkedVerse : nil
        )
        modelContext.insert(prayer)
        try? modelContext.save()
    }

    private func markAnswered(_ prayer: Prayer) {
        prayer.status = .answered
        prayer.updatedAt = .now
        try? modelContext.save()
    }

    private func delete(_ note: BibleNote) {
        modelContext.delete(note)
        try? modelContext.save()
    }

    private func delete(_ prayer: Prayer) {
        modelContext.delete(prayer)
        try? modelContext.save()
    }

    private func delete(_ verse: SavedVerse) {
        modelContext.delete(verse)
        try? modelContext.save()
    }
}

// MARK: - Saved Verse Detail Sheet

private struct SavedVerseDetailSheet: View {
    let verse: SavedVerse

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var noteText: String
    @State private var selectedColor: HighlightColor?

    init(verse: SavedVerse) {
        self.verse = verse
        _noteText = State(initialValue: verse.note ?? "")
        _selectedColor = State(initialValue: verse.highlightColor.flatMap { HighlightColor(rawValue: $0) })
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AnchoredColors.parchment.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Verse card
                        VStack(alignment: .leading, spacing: 6) {
                            Text(verse.reference)
                                .anchoredStyle(.reference)
                                .foregroundStyle(AnchoredColors.amber)
                            Text(verse.text)
                                .anchoredStyle(.scripture)
                                .foregroundStyle(AnchoredColors.navy)
                        }
                        .amberCard()

                        // Highlight picker
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Highlight color")
                                .anchoredStyle(.label)
                                .foregroundStyle(AnchoredColors.muted)
                            HStack(spacing: 14) {
                                ForEach(HighlightColor.allCases) { hc in
                                    Button {
                                        selectedColor = (selectedColor == hc) ? nil : hc
                                    } label: {
                                        Circle()
                                            .fill(hc.color)
                                            .frame(width: 34, height: 34)
                                            .overlay(
                                                Circle()
                                                    .stroke(selectedColor == hc ? AnchoredColors.navy : Color.clear, lineWidth: 2.5)
                                                    .padding(-3)
                                            )
                                            .shadow(color: hc.color.opacity(0.35), radius: 3)
                                    }
                                    .buttonStyle(.plain)
                                }
                                // Clear/no highlight
                                Button {
                                    selectedColor = nil
                                } label: {
                                    ZStack {
                                        Circle()
                                            .stroke(selectedColor == nil ? AnchoredColors.navy : AnchoredColors.border, lineWidth: selectedColor == nil ? 2.5 : 1.5)
                                            .frame(width: 34, height: 34)
                                        Image(systemName: "xmark")
                                            .font(.system(size: 12, weight: .semibold))
                                            .foregroundStyle(AnchoredColors.muted)
                                    }
                                }
                                .buttonStyle(.plain)
                            }
                        }

                        // Note editor
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Note")
                                .anchoredStyle(.label)
                                .foregroundStyle(AnchoredColors.muted)
                            ZStack(alignment: .topLeading) {
                                TextEditor(text: $noteText)
                                    .scrollContentBackground(.hidden)
                                    .padding(8)
                                    .frame(minHeight: 160)
                                    .background(AnchoredColors.card)
                                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                                            .stroke(AnchoredColors.border, lineWidth: 1)
                                    )
                                if noteText.isEmpty {
                                    Text("What does this verse mean to you?")
                                        .anchoredStyle(.body)
                                        .foregroundStyle(AnchoredColors.muted)
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 14)
                                        .allowsHitTesting(false)
                                }
                            }
                        }

                        Spacer()
                    }
                    .screenPadding()
                    .padding(.top, 12)
                }
            }
            .navigationTitle("Edit Verse")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { saveChanges(); dismiss() }
                }
            }
        }
    }

    private func saveChanges() {
        verse.note = noteText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : noteText
        verse.highlightColor = selectedColor?.rawValue
        try? modelContext.save()
    }
}

// MARK: - Prayer compose sheet

private struct PrayerComposeSheet: View {

    let onSave: (_ title: String, _ body: String, _ linkedVerse: String?) -> Void

    @State private var title: String = ""
    @State private var prayerBody: String = ""
    @State private var linkedVerse: String = ""
    @Environment(\.dismiss) private var dismiss

    var isValid: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !prayerBody.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AnchoredColors.parchment.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 14) {
                        field(title: "Title", text: $title, placeholder: "What are you praying for?")

                        editor(
                            title: "Prayer",
                            text: $prayerBody,
                            placeholder: "Write your prayer…",
                            minHeight: 160
                        )

                        field(
                            title: "Anchored verse (optional)",
                            text: $linkedVerse,
                            placeholder: "e.g. James 1:5"
                        )
                    }
                    .screenPadding()
                    .padding(.top, 12)
                }
            }
            .navigationTitle("New Prayer")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave(title, prayerBody, linkedVerse.isEmpty ? nil : linkedVerse)
                        dismiss()
                    }
                    .disabled(!isValid)
                }
            }
        }
    }

    private func field(title: String, text: Binding<String>, placeholder: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .anchoredStyle(.label)
                .foregroundStyle(AnchoredColors.muted)
            TextField(placeholder, text: text)
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background(AnchoredColors.card)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(AnchoredColors.border, lineWidth: 1)
                )
        }
    }

    private func editor(title: String, text: Binding<String>, placeholder: String, minHeight: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .anchoredStyle(.label)
                .foregroundStyle(AnchoredColors.muted)
            ZStack(alignment: .topLeading) {
                TextEditor(text: text)
                    .scrollContentBackground(.hidden)
                    .padding(8)
                    .frame(minHeight: minHeight)
                    .background(AnchoredColors.card)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(AnchoredColors.border, lineWidth: 1)
                    )
                if text.wrappedValue.isEmpty {
                    Text(placeholder)
                        .anchoredStyle(.body)
                        .foregroundStyle(AnchoredColors.muted)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 14)
                        .allowsHitTesting(false)
                }
            }
        }
    }
}

// MARK: - Preview

#Preview("Scripture seeded") {
    NavigationStack { JournalView() }
        .environmentObject(AuthManager.preview)
        .environmentObject(PremiumManager.preview)
        .modelContainer(PreviewContainer.shared)
}

#Preview("Compose prayer") {
    PrayerComposeSheet { _, _, _ in }
}
