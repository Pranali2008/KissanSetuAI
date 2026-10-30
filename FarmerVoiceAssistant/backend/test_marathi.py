
from faster_whisper import WhisperModel

AUDIO_FILE = "voice_input.wav"

print("Loading Whisper model...")
model = WhisperModel(
    "small",
    device="cpu",
    compute_type="int8"
)

print("\nTesting Marathi transcription...")

segments, info = model.transcribe(
    AUDIO_FILE,
    language="mr",
    task="transcribe",
    beam_size=5,
    vad_filter=False,
    condition_on_previous_text=False,
    initial_prompt=(
        "भाताच्या पिकाला पाणी कधी द्यावे? "
        "शेती, भात, पाणी, पीक"
    )
)

text = " ".join(segment.text.strip() for segment in segments)

print("Language:", info.language)
print("Transcribed text:", text)
