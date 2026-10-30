import sqlite3
from database import DATABASE_PATH

# Each record contains:
# topic, crop, language, question, answer, source

records = [
    # ---------------- RICE: IRRIGATION ----------------
    (
        "irrigation", "rice", "English",
        "When should I water my rice crop?",
        "Rice water requirements depend on the growth stage, soil, "
        "weather and cultivation method. Maintain the water level "
        "recommended for your rice-growing method and consult your "
        "local agricultural officer for a suitable schedule.",
        "General agricultural guidance"
    ),
    (
        "सिंचाई", "धान", "Hindi",
        "धान की फसल में पानी कब देना चाहिए?",
        "धान की फसल में पानी की जरूरत उसकी अवस्था, मिट्टी, मौसम "
        "और खेती की विधि पर निर्भर करती है। अपनी खेती की विधि के "
        "अनुसार पानी दें और सही समय-सारणी के लिए स्थानीय कृषि "
        "अधिकारी से सलाह लें।",
        "General agricultural guidance"
    ),
    (
        "सिंचन", "भात", "Marathi",
        "भाताच्या पिकाला पाणी कधी द्यावे?",
        "भाताच्या पिकाला पाण्याची गरज पिकाची अवस्था, माती, "
        "हवामान आणि लागवडीच्या पद्धतीवर अवलंबून असते. योग्य "
        "सिंचन वेळापत्रकासाठी स्थानिक कृषी अधिकाऱ्यांचा सल्ला घ्या.",
        "General agricultural guidance"
    ),

    # ---------------- TOMATO: PESTS ----------------
    (
        "pest management", "tomato", "English",
        "How can I protect my tomato crop from pests?",
        "Inspect tomato plants regularly for insects and leaf damage. "
        "Remove heavily affected plant parts when appropriate and "
        "identify the pest before choosing a control method. Use only "
        "locally approved treatments according to the product label "
        "and agricultural expert advice.",
        "General agricultural guidance"
    ),
    (
        "कीट नियंत्रण", "टमाटर", "Hindi",
        "टमाटर की फसल को कीटों से कैसे बचाएं?",
        "टमाटर के पौधों की नियमित जांच करें और पत्तियों पर कीटों "
        "या नुकसान के लक्षण देखें। नियंत्रण का तरीका चुनने से पहले "
        "कीट की पहचान करें। केवल स्थानीय रूप से स्वीकृत उपचार का "
        "लेबल और कृषि विशेषज्ञ की सलाह के अनुसार उपयोग करें।",
        "General agricultural guidance"
    ),
    (
        "कीड व्यवस्थापन", "टोमॅटो", "Marathi",
        "टोमॅटोच्या पिकाचे किडींपासून संरक्षण कसे करावे?",
        "टोमॅटोच्या झाडांची नियमित तपासणी करून पानांवरील किडी "
        "आणि नुकसानीची लक्षणे पाहा. उपाय निवडण्यापूर्वी किडीची "
        "ओळख करा. फक्त स्थानिक पातळीवर मान्य असलेली उत्पादने "
        "लेबलवरील सूचना आणि कृषी तज्ज्ञांच्या सल्ल्यानुसार वापरा.",
        "General agricultural guidance"
    ),

    # ---------------- SOIL TESTING ----------------
    (
        "soil testing", "general", "English",
        "Why should I test my farm soil?",
        "Soil testing helps estimate soil nutrient levels and other "
        "important properties. It can guide fertilizer decisions and "
        "help avoid unnecessary application. Collect samples as "
        "instructed by your local soil testing laboratory.",
        "General agricultural guidance"
    ),
    (
        "मिट्टी की जांच", "सामान्य", "Hindi",
        "खेत की मिट्टी की जांच क्यों करनी चाहिए?",
        "मिट्टी की जांच से पोषक तत्वों और मिट्टी की अन्य विशेषताओं "
        "की जानकारी मिलती है। इससे खाद की जरूरत समझने और अनावश्यक "
        "खाद डालने से बचने में मदद मिलती है। नमूना लेने के लिए "
        "स्थानीय मिट्टी परीक्षण प्रयोगशाला के निर्देश मानें।",
        "General agricultural guidance"
    ),
    (
        "माती परीक्षण", "सामान्य", "Marathi",
        "शेतातील मातीची तपासणी का करावी?",
        "मातीच्या तपासणीमुळे पोषकद्रव्यांचे प्रमाण आणि मातीच्या "
        "इतर गुणधर्मांची माहिती मिळते. त्यामुळे खतांची गरज ठरवण्यास "
        "आणि अनावश्यक खतांचा वापर टाळण्यास मदत होते. मातीचा नमुना "
        "घेताना स्थानिक माती परीक्षण प्रयोगशाळेच्या सूचना पाळा.",
        "General agricultural guidance"
    ),

    # ---------------- YELLOW LEAVES ----------------
    (
        "yellow leaves", "general", "English",
        "Why are my crop leaves turning yellow?",
        "Yellow leaves can result from nutrient deficiencies, excess "
        "or insufficient water, pests, or disease. Check soil moisture "
        "and inspect the whole plant for other symptoms. A soil test "
        "or local agricultural expert can help identify the cause.",
        "General agricultural guidance"
    ),
    (
        "पीली पत्तियां", "सामान्य", "Hindi",
        "फसल की पत्तियां पीली क्यों हो रही हैं?",
        "पत्तियां पीली होने के कई कारण हो सकते हैं, जैसे पोषक तत्वों "
        "की कमी, ज्यादा या कम पानी, कीट या रोग। मिट्टी की नमी और "
        "पौधे के अन्य लक्षण देखें। कारण पता करने के लिए मिट्टी की "
        "जांच या स्थानीय कृषि विशेषज्ञ की सलाह लें।",
        "General agricultural guidance"
    ),
    (
        "पिवळी पाने", "सामान्य", "Marathi",
        "पिकाची पाने पिवळी का पडतात?",
        "पाने पिवळी पडण्याची कारणे पोषकद्रव्यांची कमतरता, जास्त "
        "किंवा कमी पाणी, कीड किंवा रोग अशी असू शकतात. मातीतील "
        "ओलावा आणि झाडावरील इतर लक्षणे तपासा. कारण समजण्यासाठी "
        "मातीची तपासणी किंवा स्थानिक कृषी तज्ज्ञांचा सल्ला घ्या.",
        "General agricultural guidance"
    ),

    # ---------------- WEED MANAGEMENT ----------------
    (
        "weed management", "general", "English",
        "How can I control weeds in my field?",
        "Weeds compete with crops for water, nutrients and sunlight. "
        "Choose suitable control methods based on the crop, weed "
        "species and growth stage. Follow local agricultural advice "
        "and use herbicides only when approved and according to "
        "their labels.",
        "General agricultural guidance"
    ),
    (
        "खरपतवार नियंत्रण", "सामान्य", "Hindi",
        "खेत में खरपतवार को कैसे नियंत्रित करें?",
        "खरपतवार फसल के साथ पानी, पोषक तत्वों और धूप के लिए "
        "प्रतिस्पर्धा करते हैं। फसल, खरपतवार की पहचान और उसकी "
        "अवस्था के अनुसार नियंत्रण का तरीका चुनें। स्थानीय कृषि "
        "सलाह मानें और खरपतवारनाशक केवल स्वीकृत होने पर लेबल "
        "के निर्देशों के अनुसार इस्तेमाल करें।",
        "General agricultural guidance"
    ),
    (
        "तण नियंत्रण", "सामान्य", "Marathi",
        "शेतातील तण कसे नियंत्रित करावे?",
        "तण पिकांशी पाणी, पोषकद्रव्ये आणि सूर्यप्रकाशासाठी "
        "स्पर्धा करतात. पीक, तणाची ओळख आणि वाढीची अवस्था "
        "यांनुसार नियंत्रणाची पद्धत निवडा. स्थानिक कृषी सल्ला "
        "पाळा आणि मान्य तणनाशकांचा वापर फक्त लेबलवरील "
        "सूचनांनुसार करा.",
        "General agricultural guidance"
    ),
]


def expand_database():
    connection = sqlite3.connect(DATABASE_PATH)
    connection.row_factory = sqlite3.Row
    added = 0
    skipped = 0

    try:
        for record in records:
            topic, crop, language, question, answer, source = record

            existing = connection.execute(
                """
                SELECT id
                FROM farming_knowledge
                WHERE language = ? COLLATE NOCASE
                  AND question = ?
                """,
                (language, question)
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

        print("Knowledge database expansion completed!")
        print("New records added:", added)
        print("Duplicate records skipped:", skipped)
        print("Total records processed:", len(records))

    except Exception:
        connection.rollback()
        raise

    finally:
        connection.close()


if __name__ == "__main__":
    expand_database()
