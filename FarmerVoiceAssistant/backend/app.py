import base64
import re
import sqlite3
from pathlib import Path
from typing import Optional

import requests
from lingua import Language, LanguageDetectorBuilder
from fastapi import FastAPI, HTTPException, Query, UploadFile, File, Form, Body
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
# Import modular agricultural service modules
from weather_service import get_live_weather
from schemes_service import get_all_schemes, search_schemes
from disease_service import analyze_disease_image
from market_service import get_market_prices
from soil_service import get_soil_advisory
from crop_advice_service import get_crop_advice
from machinery_service import get_all_machinery, get_machinery_by_id


# --------------------------------------------------
# 1. CONFIGURATION
# --------------------------------------------------

DATABASE_PATH = Path(__file__).resolve().parent / "farmer.db"

OLLAMA_URL = "http://localhost:11434/api/generate"
OLLAMA_MODEL = "gemma3:4b"

SUPPORTED_LANGUAGES = {
    "en": "English",
    "english": "English",
    "hi": "Hindi",
    "hindi": "Hindi",
    "mr": "Marathi",
    "marathi": "Marathi",
}

app = FastAPI(
    title="KissanSetu AI API",
    description=(
        "Multilingual farming information, live weather, government schemes, "
        "disease scanning, mandi rates, and interactive conversational guidance."
    ),
    version="2.6.0",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=False,
    allow_methods=["*"],
    allow_headers=["*"],
)


# --------------------------------------------------
# 2. DATABASE CONNECTION
# --------------------------------------------------

def get_connection():
    connection = sqlite3.connect(DATABASE_PATH)
    connection.row_factory = sqlite3.Row
    return connection


# --------------------------------------------------
# 3. NORMALIZE QUESTIONS
# --------------------------------------------------

def normalize_question(text: str) -> str:
    """Normalize common English, Hindi and Marathi variations."""

    text = (text or "").casefold().strip()

    corrections = {
        # Marathi variations and speech recognition
        "गवा चा": "गव्हाच्या",
        "गवा च्या": "गव्हाच्या",
        "गव्हा च्या": "गव्हाच्या",
        "गव्हाला": "गहू",
        "गव्हाच्या": "गहू",
        "गव्हाचे": "गहू",
        "गव्हात": "गहू",
        "पिक्टाला": "पिकाला",
        "पिकटाला": "पिकाला",
        "पानि": "पाणी",
        "कदी": "कधी",
        "देवे": "द्यावे",

        # Hindi variations and speech recognition
        "गेहुकी": "गेहूं की",
        "गेहूकी": "गेहूं की",
        "गेहु की": "गेहूं की",
        "गेहूंकी": "गेहूं की",
        "गेहूं में": "गेहूं",
    }

    for incorrect, correct in corrections.items():
        text = text.replace(incorrect, correct)

    return text


def extract_words(text: str) -> set:
    """Extract English and Devanagari words."""

    return set(
        re.findall(
            r"[\u0900-\u097F]+|[a-zA-Z]+|\d+",
            (text or "").casefold(),
        )
    )


# --------------------------------------------------
# 4. STOPWORDS
# --------------------------------------------------

STOPWORDS = {
    "i", "the", "a", "an", "is", "are", "am",
    "when", "what", "how", "should", "do", "does",
    "my", "in", "to", "for", "of", "and", "can",
    "from", "it", "this", "that", "on", "with",
    "be", "your", "you", "me", "please",
    "crop", "crops", "farm", "farming", "farmer",
    "tell", "about", "much", "many", "need",
    "give", "get", "use", "used", "isn't",
    "कब", "क्या", "कैसे", "क्यों", "किस",
    "की", "का", "के", "में", "से", "को",
    "पर", "और", "है", "हैं", "था", "थे",
    "लिए", "चाहिए", "बताएं", "बताइए",
    "काय", "कसे", "कधी", "कशी", "कशा",
    "आहे", "आहेत", "मध्ये", "साठी", "आणि",
    "करावे", "सांगावे", "सांगा", "द्यावे",
    "पिकाला", "पिकाच्या",
}

MATCH_STOPWORDS = STOPWORDS


# --------------------------------------------------
# 5. CROP DETECTION
# --------------------------------------------------

CROP_ALIASES = {
    "wheat": ["wheat", "गेहूं", "गेहु", "गहू", "गव्ह"],
    "rice": ["rice", "paddy", "धान", "चावल", "भात"],
    "tomato": ["tomato", "tomatoes", "टमाटर", "टोमॅटो"],
    "cotton": ["cotton", "कपास", "कापूस"],
    "sugarcane": ["sugarcane", "गन्ना", "गन्ने", "ऊस", "उसाचा", "उसाच्या", "उसाला", "उसाचे"],
    "maize": ["maize", "corn", "मक्का", "मकई"],
    "onion": ["onion", "onions", "कांदा", "कांद्याला", "कांद्याची", "प्याज"],
    "soybean": ["soybean", "soya", "सोयाबीन"],
    "ladyfinger": ["ladyfinger", "okra", "bhindi", "भिंडी", "bhendi", "भेंडी", "ladysfinger", "lady finger"],
    "chili": ["chili", "chilli", "chillies", "chilies", "pepper", "मिर्च", "मिरची", "मिरच्या", "लाल मिर्च"],
    "broccoli": ["broccoli", "ब्रोकोली", "ब्रोकली"],
    "apple": ["apple", "सफरचंद", "सेब", "सफ़रचंद"],
    "mango": ["mango", "mangoes", "आम", "आंबा", "आंबे", "केरी"],
    "pomegranate": ["pomegranate", "अनार", "डाळिंब"],
    "banana": ["banana", "केळी", "केला", "केले", "बनाना"],
    "grapes": ["grapes", "grape", "द्राक्ष", "द्राक्षे", "अंगूर"],
    "potato": ["potato", "potatoes", "आलू", "बटाटा", "बटाटे"],
    "cabbage": ["cabbage", "पत्ता गोबी", "कोबी", "पत्तागोबी"],
    "cauliflower": ["cauliflower", "फूल गोबी", "फूलकोबी", "फुलगोबी"],
    "groundnut": ["groundnut", "peanut", "मूंगफली", "भुईमूग", "शेंगदाणे"],
    "turmeric": ["turmeric", "haldi", "हळद", "हल्दी"],
    "ginger": ["ginger", "adrak", "अदरक", "आले"],
    "garlic": ["garlic", "lahsun", "लसून", "लहसुन"],
    "watermelon": ["watermelon", "तरबूज", "कलिंगड"],
    "cucumber": ["cucumber", "खीरा", "काकडी"],
    "peas": ["peas", "pea", "मटर", "वाटाणा", "वाटाणे"],
    "spinach": ["spinach", "palak", "पालक"],
    "beetroot": ["beetroot", "beet", "चुकंदर", "बीट"],
    "carrot": ["carrot", "गाजर"],
    "radish": ["radish", "मूली", "मुळा"],
    "sorghum": ["sorghum", "jowar", "ज्वारी", "ज्वार"],
    "pearl_millet": ["bajra", "bajri", "बाजरी", "बाजरा"],
    "chickpea": ["chickpea", "gram", "chana", "चना", "हरभरा"],
    "lentil": ["lentil", "masoor", "मसूर", "मसुर"],
    "moong": ["moong", "mung", "green gram", "मूग", "मूंग"],
    "sesame": ["sesame", "til", "तिळ", "तिल"],
    "sunflower": ["sunflower", "सूरजमुखी", "सूर्यफुल"],
}


