
import sqlite3
from database import DATABASE_PATH

records = [
    # WHEAT — सिंचाई / Irrigation
    (
        "irrigation", "wheat", "English",
        "When should I irrigate my wheat crop?",
        "Wheat irrigation depends on soil moisture, weather, soil type "
        "and crop growth stage. Important growth stages may need timely "
        "irrigation. Check field moisture and follow recommendations "
        "from your local agricultural department.",
        "General agricultural guidance"
    ),
    (
        "सिंचाई", "गेहूं", "Hindi",
        "गेहूं की फसल में पानी कब देना चाहिए?",
        "गेहूं में सिंचाई का समय मिट्टी की नमी, मौसम, मिट्टी के प्रकार "
        "और फसल की अवस्था पर निर्भर करता है। खेत की नमी देखें और "
        "अपने क्षेत्र के कृषि विभाग की सलाह के अनुसार सिंचाई करें।",
        "General agricultural guidance"
    ),
    (
        "सिंचन", "गहू", "Marathi",
        "गव्हाच्या पिकाला पाणी कधी द्यावे?",
        "गव्हाला पाणी देण्याची वेळ मातीतील ओलावा, हवामान, मातीचा "
        "प्रकार आणि पिकाच्या अवस्थेवर अवलंबून असते. शेतातील ओलावा "
        "तपासा आणि स्थानिक कृषी विभागाच्या सल्ल्यानुसार सिंचन करा.",
        "General agricultural guidance"
    ),

    # COTTON — Pest management
    (
        "pest management", "cotton", "English",
        "How can I protect my cotton crop from pests?",
        "Inspect cotton plants regularly for insects, damaged leaves "
        "and affected bolls. Identify the pest before selecting a "
        "control method. Use locally approved treatments only "
        "according to the label and agricultural expert advice.",
        "General agricultural guidance"
    ),
    (
        "कीट नियंत्रण", "कपास", "Hindi",
        "कपास की फसल को कीटों से कैसे बचाएं?",
        "कपास के पौधों और टिंडों की नियमित जांच करें। कीट और नुकसान "
        "की पहचान करने के बाद ही नियंत्रण का तरीका चुनें। स्थानीय "
        "रूप से स्वीकृत उपचार का उपयोग लेबल और कृषि विशेषज्ञ की "
        "सलाह के अनुसार करें।",
        "General agricultural guidance"
    ),
    (
        "कीड व्यवस्थापन", "कापूस", "Marathi",
        "कापसाच्या पिकाचे किडींपासून संरक्षण कसे करावे?",
        "कापसाच्या झाडांची आणि बोंडांची नियमित तपासणी करा. किडीची "
        "ओळख केल्यानंतरच नियंत्रणाची पद्धत निवडा. स्थानिक पातळीवर "
        "मान्य असलेली उत्पादने लेबलवरील सूचना आणि कृषी तज्ज्ञांच्या "
        "सल्ल्यानुसार वापरा.",
        "General agricultural guidance"
    ),

    # SUGARCANE — Irrigation
    (
        "irrigation", "sugarcane", "English",
        "How should I manage irrigation in sugarcane?",
        "Sugarcane water needs vary with growth stage, soil, weather "
        "and irrigation method. Check soil moisture, avoid prolonged "
        "waterlogging, and follow a schedule recommended for your "
        "region and field conditions.",
        "General agricultural guidance"
    ),
    (
        "सिंचाई", "गन्ना", "Hindi",
        "गन्ने की फसल में सिंचाई कैसे करें?",
        "गन्ने में पानी की जरूरत फसल की अवस्था, मिट्टी, मौसम और "
        "सिंचाई की विधि पर निर्भर करती है। मिट्टी की नमी देखें, "
        "लंबे समय तक जलभराव से बचें और अपने क्षेत्र के अनुसार "
        "सिंचाई की सलाह मानें।",
        "General agricultural guidance"
    ),
    (
        "सिंचन", "ऊस", "Marathi",
        "उसाच्या पिकाला पाणी कसे द्यावे?",
        "उसाला पाण्याची गरज पिकाची अवस्था, माती, हवामान आणि "
        "सिंचनाच्या पद्धतीवर अवलंबून असते. मातीतील ओलावा तपासा, "
        "दीर्घकाळ पाणी साचू देऊ नका आणि स्थानिक कृषी सल्ल्यानुसार "
        "सिंचनाचे नियोजन करा.",
        "General agricultural guidance"
    ),

    # VEGETABLES — Yellow leaves
    (
        "yellow leaves", "vegetables", "English",
        "Why are my vegetable crop leaves turning yellow?",
        "Yellow leaves may result from nutrient deficiencies, "
        "incorrect watering, pests or disease. Check soil moisture "
        "and inspect the plant for other symptoms. Identify the "
        "cause before applying fertilizer or plant protection products.",
        "General agricultural guidance"
    ),
    (
        "पीली पत्तियां", "सब्जियां", "Hindi",
        "सब्जियों की पत्तियां पीली क्यों हो रही हैं?",
        "पत्तियां पीली होने के कारणों में पोषक तत्वों की कमी, "
        "गलत सिंचाई, कीट या रोग शामिल हो सकते हैं। मिट्टी की नमी "
        "और पौधे के अन्य लक्षण देखें। खाद या दवा डालने से पहले "
        "कारण की पहचान करें।",
        "General agricultural guidance"
    ),
    (
        "पिवळी पाने", "भाजीपाला", "Marathi",
        "भाजीपाला पिकाची पाने पिवळी का पडतात?",
        "पाने पिवळी पडण्याची कारणे पोषकद्रव्यांची कमतरता, "
        "चुकीचे सिंचन, कीड किंवा रोग अशी असू शकतात. मातीतील "
        "ओलावा आणि झाडावरील इतर लक्षणे तपासा. खत किंवा औषध "
        "वापरण्यापूर्वी कारणाची खात्री करा.",
        "General agricultural guidance"
    ),

    # FRUIT CROPS — Fruit drop
    (
        "fruit drop", "fruit crops", "English",
        "Why are fruits falling from my fruit trees?",
        "Fruit drop can be related to natural thinning, irregular "
        "watering, weather stress, poor pollination, pests or disease. "
        "Check the crop and stage of fruit development. Seek local "
        "horticulture advice before applying any treatment.",
        "General agricultural guidance"
    ),
    (
        "फलों का गिरना", "फलदार फसलें", "Hindi",
        "मेरे फलदार पेड़ों से फल क्यों गिर रहे हैं?",
        "फलों का गिरना प्राकृतिक प्रक्रिया, अनियमित सिंचाई, मौसम "
        "के तनाव, परागण की समस्या, कीट या रोग के कारण हो सकता है। "
        "फसल और फल के विकास की अवस्था देखें तथा उपचार से पहले "
        "स्थानीय बागवानी विशेषज्ञ की सलाह लें।",
        "General agricultural guidance"
    ),
    (
        "फळगळ", "फळपिके", "Marathi",
        "फळझाडांची फळे गळून का पडतात?",
        "फळगळ नैसर्गिक प्रक्रिया, अनियमित सिंचन, हवामानातील ताण, "
        "परागीभवनातील अडचणी, कीड किंवा रोग यांमुळे होऊ शकते. "
        "फळांची वाढीची अवस्था तपासा आणि उपाय करण्यापूर्वी "
        "स्थानिक फलोत्पादन तज्ज्ञांचा सल्ला घ्या.",
        "General agricultural guidance"
    ),
]


def add_records():
    connection = sqlite3.connect(DATABASE_PATH)
    added = 0
    skipped = 0

    try:
        for record in records:
            existing = connection.execute(
                """
                SELECT id
                FROM farming_knowledge
                WHERE language = ? COLLATE NOCASE
                  AND question = ?
                """,
                (record[2], record[3])
            ).fetchone()

            if existing:
                skipped += 1
                continue

            connection.execute(
                """
                INSERT INTO farming_knowledge
                (topic, crop, language, question, answer,
                 source, offline_available)
                VALUES (?, ?, ?, ?, ?, ?, 1)
                """,
                record
            )
            added += 1

        connection.commit()
        print("Crop knowledge added successfully!")
        print("New records:", added)
        print("Duplicates skipped:", skipped)

    except Exception:
        connection.rollback()
        raise

    finally:
        connection.close()


if __name__ == "__main__":
    add_records()
