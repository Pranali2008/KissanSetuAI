import pyttsx3

engine = pyttsx3.init()

voices = engine.getProperty("voices")

for voice in voices:
    print("Name:", voice.name)
    print("ID:", voice.id)

engine.setProperty("rate", 150)
engine.say("Hello! Your farmer voice assistant is working.")
engine.runAndWait()