def detect_crop(text: str) -> str | None:
    """Identify a supported crop and common word variations."""

    text = normalize_question(text)

    for crop_name, aliases in CROP_ALIASES.items():
        for alias in aliases:
            if re.search(r"[a-z]", alias, re.IGNORECASE):
                pattern = rf"\b{re.escape(alias.casefold())}\b"
                if re.search(pattern, text):
                    return crop_name
            elif alias in text:
                return crop_name

    return None


# --------------------------------------------------
# 6. LANGUAGE DETECTION
# --------------------------------------------------

LANGUAGE_DETECTOR = LanguageDetectorBuilder.from_languages(
    Language.ENGLISH,
    Language.HINDI,
    Language.MARATHI,
).build()

DETECTED_LANGUAGE_NAMES = {
    Language.ENGLISH: "English",
    Language.HINDI: "Hindi",
    Language.MARATHI: "Marathi",
}


def detect_language(text: str, requested_language=None) -> str:
    """Detect English, Hindi, or Marathi automatically."""

    if requested_language:
        language = SUPPORTED_LANGUAGES.get(
            requested_language.strip().casefold()
        )
        if language is None:
            raise HTTPException(
                status_code=400,
                detail="Supported languages: English, Hindi, Marathi.",
            )
        return language

    normalized_text = normalize_question(text)

    # Common Marathi words that may be misclassified as Hindi
    marathi_markers = [
        "उसाच्या", "उसाला", "उसाचे",
        "गव्हाला", "गव्हाच्या",
        "पिकाला", "द्यावे",
        "कसे", "कशी", "कधी", "आहे", "आणि", "नाही",
        "टोमॅटोची", "पाने", "पिवळी", "पडत", "खत", "कीड",
        "बाजारभाव", "हवामान", "पाऊस", "योजना"
    ]

    if any(marker in normalized_text for marker in marathi_markers):
        return "Marathi"

    detected = LANGUAGE_DETECTOR.detect_language_of(text or "")

    if detected in DETECTED_LANGUAGE_NAMES:
        return DETECTED_LANGUAGE_NAMES[detected]

    return "English"


# --------------------------------------------------
# 7. QUESTION INTENT DETECTION
# --------------------------------------------------

INTENT_KEYWORDS = {
    "quantity": [
        "how much", "how many", "quantity", "amount",
        "कितना", "कितनी", "कितने", "मात्रा",
        "किती", "प्रमाण",
    ],
    "timing": [
        "when", "what time", "कब", "कबसे", "समय",
        "कधी", "केव्हा",
    ],
    "frequency": [
        "how often", "how many times", "कितनी बार",
        "किती वेळा",
    ],
    "method": [
        "how to", "how do", "how should",
        "कैसे", "कैसा", "कसे", "कशी",
    ],
    "reason": [
        "why", "क्यों", "कशामुळे", "का",
    ],
}


def detect_intent(text: str) -> str | None:
    """Identify the main purpose of a farming question."""

    text = normalize_question(text).casefold()
    words = extract_words(text)

    for intent, keywords in INTENT_KEYWORDS.items():
        for keyword in keywords:
            if " " in keyword:
                if keyword in text:
                    return intent
            elif keyword in words:
                return intent

    return None


# --------------------------------------------------
# 8. QUESTION SYNONYMS
# --------------------------------------------------

SYNONYM_GROUPS = [
    {"wheat", "गेहूं", "गेहु", "गहू", "गव्ह"},
    {"rice", "paddy", "धान", "चावल", "भात"},
    {"tomato", "tomatoes", "टमाटर", "टोमॅटो"},
    {"cotton", "कपास", "कापूस"},
    {"sugarcane", "गन्ना", "ऊस"},
    {"maize", "corn", "मक्का", "मकई"},
    {"onion", "कांदा", "प्याज"},
    {"soybean", "सोयाबीन"},
    {"water", "irrigate", "irrigation", "irrigated", "watering", "पाणी", "सिंचाई", "सिंचन"},
    {"fertilizer", "fertiliser", "खाद", "उर्वरक", "खत"},
    {"disease", "illness", "रोग", "बीमारी"},
    {"pest", "insect", "कीट", "किड", "अळी"},
    {"spray", "छिड़काव", "फवारणी"},
    {"quantity", "amount", "कितना", "कितनी", "किती", "प्रमाण"},
]

SYNONYM_LOOKUP = {}
for group in SYNONYM_GROUPS:
    canonical = sorted(group, key=lambda word: (len(word), word))[0]
    for word in group:
        SYNONYM_LOOKUP[word] = canonical


def canonicalize_words(text: str) -> set:
    """Normalize question keywords using the synonym groups."""

    text = normalize_question(text)
    words = extract_words(text)

    normalized = set()
    for word in words:
        canonical = SYNONYM_LOOKUP.get(word, word)
        if canonical not in MATCH_STOPWORDS:
            normalized.add(canonical)

    return normalized


# --------------------------------------------------
# 9. DOMAIN QUERY DETECTORS (WEATHER, SCHEMES, ETC.)
# --------------------------------------------------

def is_weather_query(text: str) -> bool:
    """Check if farmer is asking about weather, temperature, rain, or climate."""
    keywords = [
        "weather", "temperature", "temp", "rain", "rainfall", "forecast", "climate", "humid", "wind",
        "हवामान", "तापमान", "पाऊस", "गारपीट", "वादळ", "आर्द्रता", "थंडी", "ऊन",
        "मौसम", "तापमान", "बारिश", "बरसात", "ओलावृष्टि", "हवा", "गर्मी"
    ]
    t = (text or "").casefold()
    return any(k in t for k in keywords)


def extract_location_hint(text: str) -> Optional[str]:
    """Extract location name from farmer question if mentioned."""
    locations = [
        "pune", "पुणे", "nashik", "नाशिक", "नासिक", "nagpur", "नागपूर", "नागपुर",
        "solapur", "सोलापूर", "satara", "सातारा", "kolhapur", "कोल्हापूर",
        "sambhajinagar", "aurangabad", "संभाजीनगर", "औरंगाबाद",
        "ahmednagar", "ahilyanagar", "अहमदनगर", "अहिल्यानगर",
        "amravati", "अमरावती", "baramati", "बारामती", "mumbai", "मुंबई", "delhi", "दिल्ली"
    ]
    t = (text or "").casefold()
    for loc in locations:
        if loc in t:
            return loc
    return "Pune"


def is_schemes_query(text: str) -> bool:
    """Check if farmer is asking about government schemes, subsidies, or loans."""
    keywords = [
        "scheme", "schemes", "subsidy", "subsidies", "pm kisan", "pmkisan", "fasal bima", "kusum", "kcc",
        "योजना", "योजनांची", "योजनांचा", "अनुदान", "पीएम किसान", "पीक विमा", "कुसुम", "कर्ज", "महाडीबीटी",
        "योजनाएं", "सब्सिडी", "फसल बीमा", "ऋण", "सरकारी योजना"
    ]
    t = (text or "").casefold()
    return any(k in t for k in keywords)


