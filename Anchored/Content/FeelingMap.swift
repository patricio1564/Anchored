// ────────────────────────────────────────────────────────────────────────────
// FeelingMap.swift
//
// Curated fallback for the Verse Recommender feature.
//
// The primary path uses Apple's on-device Foundation Models framework
// (iOS 18.1+). This file provides a deterministic, fully-offline
// backup: pre-authored pastoral content keyed to 8 emotional categories
// pulled from Base44's FEELING_SUGGESTIONS.
//
// Philosophy for the curated content:
//   • Same output shape as the LLM path (summary + verses + closing).
//   • First-person prayers, conversational, addressed to God directly.
//   • Scripture taken from public-domain WEB so there's no licensing
//     concern bundling the text in the binary.
// ────────────────────────────────────────────────────────────────────────────

import Foundation

// ─────────────────────────────────────────────────────────────────────────────
// MARK: - Shared result types (also used by VerseRecommenderService)
// ─────────────────────────────────────────────────────────────────────────────

/// One verse inside a recommender result. Matches the Base44 JSON schema so
/// the LLM path can decode into the same shape.
struct RecommendedVerse: Hashable, Sendable {
    let reference: String
    let text: String
    /// Why this verse applies. 1–2 sentences.
    let explanation: String
    /// A first-person prayer inspired by the verse.
    let prayer: String
}

/// A complete recommender response.
struct VerseRecommendation: Hashable, Sendable {
    let summary: String
    let verses: [RecommendedVerse]
    let closingEncouragement: String
}

// ─────────────────────────────────────────────────────────────────────────────
// MARK: - Feeling categories
// ─────────────────────────────────────────────────────────────────────────────

/// The 8 feelings the Recommender's suggestion chips map to. Order is UI order.
enum Feeling: String, CaseIterable, Sendable {
    case anxiety
    case grief
    case loneliness
    case forgiveness
    case doubt
    case overwhelm
    case gratitude
    case guidance

    /// The suggestion chip label shown in the UI. Matches Base44 copy.
    var chipLabel: String {
        switch self {
        case .anxiety:     return "I'm feeling anxious about the future"
        case .grief:       return "I'm going through a difficult loss"
        case .loneliness:  return "I feel alone and forgotten"
        case .forgiveness: return "I need strength to forgive someone"
        case .doubt:       return "I'm struggling with doubt"
        case .overwhelm:   return "I feel overwhelmed and burned out"
        case .gratitude:   return "I'm grateful and want to praise God"
        case .guidance:    return "I need guidance for a big decision"
        }
    }
}

// ─────────────────────────────────────────────────────────────────────────────
// MARK: - FeelingMap (curated content + matcher)
// ─────────────────────────────────────────────────────────────────────────────

enum FeelingMap {

    /// Keywords → feeling. Checked case-insensitively on the user's text.
    /// The first feeling with a matching keyword wins (so order matters for
    /// terms that could plausibly fit two categories).
    private static let keywords: [(Feeling, [String])] = [
        (.anxiety, ["anxious", "anxiety", "worried", "worry", "scared", "afraid", "fearful", "fear", "panic", "nervous"]),
        (.grief, ["grief", "grieving", "loss", "lost", "died", "death", "mourning", "mourn", "heartbroken", "broken"]),
        (.loneliness, ["lonely", "alone", "isolated", "forgotten", "abandoned", "nobody"]),
        (.forgiveness, ["forgive", "forgiveness", "resentment", "bitter", "hurt me", "hurt by"]),
        (.doubt, ["doubt", "doubting", "unbelief", "don't believe", "don't know if", "is god real", "questioning"]),
        (.overwhelm, ["overwhelmed", "overwhelm", "burned out", "burnout", "exhausted", "too much", "stressed", "stress"]),
        (.gratitude, ["grateful", "gratitude", "thankful", "thank you", "praise", "blessed", "rejoice"]),
        (.guidance, ["guidance", "guide", "decision", "decide", "direction", "which way", "what should i", "confused"])
    ]

