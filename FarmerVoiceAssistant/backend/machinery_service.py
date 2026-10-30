"""
Farm Machinery & Equipment Service for KissanSetu
Provides tractor and implement guides, custom hiring rental rates,
usage instructions, maintenance tips, and approximate costs with subsidies.
"""

from typing import List, Dict, Any, Optional

MACHINERY_DATA = [
    {
        "id": "tractor_45hp",
        "name": {
            "en": "Medium Utility Tractor (40–50 HP)",
            "hi": "मध्यम श्रेणी ट्रैक्टर (40–50 HP)",
            "mr": "मध्यम उपयुक्त ट्रॅक्टर (४० ते ५० एचपी)",
        },
        "category": "tractor",
        "icon": "🚜",
        "approx_cost": "₹6,50,000 – ₹8,20,000",
        "subsidy": {
            "en": "Up to ₹1,25,000 subsidy under MahaDBT / SMAM scheme (higher for SC/ST/Women).",
            "hi": "महाडीबीटी / एसएमएएम योजना के तहत ₹1,25,000 तक की सब्सिडी।",
            "mr": "महाडीबीटी व कृषी यांत्रिकीकरण योजनेअंतर्गत ₹१,२५,००० पर्यंत शासकीय अनुदान.",
        },
        "rental_rate": {
            "en": "₹700 – ₹1,000 per hour (including diesel & driver)",
            "hi": "₹700 – ₹1,000 प्रति घंटा (डीजल व चालक सहित)",
            "mr": "₹७०० ते ₹१,००० प्रति तास (डिझेल व चालकासह)",
        },
        "usage_instructions": {
            "en": "Ideal for plowing, rotavating, sowing, and heavy trolley haulage on 5 to 20 acre farms. Use low 1st gear for heavy plowing.",
            "hi": "5 से 20 एकड़ में गहरी जुताई, रोटावेटर और भारी ढुलाई के लिए उत्तम। जुताई के समय लो-1 गियर का प्रयोग करें।",
            "mr": "५ ते २० एकर शेतामध्ये नांगरट, रोटाव्हेटर, पेरणी व वाहतुकीसाठी सर्वोत्तम. जड कामांसाठी लो-१ गिअर वापरावा.",
        },
        "maintenance_tips": {
            "en": "Change engine oil and oil filter every 250-300 hours. Clean primary air filter weekly during dry dusty operations. Check tire pressure (front 28 psi, rear 14 psi).",
            "hi": "हर 250-300 घंटे पर इंजन ऑयल बदलें। धूल भरे काम में एयर फिल्टर की साप्ताहिक सफाई करें। टायर प्रेशर सही रखें।",
            "mr": "दर २५०-३०० तासांनंतर इंजिन ऑइल आणि ऑइल फिल्टर बदला. धूळ असल्यास एअर फिल्टर आठवड्यातून स्वच्छ करा. टायरमधील हवा तपासा.",
        }
    },
    {
        "id": "rotavator",
        "name": {
            "en": "Tractor Rotavator (Rotary Tiller - 6 ft)",
            "hi": "रोटावेटर (रोटरी टिलर - 6 फीट)",
            "mr": "रोटाव्हेटर (६ फूट रोटरी टिलर)",
        },
        "category": "tillage",
        "icon": "⚙️",
        "approx_cost": "₹95,000 – ₹1,35,000",
        "subsidy": {
            "en": "40% to 50% subsidy (up to ₹42,000) under agricultural mechanization schemes.",
            "hi": "कृषि यंत्रीकरण योजना में 40% से 50% (₹42,000 तक) अनुदान।",
            "mr": "कृषी यांत्रिकीकरण योजनेतून ४०% ते ५०% (₹४२,००० पर्यंत) थेट अनुदान.",
        },
        "rental_rate": {
            "en": "₹800 – ₹1,100 per hour / ₹900 per acre",
            "hi": "₹800 – ₹1,100 प्रति घंटा / ₹900 प्रति एकड़",
            "mr": "₹८०० ते ₹१,१०० प्रति तास / ₹९०० प्रति एकर",
        },
        "usage_instructions": {
            "en": "Prepares fine seedbed in a single pass. Operate tractor PTO at 540 RPM in medium moisture soil (avoid running in bone-dry or muddy soil).",
            "hi": "एक ही बार में खेत को भुरभुरा बनाता है। 540 आरपीएम पीटीओ पर चलाएं, अत्यधिक गीली या सूखी मिट्टी में न चलाएं।",
            "mr": "एकाच फेऱ्यात ढेकळे फोडून जमीन पेरणीयोग्य भुसभुशीत करतो. ५४० आरपीएम पीटीओ वेगावर मध्यम वाफसा जमिनीत चालवावा.",
        },
        "maintenance_tips": {
            "en": "Inspect L-type / C-type boron blades regularly; replace worn blades. Check side gear-box oil (SAE 90/140) every 50 operating hours.",
            "hi": "ब्लेड की धार जांचें और घिसे ब्लेड बदलें। साइड गियरबॉक्स में 140 ग्रेड ऑयल हर 50 घंटे पर चेक करें।",
            "mr": "रोटाव्हेटरच्या बोरॉन ब्लेडची झीज तपासा. साइड गिअरबॉक्समधील १४० ग्रेड ऑइलची पातळी दर ५० तासांनी तपासावी.",
        }
    },
    {
        "id": "seed_drill",
        "name": {
            "en": "Automatic Seed Cum Fertilizer Drill (9 Tyne)",
            "hi": "स्वचालित बीज एवं खाद ड्रिल (9 टाइन)",
            "mr": "स्वयंचलित बियाणे व खत पेरणी यंत्र (९ फणी)",
        },
        "category": "sowing",
        "icon": "🌱",
        "approx_cost": "₹55,000 – ₹85,000",
        "subsidy": {
            "en": "50% subsidy under NFSM and Sub-Mission on Agricultural Mechanization.",
            "hi": "राष्ट्रीय खाद्य सुरक्षा मिशन के तहत 50% तक सरकारी अनुदान।",
            "mr": "राष्ट्रीय अन्न सुरक्षा अभियानांतर्गत ५०% पर्यंत शासकीय अनुदान.",
        },
        "rental_rate": {
            "en": "₹600 – ₹800 per acre",
            "hi": "₹600 – ₹800 प्रति एकड़",
            "mr": "₹६०० ते ₹८०० प्रति एकर पेरणी",
        },
        "usage_instructions": {
            "en": "Places seeds and basal fertilizer at distinct depths simultaneously to prevent seed scorching. Calibrate seed meters before entering the field.",
            "hi": "बीज और खाद को सही गहराई पर अलग-अलग डालता है। खेत में जाने से पहले बीज दर कैलिब्रेट करें।",
            "mr": "बियाणे आणि खत एकाच वेळी योग्य खोलीवर टाकते, ज्यामुळे खताचा बियाण्याला थेट स्पर्श होत नाही. पेरणीपूर्वी बियाण्याचे प्रमाण सेट करा.",
        },
        "maintenance_tips": {
            "en": "Thoroughly empty and wash fertilizer box with water and dry after sowing to prevent corrosive rust. Grease chain drive daily.",
            "hi": "काम के बाद खाद का डिब्बा पूरी तरह खाली करें ताकि जंग न लगे। चेन ड्राइव पर ग्रीसिंग करें।",
            "mr": "पेरणीनंतर खताचा डबा स्वच्छ धुवून कोरडा करावा जेणेकरून खतामुळे पत्र्याला गंज लागणार नाही. चेनला नियमित ग्रीस लावा.",
        }
    },
    {
        "id": "drone_sprayer",
        "name": {
            "en": "Agricultural Drone Sprayer (10–16 Liter)",
            "hi": "कृषि ड्रोन स्प्रेयर (10–16 लीटर)",
            "mr": "कृषी फवारणी ड्रोन (१० ते १६ लिटर)",
        },
        "category": "spraying",
        "icon": "🛸",
        "approx_cost": "₹4,50,000 – ₹6,00,000",
        "subsidy": {
            "en": "Up to ₹5,00,000 (50%) subsidy for FPOs and ₹4,00,000 (40%) for individual youth/farmers under Kisan Drone Scheme.",
            "hi": "किसान ड्रोन योजना में किसान उत्पादक संगठनों (FPO) को 50% और युवाओं को 40% तक सब्सिडी।",
            "mr": "किसान ड्रोन योजनेअंतर्गत शेतकरी उत्पादक कंपन्यांना (FPO) ५०% आणि सुशिक्षित तरुणांना ४०% अनुदान.",
        },
        "rental_rate": {
            "en": "₹350 – ₹500 per acre (covers 1 acre in 7–10 minutes with ultra-fine droplet coverage)",
            "hi": "₹350 – ₹500 प्रति एकड़ (1 एकड़ 7-10 मिनट में छिड़काव)",
            "mr": "₹३५० ते ₹५०० प्रति एकर (अवघ्या ७ ते १० मिनिटांत १ एकर फवारणी पूर्ण)",
        },
        "usage_instructions": {
            "en": "Saves 90% water compared to conventional knapsack spraying. Fly at 1.5 to 2.5 meters above canopy in calm winds (<10 km/h).",
            "hi": "90% पानी की बचत। शांत हवा में फसल से 1.5 से 2.5 मीटर की ऊंचाई पर ऑटोपायलट मोड में उड़ाएं।",
            "mr": "पारंपारिक फवारणीपेक्षा ९०% पाण्याची बचत होते. वाऱ्याचा वेग कमी असताना पिकाच्या उंचीपासून १.५ ते २.५ मीटरवरून उडवावे.",
        },
        "maintenance_tips": {
            "en": "Flush nozzles and chemical pump with clean water immediately after every flight. Store intelligent lithium batteries at 50% charge.",
            "hi": "छिड़काव के तुरंत बाद नोजल और पंप को साफ पानी से धोएं। बैटरी को धूप से बचाकर सुरक्षित रखें।",
            "mr": "फवारणी संपताच नोझल्स आणि पंप स्वच्छ पाण्याने धुवून काढा. बॅटरी ५०% चार्ज ठेवून सुरक्षित ठिकाणी साठवावी.",
        }
    },
    {
        "id": "combine_harvester",
        "name": {
            "en": "Multi-Crop Combine Harvester (Track / Wheel type)",
            "hi": "मल्टी-क्रॉप कंबाइन हार्वेस्टर",
            "mr": "मल्टी-क्रॉप कम्बाईन हार्वेस्टर (काढणी व मळणी यंत्र)",
        },
        "category": "harvesting",
        "icon": "🌾",
        "approx_cost": "₹22,00,000 – ₹32,00,000",
        "subsidy": {
            "en": "Up to ₹8,00,000 subsidy under CHC (Custom Hiring Center) setup schemes.",
            "hi": "कस्टम हायरिंग सेंटर योजना के तहत ₹8,00,000 तक की वित्तीय सहायता।",
            "mr": "कस्टम हायरिंग सेंटर (CHC) योजनेअंतर्गत ₹८,००,००० पर्यंत शासकीय अनुदान.",
        },
        "rental_rate": {
            "en": "₹1,800 – ₹2,400 per acre for soybean, wheat, and paddy",
            "hi": "₹1,800 – ₹2,400 प्रति एकड़ (गेहूं, धान और सोयाबीन कटाई)",
            "mr": "₹१,८०० ते ₹२,४०० प्रति एकर (सोयाबीन, गहू, हरभरा व भात काढणी)",
        },
        "usage_instructions": {
            "en": "Performs harvesting, threshing, and cleaning simultaneously. Harvest when crop moisture is 14–16% to prevent grain cracking.",
            "hi": "कटाई, गहाई और सफाई एक साथ। दाने में 14-16% नमी होने पर ही कटाई करें ताकि दाना न टूटे।",
            "mr": "कापणी, मळणी आणि पाखडणी एकाच वेळी करते. दाण्यांमध्ये १४ ते १६% ओलावा असताना काढणी केल्यास दाणे फुटत नाहीत.",
        },
        "maintenance_tips": {
            "en": "Check cutter bar knife section alignment daily. Clean sieve and straw-walker chambers to prevent choking. Grease bearings every morning.",
            "hi": "कटर बार के ब्लेड प्रतिदिन जांचें। छलनी और स्ट्रॉ वॉकर को साफ रखें। सभी बेयरिंग में ग्रीस भरें।",
            "mr": "कटर बारच्या पात्यांची धार रोज तपासावी. चाळणी व थ्रेशर ड्रममधील भुसा स्वच्छ करावा. सर्व बेअरिंग्जला रोज सकाळी ग्रीसिंग करावे.",
        }
    }
]


