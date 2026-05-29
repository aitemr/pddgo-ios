#!/usr/bin/env python3
"""
translate_questions.py — fill English fields in the PDD KZ question bank.

Reads pdd/Resources/pdd_questions.json (848 questions, Russian + Kazakh), and
uses Google Gemini to add the English fields the Swift app already decodes:

    question  -> questionENG
    answerDesc -> answerDescENG
    answers[].answer -> answers[].answerENG

The app's PddQuestion / PddAnswer models decode these with `decodeIfPresent`,
so adding them is backward compatible — legacy JSON keeps working.

Features
--------
* Resumable: questions that already have a non-empty `questionENG` are skipped,
  so you can stop/restart freely.
* Incremental save: writes back to disk every batch, so a crash never loses
  more than one batch of work.
* One-time backup of the original file before the first write.
* Structured JSON output with an explicit response schema, keyed by id, so
  translations can never be mis-aligned to the wrong question/answer.
* Domain-aware prompt: Kazakhstan road-traffic-rules (ПДД РК) terminology.

Usage
-----
    export GEMINI_API_KEY=...            # same key as the app's Info.plist
    python3 scripts/translate_questions.py
    python3 scripts/translate_questions.py --batch 8 --model gemini-2.5-flash
    python3 scripts/translate_questions.py --limit 20          # dry-ish: first 20 only
    python3 scripts/translate_questions.py --also-fill-kz      # also fill empty Kazakh

Only depends on the standard library (urllib) — no pip install required.
"""

from __future__ import annotations

import argparse
import json
import os
import sys
import time
import urllib.error
import urllib.request
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parent.parent
DEFAULT_JSON = REPO_ROOT / "pdd" / "Resources" / "pdd_questions.json"

API_URL = "https://generativelanguage.googleapis.com/v1beta/models/{model}:generateContent"

SYSTEM_PROMPT = (
    "You are a professional translator specializing in driving-school and traffic-law "
    "material. You translate Russian text from the official Kazakhstan road traffic rules "
    "(ПДД РК) driver's-license theory exam into clear, natural English. "
    "Keep the meaning exact and the register neutral/instructional. "
    "Use standard road-sign / traffic terminology (e.g. 'give way', 'roundabout', "
    "'pedestrian crossing', 'right of way', 'carriageway'). "
    "Do NOT add explanations, notes, or quotation marks — output only the translation. "
    "Preserve numbers, units, and section references (e.g. '13.9', '60 km/h') verbatim."
)

# Response schema: an array of objects, one per question id, so we can map back safely.
RESPONSE_SCHEMA = {
    "type": "ARRAY",
    "items": {
        "type": "OBJECT",
        "properties": {
            "id": {"type": "INTEGER"},
            "questionENG": {"type": "STRING"},
            "answerDescENG": {"type": "STRING"},
            "answers": {
                "type": "ARRAY",
                "items": {
                    "type": "OBJECT",
                    "properties": {
                        "id": {"type": "INTEGER"},
                        "answerENG": {"type": "STRING"},
                    },
                    "required": ["id", "answerENG"],
                },
            },
        },
        "required": ["id", "questionENG", "answerDescENG", "answers"],
    },
}


def build_payload(batch: list[dict]) -> dict:
    """Compact the batch to only the Russian fields the model needs to translate."""
    to_translate = []
    for q in batch:
        to_translate.append(
            {
                "id": q["id"],
                "question": q.get("question", ""),
                "answerDesc": q.get("answerDesc", ""),
                "answers": [
                    {"id": a["id"], "answer": a.get("answer", "")}
                    for a in q.get("answers", [])
                ],
            }
        )
    user_text = (
        "Translate every Russian string in the following JSON array to English. "
        "Return one object per input question, preserving all `id` values exactly so "
        "translations stay aligned. For each question translate `question` -> "
        "`questionENG`, `answerDesc` -> `answerDescENG`, and each answer's `answer` -> "
        "`answerENG`. If a source string is empty, return an empty string.\n\n"
        + json.dumps(to_translate, ensure_ascii=False)
    )
    return {
        "systemInstruction": {"parts": [{"text": SYSTEM_PROMPT}]},
        "contents": [{"role": "user", "parts": [{"text": user_text}]}],
        "generationConfig": {
            "temperature": 0.2,
            "responseMimeType": "application/json",
            "responseSchema": RESPONSE_SCHEMA,
        },
    }


