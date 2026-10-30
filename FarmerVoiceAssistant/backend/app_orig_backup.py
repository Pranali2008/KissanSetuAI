import re
import sqlite3
from pathlib import Path

import requests
from lingua import Language, LanguageDetectorBuilder
from fastapi import FastAPI, HTTPException, Query
from fastapi.middleware.cors import CORSMiddleware


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
    title="Farmer Voice Assistant API",
    description=(
        "Multilingual farming information using an offline "
        "database and local AI model"
    ),
    version="2.1.0",
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
    "wheat": [
        "wheat", "गेहूं", "गेहु", "गहू", "गव्ह",
    ],
    "rice": [
        "rice", "paddy", "धान", "चावल", "भात",
    ],
    "tomato": [
        "tomato", "tomatoes", "टमाटर", "टोमॅटो",
    ],
    "cotton": [
        "cotton", "कपास", "कापूस",
    ],

        
    "sugarcane": [
    "sugarcane",
    "गन्ना",
    "गन्ने",
    "ऊस",
    "उसाचा",
    "उसाच्या",
    "उसाला",
    "उसाचे",
],

    "maize": [
        "maize", "corn", "मक्का", "मकई",
    ],
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

    # Respect a language explicitly selected by the user.
    if requested_language:
        language = SUPPORTED_LANGUAGES.get(
            requested_language.strip().casefold()
        )

        if language is None:
            raise HTTPException(
                status_code=400,
                detail=(
                    "Supported languages: "
                    "English, Hindi, Marathi."
                ),
            )

        return language

    normalized_text = normalize_question(text)

    # Common Marathi words that may be misclassified as Hindi.
    marathi_markers = [
        "उसाच्या", "उसाला", "उसाचे",
        "गव्हाला", "गव्हाच्या",
        "पिकाला", "द्यावे",
        "कसे", "कशी", "कधी", "आहे", "आणि",
        "टोमॅटोची", "पाने", "पिवळी", "पडत",
    ]

    if any(
        marker in normalized_text
        for marker in marathi_markers
    ):
        return "Marathi"

    detected = LANGUAGE_DETECTOR.detect_language_of(
        text or ""
    )

    if detected in DETECTED_LANGUAGE_NAMES:
        return DETECTED_LANGUAGE_NAMES[detected]

# --------------------------------------------------
# QUESTION INTENT DETECTION
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
        "कितनी बार", "किती वेळा",
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

    # Check longer phrases first.
    for intent, keywords in INTENT_KEYWORDS.items():
        for keyword in keywords:
            if " " in keyword:
                if keyword in text:
                    return intent
            elif keyword in words:
                return intent

    return None

# --------------------------------------------------
# 7. QUESTION SYNONYMS
# --------------------------------------------------

# Map different words for the same concept to a
# common English keyword for matching purposes.

SYNONYM_GROUPS = [
    {
        "wheat", "गेहूं", "गेहु", "गहू", "गव्ह",
    },
    {
        "rice", "paddy", "धान", "चावल", "भात",
    },
    {
        "tomato", "tomatoes", "टमाटर", "टोमॅटो",
    },
    {
        "cotton", "कपास", "कापूस",
    },
    {
        "sugarcane", "गन्ना", "ऊस",
    },
    {
        "maize", "corn", "मक्का", "मकई",
    },
    {
        "water", "irrigate", "irrigation",
        "irrigated", "watering", "पाणी",
        "सिंचाई", "सिंचन", "सिंचाई",
    },
    {
        "fertilizer", "fertiliser",
        "खाद", "उर्वरक", "खत",
    },
    {
        "disease", "illness", "रोग", "बीमारी",
    },
    {
        "pest", "insect", "कीट", "किड",
    },
    {
        "spray", "छिड़काव", "फवारणी",
    },
    {
        "quantity", "amount", "कितना", "कितनी",
        "किती", "प्रमाण",
    },
]

SYNONYM_LOOKUP = {}

for group in SYNONYM_GROUPS:
    canonical = sorted(
        group,
        key=lambda word: (len(word), word)
    )[0]

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
# 8. LOCAL LLM ANSWER GENERATION
# --------------------------------------------------