def get_all_machinery(language: str = "English", category: Optional[str] = None) -> List[Dict[str, Any]]:
    lang = language.strip().lower()
    lang_code = "mr" if lang in ["mr", "marathi"] else "hi" if lang in ["hi", "hindi"] else "en"

    results = []
    for item in MACHINERY_DATA:
        if category and item["category"].casefold() != category.strip().casefold():
            continue
        results.append({
            "id": item["id"],
            "name": item["name"].get(lang_code, item["name"]["en"]),
            "category": item["category"],
            "icon": item["icon"],
            "approx_cost": item["approx_cost"],
            "subsidy": item["subsidy"].get(lang_code, item["subsidy"]["en"]),
            "rental_rate": item["rental_rate"].get(lang_code, item["rental_rate"]["en"]),
            "usage_instructions": item["usage_instructions"].get(lang_code, item["usage_instructions"]["en"]),
            "maintenance_tips": item["maintenance_tips"].get(lang_code, item["maintenance_tips"]["en"]),
        })
    return results


def get_machinery_by_id(machinery_id: str, language: str = "English") -> Optional[Dict[str, Any]]:
    lang = language.strip().lower()
    lang_code = "mr" if lang in ["mr", "marathi"] else "hi" if lang in ["hi", "hindi"] else "en"

    for item in MACHINERY_DATA:
        if item["id"].casefold() == machinery_id.strip().casefold():
            return {
                "id": item["id"],
                "name": item["name"].get(lang_code, item["name"]["en"]),
                "category": item["category"],
                "icon": item["icon"],
                "approx_cost": item["approx_cost"],
                "subsidy": item["subsidy"].get(lang_code, item["subsidy"]["en"]),
                "rental_rate": item["rental_rate"].get(lang_code, item["rental_rate"]["en"]),
                "usage_instructions": item["usage_instructions"].get(lang_code, item["usage_instructions"]["en"]),
                "maintenance_tips": item["maintenance_tips"].get(lang_code, item["maintenance_tips"]["en"]),
            }
    return None