"""
Disease Scan & Plant Pathology Service for Farmer Voice Assistant
Analyzes images of crops, fruits, vegetables, and leaves for diseases, pests,
and nutrient deficiencies using Ollama Vision (Gemma3) and offline expert diagnostic rules.
"""

import base64
import re
import requests
from typing import Dict, Any, Optional, List

OLLAMA_URL = "http://localhost:11434/api/generate"
VISION_MODEL = "gemma3:4b"

# Comprehensive agricultural disease database for offline fallback and verification
OFFLINE_DISEASE_DB = {
    "tomato": [
        {
            "name": {"en": "Tomato Early Blight (Alternaria)", "hi": "टमाटर का अगेती झुलसा (अल्टरनेरिया)", "mr": "टोमॅटोचा करपा / अल्टरनेरिया बुरशी रोग"},
            "type": "Fungal",
            "symptoms": {
                "en": "Brown to black concentric target-like rings on older leaves, lower leaves turning yellow and dying.",
                "hi": "निचली पत्तियों पर गोल भूरे-काले छल्ले (टारगेट बोर्ड जैसे धब्बे), पत्तियों का पीला पड़कर सूखना।",
                "mr": "खालच्या जुन्या पानांवर काळे-किरमिजी गोल कडा असलेले ठिपके, पाने पिवळी पडून वाळणे आणि गळणे."
            },
            "organic_remedy": {
                "en": "Spray Neem oil (5ml/liter water) or Trichoderma viride (5g/liter). Remove infected bottom leaves.",
                "hi": "नीम का तेल (5 मिली/लीटर) या ट्राइकोडर्मा विरिडी (5 ग्राम/लीटर) का छिड़काव करें। निचली सूखी पत्तियां हटा दें।",
                "mr": "५ मिली कडुलिंब (नीम) तेल प्रति लिटर पाणी किंवा ट्रायकोडर्मा व्हिरिडी ५ ग्रॅम/लिटर फवारावे. खालची रोगट पाने काढून टाकावीत."
            },
            "chemical_remedy": {
                "en": "Spray Mancozeb 75% WP @ 2.5g/liter or Azoxystrobin + Difenoconazole @ 1ml/liter during early stages.",
                "hi": "शुरुआती अवस्था में मैंकोजेब 75% डब्ल्यूपी (2.5 ग्राम/लीटर) या एज़ोक्सीस्ट्रोबिन + डिफेनोकोनाज़ोल (1 मिली/लीटर) का छिड़काव करें।",
                "mr": "मँकोझेब ७५% डब्ल्यूपी २.५ ग्रॅम प्रति लिटर पाणी किंवा अॅझॉक्सीस्ट्रॉबिन + डायफेनोकोनॅझोल १ मिली प्रति लिटर पाण्यात मिसळून फवारणी करावी."
            },
            "prevention": {
                "en": "Avoid overhead watering; ensure crop rotation with non-solanaceous crops; mulch soil.",
                "hi": "फव्वारे से पानी न दें, फसलों की अदला-बदली करें और मल्चिंग का प्रयोग करें।",
                "mr": "ठिबक सिंचनाचा वापर करा; पालापाचोळा किंवा मल्चिंग वापरा आणि फेरपालट करा."
            }
        },
        {
            "name": {"en": "Tomato Leaf Curl Virus", "hi": "टमाटर का पर्ण कुंचन रोग (लीफ कर्ल)", "mr": "टोमॅटोचा चुरडा-मुरडा (लीफ कर्ल / बोकड्या रोग)"},
            "type": "Viral (spread by Whiteflies)",
            "symptoms": {
                "en": "Severe upward and downward curling and twisting of leaves, stunted plant growth, thick and puckered leaves.",
                "hi": "पत्तियों का ऊपर व नीचे की ओर मुड़ना (सिकुड़ना), पौधे का बौना रह जाना, फल न लगना।",
                "mr": "पाने आकसणे, वर किंवा खाली वळणे, झाडांची वाढ खुंटणे आणि फळधारणा न होणे (पांढऱ्या माशीमुळे पसरतो)."
            },
            "organic_remedy": {
                "en": "Install yellow sticky traps (15-20 traps/acre) to catch whiteflies. Spray 5% neem seed kernel extract (NSKE).",
                "hi": "सफेद मक्खी नियंत्रण के लिए पीले चिपचिपे कार्ड (15-20 प्रति एकड़) लगाएं और 5% नीम अर्क छिड़कें।",
                "mr": "पांढरी माशी रोखण्यासाठी एकरी १५-२० पिवळे चिकट सापळे लावा. ५% निंबोळी अर्क फवारावा."
            },
            "chemical_remedy": {
                "en": "Control vector whitefly: Spray Diafenthiuron 50% WP @ 1g/liter or Imidacloprid 17.8% SL @ 0.5ml/liter.",
                "hi": "सफेद मक्खी नियंत्रण: डायफेन्थियूरॉन 50% WP (1 ग्राम/लीटर) या इमिडाक्लोप्रिड 17.8% SL (0.5 मिली/लीटर)।",
                "mr": "पांढऱ्या माशीच्या नियंत्रणासाठी डायफेंथियुरॉन ५०% डब्ल्यूपी १ ग्रॅम/लिटर किंवा इमिडाक्लोप्रिड ०.५ मिली प्रति लिटर पाण्यात मिसळून फवारावे."
            },
            "prevention": {
                "en": "Uproot and destroy severely infested plants to stop viral transmission.",
                "hi": "रोगग्रस्त पौधों को तुरंत उखाड़कर नष्ट करें ताकि अन्य पौधे सुरक्षित रहें।",
                "mr": "तीव्र प्रादुर्भाव झालेली रोपे उपटून जाळून नष्ट करावीत."
            }
        }
    ],
    "cotton": [
        {
            "name": {"en": "Cotton Pink Bollworm", "hi": "कपास की गुलाबी सूंडी (पिंक बॉलवर्म)", "mr": "कापसावरील गुलाबी बोंडअळी"},
            "type": "Pest",
            "symptoms": {
                "en": "Rosette flowers (petals twisted into rosette), holes plugged with excreta in bolls, stained fiber and damaged seeds.",
                "hi": "गुलाब के आकार के मुड़े हुए फूल, बोंडों में छेद और अंदर काले-भूरे धब्बे, खराब कपास।",
                "mr": "फुले उमलण्यापूर्वी पाकळ्या एकमेकांना चिकटून गुलाबाच्या कळीसारखी दिसणे (रोझेट फ्लॉवर), बोंडामध्ये छिद्र व आतील रुई खराब होणे."
            },
            "organic_remedy": {
                "en": "Install Pheromone traps @ 5-8 traps/acre for monitoring. Release Trichogramma egg parasitoids @ 60,000/acre.",
                "hi": "प्रति एकड़ 5-8 फेरोमोन ट्रैप लगाएं। ट्राइकोग्रामा परजीवी कार्ड लगाएं।",
                "mr": "एकरी ५ ते ८ कामगंध सापळे (फेरोमोन ट्रॅप) लावावेत. ट्रायकोकार्ड एकरी २ ते ३ वापरावेत."
            },
            "chemical_remedy": {
                "en": "Spray Chlorantraniliprole 18.5% SC @ 0.3ml/liter or Emamectin Benzoate 5% SG @ 0.5g/liter.",
                "hi": "क्लोरांट्रानिलिप्रोल 18.5% SC (0.3 मिली/लीटर) या इमामेक्टिन बेंजोएट 5% SG (0.5 ग्राम/लीटर)।",
                "mr": "क्लोरांट्रानिलीप्रोल १८.५% एससी ०.३ मिली किंवा इमामेक्टिन बेन्झोएट ५% एसजी ०.५ ग्रॅम प्रति लिटर पाण्यात फवारावे."
            },
            "prevention": {
                "en": "Avoid extending the cotton crop into late season; shred cotton stalks post-harvest.",
                "hi": "कपास की फसल को अनावश्यक न खींचें, तुड़ाई के बाद अवशेषों को नष्ट करें।",
                "mr": "फरदड (खोडवा) कापूस घेणे टाळावे आणि वेचणीनंतर धसकटे नष्ट करावीत."
            }
        }
    ],
    "sugarcane": [
        {
            "name": {"en": "Sugarcane Early Shoot Borer", "hi": "गन्ने का तना छेदक (अर्ली शूट बोरर)", "mr": "उसावरील खोडकीड"},
            "type": "Pest",
            "symptoms": {
                "en": "Dead heart in young shoots (1 to 3 months old) which emits foul odor when pulled out easily.",
                "hi": "शुरुआती अंकुरों में बीच की पत्ती सूख जाना (डेड हार्ट), खींचने पर बदबू के साथ आसानी से निकल आना।",
                "mr": "उसाच्या फुटव्यांमधील मधला पोंगा वाळणे (डेड हार्ट), ओढल्यावर कुजट वासासह सहज बाहेर येणे."
            },
            "organic_remedy": {
                "en": "Install pheromone traps (10/acre). Apply trash mulch in furrows to conserve moisture and suppress borer.",
                "hi": "एकड़ में 10 फेरोमोन ट्रैप लगाएं और कतारों में सूखी पत्तियों की मल्चिंग करें।",
                "mr": "एकरी १० कामगंध सापळे लावावेत आणि पाचटाचे आच्छादन (मल्चिंग) करावे."
            },
            "chemical_remedy": {
                "en": "Soil drenching / granules: Cartap hydrochloride 4% G @ 10kg/acre or Chlorantraniliprole 0.4% G @ 7.5kg/acre.",
                "hi": "कार्टाप हाइड्रोक्लोराइड 4% G (10 किग्रा/एकड़) या क्लोरांट्रानिलिप्रोल (7.5 किग्रा/एकड़)।",
                "mr": "कार्टाप हायड्रोक्लोराईड ४% दाणेदार एकरी १० किलो किंवा क्लोरांट्रानिलीप्रोल ०.४% जी एकरी ७.५ किलो मुळांशी द्यावे."
            },
            "prevention": {
                "en": "Early earthing up at 45 days after planting helps prevent borer entry into shoots.",
                "hi": "बुवाई के 45 दिनों बाद पहली मिट्टी चढ़ाने से कीट प्रकोप रुकता है।",
                "mr": "ऊस लागवडीनंतर ४५ दिवसांनी पिकाला हलकी बांधणी (माती लावणे) करावी."
            }
        }
    ],
    "grapes": [
        {
            "name": {"en": "Grapes Downy Mildew", "hi": "अंगूर का डाउनी मिल्ड्यू (मृदुरोमिल फफूंदी)", "mr": "द्राक्षांवरील केवडा (डाऊनी मिल्ड्यू रोग)"},
            "type": "Fungal",
            "symptoms": {
                "en": "Oil-like yellow translucent spots on upper leaf surface with dense white cottony growth on underside.",
                "hi": "पत्तियों की ऊपरी सतह पर तेल जैसे पीले पारदर्शी धब्बे और नीचे सफेद रुई जैसी फफूंद।",
                "mr": "पानांच्या वरच्या भागावर तेलासारखे पिवळसर पारदर्शक ठिपके आणि मागच्या बाजूला पांढरी कापसासारखी बुरशीची वाढ."
            },
            "organic_remedy": {
                "en": "Spray 1% Bordeaux mixture (Copper sulfate + Lime) preventively before rain and foggy spells.",
                "hi": "बारिश और कोहरे से पहले 1% बोर्डो मिश्रण का छिड़काव करें।",
                "mr": "पाऊस किंवा धुके येण्यापूर्वी प्रतिबंधक उपाय म्हणून १% बोर्डो मिश्रण फवारावे."
            },
            "chemical_remedy": {
                "en": "Curative spray: Dimethomorph 50% WP @ 1g/liter or Cymoxanil 8% + Mancozeb 64% WP @ 2g/liter.",
                "hi": "डाइमेथोमॉर्फ 50% WP (1 ग्राम/लीटर) या साइमोक्सानिल + मैंकोजेब (2 ग्राम/लीटर)।",
                "mr": "डायमेथोमॉर्फ ५०% डब्ल्यूपी १ ग्रॅम/लिटर किंवा सायमोक्सॅनिल + मँकोझेब २ ग्रॅम प्रति लिटर पाण्यात फवारावे."
            },
            "prevention": {
                "en": "Ensure proper canopy management for air circulation and sunlight penetration; keep leaves dry.",
                "hi": "कैनोपी छंटाई सही रखें ताकि हवा और धूप पत्तियों तक पहुंचे।",
                "mr": "वेलींची योग्य छाटणी करून हवा व सूर्यप्रकाश खेळता ठेवावा."
            }
        }
    ],
    "onion": [
        {
            "name": {"en": "Onion Purple Blotch", "hi": "प्याज का बैंगनी धब्बा रोग (पर्पल ब्लॉच)", "mr": "कांद्यावरील करपा (जांभळा करपा / पर्पल ब्लॉच)"},
            "type": "Fungal",
            "symptoms": {
                "en": "Small sunken water-soaked spots on leaves that turn purple-brown with yellow halo, leading to leaf blighting.",
                "hi": "पत्तियों पर छोटे पानी जैसे धब्बे जो बाद में बैंगनी-भूरे हो जाते हैं और पत्तियां ऊपर से सूखने लगती हैं।",
                "mr": "पानांवर सुरुवातीला पांढुरके आणि नंतर मध्यभागी जांभळट तपकिरी रंगाचे लंबगोलाकार चट्टे पडणे, पाने शेंड्याकडून वाळणे."
            },
            "organic_remedy": {
                "en": "Spray Trichoderma harzianum @ 5g/liter. Avoid excessive nitrogen fertilizer.",
                "hi": "ट्राइकोडर्मा (5 ग्राम/लीटर) छिड़कें। आवश्यकता से अधिक यूरिया का प्रयोग न करें।",
                "mr": "ट्रायकोडर्मा ५ ग्रॅम/लिटर फवारावे. जास्त प्रमाणात युरिया खताचा वापर टाळावा."
            },
            "chemical_remedy": {
                "en": "Spray Tebuconazole 25.9% EC @ 1ml/liter or Mancozeb 75% WP @ 2.5g/liter with sticker/spreader.",
                "hi": "टेबुकोनाज़ोल 25.9% EC (1 मिली/लीटर) या मैंकोजेब 75% WP (2.5 ग्राम/लीटर) स्टीकर के साथ छिड़कें।",
                "mr": "टेब्युकोनॅझोल २५.९% ईसी १ मिली किंवा मँकोझेब २.५ ग्रॅम प्रति लिटर पाण्यात स्टिकर (स्प्रेडर) सह फवारावे."
            },
            "prevention": {
                "en": "Provide proper field drainage, avoid waterlogging, and treat seedlings with fungicide before transplanting.",
                "hi": "खेत में पानी न भरने दें और रोपाई से पहले पौध को फफूंदनाशक घोल में डुबोएं।",
                "mr": "शेतात पाण्याचा योग्य निचरा ठेवावा आणि पुनर्लागवडीपूर्वी रोपांची मुळे बुरशीनाशकाच्या द्रावणात बुडवावीत."
            }
        }
    ]
}


