import Foundation

// MARK: - BibleBook

struct BibleBook: Hashable, Identifiable {
    let name: String
    let chapters: Int
    let testament: Testament

    var id: String { name }

    enum Testament: String {
        case old = "Old Testament"
        case new = "New Testament"
    }
}

// MARK: - BiblePassageRef

/// Navigation destination type — pushed when a chapter is selected or
/// a search is submitted. apiReference is passed directly to the API.
struct BiblePassageRef: Hashable {
    let apiReference: String
    let book: String
    let chapter: Int
}

// MARK: - BibleCatalog

enum BibleCatalog {

    static let oldTestament: [BibleBook] = [
        .init(name: "Genesis",           chapters: 50,  testament: .old),
        .init(name: "Exodus",            chapters: 40,  testament: .old),
        .init(name: "Leviticus",         chapters: 27,  testament: .old),
        .init(name: "Numbers",           chapters: 36,  testament: .old),
        .init(name: "Deuteronomy",       chapters: 34,  testament: .old),
        .init(name: "Joshua",            chapters: 24,  testament: .old),
        .init(name: "Judges",            chapters: 21,  testament: .old),
        .init(name: "Ruth",              chapters: 4,   testament: .old),
        .init(name: "1 Samuel",          chapters: 31,  testament: .old),
        .init(name: "2 Samuel",          chapters: 24,  testament: .old),
        .init(name: "1 Kings",           chapters: 22,  testament: .old),
        .init(name: "2 Kings",           chapters: 25,  testament: .old),
        .init(name: "1 Chronicles",      chapters: 29,  testament: .old),
        .init(name: "2 Chronicles",      chapters: 36,  testament: .old),
        .init(name: "Ezra",              chapters: 10,  testament: .old),
        .init(name: "Nehemiah",          chapters: 13,  testament: .old),
        .init(name: "Esther",            chapters: 10,  testament: .old),
        .init(name: "Job",               chapters: 42,  testament: .old),
        .init(name: "Psalms",            chapters: 150, testament: .old),
        .init(name: "Proverbs",          chapters: 31,  testament: .old),
        .init(name: "Ecclesiastes",      chapters: 12,  testament: .old),
        .init(name: "Song of Solomon",   chapters: 8,   testament: .old),
        .init(name: "Isaiah",            chapters: 66,  testament: .old),
        .init(name: "Jeremiah",          chapters: 52,  testament: .old),
        .init(name: "Lamentations",      chapters: 5,   testament: .old),
        .init(name: "Ezekiel",           chapters: 48,  testament: .old),
        .init(name: "Daniel",            chapters: 12,  testament: .old),
        .init(name: "Hosea",             chapters: 14,  testament: .old),
        .init(name: "Joel",              chapters: 3,   testament: .old),
        .init(name: "Amos",              chapters: 9,   testament: .old),
        .init(name: "Obadiah",           chapters: 1,   testament: .old),
        .init(name: "Jonah",             chapters: 4,   testament: .old),
        .init(name: "Micah",             chapters: 7,   testament: .old),
        .init(name: "Nahum",             chapters: 3,   testament: .old),
        .init(name: "Habakkuk",          chapters: 3,   testament: .old),
        .init(name: "Zephaniah",         chapters: 3,   testament: .old),
        .init(name: "Haggai",            chapters: 2,   testament: .old),
        .init(name: "Zechariah",         chapters: 14,  testament: .old),
        .init(name: "Malachi",           chapters: 4,   testament: .old),
    ]