    /// Find the best-matching feeling for an arbitrary user phrase.
    /// Returns nil if nothing matches — caller can fall back to `genericComfort()`.
    static func match(_ text: String) -> Feeling? {
        let lower = text.lowercased()
        for (feeling, terms) in keywords {
            if terms.contains(where: { lower.contains($0) }) {
                return feeling
            }
        }
        return nil
    }

    /// Build the full curated response for a given feeling.
    static func recommendation(for feeling: Feeling) -> VerseRecommendation {
        switch feeling {
        case .anxiety:     return anxiety
        case .grief:       return grief
        case .loneliness:  return loneliness
        case .forgiveness: return forgiveness
        case .doubt:       return doubt
        case .overwhelm:   return overwhelm
        case .gratitude:   return gratitude
        case .guidance:    return guidance
        }
    }

    /// Last-resort fallback for unrecognized input. Broad comfort passages.
    static func genericComfort() -> VerseRecommendation {
        VerseRecommendation(
            summary: "Whatever you're carrying right now, you don't have to carry it alone. Here are a few passages that have brought steadiness to countless others.",
            verses: [
                RecommendedVerse(
                    reference: "Psalm 46:1",
                    text: "God is our refuge and strength, a very present help in trouble.",
                    explanation: "A reminder that God isn't distant when things are hard — he is a present help, right here, right now.",
                    prayer: "God, I don't have the words today. Be my refuge. Meet me in whatever I'm walking through, even when I can't name it."
                ),
                RecommendedVerse(
                    reference: "Matthew 11:28",
                    text: "Come to me, all you who labor and are heavily burdened, and I will give you rest.",
                    explanation: "Jesus' invitation is open-ended. You don't have to get cleaned up or figure it out first — you just come.",
                    prayer: "Jesus, I'm coming as I am. I'm tired. I need the rest you promised. Thank you for not turning me away."
                ),
                RecommendedVerse(
                    reference: "Psalm 34:18",
                    text: "Yahweh is near to those who have a broken heart, and saves those who have a crushed spirit.",
                    explanation: "Nearness, not distance. God moves closer to hurting people, not further away.",
                    prayer: "Lord, draw near. I believe you are close even when I can't feel you. Please save what feels crushed in me."
                )
            ],
            closingEncouragement: "You are seen. You are loved. Take the next small step."
        )
    }

    // ─────────────────────────────────────────────────────────────────────
    // MARK: - Curated content per feeling
    // ─────────────────────────────────────────────────────────────────────

    private static let anxiety = VerseRecommendation(
        summary: "Anxiety is exhausting, and God knows. Scripture doesn't dismiss fear — it invites you to hand it off, piece by piece.",
        verses: [
            RecommendedVerse(
                reference: "Philippians 4:6-7",
                text: "In nothing be anxious, but in everything, by prayer and petition with thanksgiving, let your requests be made known to God. And the peace of God, which surpasses all understanding, will guard your hearts and your thoughts in Christ Jesus.",
                explanation: "The antidote offered here isn't willpower — it's transferring the weight to God through prayer, one specific request at a time.",
                prayer: "Father, I'm anxious. I'm laying it out in front of you — every uncertainty, every what-if. Please guard my heart with a peace I can't manufacture on my own."
            ),
            RecommendedVerse(
                reference: "1 Peter 5:7",
                text: "casting all your worries on him, because he cares for you.",
                explanation: "Cast — not just share or discuss. The image is of actually throwing the weight off yourself and onto someone stronger.",
                prayer: "God, I'm casting this on you. I keep trying to carry it myself. Help me let it go and trust that you actually care about every detail."
            ),
            RecommendedVerse(
                reference: "Isaiah 41:10",
                text: "Don't you be afraid, for I am with you. Don't be dismayed, for I am your God. I will strengthen you. I will help you. I will uphold you with the right hand of my righteousness.",
                explanation: "Four promises in one verse — with you, your God, will strengthen, will help. Your fear doesn't cancel any of them.",
                prayer: "Lord, remind me you are with me. Strengthen me when I feel weak. Uphold me when I can't stand on my own."
            )
        ],
        closingEncouragement: "You don't have to figure everything out tonight. One breath, one prayer, one step."
    )

