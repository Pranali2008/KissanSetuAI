"""
Market Price (Mandi Rates) Service for Farmer Voice Assistant
Provides current APMC mandi prices, modal rates, arrivals, and price trends
in English, Hindi, and Marathi.
"""

from typing import List, Dict, Any, Optional

MARKET_DATA = [
    {
        "crop_id": "tomato",
        "crop_name": {"en": "Tomato", "hi": "टमाटर", "mr": "टोमॅटो"},
        "market": "Narayangaon APMC (Pune)",
        "state": "Maharashtra",
        "min_price": 1400,
        "max_price": 2800,
        "modal_price": 2200,
        "unit": "₹ / Quintal (100 kg)",
        "trend": "Upward (+₹200)",
        "arrival_quintals": 1850,
        "quality": "Grade A (Hybrid)",
        "advisory": {
            "en": "Demand is high in major urban centers. Harvesting mature-green to turning fruits for distant markets is recommended.",
            "hi": "शहरी बाजारों में मांग अच्छी है। दूर की मंडियों के लिए अधपके टमाटर तोड़ें।",
            "mr": "शहरी बाजारात चांगली मागणी आहे. दूरच्या बाजारपेठेसाठी पक्व पण किंचित तांबूस टोमॅटोची काढणी करावी."
        }
    },
    {
        "crop_id": "onion",
        "crop_name": {"en": "Onion (Red)", "hi": "लाल प्याज", "mr": "लाल कांदा"},
        "market": "Lasalgaon APMC (Nashik)",
        "state": "Maharashtra",
        "min_price": 1800,
        "max_price": 3400,
        "modal_price": 2900,
        "unit": "₹ / Quintal (100 kg)",
        "trend": "Stable",
        "arrival_quintals": 4200,
        "quality": "Medium to Good Size",
        "advisory": {
            "en": "Graded and well-cured onions fetching premium rates. Avoid bringing wet onions to mandi.",
            "hi": "अच्छी ग्रेडिंग और सूखी प्याज को ऊंचा भाव मिल रहा है। गीली प्याज मंडी न लाएं।",
            "mr": "चांगली प्रतवारी केलेला आणि व्यवस्थित वाळवलेला कांदा विकल्यास चांगला दर मिळतो. ओला कांदा बाजारात आणू नये."
        }
    },
    {
        "crop_id": "cotton",
        "crop_name": {"en": "Cotton (Medium Staple)", "hi": "कपास", "mr": "कापूस"},
        "market": "Akola APMC",
        "state": "Maharashtra",
        "min_price": 6800,
        "max_price": 7650,
        "modal_price": 7250,
        "unit": "₹ / Quintal (100 kg)",
        "trend": "Steady",
        "arrival_quintals": 1200,
        "quality": "Clean, Low Moisture (<8%)",
        "advisory": {
            "en": "Prices are hovering close to MSP. Ensure moisture content is below 8% to prevent price deduction.",
            "hi": "भाव एमएसपी के आसपास हैं। 8% से कम नमी होने पर ही पूरा भाव मिलता है।",
            "mr": "भाव हमीभावाच्या आसपास आहेत. कापसात ओलावा ८ टक्क्यांपेक्षा कमी असावा, ज्यामुळे चांगला भाव मिळतो."
        }
    },
    {
        "crop_id": "wheat",
        "crop_name": {"en": "Wheat (Lokwan / Sharbati)", "hi": "गेहूं (लोकवन)", "mr": "गहू (लोकवन)"},
        "market": "Pune APMC",
        "state": "Maharashtra",
        "min_price": 2600,
        "max_price": 3300,
        "modal_price": 2950,
        "unit": "₹ / Quintal (100 kg)",
        "trend": "Firm",
        "arrival_quintals": 800,
        "quality": "Bold Grain (Lokwan)",
        "advisory": {
            "en": "Strong milling demand. Clean, bold grains receive premium over standard FAQ rates.",
            "hi": "आटा मिलों की मजबूत मांग है। साफ और चमकदार दानों को प्रीमियम भाव मिल रहा है।",
            "mr": "पिठाच्या गिरण्यांकडून चांगली मागणी आहे. स्वच्छ आणि भरदार दाण्यांच्या लोकवन गव्हाला अधिक दर मिळत आहे."
        }
    },
    {
        "crop_id": "soybean",
        "crop_name": {"en": "Soybean (Yellow)", "hi": "सोयाबीन (पीला)", "mr": "सोयाबीन (पिवळा)"},
        "market": "Latur APMC",
        "state": "Maharashtra",
        "min_price": 4200,
        "max_price": 4850,
        "modal_price": 4600,
        "unit": "₹ / Quintal (100 kg)",
        "trend": "Upward (+₹100)",
        "arrival_quintals": 3100,
        "quality": "Standard Quality",
        "advisory": {
            "en": "Crushers actively buying. Hold quality stocks if you have safe storage, as demand is firm.",
            "hi": "तेल मिलों की मांग तेज है। सुरक्षित भंडारण हो तो धीरे-धीरे माल निकालें।",
            "mr": "तेल गिरण्यांकडून खरेदी सुरू आहे. सुरक्षित साठवणूक असल्यास हळूहळू विक्री करणे फायदेशीर ठरेल."
        }
    },
    {
        "crop_id": "sugarcane",
        "crop_name": {"en": "Sugarcane (FRP Rate)", "hi": "गन्ना (एफआरपी)", "mr": "ऊस (एफआरपी भाव)"},
        "market": "Cooperative Sugar Mills (Kolhapur/Pune)",
        "state": "Maharashtra",
        "min_price": 3150,
        "max_price": 3550,
        "modal_price": 3400,
        "unit": "₹ / Ton (1000 kg)",
        "trend": "Stable at FRP baseline",
        "arrival_quintals": 0,
        "quality": "10.25% sugar recovery base",
        "advisory": {
            "en": "Register harvest slips according to mill schedules to ensure timely crushing and recovery bonuses.",
            "hi": "मिल के कैलेंडर के अनुसार पर्ची कटवाएं ताकि समय पर पेराई और पूरा भाव मिले।",
            "mr": "साखर कारखान्याच्या तोडणी वेळापत्रकानुसार नोंद ठेवावी, जेणेकरून वेळेवर तोड होऊन अधिक उतारा मिळेल."
        }
    }
]


