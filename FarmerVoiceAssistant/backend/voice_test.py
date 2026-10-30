import wave
import sounddevice as sd
from faster_whisper import WhisperModel

SAMPLE_RATE = 16000
DURATION = 8
AUDIO_FILE = "voice_input.wav"

print("Recording will start now.")
print("Speak your question clearly for 8 seconds.")

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

print("Recording saved.")
print("Loading the speech recognition model...")

# The first run downloads the model.
# Later runs can use the locally cached model.
model = WhisperModel(
    "base",
    device="cpu",
    compute_type="int8"
)

print("Recognizing speech...")

segments, info = model.transcribe(
    AUDIO_FILE,
    beam_size=3
)

print("\nDetected language:", info.language)
print("Recognized question:")

text_found = False

for segment in segments:
    print(segment.text)
    text_found = True

if not text_found:
    print("No speech was recognized. Please try again.")