# --------------------------------------------------
# 10. DETAILED INTERACTIVE LLM GENERATION
# --------------------------------------------------

def generate_llm_answer(question: str, language: str | None = None) -> str:
    """
    Generate detailed, practical agricultural advice using local Ollama model.
    Proactively asks clarifying follow-up questions to the farmer like an interactive chatbot.
    Never gives canned dismissive disclaimers like 'consult KVK or local officer'.
    """

    language_name = detect_language(question, language)

    language_instructions = {
        "English": (
            "Write in clear, respectful, practical English. Provide a comprehensive, "
            "detailed answer with step-by-step guidance, dosages, and timings. "
            "Conclude by asking 1-2 interactive follow-up questions about the farmer's crop stage "
            "or farm conditions to explore further."
        ),
        "Hindi": (
            "Write entirely in natural, respectful, detailed Hindi using Devanagari script. "
            "Provide clear, comprehensive guidance with practical steps, dosages or remedies. "
            "Do NOT end with canned disclaimers like 'कृषि अधिकारी से संपर्क करें'. "
            "Instead, conclude with 1-2 interactive follow-up questions asking about the farmer's "
            "crop stage, soil, or symptoms to provide more detailed help."
        ),
        "Marathi": (
            "Write entirely in natural, respectful, detailed Marathi using Devanagari script, "
            "specifically suited for farmers in Maharashtra. Provide comprehensive, practical "
            "advice with clear steps, dosages or remedies. Do NOT end with canned disclaimers like "
            "'स्थानिक कृषी अधिकाऱ्यांशी संपर्क साधा'. "
            "Instead, conclude by asking 1-2 helpful interactive follow-up questions to the farmer "
            "(e.g., asking about crop stage, soil type, leaf symptoms, or irrigation) to explore further."
        ),
    }

    system_prompt = f"""
You are an intelligent, caring, and expert agricultural voice assistant for farmers in India.

Respond in {language_name}.

Language instructions:
{language_instructions[language_name]}

Core Guidelines:
1. Provide a comprehensive, clear, and detailed answer explaining the 'why' and 'how'.
2. When discussing crop care, pests, diseases, or fertilizers, give practical step-by-step methods, organic/chemical solutions with standard dosages, and preventive tips.
3. NEVER say generic dismissive disclaimers like 'consult your local agriculture officer', 'consult Krishi Vigyan Kendra', or 'visit a local expert'. You are their knowledgeable guide.
4. Always act like an interactive chatbot: end your answer with 1 or 2 relevant, probing follow-up questions (such as asking about their crop's current age/stage, soil type, irrigation method, or specific symptoms) so the farmer can provide more details and you can help them even more.
5. Keep the tone respectful, encouraging, and farmer-friendly.
"""

    payload = {
        "model": OLLAMA_MODEL,
        "system": system_prompt,
        "prompt": f"Farmer's question in {language_name}:\n{question}",
        "stream": False,
        "options": {
            "temperature": 0.2,
            "top_p": 0.85,
            "repeat_penalty": 1.05,
            "num_predict": 650,
        },
    }

    response = requests.post(
        OLLAMA_URL,
        json=payload,
        timeout=120,
    )

    response.raise_for_status()
    result = response.json()
    answer = result.get("response", "").strip()

    if not answer:
        raise ValueError("The local AI model returned an empty answer.")

    return answer


def clean_and_enrich_db_answer(answer: str, crop: Optional[str], language_name: str) -> str:
    """Remove legacy canned disclaimers and add interactive exploration questions."""
    canned_phrases = [
        "and consult your local agricultural officer for a suitable schedule.",
        "Ask your local agricultural officer for a suitable irrigation schedule.",
        "Ask your local agricultural officer or Krishi Vigyan Kendra (KVK) for advice on the correct treatment and approved pesticides, if needed.",
        "consult your local agricultural officer for a suitable schedule.",
        "योग्य सिंचन वेळापत्रकासाठी स्थानिक कृषी अधिकाऱ्यांचा सल्ला घ्या.",
        "स्थानिक कृषी अधिकारी किंवा कृषी विज्ञान केंद्राचा सल्ला घ्या.",
        "सही सिंचाई कार्यक्रम के लिए स्थानीय कृषि अधिकारी से सलाह लें।",
        "स्थानीय कृषि अधिकारी या कृषि विज्ञान केंद्र से सलाह लें।"
    ]

    cleaned = answer
    for phrase in canned_phrases:
        cleaned = cleaned.replace(phrase, "").strip()

    crop_display = crop.capitalize() if crop else "crop"
    if language_name == "Marathi":
        followup = (
            f"\n\nअधिक माहितीसाठी: तुमच्या {crop_display} पिकाचे वय किती आहे आणि "
            f"जमिनीचा प्रकार कोणता आहे? हे सांगितल्यास मी पुढील खते आणि फवारणीचे अचूक नियोजन सांगू शकेन."
        )
    elif language_name == "Hindi":
        followup = (
            f"\n\nअधिक जानकारी के लिए: आपकी {crop_display} की फसल कितने दिनों की है और "
            f"मिट्टी का प्रकार क्या है? यह बताने पर हम आगे के खाद और स्प्रे का सटीक शेड्यूल बता सकते हैं।"
        )
    else:
        followup = (
            f"\n\nTo help you further: What is the current age/growth stage of your {crop_display} crop, "
            f"and what soil type do you have? Letting me know helps provide specific nutrition and spraying schedules."
        )

    return f"{cleaned} {followup}".strip()


# --------------------------------------------------
# 11. EXPERT AGRICULTURAL INTELLIGENCE ENGINE & LLM FALLBACK
# --------------------------------------------------

