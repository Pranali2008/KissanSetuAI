
import sqlite3
from pathlib import Path

DATABASE_PATH = Path(__file__).parent / "farmer.db"

records = [
    {
        "topic": "yellow leaves",
        "crop": "tomato",
        "language": "English",
        "question": "Why are my tomato leaves turning yellow?",
        "answer": (
            "Tomato leaves can turn yellow because of nutrient "
            "deficiencies, too much or too little water, pests, "
            "or disease. Check the soil moisture and inspect the "
            "plant for other symptoms. Avoid adding fertilizer or "
            "plant protection products before identifying the cause. "
            "For a reliable diagnosis, consult your local agricultural "
            "officer or Krishi Vigyan Kendra (KVK)."
        ),
        "source": "General agricultural guidance",
    },
    {
        "topic": "पिवळी पाने",
        "crop": "टोमॅटो",
        "language": "Marathi",
        "question": "टोमॅटोची पाने पिवळी का पडत आहेत?",
        "answer": (
            "टोमॅटोची पाने पिवळी पडण्याची अनेक कारणे असू शकतात, "
            "जसे पोषकद्रव्यांची कमतरता, जास्त किंवा कमी पाणी, "
            "कीड किंवा रोग. मातीतील ओलावा तपासा आणि झाडावर "
            "इतर लक्षणे आहेत का ते पाहा. कारण न समजता खत किंवा "
            "औषध वापरू नका. योग्य निदानासाठी स्थानिक कृषी अधिकारी "
            "किंवा कृषी विज्ञान केंद्राचा (KVK) सल्ला घ्या."
        ),
        "source": "General agricultural guidance",
    },
]

connection = sqlite3.connect(str(DATABASE_PATH))
connection.row_factory = sqlite3.Row

try:
    cursor = connection.cursor()

    for record in records:
        existing = cursor.execute(
            """
            SELECT id
            FROM farming_knowledge
            WHERE language = ? AND question = ?
            """,
            (record["language"], record["question"]),
        ).fetchone()

        if existing:
            print(
                f"Already exists: {record['language']} "
                f"- {record['question']}"
            )
            continue

        cursor.execute(
            """
            INSERT INTO farming_knowledge
            (topic, crop, language, question, answer, source,
             offline_available)
            VALUES (?, ?, ?, ?, ?, ?, 1)
            """,
            (
                record["topic"],
                record["crop"],
                record["language"],
                record["question"],
                record["answer"],
                record["source"],
            ),
        )

        print(f"Added: {record['language']}")

    connection.commit()
    print("\nTomato records processed successfully.")
    print(f"Database: {DATABASE_PATH}")

finally:
    connection.close()