    static let newTestament: [BibleBook] = [
        .init(name: "Matthew",           chapters: 28, testament: .new),
        .init(name: "Mark",              chapters: 16, testament: .new),
        .init(name: "Luke",              chapters: 24, testament: .new),
        .init(name: "John",              chapters: 21, testament: .new),
        .init(name: "Acts",              chapters: 28, testament: .new),
        .init(name: "Romans",            chapters: 16, testament: .new),
        .init(name: "1 Corinthians",     chapters: 16, testament: .new),
        .init(name: "2 Corinthians",     chapters: 13, testament: .new),
        .init(name: "Galatians",         chapters: 6,  testament: .new),
        .init(name: "Ephesians",         chapters: 6,  testament: .new),
        .init(name: "Philippians",       chapters: 4,  testament: .new),
        .init(name: "Colossians",        chapters: 4,  testament: .new),
        .init(name: "1 Thessalonians",   chapters: 5,  testament: .new),
        .init(name: "2 Thessalonians",   chapters: 3,  testament: .new),
        .init(name: "1 Timothy",         chapters: 6,  testament: .new),
        .init(name: "2 Timothy",         chapters: 4,  testament: .new),
        .init(name: "Titus",             chapters: 3,  testament: .new),
        .init(name: "Philemon",          chapters: 1,  testament: .new),
        .init(name: "Hebrews",           chapters: 13, testament: .new),
        .init(name: "James",             chapters: 5,  testament: .new),
        .init(name: "1 Peter",           chapters: 5,  testament: .new),
        .init(name: "2 Peter",           chapters: 3,  testament: .new),
        .init(name: "1 John",            chapters: 5,  testament: .new),
        .init(name: "2 John",            chapters: 1,  testament: .new),
        .init(name: "3 John",            chapters: 1,  testament: .new),
        .init(name: "Jude",              chapters: 1,  testament: .new),
        .init(name: "Revelation",        chapters: 22, testament: .new),
    ]

    static let all: [BibleBook] = oldTestament + newTestament

    /// Returns the next chapter ref, crossing book boundaries. Returns nil at the end of Revelation.
    static func next(after ref: BiblePassageRef) -> BiblePassageRef? {
        guard let book = all.first(where: { $0.name == ref.book }) else { return nil }
        if ref.chapter < book.chapters {
            let ch = ref.chapter + 1
            return BiblePassageRef(apiReference: "\(ref.book) \(ch)", book: ref.book, chapter: ch)
        }
        guard let idx = all.firstIndex(where: { $0.name == ref.book }), idx + 1 < all.count else { return nil }
        let nextBook = all[idx + 1]
        return BiblePassageRef(apiReference: "\(nextBook.name) 1", book: nextBook.name, chapter: 1)
    }

    /// Returns the previous chapter ref, crossing book boundaries. Returns nil before Genesis 1.
    static func previous(before ref: BiblePassageRef) -> BiblePassageRef? {
        guard all.contains(where: { $0.name == ref.book }) else { return nil }
        if ref.chapter > 1 {
            let ch = ref.chapter - 1
            return BiblePassageRef(apiReference: "\(ref.book) \(ch)", book: ref.book, chapter: ch)
        }
        guard let idx = all.firstIndex(where: { $0.name == ref.book }), idx > 0 else { return nil }
        let prevBook = all[idx - 1]
        return BiblePassageRef(apiReference: "\(prevBook.name) \(prevBook.chapters)", book: prevBook.name, chapter: prevBook.chapters)
    }

    /// Parse a reference string like "John 3" or "1 Corinthians 13:4" into
    /// a BiblePassageRef. Returns nil if the string can't be parsed.
    static func parseRef(from input: String) -> BiblePassageRef? {
        let trimmed = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        let parts = trimmed.split(separator: " ", omittingEmptySubsequences: true)
        guard parts.count >= 2 else { return nil }
        // Chapter number is the last token; may be "3:16" — take the part before ":"
        let lastToken = String(parts.last!)
        let chapterStr = lastToken.split(separator: ":").first.map(String.init) ?? lastToken
        guard let chapter = Int(chapterStr) else { return nil }
        let book = parts.dropLast().joined(separator: " ")
        return BiblePassageRef(apiReference: trimmed, book: book, chapter: chapter)
    }
}
