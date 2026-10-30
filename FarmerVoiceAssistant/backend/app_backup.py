import re
from pathlib import Path
import sqlite3

from fastapi import FastAPI, HTTPException, Query
from fastapi.middleware.cors import CORSMiddleware

DATABASE_PATH = Path(__file__).resolve().parent / "farmer.db"

app = FastAPI(
    title="Farmer Voice Assistant API",
    description="Multilingual farming information with offline database access",
    version="1.0.0"
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=False,
    allow_methods=["*"],
    allow_headers=["*"],
)


def get_connection():
    connection = sqlite3.connect(DATABASE_PATH)
    connection.row_factory = sqlite3.Row
    return connection


@app.get("/")
def home():
    return {
        "message": "Welcome to Farmer Voice Assistant!",
        "status": "running"
    }


@app.get("/health")
def health_check():
    return {
        "status": "healthy",
        "application": "Farmer Voice Assistant"
    }


@app.get("/knowledge")
def get_knowledge(
    language: str | None = Query(default=None),
    crop: str | None = Query(default=None)
):
    connection = get_connection()

    try:
        sql = """
            SELECT id, topic, crop, language, question, answer, source
            FROM farming_knowledge
            WHERE offline_available = 1
        """
        parameters = []

        if language:
            sql += " AND language = ? COLLATE NOCASE"
            parameters.append(language)

        if crop:
            sql += " AND crop = ? COLLATE NOCASE"
            parameters.append(crop)

        sql += " ORDER BY id"

        cursor = connection.execute(sql, parameters)
        records = [dict(row) for row in cursor.fetchall()]

        return {
            "count": len(records),
            "results": records
        }

    finally:
        connection.close()


@app.get("/knowledge/{record_id}")
def get_knowledge_by_id(record_id: int):
    connection = get_connection()

    try:
        cursor = connection.execute(
            """
            SELECT id, topic, crop, language, question, answer, source
            FROM farming_knowledge
            WHERE id = ? AND offline_available = 1
            """,
            (record_id,)
        )

        record = cursor.fetchone()

        if record is None:
            raise HTTPException(
                status_code=404,
                detail="Farming information not found"
            )

        return dict(record)

    finally:
        connection.close()


@app.get("/ask")
def ask_question(
    question: str = Query(..., min_length=2),
    language: str | None = Query(default=None)
):
    # Extract complete English, Hindi and Marathi words
    def extract_words(text):
        return set(
            re.findall(
                r'[\u0900-\u097F]+|[a-zA-Z]+|\d+',
                text.casefold()
            )
        )

    # Remove common English words that are not useful for matching
    stopwords = {
        "i", "the", "a", "an", "is", "are", "am",
        "when", "what", "how", "should", "do", "does",
        "my", "in", "to", "for", "of", "and", "can",
        "from", "it", "this", "that", "on", "with",
        "be", "your", "you", "me", "please",
        "crop", "crops", "farm", "farming", "farmer",
        "protect", "help", "tell", "about"
    }

    question_words = extract_words(question) - stopwords

    if not question_words:
        return {
            "found": False,
            "message": "Please ask a question with meaningful keywords."
        }

    connection = get_connection()

    try:
        cursor = connection.execute("""
            SELECT id, topic, crop, language, question, answer, source
            FROM farming_knowledge
            WHERE offline_available = 1
        """)

        records = [dict(row) for row in cursor.fetchall()]

        # Filter records by the selected language, if provided
        if language:
            records = [
                record for record in records
                if record["language"].casefold() == language.casefold()
            ]

        best_record = None
        best_score = 0
        best_matches = set()

        for record in records:
            searchable_text = " ".join([
                record["question"] or "",
                record["topic"] or "",
                record["crop"] or ""
            ])

            record_words = extract_words(searchable_text) - stopwords
            matched_words = question_words & record_words

            # Avoid division by zero
            score = len(matched_words) / len(question_words)

            if score > best_score:
                best_score = score
                best_record = record
                best_matches = matched_words

        # Return an answer only when the match is sufficiently relevant
        minimum_score = 0.5

        if best_record is None or best_score < minimum_score:
            return {
                "found": False,
                "message": (
                    "No sufficiently relevant information was found "
                    "in the offline knowledge database."
                ),
                "explanation": {
                    "method": "Keyword overlap",
                    "minimum_matching_score_percent": 50
                }
            }

        return {
            "found": True,
            "matched_question": best_record["question"],
            "answer": best_record["answer"],
            "language": best_record["language"],
            "source": best_record["source"],
            "explanation": {
                "matched_keywords": sorted(best_matches),
                "matching_score_percent": round(best_score * 100, 2),
                "method": "Keyword overlap"
            }
        }

    finally:
        connection.close()


def extract_words(text):
    # Keep complete Devanagari words together.
    # Also support English words and numbers.
    return re.findall(
        r'[\u0900-\u097F]+|[a-zA-Z]+|\d+',
        text.casefold()
    )

    # Remove common and overly general words
    stopwords = {
        "i", "the", "a", "an", "is", "are", "am",
        "when", "what", "how", "should", "do", "does",
        "my", "in", "to", "for", "of", "and", "can",
        "from", "it", "this", "that", "on", "with",
        "be", "your", "you", "me", "please",
        "crop", "crops", "farm", "farming", "farmer",
        "protect", "help", "tell", "about"
    }

    question_words = get_words(question) - stopwords

    if not question_words:
        return {
            "found": False,
            "message": "Please ask a question with meaningful keywords."
        }

    connection = get_connection()

    try:
        cursor = connection.execute("""
            SELECT id, topic, crop, language, question, answer, source
            FROM farming_knowledge
            WHERE offline_available = 1
        """)

        records = [dict(row) for row in cursor.fetchall()]

        if language:
            records = [
                record for record in records
                if record["language"].casefold() == language.casefold()
            ]

        best_record = None
        best_score = 0
        best_matches = set()

        for record in records:
            searchable_text = " ".join([
                record["question"] or "",
                record["topic"] or "",
                record["crop"] or ""
            ])

            record_words = get_words(searchable_text) - stopwords
            matched_words = question_words & record_words

            # Score based on meaningful question keywords
            score = len(matched_words) / len(question_words)

            if score > best_score:
                best_score = score
                best_record = record
                best_matches = matched_words

        # Reject weak matches instead of returning unrelated answers
        minimum_score = 0.5

        if best_record is None or best_score < minimum_score:
            return {
                "found": False,
                "message": (
                    "No sufficiently relevant information was found "
                    "in the offline knowledge database."
                ),
                "explanation": {
                    "method": "Keyword overlap",
                    "minimum_matching_score_percent": 50
                }
            }

        return {
            "found": True,
            "matched_question": best_record["question"],
            "answer": best_record["answer"],
            "language": best_record["language"],
            "source": best_record["source"],
            "explanation": {
                "matched_keywords": sorted(best_matches),
                "matching_score_percent": round(best_score * 100, 2),
                "method": "Keyword overlap"
            }
        }

    finally:
        connection.close()