def generate_llm_answer(
    question: str,
    language: str | None = None
) -> str:

    language_name = detect_language(question, language)

    language_instructions = {
        "English": (
            "Write in clear, simple English. "
            "Use short sentences."
        ),
        "Hindi": (
            "Write entirely in natural, simple Hindi "
            "using Devanagari script. Do not use Marathi."
        ),
        "Marathi": (
            "Write entirely in natural, simple Marathi "
            "using Devanagari script, suitable for farmers "
            "in Maharashtra. Do not use Hindi grammar."
        ),
    }

    system_prompt = f"""
You are a careful multilingual agricultural information
assistant for farmers in India.

Respond in {language_name}.

Language instructions:
{language_instructions[language_name]}

Rules:
1. Answer the actual question directly.
2. Use 3 to 5 short sentences when appropriate.
3. Never invent pesticide doses, fertilizer quantities,
   irrigation schedules, statistics or sources.
4. Explain when an answer depends on soil, weather,
   crop stage or local conditions.
5. If important information is missing, say so.
6. Recommend a Krishi Vigyan Kendra (KVK) or local
   agricultural officer for important local decisions.
7. Never claim to have checked live weather or soil.
8. For unrelated questions, answer only if appropriate;
   do not pretend an unrelated answer is farming advice.
9. Return only the answer, without role descriptions.
"""

    payload = {
        "model": OLLAMA_MODEL,
        "system": system_prompt,
        "prompt": (
            f"Answer this question in {language_name}:\n"
            f"{question}"
        ),
        "stream": False,
        "options": {
            "temperature": 0.1,
            "top_p": 0.8,
            "repeat_penalty": 1.1,
            "num_predict": 180,
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
        raise ValueError(
            "The local AI model returned an empty answer."
        )

    # IMPORTANT: return is outside the if statement.
    return answer


# --------------------------------------------------
# 9. LLM FALLBACK
# --------------------------------------------------

def llm_fallback(
    question: str,
    language: str | None = None
):
    language_name = detect_language(question, language)

    try:
        answer = generate_llm_answer(
            question,
            language_name,
        )

        return {
            "found": True,
            "database_match": False,
            "matched_question": None,
            "answer": answer,
            "language": language_name,
            "source": "Local LLM: " + OLLAMA_MODEL,
            "answer_type": "ai_generated_unverified",
            "warning": (
                "AI-generated answer, not verified against "
                "the farming knowledge database. Confirm "
                "important farming decisions with a qualified "
                "local agricultural expert."
            ),
            "explanation": {
                "method": "Local LLM fallback",
                "database_match": False,
            },
        }

    except requests.RequestException:
        return {
            "found": False,
            "database_match": False,
            "answer": None,
            "language": language_name,
            "message": (
                "The local AI model could not be reached. "
                "Check that Ollama is running and the model "
                "is installed."
            ),
            "answer_type": "unavailable",
        }

    except (ValueError, RuntimeError):
        return {
            "found": False,
            "database_match": False,
            "answer": None,
            "language": language_name,
            "message": (
                "The local AI model could not generate "
                "a valid answer."
            ),
            "answer_type": "unavailable",
        }


# --------------------------------------------------
# 10. MAIN ASK ENDPOINT
# --------------------------------------------------

@app.get("/ask")
def ask_question(
    question: str = Query(..., min_length=2),
    language: str | None = Query(default=None),
):
    question = normalize_question(question)

    language_name = detect_language(question, language)

    question_words = canonicalize_words(question)

    if not question_words:
        return {
            "found": False,
            "database_match": False,
            "answer": None,
            "language": language_name,
            "message": (
                "Please ask a question with meaningful keywords."
            ),
        }

    requested_crop = detect_crop(question)

    # Read knowledge records from SQLite.
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

    # Always restrict database search to the detected language.
    # This prevents a question in one language from returning
    # a database answer written in another language.
    def normalize_db_language(value):
        value = (value or "").strip()
        return SUPPORTED_LANGUAGES.get(
            value.casefold(), value
        ).casefold()

    records = [
        record for record in records
        if normalize_db_language(record["language"])
        == language_name.casefold()
    ]


    best_record = None
    best_score = 0.0
    best_matches = set()

    question_intent = detect_intent(question)

    for record in records:
        record_question = record["question"] or ""

        # Check whether the question intents conflict.
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

        

        # Identify the crop of this database record.
        record_crop = detect_crop(
            f"{record_crop_field} "
            f"{record_question} {record_topic}"
        )

        if record_crop is None:
            record_crop = detect_crop(record_answer)

        # Match the requested crop.
        if requested_crop is not None:
            if record_crop != requested_crop:
                continue



        searchable_text = " ".join([
            record_question,
            record_topic,
            record_crop_field,
        ])

        record_words = canonicalize_words(searchable_text)

        if not record_words:
            continue

        matched_words = question_words & record_words

        # Calculate overlap relative to question keywords.
        score = len(matched_words) / len(question_words)

        # Prefer the highest score.
        if score > best_score:
            best_score = score
            best_record = record
            best_matches = matched_words


    # Database matching threshold.
    minimum_score = 0.5

    if best_record is not None and best_score >= minimum_score:
        return {
            "found": True,
            "database_match": True,
            "matched_question": best_record["question"],
            "answer": best_record["answer"],
            "language": best_record["language"],
            "source": best_record["source"],
            "answer_type": "database",
            "explanation": {
                "matched_keywords": sorted(best_matches),
                "matching_score_percent": round(
                    best_score * 100, 2
                ),
                "requested_crop": requested_crop,
                "matched_crop": detect_crop(
                    " ".join([
                        best_record["crop"] or "",
                        best_record["question"] or "",
                        best_record["topic"] or "",
                        best_record["answer"] or "",
                    ])
                ),
                "method": (
                    "Canonical keyword overlap with crop filtering"
                ),
            },
        }

    # No sufficiently strong match: use local Gemma model.
    return llm_fallback(question, language_name)


# --------------------------------------------------
# 11. HEALTH CHECK
# --------------------------------------------------

@app.get("/health")
def health_check():
    return {
        "status": "healthy",
        "application": "Farmer Voice Assistant",
        "database_exists": DATABASE_PATH.exists(),
        "llm_model": OLLAMA_MODEL,
    }


# --------------------------------------------------
# 12. GET KNOWLEDGE RECORDS
# --------------------------------------------------

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

                conditions = []

                for alias in crop_aliases:
                    conditions.append("crop = ? COLLATE NOCASE")
                    parameters.append(alias)

                sql += " AND (" + " OR ".join(conditions) + ")"

            sql += " ORDER BY id"

            records = [
                dict(row)
                for row in connection.execute(
                    sql, parameters
                ).fetchall()
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

# --------------------------------------------------
# 13. GET ONE KNOWLEDGE RECORD
# --------------------------------------------------

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
