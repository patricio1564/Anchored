#!/usr/bin/env python3
"""
Anchored — Curriculum Generator

Reads the three Base44 JS curriculum source files and emits a single
Swift file containing the fully-typed TopicsCatalog.generated data.

Why a custom parser?
--------------------
The source files are JavaScript object literals, not JSON:
    • unquoted keys            ({ id: "creation", ... })
    • single-quoted strings    (rare, but possible)
    • line comments            (// ─── PAUL'S LETTERS ───)
    • trailing commas          (questions: [ ..., ], )

json.loads chokes on all of these. A real JS parser would work but pulls
in a heavy dependency. Instead, we do a deliberate 3-stage rewrite:

    Stage 1: strip_js_comments
        Remove every //… line comment BEFORE doing anything else.
        This is critical: comments like "PAUL'S LETTERS" contain a stray
        apostrophe that poisons naive in-string tracking further down.

    Stage 2: extract_array_literal
        Find the array literal after `export const EXTRA_TOPICS = [` (or
        `const BASE_TOPICS = [`). Walk the characters, tracking string
        state correctly, and grab the balanced `[ ... ]` body.

    Stage 3: js_to_json
        Quote unquoted keys, swap single-quoted strings to double-quoted,
        strip trailing commas. At this point the body is valid JSON and
        json.loads handles it.

Run:
    python3 scripts/generate_curriculum.py

Output:
    Anchored/Anchored/Content/GeneratedData/TopicsCatalog+Generated.swift
"""

import json
import re
import sys
from pathlib import Path
from typing import Any


# ─────────────────────────────────────────────────────────────────────────────
# Paths
# ─────────────────────────────────────────────────────────────────────────────

ROOT = Path(__file__).resolve().parent.parent
SOURCE_DIR = ROOT / "source-js"
OUTPUT_PATH = (
    ROOT
    / "Anchored"
    / "Anchored"
    / "Content"
    / "GeneratedData"
    / "TopicsCatalog+Generated.swift"
)

BASE_FILE = SOURCE_DIR / "bibleContent.js"
EXTRA_FILE = SOURCE_DIR / "bibleContentExtra.js"
EXTRA2_FILE = SOURCE_DIR / "bibleContentExtra2.js"


# ─────────────────────────────────────────────────────────────────────────────
# Stage 1 — Comment stripping
# ─────────────────────────────────────────────────────────────────────────────

def strip_js_comments(source: str) -> str:
    """Remove // line comments and /* block */ comments while respecting strings.

    This MUST run before any other scanning, because comments may contain
    apostrophes, quotes, or braces that would confuse a naive walker.
    """
    out: list[str] = []
    i = 0
    n = len(source)
    in_string: str | None = None  # holds the opening quote char, or None

    while i < n:
        c = source[i]
        nxt = source[i + 1] if i + 1 < n else ""

        if in_string:
            out.append(c)
            if c == "\\" and i + 1 < n:
                # Preserve escape sequences verbatim.
                out.append(source[i + 1])
                i += 2
                continue
            if c == in_string:
                in_string = None
            i += 1
            continue

        # Not inside a string — comments are possible.
        if c == "/" and nxt == "/":
            # Line comment: skip until newline (keep the newline so line
            # numbers stay roughly aligned in any downstream errors).
            while i < n and source[i] != "\n":
                i += 1
            continue
        if c == "/" and nxt == "*":
            # Block comment: skip until */
            i += 2
            while i < n - 1 and not (source[i] == "*" and source[i + 1] == "/"):
                i += 1
            i += 2  # consume */
            continue

        if c in ('"', "'", "`"):
            in_string = c

        out.append(c)
        i += 1

    return "".join(out)


# ─────────────────────────────────────────────────────────────────────────────
# Stage 2 — Extract the balanced array literal after a marker
# ─────────────────────────────────────────────────────────────────────────────

def extract_array_literal(source: str, marker_regex: str) -> str:
    """Find a `[...]` array literal following a regex marker in `source`.

    Returns the literal text including the outer brackets.
    """
    m = re.search(marker_regex, source)
    if not m:
        raise ValueError(f"Could not find marker: {marker_regex}")

    # Move to the opening '['.
    i = source.find("[", m.end())
    if i == -1:
        raise ValueError(f"No '[' after marker: {marker_regex}")

    start = i
    depth = 0
    in_string: str | None = None
    n = len(source)

    while i < n:
        c = source[i]
        if in_string:
            if c == "\\" and i + 1 < n:
                i += 2
                continue
            if c == in_string:
                in_string = None
            i += 1
            continue

        if c in ('"', "'", "`"):
            in_string = c
        elif c == "[":
            depth += 1
        elif c == "]":
            depth -= 1
            if depth == 0:
                return source[start : i + 1]
        i += 1

    raise ValueError("Unbalanced brackets in array literal")