    private static let grief = VerseRecommendation(
        summary: "Grief is love with nowhere to go. God doesn't rush you through it — he sits with you in it.",
        verses: [
            RecommendedVerse(
                reference: "Psalm 34:18",
                text: "Yahweh is near to those who have a broken heart, and saves those who have a crushed spirit.",
                explanation: "God's default move toward a broken heart is nearness — not explanation, not correction. Just closeness.",
                prayer: "Lord, my heart is broken. I don't need answers right now. I just need you close. Please be near."
            ),
            RecommendedVerse(
                reference: "Matthew 5:4",
                text: "Blessed are those who mourn, for they shall be comforted.",
                explanation: "Jesus names mourning as blessed — not pitied, not rushed. Comfort is promised on the other side of the tears, not in their absence.",
                prayer: "Jesus, I'm mourning. Thank you for not telling me to stop. I'm trusting your promise that comfort is coming."
            ),
            RecommendedVerse(
                reference: "Revelation 21:4",
                text: "He will wipe away every tear from their eyes. Death will be no more; neither will there be mourning, nor crying, nor pain, any more.",
                explanation: "A concrete promise about the future: this pain is not the end. There is a day coming when every tear will be personally wiped away.",
                prayer: "God, hold this promise in front of me when the weight is too heavy. Help me grieve with hope, knowing this isn't forever."
            ),
            RecommendedVerse(
                reference: "John 11:35",
                text: "Jesus wept.",
                explanation: "The shortest verse in scripture. Jesus — knowing the ending, knowing he was about to raise Lazarus — still stopped and wept. Your tears are not a lack of faith.",
                prayer: "Jesus, thank you that you wept. Thank you that my tears don't disappoint you. Weep with me now."
            )
        ],
        closingEncouragement: "You are allowed to grieve. God is nearer than you can feel right now."
    )

    private static let loneliness = VerseRecommendation(
        summary: "Loneliness lies. It tells you that you're forgotten. Scripture insists, over and over, that you are seen.",
        verses: [
            RecommendedVerse(
                reference: "Deuteronomy 31:6",
                text: "Be strong and courageous. Don't be afraid or scared of them; for Yahweh your God himself is who goes with you. He will not fail you nor forsake you.",
                explanation: "A promise originally spoken to a whole nation, but each word is also true for you. He goes with you. He will not fail you. He will not forsake you.",
                prayer: "God, remind me you are here. Even when I feel alone, you are with me. I'm trusting this promise over what my feelings are telling me."
            ),
            RecommendedVerse(
                reference: "Psalm 139:7-10",
                text: "Where could I go from your Spirit? Or where could I flee from your presence? If I ascend up into heaven, you are there. If I make my bed in Sheol, behold, you are there. If I take the wings of the dawn, and settle in the uttermost parts of the sea, even there your hand will lead me, your right hand will hold me.",
                explanation: "There is no place you can go where God is not already waiting. Your loneliness is real, but it's not the final word.",
                prayer: "Lord, I feel alone — but your word says you are here. Meet me. Let me sense your presence even in small ways today."
            ),
            RecommendedVerse(
                reference: "Hebrews 13:5",
                text: "Be free from the love of money, content with such things as you have, for he has said, \"I will in no way leave you, neither will I in any way forsake you.\"",
                explanation: "A double negative in the original Greek — \"never, never leave.\" God doubled down on this promise on purpose.",
                prayer: "Father, I receive this. You will never leave. You will never forsake. Help me believe this when my heart tells me otherwise."
            )
        ],
        closingEncouragement: "You are not forgotten. You are known, named, and loved."
    )

