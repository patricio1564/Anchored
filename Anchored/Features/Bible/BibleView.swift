//
//  BibleView.swift
//  Anchored
//
//  Root of the Bible tab. Shows the full book list grouped by testament.
//  If the user has read before, a "Continue reading" card appears at top.
//  The search bar offers predictive suggestions as the user types.
//  The sparkles button opens the Verse Recommender sheet.
//

import SwiftUI

struct BibleView: View {

    @EnvironmentObject private var premiumManager: PremiumManager

    @AppStorage("lastBibleApiReference") private var lastBibleApiReference: String = ""

    @State private var searchInput: String = ""
    @State private var showRecommender = false
    @State private var isPushingSearch = false
    @State private var searchRef: BiblePassageRef?
    @State private var isPushingBook = false
    @State private var suggestedBook: BibleBook?

    private var lastRef: BiblePassageRef? {
        BibleCatalog.parseRef(from: lastBibleApiReference)
    }

    // MARK: - Predictive search suggestions

    private enum SearchSuggestion: Identifiable {
        case book(BibleBook)
        case chapter(BiblePassageRef)

        var id: String {
            switch self {
            case .book(let b):    return "book-\(b.name)"
            case .chapter(let r): return "ch-\(r.apiReference)"
            }
        }

        var label: String {
            switch self {
            case .book(let b):    return b.name
            case .chapter(let r): return r.apiReference
            }
        }

        var detail: String {
            switch self {
            case .book(let b):    return "\(b.chapters) chapters"
            case .chapter:        return "Go to chapter"
            }
        }

        var icon: String {
            switch self {
            case .book:    return "books.vertical"
            case .chapter: return "book.pages"
            }
        }
    }

