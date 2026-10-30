"""
Soil Health & Fertilizer Advisory Service for Farmer Voice Assistant
Provides soil testing guidance, nutrient management (NPK), organic carbon,
and soil amendment advice in English, Hindi, and Marathi.
"""

from typing import Dict, Any, Optional

SOIL_TYPES_DATA = {
    "black": {
        "id": "black",
        "name": {"en": "Black Cotton Soil (Regur)", "hi": "काली मिट्टी (रेगुर)", "mr": "काळी कसदार माती (रेगूर / भारी जमीन)"},
        "characteristics": {
            "en": "High clay content, excellent moisture retention, swells when wet and develops deep cracks when dry. Rich in Calcium, Magnesium, Potassium, but generally deficient in Nitrogen and Phosphorus.",
            "hi": "अधिक जलधारण क्षमता, भीगने पर चिपचिपी और सूखने पर गहरी दरारें। कैल्शियम और पोटाश में समृद्ध, नाइट्रोजन व फास्फोरस की कमी।",
            "mr": "पाणी धरून ठेवण्याची उत्तम क्षमता, ओली असताना चिकट व सुकल्यावर मोठ्या भेगा पडतात. चुना, मॅग्नेशियम व पालाश भरपूर, पण नत्र व स्फुरदची कमतरता."
        },
        "best_crops": {
            "en": "Cotton, Sugarcane, Soybean, Wheat, Gram (Chana), Jowar, Onion.",
            "hi": "कपास, गन्ना, सोयाबीन, गेहूं, चना, ज्वार, प्याज।",
            "mr": "कापूस, ऊस, सोयाबीन, गहू, हरभरा, ज्वारी, कांदा."
        },
        "management_tips": {
            "en": "Ensure proper surface drainage to prevent waterlogging. Apply gypsum if soil becomes sodic or compacted. Use deep summer plowing to aerate.",
            "hi": "जल निकासी की उचित व्यवस्था करें ताकि दलदल न बने। गर्मियों में गहरी जुताई करें और सड़ी गोबर खाद डालें।",
            "mr": "पाण्याचा निचरा होण्यासाठी चारी पाडा. उन्हाळ्यात खोल नांगरट करून जमीन तापू द्यावी. शेणखत आणि जिप्समचा वापर फायदेशीर ठरतो."
        }
    },
    "red": {
        "id": "red",
        "name": {"en": "Red Soil", "hi": "लाल मिट्टी", "mr": "तांबडी माती"},
        "characteristics": {
            "en": "Porous, light texture with iron oxide richness. Good drainage but low organic carbon and low water holding capacity. Deficient in Nitrogen, Phosphorus, and Humus.",
            "hi": "हल्की, भुरभुरी और लौह युक्त। पानी जल्दी निकलता है, जैविक कार्बन व नाइट्रोजन की कमी।",
            "mr": "हलकी ते मध्यम, सच्छिद्र आणि पाण्याचा निचरा वेगाने होणारी जमीन. सेंद्रिय कर्ब व नत्राचे प्रमाण कमी असते."
        },
        "best_crops": {
            "en": "Groundnut, Pulses, Millets (Ragi/Bajra), Tomato, Vegetables, Mango.",
            "hi": "मूंगफली, दलहन, बाजरा, रागी, टमाटर, सब्जियां।",
            "mr": "भुईमूग, कडधान्ये, नाचणी, बाजरी, टोमॅटो, भाजीपाला, आंबा."
        },
        "management_tips": {
            "en": "Apply heavy doses of Farmyard Manure (FYM) or Vermicompost (3-5 tons/acre) to build organic matter and moisture retention. Use drip irrigation.",
            "hi": "नमी रोकने के लिए प्रति एकड़ 3-4 ट्रॉली गोबर की खाद या वर्मीकंपोस्ट डालें। ड्रिप सिंचाई अपनाएं।",
            "mr": "जमिनीची पाणी धरून ठेवण्याची क्षमता वाढवण्यासाठी एकरी ४ ते ५ टन चांगले कुजलेले शेणखत किंवा गांडूळ खत वापरावे. ठिबक सिंचनाचा वापर करावा."
        }
    },
    "alluvial": {
        "id": "alluvial",
        "name": {"en": "Alluvial Soil (River Basin)", "hi": "जलोढ़ मिट्टी (दोमट)", "mr": "गाळाची जमीन / पोयटा माती"},
        "characteristics": {
            "en": "Highly fertile, balanced loam texture, ideal for most crops. Rich in Potash and Lime, moderate in Phosphorus.",
            "hi": "अत्यधिक उपजाऊ, दोमट बनावट। लगभग सभी फसलों के लिए सर्वोत्तम।",
            "mr": "नदीकाठची अत्यंत सुपीक, भुसभुशीत आणि पाण्याचा उत्तम निचरा असणारी जमीन. सर्व पिकांसाठी अतिशय उपयुक्त."
        },
        "best_crops": {
            "en": "Rice, Wheat, Sugarcane, Maize, Vegetables, Banana.",
            "hi": "धान, गेहूं, गन्ना, मक्का, सब्जियां, केला।",
            "mr": "भात, गहू, ऊस, मका, भाजीपाला, केळी."
        },
        "management_tips": {
            "en": "Maintain balanced NPK fertilization. Practice crop rotation with leguminous green manure crops (Dhaincha or Sunhemp).",
            "hi": "संतुलित उर्वरक दें। ढैंचा या सनई जैसी हरी खाद की फसलें लगाकर पलटें।",
            "mr": "ताग किंवा धैंचा सारखी हिरवळीची खते जमिनीत गाडून सेंद्रिय कर्ब १% च्या वर ठेवावा."
        }
    }
}