def generate_expert_agricultural_answer(question: str, language_name: str) -> str:
    """
    Expert agricultural reasoning engine that answers ANY question about crops,
    vegetables, fruits, pests, fertilizers, soil, and farming practices
    clearly in English, Hindi, or Marathi without defaulting to a single crop.
    """
    q_lower = (question or "").casefold().strip()
    crop = detect_crop(question)
    lang = language_name.strip().capitalize()
    if lang not in ["English", "Hindi", "Marathi"]:
        lang = "English"

    # Identify topic intent
    is_disease = any(w in q_lower for w in [
        "disease", "pest", "insect", "fungus", "blight", "curl", "rot", "yellow", "spots", "wilt",
        "रोग", "कीट", "कीड़ा", "फफूंद", "झुलसा", "पीला", "सड़न", "धब्बा", "सुंडी", "माइट", "चुरड़ा",
        "अळी", "बुरशी", "करपा", "पिवळे", "सड", "चुरडा", "बोकड्या", "तुडतुडे", "मावा", "खोडकिडा", "कीड"
    ])
    is_fert = any(w in q_lower for w in [
        "fertilizer", "nutrient", "urea", "dap", "npk", "potash", "manure", "compost", "dose", "zinc",
        "उर्वरक", "खाद", "यूरिया", "डीएपी", "पोटाश", "एनपीके", "खुराक", "जिंक", "गोबर",
        "खत", "युरिया", "डीएपी", "पोटॅश", "शेणखत", "मात्रा", "डोस", "सूक्ष्मअन्नद्रव्य"
    ])
    is_water = any(w in q_lower for w in [
        "water", "irrigation", "drip", "sprinkler", "moisture", "flood",
        "सिंचाई", "पानी", "ड्रिप", "नमी", "फव्वारा",
        "पाणी", "सिंचन", "ठिबक", "तुषार", "ओलावा"
    ])
    is_sowing = any(w in q_lower for w in [
        "sow", "sowing", "seed", "variety", "spacing", "nursery", "plant", "transplant",
        "बुवाई", "बीज", "किस्म", "दूरी", "नर्सरी", "पौध", "रोपाई",
        "पेरणी", "बियाणे", "वाण", "अंतर", "रोपवाटिका", "लागवड", "पुनर्लागवड"
    ])
    is_harvest = any(w in q_lower for w in [
        "harvest", "picking", "yield", "production", "mature", "maturity",
        "कटाई", "तुड़ाई", "उपज", "पैदावार", "पकाव",
        "काढणी", "तोडणी", "उत्पादन", "उतारा", "पक्वता"
    ])

    # Crop specific responses
    if crop == "ladyfinger":
        if is_disease:
            if lang == "Marathi":
                return (
                    "🌿 भेंडी (Okra) वरील कीड व रोग व्यवस्थापन:\n\n"
                    "१. पिवळा शिरा रोग (Yellow Vein Mosaic Virus): हा रोग पांढऱ्या माशीमुळे पसरतो. पाने पिवळी पडतात आणि शिरा जाळीसारख्या दिसतात.\n"
                    "• उपाय: एकरी १५-२० पिवळे चिकट सापळे लावा. ५% निंबोळी अर्क (Neem oil 5ml/L) फवारा. तीव्र प्रादुर्भावात डायफेंथियुरॉन ५०% WP १ ग्रॅम किंवा इमिडाक्लोप्रिड ०.५ मिली/लिटर फवारा.\n"
                    "२. फळ पोखरणाऱ्या अळ्या: कोवळ्या भेंडीमध्ये छिद्र करून नुकसान करतात.\n"
                    "• उपाय: क्लोरांट्रानिलीप्रोल (कोराजन) ०.३ मिली किंवा इमामेक्टिन बेन्झोएट ०.५ ग्रॅम प्रति लिटर पाण्यात फवारावे."
                )
            elif lang == "Hindi":
                return (
                    "🌿 भिंडी (Ladyfinger / Okra) कीट एवं रोग प्रबंधन:\n\n"
                    "१. पीला मोज़ेक वायरस (YVMV): सफेद मक्खी द्वारा फैलता है, पत्तियां पीली पड़ जाती हैं।\n"
                    "• उपाय: पीले चिपचिपे ट्रैप (15/एकड़) लगाएं। 5 मिली नीम तेल प्रति लीटर पानी में छिड़कें। सफेद मक्खी नियंत्रण के लिए इमिडाक्लोप्रिड 0.5 मिली या डायफेन्थियूरॉन 1 ग्राम/लीटर छिड़कें।\n"
                    "२. तना व फल छेदक सुंडी:\n"
                    "• उपाय: इमामेक्टिन बेंजोएट 5% SG (0.5 ग्राम/लीटर) या कोराजन (0.3 मिली/लीटर) का छिड़काव करें।"
                )
            else:
                return (
                    "🌿 Ladyfinger (Okra / Bhindi) Pest & Disease Management:\n\n"
                    "1. Yellow Vein Mosaic Virus (YVMV): Transmitted by whiteflies, turning leaf veins yellow and chlorotic.\n"
                    "• Control: Install yellow sticky traps (15-20/acre). Spray 5% Neem oil (5ml/L) or Imidacloprid 17.8% SL @ 0.5ml/L for vector control.\n"
                    "2. Fruit & Shoot Borer: Caterpillars bore into tender pods causing deformity.\n"
                    "• Control: Spray Emamectin Benzoate 5% SG @ 0.5g/L or Chlorantraniliprole 18.5% SC @ 0.3ml/L."
                )
        elif is_fert:
            if lang == "Marathi":
                return (
                    "🧪 भेंडी खत व्यवस्थापन:\n\n"
                    "• लागवडीवेळी (Basal dose): एकरी ५-८ टन चांगले कुजलेले शेणखत + ५० किलो डीएपी (DAP) + २५ किलो म्युरेट ऑफ पोटॅश (MOP).\n"
                    "• वाढीच्या काळात (३० दिवसांनी): २५ किलो युरिया + सूक्ष्मअन्नद्रव्ये (झिंक, बोरॉन).\n"
                    "• फुलधारणेवेळी (४५ दिवसांनी): २५ किलो युरिया आणि १९:१९:१९ विद्राव्य खत ३ ग्रॅम/लिटर फवारावे."
                )
            elif lang == "Hindi":
                return (
                    "🧪 भिंडी के लिए उर्वरक व खाद प्रबंधन:\n\n"
                    "• बुवाई के समय: 5-8 टन सड़ी गोबर खाद + 50 किग्रा DAP + 25 किग्रा पोटाश प्रति एकड़।\n"
                    "• बुवाई के 30 दिन बाद: 25 किग्रा यूरिया की टॉप ड्रेसिंग करें।\n"
                    "• फूल व फल बनते समय (45 दिन): 25 किग्रा यूरिया + 19:19:19 घुलनशील खाद का पर्णीय छिड़काव करें।"
                )
            else:
                return (
                    "🧪 Ladyfinger (Okra) Fertilizer Schedule:\n\n"
                    "• Basal application: 5-8 tons decomposed FYM + 50 kg DAP + 25 kg MOP per acre.\n"
                    "• 30 days after sowing: Top dress 25 kg Urea.\n"
                    "• Flowering & fruiting (45 days): Top dress 25 kg Urea + foliar spray 19:19:19 (3g/L) for pod shine."
                )

    elif crop == "chili":
        if is_disease:
            if lang == "Marathi":
                return (
                    "🌶️ मिरची (Chili) रोग व कीड नियंत्रण:\n\n"
                    "१. बोकड्या / चुरडा-मुरडा (Leaf Curl / Thrips & Mites):\n"
                    "• पाने वर किंवा खाली वाकडी होतात, वाढ खुंटते. हे थ्रिप्स (फुलकिडे) व पांढऱ्या माशीमुळे होते.\n"
                    "• उपाय: एकरी २० निळे व पिवळे चिकट सापळे लावा. थ्रिप्ससाठी फिप्रोनिल ५% एससी (१.५ मिली/लि.) किंवा फेनपायरोक्सिमेट (१ मिली/लि.) फवारावे.\n"
                    "२. फळकुज व करपा (Dieback & Anthracnose):\n"
                    "• फांद्या शेंड्याकडून वाळतात व फळांवर काळे डाग पडतात.\n"
                    "• उपाय: अझॉक्सीस्ट्रॉबिन + डायफेनोकोनॅझोल (१ मिली/लि.) किंवा कॉपर ऑक्झिक्लोराईड (२.५ ग्रॅ/लि.) फवारावे."
                )
            elif lang == "Hindi":
                return (
                    "🌶️ मिर्च (Chili) कीट एवं रोग समाधान:\n\n"
                    "१. पत्ती मरोड़ / चुरड़ा रोग (Leaf Curl):\n"
                    "• थ्रिप्स और माइट्स के रस चूसने से पत्तियां नाव की तरह मुड़ जाती हैं।\n"
                    "• उपाय: नीले व पीले स्टिकी ट्रैप लगाएं। फिप्रोनिल 5% SC (1.5 मिली/लीटर) या नीम तेल (5 मिली/लीटर) का छिड़काव करें।\n"
                    "२. डाईबैक व फल सड़न (एंथ्रेक्नोज़):\n"
                    "• उपाय: कॉपर ऑक्सीक्लोराइड 2.5 ग्राम/लीटर या एज़ॉक्सीस्ट्रोबिन 1 मिली/लीटर का छिड़काव करें।"
                )
            else:
                return (
                    "🌶️ Chili Pest & Disease Management:\n\n"
                    "1. Chili Leaf Curl (Churada-Murada / Bokadya): Caused by thrips and yellow mite feeding, leaves curl upward or downward.\n"
                    "• Remedy: Install blue & yellow sticky traps (20/acre). Spray Fipronil 5% SC @ 1.5ml/L or Diafenthiuron 50% WP @ 1g/L.\n"
                    "2. Anthracnose / Die-back: Dark circular sunken lesions on fruit and drying branch tips.\n"
                    "• Remedy: Spray Azoxystrobin + Difenoconazole @ 1ml/L or Mancozeb @ 2.5g/L."
                )

    elif crop == "broccoli":
        if lang == "Marathi":
            return (
                "🥦 ब्रोकोली (Broccoli) लागवड व उत्पादन मार्गदर्शन:\n\n"
                "• हवामान व हंगाम: रब्बी (सप्टेंबर ते नोव्हेंबर लागवड), थंड व कोरडे हवामान (१५°C ते २५°C).\n"
                "• रोपे व पुनर्लागवड: प्रोट्रेमध्ये २५-३० दिवस वाढवलेली निरोगी रोपे ४५ x ४५ सेमी अंतरावर गादीवाफ्यावर लावावीत.\n"
                "• खते: एकरी ८-१० टन शेणखत + १२०:६०:६० किलो NPK प्रति हेक्टर. खोड पोकळ पडू नये म्हणून बोरॉन (Boron 2g/L) फवारावे.\n"
                "• सिंचन: ठिबक सिंचनाने नियमित ओलावा ठेवावा. गड्डा भरताना पाण्याचा ताण पडू देऊ नये.\n"
                "• काढणी: गड्डा घट्ट हिरवा असताना व कळ्या उमलण्यापूर्वी ६०-७५ दिवसांनी तोडणी करावी."
            )
        elif lang == "Hindi":
            return (
                "🥦 ब्रोकोली (Broccoli) उन्नत खेती मार्गदर्शन:\n\n"
                "• मौसम: रबी मौसम (सितंबर से नवंबर रोपाई), 15°C से 22°C तापमान सर्वोत्तम।\n"
                "• रोपाई व दूरी: 25-30 दिन की स्वस्थ पौध 45 x 45 सेमी की दूरी पर मेड़ों पर लगाएं।\n"
                "• उर्वरक: 10 टन गोबर खाद + 120:60:60 NPK प्रति हेक्टेयर। तना खोखला होने से बचाने के लिए 2 ग्राम बोरॉन प्रति लीटर छिड़कें।\n"
                "• सिंचाई: ड्रिप से नियमित समान नमी बनाए रखें।\n"
                "• तुड़ाई: फूल खिलने से पहले 65-75 दिन में ठोस हरे हेड काटें।"
            )
        else:
            return (
                "🥦 Broccoli Cultivation & Management Guide:\n\n"
                "• Season & Climate: Rabi (transplanting Sept-Nov), cool climate (15°C–22°C).\n"
                "• Planting & Spacing: Transplant 25-30 day seedlings at 45 x 45 cm spacing on raised beds with drip.\n"
                "• Nutrition: FYM 8-10 tons + 120:60:60 kg NPK/ha. Spray Boron (2g/L) to prevent hollow stem disorder.\n"
                "• Irrigation: Regular uniform moisture via drip; avoid water stress during head formation.\n"
                "• Harvesting: Harvest compact dark-green heads in 60-75 days before florets begin opening."
            )

    elif crop == "apple":
        if lang == "Marathi":
            return (
                "🍎 सफरचंद (Apple) लागवड व व्यवस्थापन:\n\n"
                "• हवामान व वाण: थंड हवामान (८००-१२०० चिलिंग तास). उष्ण प्रदेशासाठी कमी थंडी लागणारे वाण: HRMN-99, अण्णा (Anna), डोर्सेट गोल्डन.\n"
                "• लागवड: डिसेंबर-फेब्रुवारीमध्ये कलमे लावावीत. पारंपारिक ५ x ५ मीटर, सघन लागवड (High density) ३ x १.५ मीटर.\n"
                "• छाटणी (Pruning): जानेवारी महिन्यात झाडाची योग्य छाटणी करून फळधारणेच्या फांद्या (Spurs) मोकळ्या कराव्यात.\n"
                "• खत व पाणी: प्रति झाड ३०-४० किलो शेणखत + ५०० ग्रॅम नत्र, २५० ग्रॅम स्फुरद, ७५० ग्रॅम पालाश हिवाळ्यात द्यावे. फळवाढीच्या काळात (एप्रिल-जून) ठिबकने नियमित पाणी द्यावे.\n"
                "• रोग: खवले कीड (San Jose scale) व खपल्या रोग (Apple Scab) नियंत्रणासाठी कॉपर बुरशीनाशक फवारावे."
            )
        elif lang == "Hindi":
            return (
                "🍎 सेब (Apple) बागवानी एवं प्रबंधन:\n\n"
                "• जलवायु व किस्में: कम ठंड वाले क्षेत्रों के लिए HRMN-99, अन्ना (Anna), और डोर्सेट गोल्डन उपयुक्त हैं।\n"
                "• रोपाई: दिसंबर से फरवरी में 1x1x1 मीटर गड्ढों में कलमी पौधे लगाएं।\n"
                "• छंटाई (Pruning): जनवरी में वार्षिक प्रूनिंग करें ताकि नए फलदार स्पर बन सकें।\n"
                "• पोषण: वयस्क पेड़ को 30-40 किग्रा गोबर खाद + NPK (500:250:750 ग्राम) दें। बोरॉन व कैल्शियम से फल चमकदार बनते हैं।\n"
                "• सिंचाई: फल बनने और बड़े होने के समय (अप्रैल से जून) ड्रिप से नियमित सिंचाई करें।"
            )
        else:
            return (
                "🍎 Apple Orchard Management & Care:\n\n"
                "• Climate & Varieties: Traditional temperate (800-1200 chill hours) and Low-Chill varieties for plains: HRMN-99, Anna, Dorsett Golden.\n"
                "• Planting & Spacing: Standard 5x5m; High Density 3x1.5m on trellises. Plant dormant grafts in Dec–Feb.\n"
                "• Pruning: Perform annual dormant pruning in January to stimulate fruiting spurs and sunlight entry.\n"
                "• Nutrition: Mature tree: 35-40 kg FYM + 500g N, 250g P2O5, 750g K2O. Spray Calcium & Boron for fruit shine & firmness.\n"
                "• Irrigation: Critical during fruit enlargement (April to June) via regulated drip irrigation."
            )

    # General agricultural query resolution when no specific crop or topic is matched
    if is_disease:
        if lang == "Marathi":
            return (
                "🌿 पीक रोग व पिवळेपणा निवारण उपाय:\n\n"
                "१. पाने पिवळी पडणे (Chlorosis): नत्राची कमतरता किंवा पाणी साचल्यामुळे मुळे कुजल्यास पाने पिवळी पडतात. १९:१९:१९ खत ५ ग्रॅम/लिटर + चिलेटेड झिंक १ ग्रॅम/लिटर फवारावे.\n"
                "२. बुरशीजन्य रोग (करपा, सड, भुरी): मँकोझेब २.५ ग्रॅम किंवा कॉपर ऑक्झिक्लोराईड २.५ ग्रॅम प्रति लिटर पाण्यात मिसळून फवारावे.\n"
                "३. रसशोषक किडी (मावा, तुडतुडे, पांढरी माशी): ५ मिली कडुलिंब (नीम) तेल प्रति लिटर पाण्यात मिसळून फवारणी करावी किंवा पिवळे चिकट सापळे लावावेत."
            )
        elif lang == "Hindi":
            return (
                "🌿 फसल कीट व रोग निवारण सलाह:\n\n"
                "१. पत्तियां पीली पड़ना: जलभराव या नाइट्रोजन व सूक्ष्म पोषक तत्वों की कमी से होता है। 19:19:19 (5 ग्राम/लीटर) + सूक्ष्म पोषक तत्व का पर्णीय छिड़काव करें।\n"
                "२. फफूंद रोग (झुलसा, सड़न, धब्बा): मैंकोजेब (2.5 ग्राम/लीटर) या कॉपर ऑक्सीक्लोराइड का छिड़काव करें।\n"
                "३. रस चूसक कीट: 5 मिली नीम तेल प्रति लीटर पानी में मिलाकर छिड़कें और पीले चिपचिपे ट्रैप लगाएं।"
            )
        else:
            return (
                "🌿 Plant Disease & Yellowing Resolution:\n\n"
                "1. Leaf Yellowing (Chlorosis): Usually caused by water stagnation, nitrogen deficiency, or lack of micronutrients (Zinc/Iron). Spray soluble 19:19:19 @ 5g/L with chelated micronutrients.\n"
                "2. Fungal Diseases (Blight, Rot, Spot): Spray Mancozeb 75% WP @ 2.5g/L or Azoxystrobin + Difenoconazole @ 1ml/L.\n"
                "3. Sucking Pests (Whitefly, Thrips, Aphids): Spray Cold-pressed Neem Oil @ 5ml/L or install yellow and blue sticky traps (15-20 traps/acre)."
            )

    if is_fert:
        if lang == "Marathi":
            return (
                "🧪 संतुलित खत व्यवस्थापन (NPK & सूक्ष्मअन्नद्रव्ये):\n\n"
                "• नत्र (Nitrogen / Urea): झाडांची शाकीय वाढ, हिरवेगार पानांसाठी आवश्यक. जास्त देऊ नये.\n"
                "• स्फुरद (Phosphorus / DAP / Single Super Phosphate): मुळांची मजबूत वाढ आणि फुलधारणेसाठी सुरुवातीलाच द्यावे.\n"
                "• पालाश (Potash / MOP / 0:0:50): फळांचा आकार, चकाकी, वजन आणि रोगप्रतिकारशक्ती वाढवण्यासाठी फळधारणेच्या वेळी द्यावे.\n"
                "• सेंद्रिय खते: पेरणीपूर्वी एकरी ५-१० टन कुजलेले शेणखत किंवा गांडूळ खत जमिनीत मिसळल्यास रासायनिक खतांची कार्यक्षमता वाढते."
            )
        elif lang == "Hindi":
            return (
                "🧪 संतुलित उर्वरक प्रबंधन (NPK व जैविक खाद):\n\n"
                "• नाइट्रोजन (यूरिया): वानस्पतिक बढ़वार व पत्तियों के विकास के लिए।\n"
                "• फास्फोरस (DAP / SSP): मजबूत जड़ों के विकास व भरपूर फूल आने के लिए बुवाई पर दें।\n"
                "• पोटाश (MOP): फलों के आकार, मिठास, वजन व रोग प्रतिरोधक क्षमता बढ़ाने हेतु।\n"
                "• जैविक खाद: बुवाई से पहले 5-8 टन सड़ी गोबर खाद या वर्मीकम्पोस्ट अवश्य मिलाएं।"
            )
        else:
            return (
                "🧪 Balanced Crop Nutrition Guide (NPK & Organics):\n\n"
                "• Nitrogen (N): Promotes vigorous vegetative growth and chlorophyll synthesis. Apply in split doses.\n"
                "• Phosphorus (P): Critical for root establishment and heavy flowering. Apply as basal dose at sowing.\n"
                "• Potassium (K): Essential for fruit sizing, grain filling, sugar development, and drought resistance.\n"
                "• Organics: Incorporate 5-8 tons of decomposed FYM or vermicompost per acre before planting to boost soil microbial activity."
            )

    # General crop advisory lookup if crop exists
    if crop:
        offline_adv = get_crop_advice(crop, language_name)
        return f"{offline_adv['advice_text']}\n\n{offline_adv['interactive_prompt']}"

    # Default friendly greeting and comprehensive guidance
    if lang == "Marathi":
        return (
            "🌾 किसानसेतू AI शेती सल्लागार:\n\n"
            "मी तुम्हाला कोणत्याही पिकाविषयी (उदा. भेंडी, मिरची, ब्रोकोली, सफरचंद, टोमॅटो, कांदा, कापूस, ऊस, आंबा, डाळिंब इ.), "
            "रोग व कीड व्यवस्थापन, खतांचे नियोजन, हवामान किंवा बाजारभावाविषयी सविस्तर मार्गदर्शन करू शकेन.\n\n"
            "कृपया तुमच्या पिकाचे नाव किंवा समस्या सांगा (उदा. 'मिरचीचे पाने चुरडत आहेत', 'भेंडीसाठी कोणते खत द्यावे?', 'ब्रोकोली कशी लावावी?')."
        )
    elif lang == "Hindi":
        return (
            "🌾 किसानसेतु AI कृषि सहायक:\n\n"
            "हम आपको किसी भी फसल (जैसे भिंडी, मिर्च, ब्रोकोली, सेब, टमाटर, प्याज, कपास, गन्ना, आम, अनार आदि), "
            "कीट व रोग प्रबंधन, खाद व सिंचाई, मंडी भाव या मौसम की सटीक जानकारी दे सकते हैं।\n\n"
            "कृपया अपनी फसल या समस्या बताएं (जैसे 'मिर्च की पत्तियां मुड़ रही हैं', 'भिंडी में कौन सा खाद डालें?', 'ब्रोकोली की खेती कैसे करें?')."
        )
    else:
        return (
            "🌾 KissanSetu AI Agricultural Assistant:\n\n"
            "I provide verified expert guidance for ANY crop (including Ladyfinger/Okra, Chili, Broccoli, Apple, Tomato, Onion, Cotton, Wheat, Sugarcane, Mango, Pomegranate, etc.), "
            "pest & disease diagnosis, fertilizer dosages, drip irrigation schedules, and live Mandi rates.\n\n"
            "Please ask your question or mention your crop (e.g. 'How to control chili leaf curl?', 'What fertilizer for ladyfinger?', 'How to plant broccoli?')."
        )


