// ────────────────────────────────────────────────────────────────────────────
// BibleAPIService.swift
//
// Async/await wrapper around bible-api.com — a free, no-key service that
// serves public-domain Bible translations as JSON.
//
// Endpoint shape (GET):
//   https://bible-api.com/{reference}?translation={slug}
//
// Example:
//   https://bible-api.com/john%203:16?translation=web
//
// Response shape (relevant fields):
//   {
//     "reference": "John 3:16",
//     "verses": [ { "book_name": "John", "chapter": 3, "verse": 16, "text": "..." } ],
//     "text": "full passage text",
//     "translation_id": "web",
//     "translation_name": "World English Bible",
//     "translation_note": "..."
//   }
//
// Translations the app exposes:
//   • WEB — World English Bible (public domain, premium gate)
//   • KJV — King James Version (public domain, premium gate for parity)
//   • ASV — American Standard Version (public domain, default, FREE)
//   • BBE — Bible in Basic English (public domain, premium)
//   • Darby — Darby Translation (public domain, premium)
// ────────────────────────────────────────────────────────────────────────────

import Foundation

// ─────────────────────────────────────────────────────────────────────────────
// MARK: - Translation
// ─────────────────────────────────────────────────────────────────────────────

enum BibleTranslation: String, CaseIterable, Identifiable, Sendable {
    case web, kjv, asv, bbe, darby

    var id: String { rawValue }

    /// Display name shown in the translation picker.
    var displayName: String {
        switch self {
        case .web:   return "World English Bible"
        case .kjv:   return "King James Version"
        case .asv:   return "American Standard Version"
        case .bbe:   return "Bible in Basic English"
        case .darby: return "Darby Translation"
        }
    }

    /// Short label (3-4 chars) for compact UI.
    var shortLabel: String { rawValue.uppercased() }

    /// ASV is the free default; all others are premium.
    var isFree: Bool { self == .asv }
}

// ─────────────────────────────────────────────────────────────────────────────
// MARK: - Response types
// ─────────────────────────────────────────────────────────────────────────────

/// Public-facing passage result.
struct BiblePassage: Hashable, Sendable {
    /// e.g. "John 3:16"
    let reference: String
    /// Full concatenated passage text (what bible-api returns as `text`).
    let text: String
    /// Each verse broken out, in order.
    let verses: [BibleVerse]
    /// e.g. "World English Bible"
    let translationName: String
    /// e.g. "web"
    let translationID: String
}

struct BibleVerse: Hashable, Identifiable, Sendable {
    var id: String { "\(bookName)-\(chapter)-\(verse)" }
    let bookName: String
    let chapter: Int
    let verse: Int
    let text: String
}

// ─────────────────────────────────────────────────────────────────────────────
// MARK: - Errors
// ─────────────────────────────────────────────────────────────────────────────

enum BibleAPIError: LocalizedError {
    case invalidReference(String)
    case invalidURL
    case network(URLError)
    case httpStatus(Int)
    case notFound(String)
    case decoding(Error)
    case unknown(Error)

    var errorDescription: String? {
        switch self {
        case .invalidReference(let ref):
            return "We couldn't read that reference: \(ref)"
        case .invalidURL:
            return "Could not build a valid request."
        case .network(let urlError):
            return "Network issue: \(urlError.localizedDescription)"
        case .httpStatus(let code):
            return "Server returned status \(code)."
        case .notFound(let ref):
            return "No passage found for \(ref)."
        case .decoding:
            return "We got an unexpected response from the Bible service."
        case .unknown(let err):
            return err.localizedDescription
        }
    }
}

// ─────────────────────────────────────────────────────────────────────────────
// MARK: - Service
// ─────────────────────────────────────────────────────────────────────────────

/// Actor-isolated so the in-memory cache is access-safe under concurrency.
actor BibleAPIService {

    /// Shared instance for app-wide use. Tests/previews can make their own.
    static let shared = BibleAPIService()

    private let baseURL = URL(string: "https://bible-api.com/")!
    private let session: URLSession
    private let decoder: JSONDecoder

    /// Cache keyed on "reference|translation". Keeps frequently-seen verses
    /// (notably the daily verse) from re-hitting the network.
    private var cache: [String: BiblePassage] = [:]

    init(session: URLSession = .shared) {
        self.session = session
        self.decoder = JSONDecoder()
        // bible-api uses snake_case on some fields (book_name).
        self.decoder.keyDecodingStrategy = .convertFromSnakeCase
    }

    // MARK: Fetch

    /// Fetch a passage. Trimmed & deduped — same reference+translation reuses the cached result.
    func fetch(
        reference: String,
        translation: BibleTranslation = .web
    ) async throws -> BiblePassage {
        let trimmedReference = reference.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedReference.isEmpty else {
            throw BibleAPIError.invalidReference(reference)
        }

        let cacheKey = "\(trimmedReference.lowercased())|\(translation.rawValue)"
        if let cached = cache[cacheKey] {
            return cached
        }

        let url = try buildURL(reference: trimmedReference, translation: translation)

        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await session.data(from: url)
        } catch let urlError as URLError {
            throw BibleAPIError.network(urlError)
        } catch {
            throw BibleAPIError.unknown(error)
        }

        if let http = response as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
            if http.statusCode == 404 {
                throw BibleAPIError.notFound(trimmedReference)
            }
            throw BibleAPIError.httpStatus(http.statusCode)
        }

        let raw: APIResponse
        do {
            raw = try decoder.decode(APIResponse.self, from: data)
        } catch {
            throw BibleAPIError.decoding(error)
        }

        let passage = BiblePassage(
            reference: raw.reference,
            text: raw.text.trimmingCharacters(in: .whitespacesAndNewlines),
            verses: raw.verses.map { v in
                BibleVerse(
                    bookName: v.bookName,
                    chapter: v.chapter,
                    verse: v.verse,
                    text: v.text.trimmingCharacters(in: .whitespacesAndNewlines)
                )
            },
            translationName: raw.translationName,
            translationID: raw.translationId
        )

        cache[cacheKey] = passage
        return passage
    }

    /// Clear the cache. Called from Profile → "Clear cache" and on translation change.
    func clearCache() {
        cache.removeAll()
    }

    // MARK: URL building

    /// Build a safe URL for `bible-api.com/{reference}?translation={slug}`.
    /// Kept separate from `fetch` so the logic is unit-testable.
    private func buildURL(reference: String, translation: BibleTranslation) throws -> URL {
        // URLComponents handles percent-encoding for us. We pass the reference
        // as a path segment — URLComponents escapes spaces, colons, etc.
        guard var components = URLComponents(
            url: baseURL.appendingPathComponent(reference),
            resolvingAgainstBaseURL: false
        ) else {
            throw BibleAPIError.invalidURL
        }
        components.queryItems = [
            URLQueryItem(name: "translation", value: translation.rawValue)
        ]
        guard let url = components.url else {
            throw BibleAPIError.invalidURL
        }
        return url
    }
}

// ─────────────────────────────────────────────────────────────────────────────
// MARK: - Wire types (private to this file)
// ─────────────────────────────────────────────────────────────────────────────

private struct APIResponse: Decodable {
    let reference: String
    let verses: [APIVerse]
    let text: String
    let translationId: String
    let translationName: String
}

private struct APIVerse: Decodable {
    let bookName: String
    let chapter: Int
    let verse: Int
    let text: String
}