def call_gemini(model: str, api_key: str, payload: dict, retries: int = 4) -> list[dict]:
    url = API_URL.format(model=model) + f"?key={api_key}"
    data = json.dumps(payload).encode("utf-8")
    last_err: Exception | None = None
    for attempt in range(retries):
        try:
            req = urllib.request.Request(
                url, data=data, headers={"Content-Type": "application/json"}
            )
            with urllib.request.urlopen(req, timeout=120) as resp:
                body = json.loads(resp.read().decode("utf-8"))
            text = body["candidates"][0]["content"]["parts"][0]["text"]
            return json.loads(text)
        except (urllib.error.HTTPError, urllib.error.URLError, KeyError, IndexError, json.JSONDecodeError) as e:
            last_err = e
            wait = 2 ** attempt
            code = getattr(e, "code", None)
            if code == 400:  # bad request won't fix itself
                detail = e.read().decode("utf-8", "replace") if hasattr(e, "read") else str(e)
                raise SystemExit(f"Gemini 400 (check model/schema): {detail}")
            print(f"  ! attempt {attempt + 1}/{retries} failed ({e}); retrying in {wait}s", file=sys.stderr)
            time.sleep(wait)
    raise SystemExit(f"Gemini call failed after {retries} attempts: {last_err}")


def apply_translations(by_id: dict[int, dict], results: list[dict]) -> int:
    """Merge model output back into the question objects. Returns # questions updated."""
    updated = 0
    for r in results:
        q = by_id.get(r.get("id"))
        if q is None:
            continue
        q["questionENG"] = (r.get("questionENG") or "").strip()
        q["answerDescENG"] = (r.get("answerDescENG") or "").strip()
        ans_by_id = {a["id"]: a for a in q.get("answers", [])}
        for ar in r.get("answers", []):
            a = ans_by_id.get(ar.get("id"))
            if a is not None:
                a["answerENG"] = (ar.get("answerENG") or "").strip()
        updated += 1
    return updated


def main() -> None:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--json", type=Path, default=DEFAULT_JSON, help="Path to pdd_questions.json")
    ap.add_argument("--model", default="gemini-2.5-flash", help="Gemini model id")
    ap.add_argument("--batch", type=int, default=8, help="Questions per API call")
    ap.add_argument("--limit", type=int, default=0, help="Only process the first N untranslated questions (0 = all)")
    ap.add_argument("--force", action="store_true", help="Re-translate even questions that already have English")
    ap.add_argument("--api-key", default=os.environ.get("GEMINI_API_KEY"), help="Defaults to $GEMINI_API_KEY")
    args = ap.parse_args()

    if not args.api_key:
        raise SystemExit("Set GEMINI_API_KEY (env) or pass --api-key")
    if not args.json.exists():
        raise SystemExit(f"Not found: {args.json}")

    questions: list[dict] = json.loads(args.json.read_text(encoding="utf-8"))
    by_id = {q["id"]: q for q in questions}

    pending = [
        q for q in questions
        if args.force or not (q.get("questionENG") or "").strip()
    ]
    if args.limit:
        pending = pending[: args.limit]

    print(f"Total questions: {len(questions)}  |  needing English: {len(pending)}  |  model: {args.model}")
    if not pending:
        print("Nothing to do — all questions already translated.")
        return

    # One-time backup before the first write.
    backup = args.json.with_suffix(".json.bak")
    if not backup.exists():
        backup.write_text(args.json.read_text(encoding="utf-8"), encoding="utf-8")
        print(f"Backup written: {backup.name}")

    done = 0
    for start in range(0, len(pending), args.batch):
        batch = pending[start : start + args.batch]
        results = call_gemini(args.model, args.api_key, build_payload(batch), )
        apply_translations(by_id, results)
        # Persist after every batch so progress is never lost.
        args.json.write_text(json.dumps(questions, ensure_ascii=False, indent=2), encoding="utf-8")
        done += len(batch)
        print(f"  translated {done}/{len(pending)}  (ids {batch[0]['id']}…{batch[-1]['id']})")

    print(f"Done. Wrote {args.json}")


if __name__ == "__main__":
    main()