def llm_fallback(question: str, language: str | None = None):
    language_name = detect_language(question, language)

    try:
        answer = generate_llm_answer(question, language_name)

        return {
            "found": True,
            "database_match": False,
            "matched_question": None,
            "answer": answer,
            "language": language_name,
            "source": f"Local LLM: {OLLAMA_MODEL}",
            "answer_type": "ai_generated_verified",
            "explanation": {
                "method": "Local Gemma3 Agricultural Intelligence",
                "interactive": True,
            },
        }

    except requests.RequestException:
        answer = generate_expert_agricultural_answer(question, language_name)
        return {
            "found": True,
            "database_match": False,
            "answer": answer,
            "language": language_name,
            "source": "KissanSetu AI Expert Agricultural Intelligence",
            "answer_type": "offline_expert",
            "explanation": {
                "method": "Comprehensive Agronomy & Crop Advisory Engine",
                "interactive": True,
            },
        }

    except (ValueError, RuntimeError):
        answer = generate_expert_agricultural_answer(question, language_name)
        return {
            "found": True,
            "database_match": False,
            "answer": answer,
            "language": language_name,
            "source": "KissanSetu AI Agricultural Knowledge Engine",
            "answer_type": "offline_expert",
        }



# --------------------------------------------------
# 12. MAIN /ASK ENDPOINT
# --------------------------------------------------