# ─────────────────────────────────────────────────────────────────────────────
# Stage 3 — Convert JS object literal syntax to strict JSON
# ─────────────────────────────────────────────────────────────────────────────

def js_to_json(js_literal: str) -> str:
    """Turn a comment-free JS object/array literal into valid JSON."""
    out: list[str] = []
    i = 0
    n = len(js_literal)
    in_string: str | None = None

    while i < n:
        c = js_literal[i]

        if in_string:
            if c == "\\" and i + 1 < n:
                out.append(c)
                out.append(js_literal[i + 1])
                i += 2
                continue
            if c == in_string:
                # Normalize single-quoted strings to double-quoted.
                if in_string == "'":
                    out.append('"')
                else:
                    out.append(c)
                in_string = None
                i += 1
                continue
            # Escape double-quote chars that appear inside a single-quoted string.
            if in_string == "'" and c == '"':
                out.append('\\"')
                i += 1
                continue
            out.append(c)
            i += 1
            continue

        if c == '"':
            in_string = '"'
            out.append(c)
            i += 1
            continue

        if c == "'":
            in_string = "'"
            out.append('"')  # open as double-quote in output
            i += 1
            continue

        # Unquoted identifier key?  pattern:  key:
        # Keys are always preceded by { or , (with optional whitespace).
        if c.isalpha() or c == "_" or c == "$":
            # Look back to see if the most recent non-whitespace char is { or ,
            j = len(out) - 1
            while j >= 0 and out[j] in " \t\n\r":
                j -= 1
            if j >= 0 and out[j] in "{,":
                # Collect the identifier.
                k = i
                while k < n and (js_literal[k].isalnum() or js_literal[k] in "_$"):
                    k += 1
                ident = js_literal[i:k]
                # Skip whitespace after identifier.
                m = k
                while m < n and js_literal[m] in " \t\n\r":
                    m += 1
                if m < n and js_literal[m] == ":":
                    out.append(f'"{ident}"')
                    i = k
                    continue
                # Otherwise it's a literal like true/false/null — emit as-is.
                out.append(ident)
                i = k
                continue

        out.append(c)
        i += 1

    result = "".join(out)
    # Strip trailing commas:  ,]  or  ,}
    result = re.sub(r",(\s*[\]}])", r"\1", result)
    return result


# ─────────────────────────────────────────────────────────────────────────────
# Top-level parse: read all three source files, return merged topic list
# ─────────────────────────────────────────────────────────────────────────────

def parse_source_file(path: Path, marker: str) -> list[dict[str, Any]]:
    raw = path.read_text(encoding="utf-8")
    cleaned = strip_js_comments(raw)
    literal = extract_array_literal(cleaned, marker)
    as_json = js_to_json(literal)
    try:
        return json.loads(as_json)
    except json.JSONDecodeError as e:
        # Dump a window around the error for debugging.
        start = max(0, e.pos - 120)
        end = min(len(as_json), e.pos + 120)
        window = as_json[start:end]
        sys.stderr.write(
            f"\n[{path.name}] JSON decode failed at pos {e.pos}: {e.msg}\n"
            f"--- context ---\n{window}\n---------------\n"
        )
        raise


def load_all_topics() -> list[dict[str, Any]]:
    base = parse_source_file(BASE_FILE, r"const\s+BASE_TOPICS\s*=\s*")
    extra = parse_source_file(EXTRA_FILE, r"export\s+const\s+EXTRA_TOPICS\s*=\s*")
    extra2 = parse_source_file(EXTRA2_FILE, r"export\s+const\s+EXTRA_TOPICS_2\s*=\s*")
    return base + extra + extra2


# ─────────────────────────────────────────────────────────────────────────────
# Gradient mapping: Tailwind class → Swift TopicGradient enum case
# ─────────────────────────────────────────────────────────────────────────────

