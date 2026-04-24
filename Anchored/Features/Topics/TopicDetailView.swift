// ────────────────────────────────────────────────────────────────────────────
// TopicDetailView.swift
//
// Destination screen for a selected Topic, pushed by TopicsView via
// .navigationDestination(for: Topic.self).
//
// Responsibilities:
//   • Render the topic header (gradient icon + title + description).
//   • List every lesson with a completion checkmark and best-ever score.
//   • Push LessonView when a lesson is tapped, using LessonDestination
//     as the NavigationStack route value.
//
// Progress is read via a @Query on LessonProgress scoped to this topic's
// lessonIds. Scores displayed here are "best ever" — they update whenever
// LessonView persists a new record.
// ────────────────────────────────────────────────────────────────────────────

import SwiftUI
import SwiftData

struct TopicDetailView: View {
    let topic: Topic

    // All progress rows for this topic's lessons. Because LessonProgress.lessonId
    // is @Attribute(.unique) there is at most one row per lesson.
    @Query private var progress: [LessonProgress]

    init(topic: Topic) {
        self.topic = topic
        let topicId = topic.id
        _progress = Query(
            filter: #Predicate<LessonProgress> { $0.topicId == topicId },
            sort: [SortDescriptor(\.completedAt, order: .reverse)]
        )
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                header
                lessonList
            }
            .screenPadding()
            .padding(.top, 8)
            .padding(.bottom, 32)
        }
        .background(AnchoredColors.parchment.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Header

    private var header: some View {
        HStack(spacing: 14) {
            // Gradient icon tile — mirrors the TopicCard tile in TopicsView.
            ZStack {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(topic.gradient.linearGradient)
                Text(topic.icon)
                    .font(.system(size: 26))
            }
            .frame(width: 56, height: 56)
            .shadow(color: .black.opacity(0.08), radius: 6, y: 3)

            VStack(alignment: .leading, spacing: 4) {
                Text(topic.title)
                    .anchoredStyle(.h1)
                    .foregroundStyle(AnchoredColors.navy)
                Text(topic.description)
                    .anchoredStyle(.caption)
                    .foregroundStyle(AnchoredColors.muted)
                    .lineLimit(2)
            }
        }
    }

    // MARK: - Lessons

    private var lessonList: some View {
        VStack(spacing: 12) {
            ForEach(Array(topic.lessons.enumerated()), id: \.element.id) { index, lesson in
                NavigationLink(value: LessonDestination(topic: topic, lesson: lesson)) {
                    LessonRow(
                        lesson: lesson,
                        index: index,
                        progress: progress.first { $0.lessonId == lesson.id }
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }
}

// ────────────────────────────────────────────────────────────────────────────
// MARK: - LessonDestination
//
// NavigationStack routes on Hashable values, one handler per type. We bundle
// (topic, lesson) here so LessonView has both without needing a catalog
// lookup. Registered in TopicsView alongside the Topic destination.
// ────────────────────────────────────────────────────────────────────────────

struct LessonDestination: Hashable {
    let topic: Topic
    let lesson: Lesson
}

// ────────────────────────────────────────────────────────────────────────────
// MARK: - LessonRow
// ────────────────────────────────────────────────────────────────────────────

private struct LessonRow: View {
    let lesson: Lesson
    let index: Int
    let progress: LessonProgress?

    private var isCompleted: Bool { progress?.completed == true }
    private var score: Int? { progress?.score }

    var body: some View {
        HStack(spacing: 14) {
            // Status bubble: green check if completed, amber book otherwise.
            ZStack {
                Circle()
                    .fill(isCompleted
                          ? Color.green.opacity(0.15)
                          : AnchoredColors.amber.opacity(0.15))
                Image(systemName: isCompleted ? "checkmark.circle.fill" : "book.fill")
                    .foregroundStyle(isCompleted ? .green : AnchoredColors.amber)
                    .font(.system(size: 20, weight: .semibold))
            }
            .frame(width: 44, height: 44)

            // Title + scripture reference + optional score pill.
            VStack(alignment: .leading, spacing: 4) {
                Text(lesson.title)
                    .anchoredStyle(.h3)
                    .foregroundStyle(AnchoredColors.navy)
                    .multilineTextAlignment(.leading)

                Text(lesson.scripture)
                    .anchoredStyle(.caption)
                    .foregroundStyle(AnchoredColors.muted)

                if let score {
                    Text("Best: \(score)%")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(.green)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.green.opacity(0.12), in: Capsule())
                        .padding(.top, 2)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            // Question count chip.
            Text("\(lesson.questions.count) Q")
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(AnchoredColors.muted)

            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(AnchoredColors.muted)
        }
        .cardSurface(padding: 14)
    }
}

// ────────────────────────────────────────────────────────────────────────────
// MARK: - Preview
// ────────────────────────────────────────────────────────────────────────────

#Preview("Creation topic") {
    NavigationStack {
        TopicDetailView(topic: TopicsCatalog.all.first!)
    }
    .modelContainer(PreviewContainer.shared)
}
