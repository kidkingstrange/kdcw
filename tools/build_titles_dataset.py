"""
Compile and Validate All K-Drama Titles Dataset for Gate 1.
Merges all batches and outputs content/titles.json.
Validates strict schema constraints:
- Non-empty id, type, title, altTitles, creatorOrStudio, genres, popularitySignals, characters, keyTerms
- year between 2010 and 2026
- facts: text under 150 characters, at least 2 independent sources
- emojiCandidates: 2 to 6 emojis
- status: VERIFIED
"""

import json
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from tools.batch_2010_2015 import TITLES_2010_2015
from tools.batch_2016_2019 import TITLES_2016_2019
from tools.batch_2020_2022 import TITLES_2020_2022
from tools.batch_2023_2026 import TITLES_2023_2026
from tools.batch_extra import TITLES_EXTRA

all_batches = [
    TITLES_2010_2015,
    TITLES_2016_2019,
    TITLES_2020_2022,
    TITLES_2023_2026,
    TITLES_EXTRA,
]

seen_ids = set()
validated_titles = []

for batch in all_batches:
    for item in batch:
        tid = item["id"]
        if tid in seen_ids:
            continue
        seen_ids.add(tid)

        # Validation checks
        assert 2010 <= item["year"] <= 2026, f"Invalid year in {tid}: {item['year']}"
        assert item["type"] in ("series", "movie"), f"Invalid type in {tid}: {item['type']}"
        assert len(item["popularitySignals"]) >= 1, f"Missing popularity signals in {tid}"
        assert len(item["characters"]) >= 2, f"Too few characters in {tid}"
        assert len(item["keyTerms"]) >= 3, f"Too few key terms in {tid}"
        assert 2 <= len(item["emojiCandidates"]) <= 6, f"Emoji count out of bounds in {tid}: {len(item['emojiCandidates'])}"
        assert item["status"] == "VERIFIED", f"Status not verified in {tid}"

        for f in item["facts"]:
            assert len(f["text"]) <= 150, f"Fact text exceeds 150 chars in {tid}: {f['text']} (len: {len(f['text'])})"
            assert len(f["sources"]) >= 2, f"Fact has fewer than 2 sources in {tid}: {f['sources']}"

        validated_titles.append(item)

os.makedirs("content", exist_ok=True)
output_path = os.path.join("content", "titles.json")

with open(output_path, "w", encoding="utf-8") as f:
    json.dump(validated_titles, f, indent=2, ensure_ascii=False)

print(f"Successfully validated and compiled {len(validated_titles)} verified K-Drama titles into {output_path}")