def get_market_prices(crop: Optional[str] = None, language: str = "English") -> Dict[str, Any]:
    """Retrieve APMC mandi prices formatted in chosen language."""
    lang = language.strip().lower()
    lang_code = "mr" if lang in ["mr", "marathi"] else "hi" if lang in ["hi", "hindi"] else "en"

    matched = []
    crop_filter = crop.strip().casefold() if crop else None

    for m in MARKET_DATA:
        if crop_filter:
            searchable = f"{m['crop_id']} {m['crop_name']['en']} {m['crop_name']['hi']} {m['crop_name']['mr']}".casefold()
            if crop_filter in searchable:
                matched.append(m)
        else:
            matched.append(m)

    if not matched:
        matched = MARKET_DATA

    results = []
    for item in matched:
        results.append({
            "crop_id": item["crop_id"],
            "crop_name": item["crop_name"].get(lang_code, item["crop_name"]["en"]),
            "market": item["market"],
            "min_price": item["min_price"],
            "max_price": item["max_price"],
            "modal_price": item["modal_price"],
            "unit": item["unit"],
            "trend": item["trend"],
            "advisory": item["advisory"].get(lang_code, item["advisory"]["en"])
        })

    if lang_code == "mr":
        prompt = "तुम्हाला तुमच्या जिल्ह्यातील इतर कोणत्याही शेतमालाचा (उदा. कांदा, कापूस, सोयाबीन किंवा टोमॅटो) थेट बाजारभाव जाणून घ्यायचा आहे का?"
    elif lang_code == "hi":
        prompt = "क्या आप अपने जिले की किसी अन्य फसल (जैसे प्याज, कपास, सोयाबीन या टमाटर) का ताजा मंडी भाव जानना चाहते हैं?"
    else:
        prompt = "Would you like current mandi prices for any other crops or specific APMC markets?"

    return {
        "count": len(results),
        "rates": results,
        "interactive_prompt": prompt
    }
