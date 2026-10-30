
import sqlite3
from pathlib import Path

db_path = Path(__file__).resolve().parent / "farmer.db"

question = "टमाटर के पत्ते पीले क्यों हो रहे हैं?"

answer = (
    "टमाटर के पत्ते पीले होने के कई कारण हो सकते हैं, "
    "जैसे पोषक तत्वों की कमी, अधिक या कम पानी, कीट या रोग। "
    "मिट्टी की नमी और पौधों के अन्य लक्षणों की जांच करें। "
    "सही कारण जानने के लिए मिट्टी की जांच करवाएं या "
    "स्थानीय कृषि अधिकारी या कृषि विज्ञान केंद्र (KVK) से सलाह लें।"
)

with sqlite3.connect(db_path) as connection:
    existing = connection.execute(
        """
        SELECT id FROM farming_knowledge
        WHERE language = ? AND question = ?
        """,
        ("Hindi", question),
    ).fetchone()

    if existing:
        print("This Hindi record already exists. No changes made.")
    else:
        connection.execute(
            """
            INSERT INTO farming_knowledge
            (topic, crop, language, question, answer, source,
             offline_available)
            VALUES (?, ?, ?, ?, ?, ?, ?)
            """,
            (
                "पत्ती की समस्या",
                "टमाटर",
                "Hindi",
                question,
                answer,
                "General agricultural guidance",
                1,
            ),
        )
        print("Hindi tomato record added successfully!")

print("Database:", db_path)
