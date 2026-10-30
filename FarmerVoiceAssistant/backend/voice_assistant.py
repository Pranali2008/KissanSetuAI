import pyttsx3
from urllib.parse import quote_plus
import wave
import requests
import sounddevice as sd
from faster_whisper import WhisperModel


# Initialize offline text-to-speech
tts_engine = pyttsx3.init()
tts_engine.setProperty("rate", 150)
tts_engine.setProperty("volume", 1.0)


def speak_answer(text, language="English"):
    """Speak the answer offline when an English voice is available."""

    if language.lower() not in ("english", "en"):
        print("Offline speech is currently available in English only.")
        return

    if not text or not text.strip():
        return

    try:
        tts_engine.say(text)
        tts_engine.runAndWait()
    except Exception as error:
        print("Speech error:", error)


# Audio settings
SAMPLE_RATE = 16000
DURATION = 8
AUDIO_FILE = "voice_input.wav"

# Your running FastAPI endpoint
API_URL = "http://127.0.0.1:8000/ask"

print("=" * 50)
print(" FARMER VOICE ASSISTANT ")
print("=" * 50)

# Load the speech recognition model
print("\nLoading offline speech recognition model...")
model = WhisperModel("small", device="cpu", compute_type="int8")

print("Model loaded successfully!")


def record_question():
    print("\nSpeak your farming question after recording starts.")
    print(f"Recording for {DURATION} seconds...")

    audio = sd.rec(
        int(DURATION * SAMPLE_RATE),
        samplerate=SAMPLE_RATE,
        channels=1,
        dtype="int16"
    )

    sd.wait()

    with wave.open(AUDIO_FILE, "wb") as file:
        file.setnchannels(1)
        file.setsampwidth(2)
        file.setframerate(SAMPLE_RATE)
        file.writeframes(audio.tobytes())

    print("Recording completed!")

def transcribe_question():
    print("\nListening... Detecting the spoken language automatically.")
    print("Converting speech to text...")

    segments, info = model.transcribe(
        AUDIO_FILE,
        task="transcribe",
        beam_size=5,
        vad_filter=True,
        condition_on_previous_text=False
    )

    question = " ".join(
        segment.text.strip()
        for segment in segments
    ).strip()

    language_map = {
        "mr": "Marathi",
        "hi": "Hindi",
        "en": "English"
    }

    detected_code = info.language
    language_name = language_map.get(
        detected_code,
        detected_code
    )

    print("Detected language:", language_name)
    print(
        "Language detection confidence:",
        f"{info.language_probability:.1%}"
    )
    print("Your question:", question)

    if not question:
        print("No speech recognized. Please try again.")
        return None, language_name

    return question, language_name

def get_farming_answer(question, language):
    print("\nSending your question to the farming assistant...")

    try:
        response = requests.get(
            API_URL,
            params={
                "question": question,
                "language": language
            },
            timeout=150
        )

        response.raise_for_status()
        result = response.json()

        print("\n" + "=" * 50)
        print(" FARMING ASSISTANT RESPONSE ")
        print("=" * 50)

        answer = result.get("answer", "")
        answer_type = result.get("answer_type", "unknown")
        database_match = result.get("database_match", False)


        if answer:
            print("\nYour question:")
            print(question)

            print("\nAnswer:")
            print(answer)

            answer_language = result.get("language", language)
            print("\nSpeaking answer...")
            speak_answer(answer, answer_language)

            print("\nLanguage:")
            print(answer_language)

            print("\nAnswer source:")

            if database_match:
                print("Saved farming knowledge database (SQLite)")
            elif answer_type == "ai_generated_unverified":
                print("Local AI model (Ollama)")
            else:
                print(result.get("source", "Not available"))

            explanation = result.get("explanation", {})

            print("\nWhy this answer was selected:")

            if database_match:
                print(
                    "Matched keywords:",
                    explanation.get("matched_keywords", [])
                )
                print(
                    "Matching score:",
                    explanation.get("matching_score_percent", 0),
                    "%"
                )
                print(
                    "Method:",
                    explanation.get("method", "Database matching")
                )
            else:
                print(
                    "Method:",
                    explanation.get("method", "AI-generated response")
                )

            if answer_type == "ai_generated_unverified":
                print("\nIMPORTANT SAFETY WARNING:")
                print(
                    result.get(
                        "warning",
                        "This AI-generated answer has not been verified. "
                        "Confirm important farming decisions with a "
                        "qualified local agricultural expert."
                    )
                )

        else:
            print("\nNo answer was returned.")
            print(
                result.get(
                    "message",
                    "Please try asking your question differently."
                )
            )


        # Suggest educational videos related to the question.
        # These are search suggestions, not verified recommendations.
        video_terms = {
            "English": "farming crop pest management ICAR KVK",
            "Hindi": "फसल कीट प्रबंधन कृषि",
            "Marathi": "पीक कीड व्यवस्थापन कृषी"
        }

        searchable_text = " ".join([
            question,
            result.get("matched_question", ""),
            answer
        ]).casefold()

        tomato_words = [
            "tomato", "tomatoes", "टोमॅटो", "टमाटर"
        ]
        pest_words = [
            "pest", "pests", "कीड", "किडी", "कीट", "रोग"
        ]

        is_tomato_question = any(
            word in searchable_text for word in tomato_words
        )
        is_pest_question = any(
            word in searchable_text for word in pest_words
        )

        print("\nEducational video resources:")

        if is_tomato_question and is_pest_question:
            videos = [
                (
                    "Tomato and okra pest management - "
                    "Maharashtra Agriculture Department",
                    "https://www.youtube.com/watch?v=2cHLuKVa7UY"
                ),
                (
                    "Tomato pest and disease management - BharatAgri Marathi",
                    "https://www.youtube.com/watch?v=rSSUMcMa7vk"
                )
            ]

            for index, (title, url) in enumerate(videos, start=1):
                print(f"{index}. {title}")
                print(f"   {url}")
        else:
            search_text = (
                f"{question} "
                f"{video_terms.get(language, video_terms['English'])}"
            )
            video_url = (
                "https://www.youtube.com/results?search_query="
                + quote_plus(search_text)
            )

            print("Search for educational videos:")
            print(video_url)

            print(
                "Check the video's publisher and agricultural guidance "
                "before following any recommendation."
            )

        if language == "Marathi":
            print("\nव्हिडिओ पाहण्यासाठी वरील लिंक उघडा.")
        elif language == "Hindi":
            print("\nवीडियो देखने के लिए ऊपर दिया गया लिंक खोलें.")

    except requests.exceptions.ConnectionError:
        print("\nCannot connect to the API.")
        print("Start FastAPI in another terminal.")

    except requests.exceptions.Timeout:
        print("\nThe AI response took too long.")
        print("Check whether Ollama is running and try again.")

    except requests.exceptions.RequestException as error:
        print("\nAPI request failed:", error)

    except ValueError as error:
        print("\nCould not read the API response:", error)

def main():
    record_question()

    question, language = transcribe_question()

    if question:
        get_farming_answer(question, language)


if __name__ == "__main__":
    main()