@app.get("/ask")
def ask_question(
    question: str = Query(..., min_length=2),
    language: str | None = Query(default=None),
):
    question = normalize_question(question)
    language_name = detect_language(question, language)

    # 1. LIVE WEATHER DETECTION & HANDLING
    if is_weather_query(question):
        location = extract_location_hint(question) or "Pune"
        weather_res = get_live_weather(location_query=location, language=language_name)
        full_weather_ans = f"{weather_res['voice_summary']}\n\n{weather_res['interactive_prompt']}"

        return {
            "found": True,
            "database_match": False,
            "matched_question": "Live Weather Information",
            "answer": full_weather_ans,
            "language": language_name,
            "source": "Open-Meteo Real-Time Weather API",
            "answer_type": "live_weather",
            "weather_data": weather_res,
            "explanation": {
                "method": "Real-time live temperature and agricultural weather advisory",
                "location": weather_res.get("location"),
                "temperature": weather_res.get("temperature_celsius")
            }
        }

    # 2. GOVERNMENT SCHEMES DETECTION & HANDLING
    if is_schemes_query(question):
        schemes_res = search_schemes(question, language_name)
        matched_schemes = schemes_res.get("schemes", [])

        if matched_schemes:
            top = matched_schemes[0]
            if language_name == "Marathi":
                ans = (
                    f"योजना माहिती: {top['title']}\n\n"
                    f"तपशील: {top['description']}\n\n"
                    f"फायदे: {top['benefits']}\n\n"
                    f"पात्रता व कागदपत्रे: {top['eligibility']} (कागदपत्रे: {top['documents']})\n\n"
                    f"अधिकृत संकेतस्थळ (वेबसाईट): {top['website_url']}\n\n"
                    f"{schemes_res['interactive_prompt']}"
                )
            elif language_name == "Hindi":
                ans = (
                    f"योजना जानकारी: {top['title']}\n\n"
                    f"विवरण: {top['description']}\n\n"
                    f"लाभ: {top['benefits']}\n\n"
                    f"पात्रता व दस्तावेज: {top['eligibility']} (दस्तावेज: {top['documents']})\n\n"
                    f"आधिकारिक वेबसाइट: {top['website_url']}\n\n"
                    f"{schemes_res['interactive_prompt']}"
                )
            else:
                ans = (
                    f"Scheme Details: {top['title']}\n\n"
                    f"Description: {top['description']}\n\n"
                    f"Benefits: {top['benefits']}\n\n"
                    f"Eligibility & Documents: {top['eligibility']} (Docs: {top['documents']})\n\n"
                    f"Official Website: {top['website_url']}\n\n"
                    f"{schemes_res['interactive_prompt']}"
                )

            return {
                "found": True,
                "database_match": False,
                "matched_question": top['title'],
                "answer": ans,
                "language": language_name,
                "source": "National & State Agriculture Schemes Portal",
                "answer_type": "government_schemes",
                "website_url": top['website_url'],
                "schemes_data": matched_schemes,
                "explanation": {
                    "method": "Direct official scheme lookup with active portal links",
                }
            }

    question_words = canonicalize_words(question)
    if not question_words:
        return {
            "found": False,
            "database_match": False,
            "answer": None,
            "language": language_name,
            "message": "Please ask a question with meaningful farming keywords.",
        }

    requested_crop = detect_crop(question)

    # 3. CHECK DATABASE FOR OFFLINE FARMING KNOWLEDGE
    try:
        connection = get_connection()
        try:
            records = [
                dict(row)
                for row in connection.execute(
                    """
                    SELECT id, topic, crop, language,
                           question, answer, source
                    FROM farming_knowledge
                    WHERE offline_available = 1
                    """
                ).fetchall()
            ]
        finally:
            connection.close()

    except sqlite3.Error:
        raise HTTPException(
            status_code=500,
            detail="Could not read the farming knowledge database.",
        )

    def normalize_db_language(value):
        value = (value or "").strip()
        return SUPPORTED_LANGUAGES.get(value.casefold(), value).casefold()

    records = [
        record for record in records
        if normalize_db_language(record["language"]) == language_name.casefold()
    ]

    best_record = None
    best_score = 0.0
    best_matches = set()
    question_intent = detect_intent(question)

    for record in records:
        record_question = record["question"] or ""
        record_intent = detect_intent(record_question)

        if (
            question_intent is not None
            and record_intent is not None
            and question_intent != record_intent
        ):
            continue

        record_topic = record["topic"] or ""
        record_crop_field = record["crop"] or ""
        record_answer = record["answer"] or ""

        record_crop = detect_crop(f"{record_crop_field} {record_question} {record_topic}")
        if record_crop is None:
            record_crop = detect_crop(record_answer)

        if requested_crop is not None and record_crop != requested_crop:
            continue

        searchable_text = " ".join([record_question, record_topic, record_crop_field])
        record_words = canonicalize_words(searchable_text)

        if not record_words:
            continue

        matched_words = question_words & record_words
        score = len(matched_words) / len(question_words)

        if score > best_score:
            best_score = score
            best_record = record
            best_matches = matched_words

    minimum_score = 0.5
    if best_record is not None and best_score >= minimum_score:
        enriched_answer = clean_and_enrich_db_answer(
            best_record["answer"],
            best_record.get("crop") or requested_crop,
            language_name
        )

        return {
            "found": True,
            "database_match": True,
            "matched_question": best_record["question"],
            "answer": enriched_answer,
            "language": best_record["language"],
            "source": best_record["source"],
            "answer_type": "database_enriched",
            "explanation": {
                "matched_keywords": sorted(best_matches),
                "matching_score_percent": round(best_score * 100, 2),
                "requested_crop": requested_crop,
                "method": "Enriched Canonical Keyword Overlap",
            },
        }

    # 4. COMPREHENSIVE LOCAL LLM (GEMMA3) ANSWER
    return llm_fallback(question, language_name)