def analyze_disease_image(
    image_bytes: Optional[bytes] = None,
    image_base64: Optional[str] = None,
    crop_hint: Optional[str] = None,
    symptoms_text: Optional[str] = None,
    language: str = "Marathi"
) -> Dict[str, Any]:
    """
    Analyze plant / crop image using Gemma3 Vision via Ollama.
    Falls back gracefully to offline expert diagnostic engine if model is busy.
    """
    lang = language.strip().lower()
    lang_code = "mr" if lang in ["mr", "marathi"] else "hi" if lang in ["hi", "hindi"] else "en"
    lang_name = "Marathi" if lang_code == "mr" else "Hindi" if lang_code == "hi" else "English"

    # Prepare base64 image string
    b64_img = ""
    if image_bytes:
        b64_img = base64.b64encode(image_bytes).decode("utf-8")
    elif image_base64:
        # Strip header if present
        b64_img = re.sub(r"^data:image\/[a-zA-Z]+;base64,", "", image_base64.strip())

    # Try Ollama Vision if image is present
    if b64_img:
        try:
            prompt = (
                f"You are an expert plant pathologist and farming assistant in India.\n"
                f"Analyze this image of a plant/crop/fruit/vegetable and provide a complete diagnosis in {lang_name}:\n"
                f"1. Crop/Plant identified\n"
                f"2. Disease, pest attack, or nutritional deficiency identified with scientific & local name\n"
                f"3. Key visible symptoms observed on leaves, fruits, or stem\n"
                f"4. Immediate organic/biological control measures\n"
                f"5. Chemical treatment with exact recommended medicine name and dosage per liter of water\n"
                f"6. Preventive measures for future\n"
                f"7. Ask 2 specific interactive follow-up questions to the farmer to provide even more exact advice (e.g. asking about crop age, recent rainfall, or watering method).\n"
                f"Format cleanly and clearly for a farmer to understand easily."
            )

            payload = {
                "model": VISION_MODEL,
                "prompt": prompt,
                "images": [b64_img],
                "stream": False,
                "options": {
                    "temperature": 0.2,
                    "num_predict": 500,
                }
            }

            resp = requests.post(OLLAMA_URL, json=payload, timeout=60)
            if resp.status_code == 200:
                result = resp.json().get("response", "").strip()
                if result:
                    return {
                        "success": True,
                        "analysis_method": "Ollama Vision (Gemma3)",
                        "language": lang_name,
                        "diagnosis_text": result,
                        "interactive_prompt": _get_disease_followup(lang_code)
                    }
        except Exception:
            pass  # Fall through to expert offline rule base

    # Offline Expert Diagnostic Match
    return _diagnose_offline(crop_hint, symptoms_text, lang_code)