    private static let forgiveness = VerseRecommendation(
        summary: "Forgiveness is one of the hardest things God asks. He also knows it better than anyone — and he'll give you the strength he requires.",
        verses: [
            RecommendedVerse(
                reference: "Ephesians 4:32",
                text: "And be kind to one another, tenderhearted, forgiving each other, just as God also in Christ forgave you.",
                explanation: "The pattern is reverse: you forgive because you have been forgiven. Not because the other person deserves it — because Christ set the template.",
                prayer: "Father, I've been forgiven so much. Help me extend even a fraction of that to the person who hurt me. I can't do this on my own."
            ),
            RecommendedVerse(
                reference: "Colossians 3:13",
                text: "bearing with one another, and forgiving each other, if any man has a complaint against any; even as Christ forgave you, so you also do.",
                explanation: "Notice the phrase \"if any man has a complaint.\" Your hurt is acknowledged as real. Forgiveness isn't pretending it didn't happen.",
                prayer: "Lord, my hurt is real. You see it. I'm asking for the strength to forgive anyway — not because it's easy, but because you forgave me."
            ),
            RecommendedVerse(
                reference: "Matthew 6:14-15",
                text: "For if you forgive men their trespasses, your heavenly Father will also forgive you. But if you don't forgive men their trespasses, neither will your Father forgive your trespasses.",
                explanation: "Jesus speaks plainly here. Unforgiveness corrodes the forgiver. Letting go is as much for you as for the other person.",
                prayer: "Jesus, soften my heart. Release me from the weight of this resentment. I want to be free — help me forgive as you forgave me."
            )
        ],
        closingEncouragement: "Forgiveness is a process, not a single moment. Take the next honest step."
    )

    private static let doubt = VerseRecommendation(
        summary: "Doubt isn't the opposite of faith — it's often part of it. Scripture has room for your questions.",
        verses: [
            RecommendedVerse(
                reference: "Mark 9:24",
                text: "Immediately the father of the child cried out with tears, \"I believe. Help my unbelief!\"",
                explanation: "A man brought exactly this prayer to Jesus — faith and doubt in the same breath — and Jesus honored it. Your prayer can too.",
                prayer: "Jesus, I believe. Help my unbelief. I want to trust you — strengthen whatever faith I have, even when it feels small."
            ),
            RecommendedVerse(
                reference: "James 1:5-6",
                text: "But if any of you lacks wisdom, let him ask of God, who gives to all liberally and without reproach; and it will be given to him. But let him ask in faith, without any doubting, for he who doubts is like a wave of the sea, driven by the wind and tossed.",
                explanation: "God invites you to ask — generously, without being scolded. The invitation precedes the condition.",
                prayer: "God, I'm asking. Give me wisdom. Steady my heart when I'm tossed by doubt. Help me see clearly."
            ),
            RecommendedVerse(
                reference: "John 20:27",
                text: "Then he said to Thomas, \"Reach here your finger, and see my hands. Reach here your hand, and put it into my side. Don't be unbelieving, but believing.\"",
                explanation: "Jesus met doubting Thomas with physical evidence — not a rebuke. He was patient with the honest doubter. He is patient with you.",
                prayer: "Lord, show me yourself. I'm not asking to be flashy — I'm asking honestly. Reveal yourself in a way I can receive."
            )
        ],
        closingEncouragement: "Your questions are welcome. Keep asking — and keep listening."
    )

    private static let overwhelm = VerseRecommendation(
        summary: "When everything feels like too much, God's invitation is not to do more — it's to come and rest.",
        verses: [
            RecommendedVerse(
                reference: "Matthew 11:28-30",
                text: "\"Come to me, all you who labor and are heavily burdened, and I will give you rest. Take my yoke upon you and learn from me, for I am gentle and humble in heart; and you will find rest for your souls. For my yoke is easy, and my burden is light.\"",
                explanation: "Rest isn't a reward for finishing — it's the starting point. Jesus specifically invites the exhausted.",
                prayer: "Jesus, I'm exhausted. I'm coming. Take this load off my shoulders. Teach me what your easy yoke looks like in my life today."
            ),
            RecommendedVerse(
                reference: "Psalm 23:1-3",
                text: "Yahweh is my shepherd: I shall lack nothing. He makes me lie down in green pastures. He leads me beside still waters. He restores my soul.",
                explanation: "Notice it says \"he makes me lie down.\" Sometimes the Shepherd has to insist on rest. Pay attention if he's insisting.",
                prayer: "Shepherd, make me lie down. Lead me beside still waters. Restore my soul — I can't restore it myself."
            ),
            RecommendedVerse(
                reference: "Psalm 55:22",
                text: "Cast your burden on Yahweh and he will sustain you. He will never allow the righteous to be moved.",
                explanation: "Two verbs: cast (your part) and sustain (his part). You only have to do the first one.",
                prayer: "Lord, I'm casting this burden on you — the work, the people, the expectations, all of it. Sustain me. Hold me up."
            )
        ],
        closingEncouragement: "You don't have to do everything today. Do the next right thing, and rest."
    )

