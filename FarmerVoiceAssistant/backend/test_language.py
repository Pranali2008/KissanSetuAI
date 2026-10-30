import sys
if sys.stdout.encoding.lower() != 'utf-8':
    sys.stdout.reconfigure(encoding='utf-8')

from lingua import Language, LanguageDetectorBuilder

detector = LanguageDetectorBuilder.from_languages(
    Language.ENGLISH,
    Language.HINDI,
    Language.MARATHI
).build()

questions = [
    "How much water does wheat need?",
    "गेहूं की सिंचाई कैसे करें?",
    "गव्हाला किती पाणी द्यावे?"
]

for question in questions:
    result = detector.detect_language_of(question)
    print(question, "->", result.name if result else "Unknown")