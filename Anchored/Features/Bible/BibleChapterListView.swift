import SwiftUI

struct BibleChapterListView: View {
    let book: BibleBook

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 10), count: 5)

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("\(book.chapters) chapter\(book.chapters == 1 ? "" : "s")")
                    .anchoredStyle(.caption)
                    .foregroundStyle(AnchoredColors.muted)
                    .screenPadding()

                LazyVGrid(columns: columns, spacing: 10) {
                    ForEach(1...book.chapters, id: \.self) { chapter in
                        NavigationLink(value: BiblePassageRef(
                            apiReference: "\(book.name) \(chapter)",
                            book: book.name,
                            chapter: chapter
                        )) {
                            chapterTile(chapter)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .screenPadding()

                Spacer(minLength: 40)
            }
            .padding(.top, 8)
        }
        .background(AnchoredColors.parchment.ignoresSafeArea())
        .navigationTitle(book.name)
        .navigationBarTitleDisplayMode(.large)
    }

    private func chapterTile(_ chapter: Int) -> some View {
        Text("\(chapter)")
            .font(.system(size: 15, weight: .medium))
            .lineLimit(1)
            .foregroundStyle(AnchoredColors.navy)
            .frame(maxWidth: .infinity, minHeight: 44, maxHeight: 44)
            .background(AnchoredColors.card)
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .stroke(AnchoredColors.border, lineWidth: 1)
            )
    }
}

#Preview {
    NavigationStack {
        BibleChapterListView(book: BibleCatalog.oldTestament[18]) // Psalms
    }
    .environmentObject(AuthManager.preview)
    .environmentObject(PremiumManager.preview)
    .modelContainer(PreviewContainer.shared)
}