    private static let gratitude = VerseRecommendation(
        summary: "Gratitude is holy ground. Here are verses to help you voice what your heart is already feeling.",
        verses: [
            RecommendedVerse(
                reference: "Psalm 100:4-5",
                text: "Enter into his gates with thanksgiving, into his courts with praise. Give thanks to him, and bless his name. For Yahweh is good. His loving kindness endures forever, his faithfulness to all generations.",
                explanation: "Thanksgiving is the doorway. Praise is the room. Both are appropriate responses when your heart is overflowing.",
                prayer: "God, I come into your presence with thanksgiving. You are good. Your love never runs out. Thank you, thank you, thank you."
            ),
            RecommendedVerse(
                reference: "1 Thessalonians 5:16-18",
                text: "Rejoice always. Pray without ceasing. In everything give thanks, for this is the will of God in Christ Jesus toward you.",
                explanation: "Gratitude isn't a circumstance — it's a posture God invites in every season, but especially easy to lean into when joy wells up.",
                prayer: "Lord, I'm rejoicing. Thank you for this moment. Keep me in this posture — grateful whether things feel easy or hard."
            ),
            RecommendedVerse(
                reference: "James 1:17",
                text: "Every good gift and every perfect gift is from above, coming down from the Father of lights, with whom can be no variation nor turning shadow.",
                explanation: "Everything good traces back to the same source. Let gratitude lead you to the Giver, not just the gift.",
                prayer: "Father of lights, thank you. Every good thing is from you. I see your goodness and I want to tell you — I love you."
            )
        ],
        closingEncouragement: "Keep praising. The world is better when you do."
    )

    private static let guidance = VerseRecommendation(
        summary: "Big decisions are weighty. God doesn't promise to hand you a map — he promises to walk with you and give wisdom as you go.",
        verses: [
            RecommendedVerse(
                reference: "Proverbs 3:5-6",
                text: "Trust in Yahweh with all your heart, and don't lean on your own understanding. In all your ways acknowledge him, and he will make your paths straight.",
                explanation: "The promise is not that you'll see the whole road — only that your next step will be on solid ground if you keep acknowledging him.",
                prayer: "Lord, I don't trust my own understanding on this. I'm inviting you into every corner of this decision. Make my path straight — even if I can only see a few steps ahead."
            ),
            RecommendedVerse(
                reference: "James 1:5",
                text: "But if any of you lacks wisdom, let him ask of God, who gives to all liberally and without reproach; and it will be given to him.",
                explanation: "God isn't stingy with wisdom, and he doesn't scold you for asking. Ask specifically. Ask often.",
                prayer: "God, I need wisdom. I'm asking in faith, believing you will give it. Help me see this situation the way you see it."
            ),
            RecommendedVerse(
                reference: "Psalm 32:8",
                text: "I will instruct you and teach you in the way which you shall go. I will counsel you with my eye on you.",
                explanation: "God's eye is on you as he teaches you — deeply personal. This isn't generic advice; it's custom-fit guidance from someone who knows you fully.",
                prayer: "Father, teach me the way I should go. Your eye is on me — I trust that. Show me the next right step, and the courage to take it."
            )
        ],
        closingEncouragement: "Take the next step in faith. Clarity tends to come one step at a time."
    )
}