def tailwind_to_case(color_class: str) -> str:
    """Turn 'from-emerald-500 to-teal-600' into 'emerald500ToTeal600'."""
    # Remove 'from-' and 'to-' prefixes, split, normalize.
    tokens = color_class.replace("from-", "").replace("to-", "").split()
    if len(tokens) != 2:
        raise ValueError(f"Unexpected color class: {color_class!r}")

    def camel(tok: str) -> str:
        # e.g. 'emerald-500' → 'emerald500', 'sky-400' → 'sky400'
        parts = tok.split("-")
        return parts[0] + "".join(p.capitalize() for p in parts[1:])

    return f"{camel(tokens[0])}To{camel(tokens[1]).capitalize()}"


def collect_unique_gradients(topics: list[dict[str, Any]]) -> list[str]:
    seen: dict[str, None] = {}
    for t in topics:
        seen.setdefault(t["color"], None)
    return list(seen.keys())


# Tailwind palette hex values — a subset covering everything used in the source.
# Source of truth: https://tailwindcss.com/docs/customizing-colors
TAILWIND_HEX: dict[str, str] = {
    # amber
    "amber-400": "#FBBF24", "amber-500": "#F59E0B",
    "amber-600": "#D97706", "amber-700": "#B45309",
    # blue
    "blue-400": "#60A5FA", "blue-500": "#3B82F6", "blue-600": "#2563EB",
    # cyan
    "cyan-400": "#22D3EE", "cyan-500": "#06B6D4", "cyan-600": "#0891B2",
    # emerald
    "emerald-400": "#34D399", "emerald-500": "#10B981",
    "emerald-600": "#059669",
    # fuchsia
    "fuchsia-500": "#D946EF",
    # gray
    "gray-600": "#4B5563",
    # green
    "green-400": "#4ADE80", "green-500": "#22C55E", "green-600": "#16A34A",
    # indigo
    "indigo-400": "#818CF8", "indigo-500": "#6366F1", "indigo-600": "#4F46E5",
    # orange
    "orange-400": "#FB923C", "orange-500": "#F97316", "orange-600": "#EA580C",
    # pink
    "pink-400": "#F472B6", "pink-500": "#EC4899", "pink-600": "#DB2777",
    # purple
    "purple-400": "#C084FC", "purple-600": "#9333EA",
    # red
    "red-400": "#F87171", "red-500": "#EF4444",
    # rose
    "rose-500": "#F43F5E", "rose-600": "#E11D48",
    # sky
    "sky-500": "#0EA5E9", "sky-600": "#0284C7",
    # slate
    "slate-400": "#94A3B8", "slate-500": "#64748B", "slate-600": "#475569",
    # stone
    "stone-500": "#78716C",
    # teal
    "teal-500": "#14B8A6", "teal-600": "#0D9488",
    # violet
    "violet-400": "#A78BFA", "violet-500": "#8B5CF6", "violet-600": "#7C3AED",
    # yellow
    "yellow-400": "#FACC15", "yellow-500": "#EAB308",
}


def gradient_hex_stops(color_class: str) -> tuple[str, str]:
    tokens = color_class.replace("from-", "").replace("to-", "").split()
    if len(tokens) != 2:
        raise ValueError(f"Unexpected color class: {color_class!r}")
    for tok in tokens:
        if tok not in TAILWIND_HEX:
            raise ValueError(f"Missing Tailwind hex for {tok!r}")
    return TAILWIND_HEX[tokens[0]], TAILWIND_HEX[tokens[1]]


# ─────────────────────────────────────────────────────────────────────────────
# Swift emission
# ─────────────────────────────────────────────────────────────────────────────

def swift_escape(s: str) -> str:
    """Escape a Python string so it's a safe Swift string literal body."""
    # Normalize em/en dashes and curly quotes? — leave as UTF-8, they're fine.
    # Just escape backslashes, double-quotes, and newlines.
    return (
        s.replace("\\", "\\\\")
        .replace("\"", "\\\"")
        .replace("\n", "\\n")
        .replace("\r", "")
        .replace("\t", "\\t")
    )