def get_soil_advisory(soil_type: Optional[str] = "black", language: str = "English") -> Dict[str, Any]:
    """Provide comprehensive soil health recommendations."""
    lang = language.strip().lower()
    lang_code = "mr" if lang in ["mr", "marathi"] else "hi" if lang in ["hi", "hindi"] else "en"

    key = "black"
    if soil_type:
        s = soil_type.casefold()
        if any(w in s for w in ["red", "लाल", "तांबडी"]):
            key = "red"
        elif any(w in s for w in ["alluvial", "गाळ", "दोमट", "पोयटा"]):
            key = "alluvial"

    data = SOIL_TYPES_DATA.get(key, SOIL_TYPES_DATA["black"])

    name = data["name"].get(lang_code, data["name"]["en"])
    char = data["characteristics"].get(lang_code, data["characteristics"]["en"])
    crops = data["best_crops"].get(lang_code, data["best_crops"]["en"])
    tips = data["management_tips"].get(lang_code, data["management_tips"]["en"])

    if lang_code == "mr":
        text = (
            f"जमिनीचा प्रकार: {name}\n\n"
            f"गुणधर्म: {char}\n\n"
            f"योग्य पिके: {crops}\n\n"
            f"सुधारणेचे उपाय: {tips}\n\n"
            f"महत्त्वाची टीप: रासायनिक खते देण्यापूर्वी दर २ वर्षांनी माती परीक्षण करून घेणे फायदेशीर ठरते."
        )
        prompt = "तुमच्या शेतातील मातीचा सामू (pH) किंवा माती परीक्षण अहवाल उपलब्ध आहे का? तसेच तुम्ही सध्या कोणती पिके घेणार आहात?"
    elif lang_code == "hi":
        text = (
            f"मिट्टी का प्रकार: {name}\n\n"
            f"विशेषताएं: {char}\n\n"
            f"उपयुक्त फसलें: {crops}\n\n"
            f"सुधार के उपाय: {tips}\n\n"
            f"सलाह: असंतुलित खाद से बचने के लिए हर 2 वर्ष में सॉइल टेस्ट अवश्य कराएं।"
        )
        prompt = "क्या आपके पास अपने खेत की मिट्टी की जांच (सॉइल हेल्थ कार्ड) रिपोर्ट है? और आप किस फसल की तैयारी कर रहे हैं?"
    else:
        text = (
            f"Soil Type: {name}\n\n"
            f"Key Characteristics: {char}\n\n"
            f"Recommended Crops: {crops}\n\n"
            f"Soil Improvement & Nutrition: {tips}\n\n"
            f"Note: Test your soil every 2 years through the Soil Health Card scheme to apply exact NPK doses."
        )
        prompt = "Do you have your recent soil test report or pH value? What crop are you planning to sow next?"

    return {
        "success": True,
        "soil_type_id": key,
        "soil_name": name,
        "advisory_text": text,
        "interactive_prompt": prompt
    }
