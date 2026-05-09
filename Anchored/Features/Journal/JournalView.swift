import SwiftUI
import SwiftData

struct JournalView: View {

    enum Segment: String, CaseIterable, Identifiable {
        case scripture = "Scripture"
        case prayers = "Prayers"
        case notes = "Notes"
        var id: String { rawValue }
    }

    @State private var segment: Segment = .scripture

    @Query(sort: \BibleNote.updatedAt, order: .reverse)  private var notes: [BibleNote]
    @Query(sort: \Prayer.updatedAt, order: .reverse)      private var prayers: [Prayer]
    @Query(sort: \SavedVerse.savedAt, order: .reverse)    private var verses: [SavedVerse]

    @Environment(\.modelContext) private var modelContext

    @State private var isComposingPrayer = false
    @State private var selectedVerse: SavedVerse?

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
            // Header
            VStack(alignment: .leading, spacing: 0) {
                Text("Your")
                    .font(.custom("Newsreader", size: 13).weight(.regular).italic())
                    .foregroundStyle(AnchoredColors.inkSoft)
                Text("Journal")
                    .font(.custom("Newsreader", size: 36).weight(.regular))
                    .tracking(-0.72)
                    .foregroundStyle(AnchoredColors.ink)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .screenPadding()
            .padding(.top, 58)
            .padding(.bottom, 18)

            // Segmented tabs
            segmentedTabs
                .screenPadding()
                .padding(.bottom, 18)

            content
        }
        .appBackground()
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .toolbar {
            if segment == .prayers {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        isComposingPrayer = true
                    } label: {
                        Image(systemName: "square.and.pencil")
                            .foregroundStyle(AnchoredColors.ink)
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

    // MARK: - Segmented tabs

    private var segmentedTabs: some View {
        HStack(spacing: 6) {
            ForEach(Segment.allCases) { seg in
                let isActive = seg == segment
                Button {
                    withAnimation(.easeOut(duration: 0.18)) {
                        segment = seg
                    }
                } label: {
                    Text(seg.rawValue)
                        .font(.custom("Outfit", size: 13).weight(.semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 9)
                        .background(
                            Group {
                                if isActive {
                                    AnchoredColors.gradientPrimary
                                } else {
                                    Color.clear
                                }
                            }
                        )
                        .clipShape(Capsule())
                        .foregroundStyle(isActive ? .white : AnchoredColors.inkSoft)
                        .shadow(
                            color: isActive ? AnchoredColors.coral.opacity(0.3) : .clear,
                            radius: 6, x: 0, y: 4
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(5)
        .background(
            Capsule()
                .fill(Color.white.opacity(0.6))
                .background(.ultraThinMaterial, in: Capsule())
        )
        .overlay(
            Capsule().stroke(AnchoredColors.line, lineWidth: 1)
        )
    }

    // MARK: - Segmented content

    @ViewBuilder
    private var content: some View {
        switch segment {
        case .scripture: scriptureList
        case .prayers:   prayersList
        case .notes:     notesList
        }
    }

    private var scriptureList: some View {
        Group {
            if verses.isEmpty {
                emptyState(
                    icon: "book.closed.fill",
                    title: "No scripture yet",
                    message: "Tap verses in the Bible tab to save them here."
                )
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(verses) { v in
                            Button { selectedVerse = v } label: {
                                savedVerseCard(v)
                            }
                            .buttonStyle(.plain)
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
                    LazyVStack(spacing: 12) {
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

    private var notesList: some View {
        Group {
            if notes.isEmpty {
                emptyState(
                    icon: "note.text",
                    title: "No notes yet",
                    message: "Add notes while reading in the Bible tab."
                )
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(notes) { n in
                            noteCard(n)
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
        HStack(spacing: 0) {
            // Left accent bar
            RoundedRectangle(cornerRadius: 2)
                .fill(AnchoredColors.gradientPrimary)
                .frame(width: 3)
                .padding(.vertical, 24)

            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(verse.reference.uppercased())
                        .font(.custom("Outfit", size: 13).weight(.semibold))
                        .tracking(0.26)
                        .foregroundStyle(AnchoredColors.coral)
                    Spacer()
                    Text(verse.translation.uppercased())
                        .font(.custom("Outfit", size: 10).weight(.semibold))
                        .tracking(0.8)
                        .foregroundStyle(AnchoredColors.inkMute)
                }

                Text(verse.text)
                    .font(.custom("Newsreader", size: 17).weight(.regular).italic())
                    .lineSpacing(5)
                    .foregroundStyle(AnchoredColors.ink)

                if let note = verse.note, !note.isEmpty {
                    Text(note)
                        .font(.custom("Outfit", size: 12.5).weight(.medium))
                        .foregroundStyle(AnchoredColors.inkSoft)
                        .lineLimit(2)
                }
            }
            .padding(22)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AnchoredColors.glassStrong)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(AnchoredColors.line, lineWidth: 1)
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
        HStack(spacing: 0) {
            RoundedRectangle(cornerRadius: 2)
                .fill(
                    LinearGradient(
                        colors: [AnchoredColors.lilac, AnchoredColors.blue],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 3)
                .padding(.vertical, 24)

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(note.reference.uppercased())
                        .font(.custom("Outfit", size: 13).weight(.semibold))
                        .tracking(0.26)
                        .foregroundStyle(AnchoredColors.lilac)
                    Spacer()
                    Text(note.updatedAt.formatted(date: .abbreviated, time: .omitted))
                        .font(.custom("Outfit", size: 10).weight(.semibold))
                        .foregroundStyle(AnchoredColors.inkMute)
                }
                Text(note.verseText)
                    .font(.custom("Newsreader", size: 16).weight(.regular).italic())
                    .lineSpacing(5)
                    .foregroundStyle(AnchoredColors.ink)
                    .lineLimit(2)
                Text(note.note)
                    .font(.custom("Outfit", size: 13).weight(.medium))
                    .foregroundStyle(AnchoredColors.ink)
                    .lineLimit(3)
            }
            .padding(.horizontal, 22)
            .padding(.vertical, 18)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AnchoredColors.glassStrong)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(AnchoredColors.line, lineWidth: 1)
        )
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
                    .font(.custom("Outfit", size: 10).weight(.semibold))
                    .foregroundStyle(AnchoredColors.inkMute)
            }
            Text(prayer.title)
                .font(.custom("Newsreader", size: 18).weight(.medium))
                .foregroundStyle(AnchoredColors.ink)
            Text(prayer.content)
                .font(.custom("Outfit", size: 13).weight(.medium))
                .foregroundStyle(AnchoredColors.inkSoft)
                .lineLimit(3)
            if let linked = prayer.linkedVerse, !linked.isEmpty {
                Text("— \(linked)")
                    .font(.custom("Outfit", size: 13).weight(.semibold))
                    .foregroundStyle(AnchoredColors.coral)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassCard(padding: 20, cornerRadius: 22)
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
        case .active:   AnchoredColors.coral
        case .answered: AnchoredColors.success
        case .archived: AnchoredColors.inkMute
        }
        return Text(status.displayName.uppercased())
            .font(.custom("Outfit", size: 11).weight(.semibold))
            .tracking(0.44)
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
                .foregroundStyle(AnchoredColors.coral)
            Text(title)
                .font(.custom("Newsreader", size: 22).weight(.medium))
                .foregroundStyle(AnchoredColors.ink)
            Text(message)
                .font(.custom("Outfit", size: 14.5).weight(.medium))
                .foregroundStyle(AnchoredColors.inkSoft)
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
                AnchoredColors.backgroundGradient.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(verse.reference)
                                .font(.custom("Outfit", size: 13).weight(.semibold))
                                .foregroundStyle(AnchoredColors.coral)
                            Text(verse.text)
                                .font(.custom("Newsreader", size: 19).weight(.regular).italic())
                                .lineSpacing(7)
                                .foregroundStyle(AnchoredColors.ink)
                        }
                        .amberCard()

                        VStack(alignment: .leading, spacing: 10) {
                            Text("HIGHLIGHT COLOR")
                                .font(.custom("Outfit", size: 11).weight(.semibold))
                                .tracking(0.44)
                                .foregroundStyle(AnchoredColors.inkSoft)
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
                                                    .stroke(selectedColor == hc ? AnchoredColors.ink : Color.clear, lineWidth: 2.5)
                                                    .padding(-3)
                                            )
                                            .shadow(color: hc.color.opacity(0.35), radius: 3)
                                    }
                                    .buttonStyle(.plain)
                                }
                                Button {
                                    selectedColor = nil
                                } label: {
                                    ZStack {
                                        Circle()
                                            .stroke(selectedColor == nil ? AnchoredColors.ink : AnchoredColors.line, lineWidth: selectedColor == nil ? 2.5 : 1.5)
                                            .frame(width: 34, height: 34)
                                        Image(systemName: "xmark")
                                            .font(.system(size: 12, weight: .semibold))
                                            .foregroundStyle(AnchoredColors.inkMute)
                                    }
                                }
                                .buttonStyle(.plain)
                            }
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            Text("NOTE")
                                .font(.custom("Outfit", size: 11).weight(.semibold))
                                .tracking(0.44)
                                .foregroundStyle(AnchoredColors.inkSoft)
                            ZStack(alignment: .topLeading) {
                                TextEditor(text: $noteText)
                                    .scrollContentBackground(.hidden)
                                    .font(.custom("Outfit", size: 14.5).weight(.medium))
                                    .padding(8)
                                    .frame(minHeight: 160)
                                    .background(AnchoredColors.glass)
                                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                                            .stroke(AnchoredColors.line, lineWidth: 1)
                                    )
                                if noteText.isEmpty {
                                    Text("What does this verse mean to you?")
                                        .font(.custom("Outfit", size: 14.5).weight(.medium))
                                        .foregroundStyle(AnchoredColors.inkMute)
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
                AnchoredColors.backgroundGradient.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 14) {
                        field(title: "Title", text: $title, placeholder: "What are you praying for?")
                        editor(
                            title: "Prayer",
                            text: $prayerBody,
                            placeholder: "Write your prayer\u{2026}",
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
            Text(title.uppercased())
                .font(.custom("Outfit", size: 11).weight(.semibold))
                .tracking(0.44)
                .foregroundStyle(AnchoredColors.inkSoft)
            TextField(placeholder, text: text)
                .font(.custom("Outfit", size: 14.5).weight(.medium))
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(AnchoredColors.glass)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(AnchoredColors.line, lineWidth: 1)
                )
        }
    }

    private func editor(title: String, text: Binding<String>, placeholder: String, minHeight: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title.uppercased())
                .font(.custom("Outfit", size: 11).weight(.semibold))
                .tracking(0.44)
                .foregroundStyle(AnchoredColors.inkSoft)
            ZStack(alignment: .topLeading) {
                TextEditor(text: text)
                    .scrollContentBackground(.hidden)
                    .font(.custom("Outfit", size: 14.5).weight(.medium))
                    .padding(8)
                    .frame(minHeight: minHeight)
                    .background(AnchoredColors.glass)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(AnchoredColors.line, lineWidth: 1)
                    )
                if text.wrappedValue.isEmpty {
                    Text(placeholder)
                        .font(.custom("Outfit", size: 14.5).weight(.medium))
                        .foregroundStyle(AnchoredColors.inkMute)
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