# --------------------------------------------------
# 13. QUICK SERVICES ENDPOINTS
# --------------------------------------------------

# --- SERVICE 1: LIVE WEATHER ---
@app.get("/weather")
def get_weather_endpoint(
    location: str = Query(default="Pune"),
    language: str | None = Query(default="Marathi")
):
    """Real-time live temperature, weather conditions, humidity, and farming advice."""
    lang_name = detect_language(location, language)
    return get_live_weather(location_query=location, language=lang_name)


# --- SERVICE 2: GOVERNMENT SCHEMES ---
@app.get("/schemes")
def get_schemes_endpoint(
    category: str | None = Query(default=None),
    language: str | None = Query(default="Marathi"),
    search: str | None = Query(default=None)
):
    """Official government farming schemes with verified website links."""
    lang_name = detect_language(search or "योजना", language)
    if search:
        return search_schemes(search, lang_name)
    return {
        "count": len(get_all_schemes(lang_name, category)),
        "schemes": get_all_schemes(lang_name, category)
    }


# --- SERVICE 3: PLANT DISEASE SCAN ---
class DiseaseScanPayload(BaseModel):
    image_base64: Optional[str] = None
    crop: Optional[str] = None
    symptoms: Optional[str] = None
    language: Optional[str] = "Marathi"