    private var suggestions: [SearchSuggestion] {
        let q = searchInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard q.count >= 2 else { return [] }

        // If it fully parses as a reference, offer it directly
        if let ref = BibleCatalog.parseRef(from: q) {
            return [.chapter(ref)]
        }

        // Otherwise find books whose names start with the query (case-insensitive)
        let lower = q.lowercased()
        let matched = BibleCatalog.all.filter { $0.name.lowercased().hasPrefix(lower) }
        return matched.map { .book($0) }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // ── Continue reading ────────────────────────────────────
                if let lastRef {
                    continueReadingCard(lastRef)
                        .screenPadding()
                        .padding(.top, 16)
                        .padding(.bottom, 8)
                }

                // ── Search + suggestions ────────────────────────────────
                VStack(alignment: .leading, spacing: 0) {
                    searchBar
                    if !suggestions.isEmpty {
                        suggestionsDropdown
                    }
                }
                .screenPadding()
                .padding(.top, lastRef == nil ? 16 : 0)
                .padding(.bottom, 24)

                // ── Old Testament ───────────────────────────────────────
                bookSection(title: "Old Testament", books: BibleCatalog.oldTestament)

                // ── New Testament ───────────────────────────────────────
                bookSection(title: "New Testament", books: BibleCatalog.newTestament)

                Spacer(minLength: 40)
            }
        }
        .background(AnchoredColors.parchment.ignoresSafeArea())
        .navigationTitle("Bible")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showRecommender = true
                } label: {
                    ZStack {
                        Circle()
                            .fill(AnchoredColors.amber)
                            .frame(width: 34, height: 34)
                        Image(systemName: "sparkles")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(.white)
                    }
                }
                .accessibilityLabel("Find verses for how you feel")
            }
        }
        // Book → chapter grid
        .navigationDestination(for: BibleBook.self) { book in
            BibleChapterListView(book: book)
        }
        // Chapter tap or search submit → passage reader
        .navigationDestination(for: BiblePassageRef.self) { ref in
            BiblePassageView(ref: ref)
        }
        // Suggestion book push
        .navigationDestination(isPresented: $isPushingBook) {
            if let book = suggestedBook {
                BibleChapterListView(book: book)
            }
        }
        // Search bar programmatic push
        .navigationDestination(isPresented: $isPushingSearch) {
            if let ref = searchRef {
                BiblePassageView(ref: ref)
            }
        }
        .sheet(isPresented: $showRecommender) {
            VerseRecommenderSheet()
        }
        .sheet(isPresented: $premiumManager.isShowingPaywall) {
            PaywallSheet()
        }
    }

    // MARK: - Continue reading card

    private func continueReadingCard(_ ref: BiblePassageRef) -> some View {
        NavigationLink(value: ref) {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(AnchoredColors.amber.opacity(0.14))
                        .frame(width: 44, height: 44)
                    Image(systemName: "book.fill")
                        .foregroundStyle(AnchoredColors.amber)
                        .font(.system(size: 18))
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text("Continue reading")
                        .anchoredStyle(.caption)
                        .foregroundStyle(AnchoredColors.muted)
                        .textCase(.uppercase)
                    Text(ref.apiReference)
                        .anchoredStyle(.bodyMd)
                        .foregroundStyle(AnchoredColors.navy)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(AnchoredColors.muted)
            }
            .cardSurface(padding: 14)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Search bar

    private var searchBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(AnchoredColors.muted)
            TextField("e.g. John 3 or Psalms 23:1", text: $searchInput)
                .textInputAutocapitalization(.words)
                .autocorrectionDisabled()
                .submitLabel(.search)
                .onSubmit {
                    if let ref = BibleCatalog.parseRef(from: searchInput) {
                        searchRef = ref
                        isPushingSearch = true
                        searchInput = ""
                    }
                }
            if !searchInput.isEmpty {
                Button {
                    searchInput = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(AnchoredColors.muted)
                }
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(AnchoredColors.card)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(AnchoredColors.border, lineWidth: 1)
        )
    }

    // MARK: - Suggestions dropdown

    private var suggestionsDropdown: some View {
        VStack(spacing: 0) {
            ForEach(Array(suggestions.prefix(6).enumerated()), id: \.element.id) { idx, suggestion in
                Button {
                    applySuggestion(suggestion)
                } label: {
                    HStack(spacing: 14) {
                        Image(systemName: suggestion.icon)
                            .font(.system(size: 14))
                            .foregroundStyle(AnchoredColors.amber)
                            .frame(width: 20)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(suggestion.label)
                                .anchoredStyle(.bodyMd)
                                .foregroundStyle(AnchoredColors.navy)
                            Text(suggestion.detail)
                                .anchoredStyle(.caption)
                                .foregroundStyle(AnchoredColors.muted)
                        }
                        Spacer()
                        Image(systemName: "arrow.up.left")
                            .font(.system(size: 11))
                            .foregroundStyle(AnchoredColors.muted)
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 11)
                }
                .buttonStyle(.plain)

                if idx < suggestions.prefix(6).count - 1 {
                    Divider().padding(.leading, 48)
                }
            }
        }
        .background(AnchoredColors.card)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(AnchoredColors.border, lineWidth: 1)
        )
        .padding(.top, 4)
    }

    private func applySuggestion(_ suggestion: SearchSuggestion) {
        searchInput = ""
        switch suggestion {
        case .book(let book):
            suggestedBook = book
            isPushingBook = true
        case .chapter(let ref):
            searchRef = ref
            isPushingSearch = true
        }
    }

    // MARK: - Book section

    private func bookSection(title: String, books: [BibleBook]) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title)
                .anchoredStyle(.label)
                .foregroundStyle(AnchoredColors.muted)
                .textCase(.uppercase)
                .screenPadding()
                .padding(.bottom, 8)

            VStack(spacing: 0) {
                ForEach(Array(books.enumerated()), id: \.element.id) { index, book in
                    NavigationLink(value: book) {
                        bookRow(book, isLast: index == books.count - 1)
                    }
                    .buttonStyle(.plain)
                }
            }
            .background(AnchoredColors.card)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(AnchoredColors.border, lineWidth: 1)
            )
            .screenPadding()
            .padding(.bottom, 24)
        }
    }

    private func bookRow(_ book: BibleBook, isLast: Bool) -> some View {
        VStack(spacing: 0) {
            HStack {
                Text(book.name)
                    .anchoredStyle(.body)
                    .foregroundStyle(AnchoredColors.navy)
                Spacer()
                Text("\(book.chapters) ch")
                    .anchoredStyle(.caption)
                    .foregroundStyle(AnchoredColors.muted)
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(AnchoredColors.muted)
                    .padding(.leading, 4)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 13)

            if !isLast {
                Divider()
                    .padding(.leading, 16)
            }
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        BibleView()
    }
    .environmentObject(AuthManager.preview)
    .environmentObject(PremiumManager.preview)
    .modelContainer(PreviewContainer.shared)
}
