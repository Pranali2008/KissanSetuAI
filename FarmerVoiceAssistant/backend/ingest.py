
import sqlite3
from pathlib import Path

DATABASE_PATH = Path(__file__).resolve().parent / "farmer.db"

sample_data = [
    # English: Rice irrigation
    (
        "irrigation", "rice", "English",
        "When should I water my rice crop?",
        "Rice water requirements depend on the crop stage, soil, and local conditions. Ask your local agricultural officer for a suitable irrigation schedule.",
        "Sample information"
    ),

    # Hindi: Rice irrigation
    (
        "सिंचाई", "धान", "Hindi",
        "धान की फसल में पानी कब देना चाहिए?",
        "धान की फसल में पानी की आवश्यकता उसकी अवस्था, मिट्टी और स्थानीय परिस्थितियों पर निर्भर करती है। सही सिंचाई कार्यक्रम के लिए स्थानीय कृषि अधिकारी से सलाह लें।",
        "Sample information"
    ),

    # Marathi: Rice irrigation
    (
        "सिंचन", "भात", "Marathi",
        "भाताच्या पिकाला पाणी कधी द्यावे?",
        "भाताच्या पिकाला पाण्याची गरज पिकाची अवस्था, माती आणि स्थानिक परिस्थितींवर अवलंबून असते. योग्य सिंचन वेळापत्रकासाठी स्थानिक कृषी अधिकाऱ्यांचा सल्ला घ्या.",
        "Sample information"
    ),

    # English: Tomato pests
    (
        "pest management", "tomato", "English",
        "How can I protect my tomato crops from pests?",
        "Inspect tomato plants regularly for insects, leaf damage, and other signs of pests. Remove badly affected plant parts when appropriate and use suitable pest-management methods after identifying the pest. Ask your local agricultural officer or Krishi Vigyan Kendra (KVK) for advice on the correct treatment and approved pesticides, if needed.",
        "General agricultural guidance"
    ),

    # Hindi: Tomato pests
    (
        "कीट प्रबंधन", "टमाटर", "Hindi",
        "टमाटर की फसल को कीटों से कैसे बचाएं?",
        "टमाटर के पौधों की नियमित जांच करें और पत्तियों पर कीटों या नुकसान के संकेत देखें। कीट की पहचान करने के बाद उचित नियंत्रण विधि अपनाएं। सही उपचार और आवश्यकता होने पर अनुमोदित कीटनाशक की जानकारी के लिए स्थानीय कृषि अधिकारी या कृषि विज्ञान केंद्र से सलाह लें।",
        "General agricultural guidance"
    ),

    # Marathi: Tomato pests
    (
        "कीड व्यवस्थापन", "टोमॅटो", "Marathi",
        "टोमॅटोच्या पिकाचे किडींपासून संरक्षण कसे करावे?",
        "टोमॅटोच्या झाडांची नियमित तपासणी करा आणि पानांवर किडींची किंवा नुकसानीची लक्षणे पाहा. कीड ओळखल्यानंतर योग्य नियंत्रण पद्धत वापरा. योग्य उपचार आणि आवश्यक असल्यास मान्यताप्राप्त कीटकनाशकांच्या माहितीसाठी स्थानिक कृषी अधिकारी किंवा कृषी विज्ञान केंद्राचा सल्ला घ्या.",
        "General agricultural guidance"
    )
]


def insert_sample_data():
    connection = sqlite3.connect(DATABASE_PATH)

    try:
        cursor = connection.cursor()
        inserted_count = 0

        for record in sample_data:
            topic, crop, language, question, answer, source = record

            # Prevent duplicate questions when this script is rerun
            cursor.execute("""
                SELECT id
                FROM farming_knowledge
                WHERE question = ? AND language = ?
                LIMIT 1
            """, (question, language))

            if cursor.fetchone() is not None:
                print(f"Already exists: {question}")
                continue

            cursor.execute("""
                INSERT INTO farming_knowledge
                (topic, crop, language, question, answer, source)
                VALUES (?, ?, ?, ?, ?, ?)
            """, record)

            inserted_count += 1

        connection.commit()

        cursor.execute("SELECT COUNT(*) FROM farming_knowledge")
        total_count = cursor.fetchone()[0]

        print("\nKnowledge insertion completed!")
        print("New records inserted:", inserted_count)
        print("Total knowledge records:", total_count)

    finally:
        connection.close()


if __name__ == "__main__":
    insert_sample_data()