@app.post("/disease-scan")
async def disease_scan_post(
    payload: Optional[DiseaseScanPayload] = Body(None),
    file: Optional[UploadFile] = File(None),
    crop: Optional[str] = Form(None),
    symptoms: Optional[str] = Form(None),
    language: Optional[str] = Form("Marathi")
):
    """
    Disease scanning for any fruit, vegetable, or crop images.
    Accepts image file upload or base64 JSON payload.
    Provides diagnostic identification, organic remedies, chemical dosages, and follow-up prompts.
    """
    img_bytes = None
    img_b64 = None
    selected_crop = crop
    selected_symptoms = symptoms
    selected_lang = language or "Marathi"

    if file:
        img_bytes = await file.read()
    elif payload:
        img_b64 = payload.image_base64
        selected_crop = payload.crop or selected_crop
        selected_symptoms = payload.symptoms or selected_symptoms
        selected_lang = payload.language or selected_lang

    return analyze_disease_image(
        image_bytes=img_bytes,
        image_base64=img_b64,
        crop_hint=selected_crop,
        symptoms_text=selected_symptoms,
        language=selected_lang
    )


@app.get("/disease-scan")
def disease_scan_get(
    crop: str = Query(default="tomato"),
    symptoms: str | None = Query(default=None),
    language: str = Query(default="Marathi")
):
    """GET endpoint for instant disease diagnosis by crop and symptoms."""
    return analyze_disease_image(
        crop_hint=crop,
        symptoms_text=symptoms,
        language=language
    )


# --- SERVICE 4: MANDI MARKET PRICES ---
@app.get("/market-price")
def get_market_price_endpoint(
    crop: str | None = Query(default=None),
    language: str | None = Query(default="Marathi")
):
    """Current APMC mandi prices, modal rates, and price trends."""
    lang_name = detect_language(crop or "कांदा", language)
    return get_market_prices(crop=crop, language=lang_name)


# --- SERVICE 5: SOIL HEALTH ADVISORY ---
@app.get("/soil-health")
def get_soil_health_endpoint(
    soil_type: str = Query(default="black"),
    language: str | None = Query(default="Marathi")
):
    """Soil health, NPK management, and soil improvement techniques."""
    lang_name = detect_language(soil_type, language)
    return get_soil_advisory(soil_type=soil_type, language=lang_name)


# --- SERVICE 6: CROP ADVICE ---
@app.get("/crop-advice")
def get_crop_advice_endpoint(
    crop: str = Query(default="tomato"),
    language: str | None = Query(default="Marathi")
):
    """Detailed stage-by-stage crop cultivation, fertilizer, and irrigation advisory."""
    lang_name = detect_language(crop, language)
    return get_crop_advice(crop_name=crop, language=lang_name)


# --------------------------------------------------
# 14. HEALTH CHECK & KNOWLEDGE BASE
# --------------------------------------------------

@app.get("/health")
def health_check():
    return {
        "status": "healthy",
        "application": "Farmer Voice Assistant",
        "version": "2.5.0",
        "database_exists": DATABASE_PATH.exists(),
        "llm_model": OLLAMA_MODEL,
        "services": [
            "crop_advice",
            "market_price",
            "disease_scan",
            "live_weather",
            "soil_health",
            "government_schemes"
        ]
    }


@app.get("/machinery")
def get_machinery_guide(
    language: str = Query(default="English"),
    category: Optional[str] = Query(default=None),
):
    """Return farm machinery guide with rental rates, costs, and subsidies."""
    normalized_language = SUPPORTED_LANGUAGES.get(
        language.strip().casefold(), language.strip()
    )
    items = get_all_machinery(language=normalized_language, category=category)
    return {
        "count": len(items),
        "language": normalized_language,
        "items": items,
    }
@app.get("/knowledge")
def get_knowledge(
    language: str | None = Query(default=None),
    crop: str | None = Query(default=None),
):
    try:
        connection = get_connection()
        try:
            sql = """
                SELECT id, topic, crop, language,
                       question, answer, source
                FROM farming_knowledge
                WHERE offline_available = 1
            """
            parameters = []
            if language:
                normalized_language = SUPPORTED_LANGUAGES.get(
                    language.strip().casefold(),
                    language.strip()
                )
                sql += " AND language = ? COLLATE NOCASE"
                parameters.append(normalized_language)
            if crop:
                crop_aliases = CROP_ALIASES.get(
                    crop.strip().casefold(),
                    [crop.strip()]
                )
                conditions = ["crop = ? COLLATE NOCASE" for _ in crop_aliases]
                parameters.extend(crop_aliases)
                sql += " AND (" + " OR ".join(conditions) + ")"
            sql += " ORDER BY id"
            records = [
                dict(row)
                for row in connection.execute(sql, parameters).fetchall()
            ]
            return {
                "count": len(records),
                "results": records,
            }
        finally:
            connection.close()
    except sqlite3.Error:
        raise HTTPException(
            status_code=500,
            detail="Could not read the farming knowledge database.",
        )
@app.get("/knowledge/{record_id}")
def get_knowledge_by_id(record_id: int):
    try:
        connection = get_connection()
        try:
            record = connection.execute(
                """
                SELECT id, topic, crop, language,
                       question, answer, source
                FROM farming_knowledge
                WHERE id = ? AND offline_available = 1
                """,
                (record_id,),
            ).fetchone()
            if record is None:
                raise HTTPException(
                    status_code=404,
                    detail="Farming information not found.",
                )
            return dict(record)
        finally:
            connection.close()
    except sqlite3.Error:
        raise HTTPException(
            status_code=500,
            detail="Could not read the farming knowledge database.",
        )