def emit_swift(topics: list[dict[str, Any]]) -> str:
    # Build a stable mapping from Tailwind class → enum case name.
    unique_gradients = collect_unique_gradients(topics)
    gradient_cases: list[tuple[str, str, str, str]] = []
    # (caseName, originalClass, startHex, endHex)
    for g in unique_gradients:
        case = tailwind_to_case(g)
        a, b = gradient_hex_stops(g)
        gradient_cases.append((case, g, a, b))

    lines: list[str] = []
    lines.append("// ────────────────────────────────────────────────────────────────────────────")
    lines.append("// TopicsCatalog+Generated.swift")
    lines.append("// GENERATED BY scripts/generate_curriculum.py — DO NOT EDIT BY HAND.")
    lines.append("//")
    lines.append("// Source: bibleContent.js + bibleContentExtra.js + bibleContentExtra2.js")
    lines.append(f"// Topics: {len(topics)}")
    lines.append(f"// Lessons: {sum(len(t['lessons']) for t in topics)}")
    lines.append(
        f"// Questions: "
        f"{sum(len(l['questions']) for t in topics for l in t['lessons'])}"
    )
    lines.append("// ────────────────────────────────────────────────────────────────────────────")
    lines.append("")
    lines.append("import Foundation")
    lines.append("")
    lines.append("extension TopicsCatalog {")
    lines.append("")
    lines.append("    /// All topics in curriculum order: Base → Extra → Extra2.")
    lines.append("    static let generatedAll: [Topic] = [")

    for t_idx, t in enumerate(topics):
        case = tailwind_to_case(t["color"])
        lines.append("        Topic(")
        lines.append(f'            id: "{swift_escape(t["id"])}",')
        lines.append(f'            title: "{swift_escape(t["title"])}",')
        lines.append(f'            description: "{swift_escape(t["description"])}",')
        lines.append(f'            icon: "{swift_escape(t["icon"])}",')
        lines.append(f"            gradient: .{case},")
        lines.append("            lessons: [")
        for l_idx, lesson in enumerate(t["lessons"]):
            lines.append("                Lesson(")
            lines.append(f'                    id: "{swift_escape(lesson["id"])}",')
            lines.append(f'                    title: "{swift_escape(lesson["title"])}",')
            lines.append(f'                    scripture: "{swift_escape(lesson["scripture"])}",')
            lines.append(f'                    teaching: "{swift_escape(lesson["teaching"])}",')
            lines.append(f'                    keyVerse: "{swift_escape(lesson["keyVerse"])}",')
            lines.append("                    questions: [")
            for q_idx, q in enumerate(lesson["questions"]):
                options_src = ", ".join(
                    f'"{swift_escape(opt)}"' for opt in q["options"]
                )
                explanation = swift_escape(q.get("explanation", ""))
                lines.append("                        QuizQuestion(")
                lines.append(f'                            prompt: "{swift_escape(q["question"])}",')
                lines.append(f"                            options: [{options_src}],")
                lines.append(f"                            correctIndex: {int(q['correct'])},")
                lines.append(f'                            explanation: "{explanation}"')
                comma = "," if q_idx < len(lesson["questions"]) - 1 else ""
                lines.append(f"                        ){comma}")
            lines.append("                    ]")
            comma = "," if l_idx < len(t["lessons"]) - 1 else ""
            lines.append(f"                ){comma}")
        lines.append("            ]")
        comma = "," if t_idx < len(topics) - 1 else ""
        lines.append(f"        ){comma}")

    lines.append("    ]")
    lines.append("}")
    lines.append("")
    return "\n".join(lines)


# ─────────────────────────────────────────────────────────────────────────────
# Main
# ─────────────────────────────────────────────────────────────────────────────

def main() -> int:
    print(f"Reading source from: {SOURCE_DIR}")
    topics = load_all_topics()

    total_lessons = sum(len(t["lessons"]) for t in topics)
    total_questions = sum(
        len(l["questions"]) for t in topics for l in t["lessons"]
    )

    print(f"  Parsed {len(topics)} topics")
    print(f"  Parsed {total_lessons} lessons")
    print(f"  Parsed {total_questions} questions")

    # Uniqueness sanity check on question prompts.
    prompts: list[str] = []
    for t in topics:
        for l in t["lessons"]:
            for q in l["questions"]:
                prompts.append(q["question"])
    unique_prompts = set(prompts)
    print(f"  {len(unique_prompts)} unique question prompts "
          f"({len(prompts) - len(unique_prompts)} duplicates)")

    # Gradient audit.
    unique_gradients = collect_unique_gradients(topics)
    print(f"  {len(unique_gradients)} unique gradient combinations")
    for g in unique_gradients:
        # Validate we have hex for both stops.
        gradient_hex_stops(g)

    # Emit.
    OUTPUT_PATH.parent.mkdir(parents=True, exist_ok=True)
    swift = emit_swift(topics)
    OUTPUT_PATH.write_text(swift, encoding="utf-8")
    print(f"\nWrote {OUTPUT_PATH}")
    print(f"  {len(swift.splitlines())} lines, {len(swift)} bytes")
    return 0


if __name__ == "__main__":
    sys.exit(main())