def _diagnose_offline(crop_hint: Optional[str], symptoms_text: Optional[str], lang_code: str) -> Dict[str, Any]:
    """Offline rule-based agricultural disease diagnostic match."""
    crop_key = "tomato"
    if crop_hint:
        c = crop_hint.casefold()
        for key in OFFLINE_DISEASE_DB.keys():
            if key in c or (key == "cotton" and any(w in c for w in ["कापूस", "कपास"])) or \
               (key == "sugarcane" and any(w in c for w in ["ऊस", "गन्ना"])) or \
               (key == "grapes" and any(w in c for w in ["द्राक्ष", "अंगूर"])) or \
               (key == "onion" and any(w in c for w in ["कांदा", "प्याज"])):
                crop_key = key
                break

    diseases = OFFLINE_DISEASE_DB.get(crop_key, OFFLINE_DISEASE_DB["tomato"])
    selected = diseases[0]

    # If symptoms indicate curling/vector
    if symptoms_text and any(w in symptoms_text.casefold() for w in ["curl", "चुरडा", "मुरडा", "बोकड्या", "सिकुड़"]):
        if len(diseases) > 1:
            selected = diseases[1]

    d_name = selected["name"].get(lang_code, selected["name"]["en"])
    d_symptoms = selected["symptoms"].get(lang_code, selected["symptoms"]["en"])
    d_organic = selected["organic_remedy"].get(lang_code, selected["organic_remedy"]["en"])
    d_chemical = selected["chemical_remedy"].get(lang_code, selected["chemical_remedy"]["en"])
    d_prev = selected["prevention"].get(lang_code, selected["prevention"]["en"])

    if lang_code == "mr":
        diagnosis_text = (
            f"रोग निदान: {d_name} (प्रकार: {selected['type']})\n\n"
            f"लक्षणे: {d_symptoms}\n\n"
            f"जैविक / सेंद्रिय उपाय: {d_organic}\n\n"
            f"रासायनिक फवारणी उपाय: {d_chemical}\n\n"
            f"प्रतिबंधात्मक काळजी: {d_prev}"
        )
    elif lang_code == "hi":
        diagnosis_text = (
            f"रोग पहचान: {d_name} (प्रकार: {selected['type']})\n\n"
            f"लक्षण: {d_symptoms}\n\n"
            f"जैविक उपाय: {d_organic}\n\n"
            f"रासायनिक छिड़काव: {d_chemical}\n\n"
            f"भविष्य की रोकथाम: {d_prev}"
        )
    else:
        diagnosis_text = (
            f"Identified Condition: {d_name} (Type: {selected['type']})\n\n"
            f"Symptoms: {d_symptoms}\n\n"
            f"Organic / Biological Solution: {d_organic}\n\n"
            f"Chemical Treatment: {d_chemical}\n\n"
            f"Preventive Measures: {d_prev}"
        )

    return {
        "success": True,
        "analysis_method": "Expert Agricultural Pathology Engine (Offline)",
        "language": "Marathi" if lang_code == "mr" else "Hindi" if lang_code == "hi" else "English",
        "crop": crop_key,
        "disease_name": d_name,
        "disease_type": selected["type"],
        "diagnosis_text": diagnosis_text,
        "interactive_prompt": _get_disease_followup(lang_code)
    }


def _get_disease_followup(lang: str) -> str:
    if lang == "mr":
        return "तुमच्या पिकाचे वय किती दिवस आहे आणि ही लक्षणे केवळ काही झाडांवर दिसत आहेत की संपूर्ण शेतात पसरली आहेत? हे सांगितल्यास मी अचूक प्रमाण सांगू शकेन."
    elif lang == "hi":
        return "आपकी फसल कितने दिनों की है और यह लक्षण कुछ पौधों पर हैं या पूरे खेत में फैल रहे हैं? यह बताने पर हम अधिक सटीक मात्रा बता सकते हैं।"
    else:
        return "What is the age or growth stage of your crop, and are these symptoms confined to a few plants or spreading rapidly across the whole plot?"
