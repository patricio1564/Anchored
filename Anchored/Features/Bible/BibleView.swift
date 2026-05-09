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
        if let ref = BibleCatalog.parseRef(from: q) {
            return [.chapter(ref)]
        }
        let lower = q.lowercased()
        let matched = BibleCatalog.all.filter { $0.name.lowercased().hasPrefix(lower) }
        return matched.map { .book($0) }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // Header
                HStack(alignment: .bottom) {
                    VStack(alignment: .leading, spacing: 0) {
                        Text("The")
                            .font(.custom("Newsreader", size: 13).weight(.regular).italic())
                            .foregroundStyle(AnchoredColors.inkSoft)
                        Text("Bible")
                            .font(.custom("Newsreader", size: 36).weight(.regular))
                            .tracking(-0.72)
                            .foregroundStyle(AnchoredColors.ink)
                    }
                    Spacer()
                    Button {
                        showRecommender = true
                    } label: {
                        ZStack {
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(
                                    LinearGradient(
                                        colors: [AnchoredColors.lilac, AnchoredColors.blue],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                            Image(systemName: "sparkles")
                                .font(.system(size: 18))
                                .foregroundStyle(.white)
                        }
                        .frame(width: 42, height: 42)
                        .shadow(color: AnchoredColors.lilac.opacity(0.35), radius: 9, x: 0, y: 8)
                    }
                    .accessibilityLabel("Find verses for how you feel")
                }
                .padding(.bottom, 18)

                // Search bar
                searchBar
                    .padding(.bottom, 18)

                if !suggestions.isEmpty {
                    suggestionsDropdown
                        .padding(.bottom, 18)
                }

                // Continue reading
                if let lastRef {
                    continueReadingCard(lastRef)
                        .padding(.bottom, 18)
                }

                // Old Testament
                bookSection(title: "Old Testament", books: BibleCatalog.oldTestament)

                // New Testament
                bookSection(title: "New Testament", books: BibleCatalog.newTestament)

                Spacer(minLength: 40)
            }
            .padding(.top, 58)
            .screenPadding()
        }
        .appBackground()
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .navigationDestination(for: BibleBook.self) { book in
            BibleChapterListView(book: book)
        }
        .navigationDestination(for: BiblePassageRef.self) { ref in
            BiblePassageView(ref: ref)
        }
        .navigationDestination(isPresented: $isPushingBook) {
            if let book = suggestedBook {
                BibleChapterListView(book: book)
            }
        }
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
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(AnchoredColors.coral.opacity(0.13))
                        .frame(width: 32, height: 32)
                    Image(systemName: "book.fill")
                        .font(.system(size: 14))
                        .foregroundStyle(AnchoredColors.coral)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text("Continue reading")
                        .font(.custom("Outfit", size: 11).weight(.semibold))
                        .tracking(0.44)
                        .textCase(.uppercase)
                        .foregroundStyle(AnchoredColors.coral)
                    Text(ref.apiReference)
                        .font(.custom("Newsreader", size: 16).weight(.medium))
                        .foregroundStyle(AnchoredColors.ink)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 13))
                    .foregroundStyle(AnchoredColors.inkMute)
            }
            .glassCard(padding: 14, cornerRadius: 18)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Search bar

    private var searchBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 16))
                .foregroundStyle(AnchoredColors.inkMute)
            TextField("", text: $searchInput, prompt: Text("e.g. John 3 or Psalm 23:1")
                .font(.custom("Newsreader", size: 14).weight(.regular).italic())
                .foregroundColor(AnchoredColors.inkMute)
            )
            .font(.custom("Newsreader", size: 14).weight(.regular))
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
                        .foregroundStyle(AnchoredColors.inkMute)
                }
            }
        }
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
                            .foregroundStyle(AnchoredColors.coral)
                            .frame(width: 20)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(suggestion.label)
                                .font(.custom("Outfit", size: 14.5).weight(.semibold))
                                .foregroundStyle(AnchoredColors.ink)
                            Text(suggestion.detail)
                                .font(.custom("Outfit", size: 12).weight(.medium))
                                .foregroundStyle(AnchoredColors.inkSoft)
                        }
                        Spacer()
                        Image(systemName: "arrow.up.left")
                            .font(.system(size: 11))
                            .foregroundStyle(AnchoredColors.inkMute)
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
        .glassCard(padding: 0, cornerRadius: 16)
        .padding(.top, -14)
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
            Text(title.uppercased())
                .font(.custom("Outfit", size: 11).weight(.semibold))
                .tracking(0.44)
                .foregroundStyle(AnchoredColors.coral)
                .padding(.bottom, 10)

            VStack(spacing: 0) {
                ForEach(Array(books.enumerated()), id: \.element.id) { index, book in
                    NavigationLink(value: book) {
                        bookRow(book, isLast: index == books.count - 1)
                    }
                    .buttonStyle(.plain)
                }
            }
            .background(AnchoredColors.glass)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(AnchoredColors.line, lineWidth: 1)
            )
            .padding(.bottom, 24)
        }
    }

    private func bookRow(_ book: BibleBook, isLast: Bool) -> some View {
        VStack(spacing: 0) {
            HStack {
                Text(book.name)
                    .font(.custom("Newsreader", size: 18).weight(.medium))
                    .foregroundStyle(AnchoredColors.ink)
                Spacer()
                HStack(spacing: 8) {
                    Text("\(book.chapters) ch")
                        .font(.custom("Outfit", size: 12).weight(.medium))
                        .monospacedDigit()
                        .foregroundStyle(AnchoredColors.inkSoft)
                    Image(systemName: "chevron.right")
                        .font(.system(size: 13))
                        .foregroundStyle(AnchoredColors.inkMute)
                }
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 14)

            if !isLast {
                Divider()
                    .overlay(AnchoredColors.lineSoft)
                    .padding(.leading, 18)
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
