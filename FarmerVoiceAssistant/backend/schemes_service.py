"""
Government Schemes Service for Farmer Voice Assistant
Provides detailed information and official website links for Central
and State (Maharashtra / India) agricultural schemes in English, Hindi, and Marathi.
"""

from typing import List, Dict, Any, Optional

GOVERNMENT_SCHEMES = [
    {
        "id": "pm-kisan",
        "category": "financial",
        "website_url": "https://pmkisan.gov.in/",
        "title": {
            "en": "PM-KISAN (Pradhan Mantri Kisan Samman Nidhi)",
            "hi": "प्रधानमंत्री किसान सम्मान निधि (पीएम-किसान)",
            "mr": "प्रधानमंत्री किसान सन्मान निधी (पीएम-किसान)",
        },
        "description": {
            "en": "Direct income support of ₹6,000 per year to eligible farmer families in three equal installments of ₹2,000.",
            "hi": "पात्र किसान परिवारों को प्रति वर्ष ₹6,000 की प्रत्यक्ष आय सहायता 2,000 रुपये की तीन समान किस्तों में प्रदान की जाती है।",
            "mr": "पात्र शेतकरी कुटुंबांना दरवर्षी ₹६,००० थेट बँक खात्यात प्रत्येकी ₹२,००० च्या तीन समान हप्त्यांमध्ये मिळतात.",
        },
        "benefits": {
            "en": "₹6,000 annually credited directly via DBT to Aadhaar-seeded bank accounts.",
            "hi": "आधार लिंक बैंक खाते में ₹6,000 प्रति वर्ष सीधे डीबीटी के माध्यम से।",
            "mr": "वार्षिक ₹६,००० थेट आधार जोडलेल्या बँक खात्यात DBT द्वारे वर्ग केले जातात.",
        },
        "eligibility": {
            "en": "All landholding farmer families with cultivable land in their names.",
            "hi": "सभी भूमिधारक किसान परिवार जिनके नाम कृषि योग्य भूमि है।",
            "mr": "स्वतःच्या नावावर शेतजमीन असलेले सर्व खातेदार शेतकरी कुटुंब.",
        },
        "documents": {
            "en": "Aadhaar Card, Land ownership proof (7/12 extract / RoR), Bank passbook, Active mobile number.",
            "hi": "आधार कार्ड, भूमि स्वामित्व प्रमाण (खसरा/खतौनी), बैंक पासबुक, सक्रिय मोबाइल नंबर।",
            "mr": "आधार कार्ड, ७/१२ व ८-अ उतारा, बँक पासबुक, आधार लिंक असलेला मोबाईल नंबर.",
        },
        "how_to_apply": {
            "en": "Register online at pmkisan.gov.in (Farmers Corner) or visit your nearest CSC center.",
            "hi": "pmkisan.gov.in पर ऑनलाइन या नजदीकी सीएससी केंद्र पर जाकर पंजीकरण करें।",
            "mr": "pmkisan.gov.in या अधिकृत पोर्टलवर किंवा जवळच्या 'आपले सरकार' / CSC केंद्रावर अर्ज करा.",
        }
    },
    {
        "id": "pmfby",
        "category": "insurance",
        "website_url": "https://pmfby.gov.in/",
        "title": {
            "en": "PMFBY (Pradhan Mantri Fasal Bima Yojana)",
            "hi": "प्रधानमंत्री फसल बीमा योजना (पीएमएफबीवाई)",
            "mr": "प्रधानमंत्री पीक विमा योजना (पीएमएफबीवाय)",
        },
        "description": {
            "en": "Comprehensive crop insurance scheme protecting farmers against crop loss due to non-preventable natural risks (drought, flood, unseasonal rain, pests).",
            "hi": "सूखा, बाढ़, बेमौसम बारिश और कीटों से फसल नुकसान की भरपाई के लिए व्यापक फसल बीमा सुरक्षा योजना।",
            "mr": "अस्मानी संकटे, दुष्काळ, अतिवृष्टी, गारपीट किंवा किडींमुळे होणाऱ्या पिकांच्या नुकसानीपासून सर्वसमावेशक विमा संरक्षण.",
        },
        "benefits": {
            "en": "Farmers pay only 2% premium for Kharif crops, 1.5% for Rabi crops, and 5% for commercial/horticultural crops. In Maharashtra, farmers can enroll at just ₹1 under special state subsidy.",
            "hi": "खरीफ के लिए 2%, रबी के लिए 1.5% और बागवानी के लिए 5% प्रीमियम। महाराष्ट्र में मात्र ₹1 में फसल बीमा सुविधा उपलब्ध।",
            "mr": "खरीप पिकांसाठी २%, रब्बीसाठी १.५% आणि बागायती पिकांसाठी ५% प्रीमियम. महाराष्ट्रात 'एक रुपया पीक विमा' योजनेचा लाभ.",
        },
        "eligibility": {
            "en": "All farmers including sharecroppers and tenant farmers growing notified crops in notified areas.",
            "hi": "अधिसूचित क्षेत्रों में अधिसूचित फसल उगाने वाले सभी किसान और बटाईदार।",
            "mr": "अधिसूचित क्षेत्रातील अधिसूचित पिके घेणारे सर्व शेतकरी व कुळ शेतकरी.",
        },
        "documents": {
            "en": "7/12 extract, Sowing certificate (Pik Pahani), Aadhaar card, Bank passbook.",
            "hi": "जमीन के कागजात (खतौनी), बुवाई प्रमाण पत्र, आधार कार्ड, बैंक पासबुक।",
            "mr": "७/१२ व ८-अ उतारा, ई-पीक पाहणी नोंद, आधार कार्ड, बँक पासबुक.",
        },
        "how_to_apply": {
            "en": "Apply through pmfby.gov.in or Bank / Common Service Centers (CSC) before the cutoff date.",
            "hi": "pmfby.gov.in पोर्टल अथवा बैंक / सीएससी केंद्र के माध्यम से आवेदन करें।",
            "mr": "pmfby.gov.in पोर्टलवरून किंवा बँकेतून / सीएससी केंद्रावर मुदतीच्या आत अर्ज भरावा.",
        }
    },
    {
        "id": "mahadbt-farmer",
        "category": "subsidies",
        "website_url": "https://mahadbt.maharashtra.gov.in/Farmer/FarmerHome/FarmerHome",
        "title": {
            "en": "MahaDBT Farmer Schemes (Maharashtra)",
            "hi": "महाडीबीटी किसान योजनाएं (महाराष्ट्र)",
            "mr": "महाडीबीटी शेतकरी योजना (महाराष्ट्र शासन)",
        },
        "description": {
            "en": "Unified single portal by Government of Maharashtra offering 50% to 80% subsidies on tractors, agricultural machinery, drip & sprinkler irrigation, farm ponds, polyhouses, and fruit plantation.",
            "hi": "महाराष्ट्र सरकार का एकीकृत पोर्टल जो ट्रैक्टर, ड्रिप सिंचाई, खेत तालाब और कृषि यंत्रों पर 50% से 80% तक सब्सिडी देता है।",
            "mr": "महाराष्ट्र शासनाचे सर्वसमावेशक पोर्टल. ट्रॅक्टर, कृषी अवजारे, ठिबक व तुषार सिंचन, शेततळे, फळबाग लागवड आणि शेडनेटवर ५०% ते ८०% पर्यंत अनुदान.",
        },
        "benefits": {
            "en": "Direct subsidy transferred to farmer bank account on lottery-based transparent allotment for equipment and irrigation systems.",
            "hi": "लॉटरी पद्धति द्वारा कृषि यंत्रों और सूक्ष्म सिंचाई पर 50% से 80% तक का सीधा अनुदान।",
            "mr": "सूक्ष्म सिंचनासाठी (ठिबक/तुषार) ७०-८०% अनुदान, ट्रॅक्टर व कृषी अवजारे, शेततळे प्लास्टिक अस्तरीकरणासाठी थेट बँक खात्यात अनुदान.",
        },
        "eligibility": {
            "en": "Farmers residing in Maharashtra with active 7/12 extract.",
            "hi": "महाराष्ट्र के किसान जिनके नाम सक्रिय 7/12 खसरा हो।",
            "mr": "महाराष्ट्रातील शेतकरी ज्यांच्या नावावर ७/१२ व ८-अ उतारा आहे.",
        },
        "documents": {
            "en": "7/12 extract, 8-A extract, Aadhaar card, Bank passbook, Caste certificate (if applicable).",
            "hi": "7/12 खतौनी, 8-A, आधार कार्ड, बैंक पासबुक, जाति प्रमाण पत्र (यदि लागू हो)।",
            "mr": "७/१२ उतारा, ८-अ, आधार कार्ड, बँक पासबुक, जात प्रमाणपत्र (लागू असल्यास).",
        },
        "how_to_apply": {
            "en": "Visit mahadbt.maharashtra.gov.in, create farmer login, select 'Farmer Schemes' and apply.",
            "hi": "mahadbt.maharashtra.gov.in पर किसान लॉगिन बनाकर 'कृषि योजनाएं' विकल्प से आवेदन करें।",
            "mr": "mahadbt.maharashtra.gov.in वर 'शेतकरी योजना' निवडून ऑनलाइन अर्ज करा.",
        }
    },
    {
        "id": "pm-kusum",
        "category": "solar",
        "website_url": "https://pmkusum.mnre.gov.in/",
        "title": {
            "en": "PM-KUSUM Solar Agricultural Pumps Scheme",
            "hi": "पीएम कुसुम सोलर पंप योजना",
            "mr": "पीएम कुसुम सौर कृषी पंप योजना",
        },
        "description": {
            "en": "Provides up to 90% subsidy for installing standalone off-grid solar water pumps for irrigation and solarizing existing grid-connected agricultural pumps.",
            "hi": "सिंचाई के लिए सोलर पंप लगाने और मौजूदा कृषि पंपों को सौर ऊर्जा से जोड़ने पर 90% तक की भारी सब्सिडी।",
            "mr": "शेतामध्ये दिवसा सिंचनासाठी ३ ते ७.५ एचपी सौर कृषी पंप बसविण्यासाठी केंद्र व राज्य शासनाकडून ९०% पर्यंत भरीव अनुदान.",
        },
        "benefits": {
            "en": "Farmers pay only 10% of total pump cost. Farmers get uninterrupted daytime power for irrigation and zero electricity bills.",
            "hi": "किसान को केवल 10% लागत देनी होती है। दिन के समय निर्बाध सिंचाई और शून्य बिजली बिल।",
            "mr": "शेतकऱ्याला केवळ १०% स्वहिस्सा भरावा लागतो. दिवसा शाश्वत वीज मिळून विजेचे बिल कायमचे शून्य होते.",
        },
        "eligibility": {
            "en": "Farmers with agriculture land and an available water source (well, borewell, farm pond) without existing electric connection.",
            "hi": "जिन किसानों के पास कृषि भूमि और पानी का स्रोत (कुआं/बोरवेल) हो और बिजली कनेक्शन न हो।",
            "mr": "शेती आणि पाण्याचा शाश्वत स्त्रोत (विहीर, कूपनलिका, शेततळे) असलेले व पारंपारिक वीज जोडणी नसलेले शेतकरी.",
        },
        "documents": {
            "en": "7/12 extract, Aadhaar card, Bank account details, Water source undertaking, Passport photo.",
            "hi": "7/12 खसरा, आधार कार्ड, बैंक पासबुक, जल स्रोत प्रमाण पत्र।",
            "mr": "७/१२ व ८-अ उतारा, आधार कार्ड, पाण्याचा स्त्रोत प्रमाणपत्र, बँक पासबुक.",
        },
        "how_to_apply": {
            "en": "Apply through state nodal portal (e.g., Mahaurja in Maharashtra at mahadiscom.in/solar-mskvy or pmkusum.mnre.gov.in).",
            "hi": "pmkusum.mnre.gov.in अथवा राज्य नोडल एजेंसी पोर्टल पर ऑनलाइन आवेदन करें।",
            "mr": "महाऊर्जा किंवा महावितरणच्या अधिकृत पोर्टलवर (mahadiscom.in) ऑनलाइन नोंदणी करा.",
        }
    },
    {
        "id": "soil-health-card",
        "category": "soil",
        "website_url": "https://soilhealth.dac.gov.in/",
        "title": {
            "en": "Soil Health Card Scheme",
            "hi": "मृदा स्वास्थ्य कार्ड योजना (सॉइल हेल्थ कार्ड)",
            "mr": "मृदा आरोग्य पत्रिका योजना (सॉईल हेल्थ कार्ड)",
        },
        "description": {
            "en": "Government tests your field's soil sample and issues a card detailing 12 parameters (N, P, K, pH, Zinc, etc.) with custom fertilizer dosage recommendations.",
            "hi": "खेत की मिट्टी की निशुल्क जांच कर 12 पोषक तत्वों की स्थिति और संतुलित खाद की मात्रा की रिपोर्ट दी जाती है।",
            "mr": "शेतातील मातीचे नमुने तपासून जमिनीचा पोत, १२ मुख्य व सूक्ष्म अन्नद्रव्ये (NPK, जस्त, बोरॉन) व योग्य खत मात्रा दर्शवणारी पत्रिका दिली जाते.",
        },
        "benefits": {
            "en": "Prevents over-fertilization, reduces input costs by 15-25%, and improves soil fertility and crop yield.",
            "hi": "अनावश्यक खाद का खर्च 15-25% घटता है और भूमि की उपजाऊ क्षमता बढ़ती है।",
            "mr": "अवाजवी खतांचा खर्च १५ ते २५% वाचतो, जमिनीची सुपिकता टिकून उत्पादन वाढते.",
        },
        "eligibility": {
            "en": "All farmers across India.",
            "hi": "देश के सभी किसान।",
            "mr": "सर्व शेतकरी बांधव.",
        },
        "documents": {
            "en": "Aadhaar Card, 7/12 extract, Soil sample from field.",
            "hi": "आधार कार्ड, खसरा नंबर, खेत की मिट्टी का नमूना।",
            "mr": "आधार कार्ड, ७/१२ उतारा, शेतातील मातीचा योग्य नमुना.",
        },
        "how_to_apply": {
            "en": "Submit soil sample to nearby Agriculture Office / Soil Testing Lab or check reports at soilhealth.dac.gov.in.",
            "hi": "नजदीकी कृषि कार्यालय अथवा मृदा परीक्षण प्रयोगशाला में संपर्क करें या soilhealth.dac.gov.in देखें।",
            "mr": "तालुका कृषी कार्यालय अथवा माती परीक्षण प्रयोगशाळेत नमुना जमा करा किंवा अधिकृत पोर्टलवर माहिती पहा.",
        }
    },
    {
        "id": "kisan-credit-card",
        "category": "financial",
        "website_url": "https://www.myscheme.gov.in/schemes/kcc",
        "title": {
            "en": "Kisan Credit Card (KCC)",
            "hi": "किसान क्रेडिट कार्ड (केसीसी)",
            "mr": "किसान क्रेडिट कार्ड (केसीसी)",
        },
        "description": {
            "en": "Affordable agricultural credit card offering loans up to ₹3 Lakh at an effective low interest rate of only 4% (with prompt repayment incentive).",
            "hi": "किसानों को खेती की जरूरतों के लिए ₹3 लाख तक का सस्ता ऋण केवल 4% ब्याज दर पर (समय पर भुगतान पर)।",
            "mr": "बियाणे, खते आणि शेती खर्चासाठी ₹३ लाखांपर्यंतचे पीक कर्ज वेळेवर परतफेड केल्यास केवळ ४% सवलतीच्या व्याजदराने मिळते.",
        },
        "benefits": {
            "en": "Revolving credit line, collateral-free loans up to ₹1.6 Lakh, hassle-free renewal, covers cultivation and post-harvest expenses.",
            "hi": "₹1.6 लाख तक बिना बंधक ऋण, लचीली पुनर्भुगतान व्यवस्था, कम ब्याज दर।",
            "mr": "₹१.६ लाखांपर्यंत कोणत्याही तारणाशिवाय कर्ज, सोपी नूतनीकरण प्रक्रिया, कमी व्याजदर.",
        },
        "eligibility": {
            "en": "Individual/joint farmers, tenant farmers, oral lessees, self-help groups (SHGs).",
            "hi": "सभी किसान, काश्तकार, पट्टेदार और स्वयं सहायता समूह।",
            "mr": "सर्व खातेदार शेतकरी, कुळ शेतकरी, बटाईदार व शेतकरी बचत गट.",
        },
        "documents": {
            "en": "Land records (7/12 & 8-A), Aadhaar Card, PAN Card, passport photos, no-dues certificate.",
            "hi": "7/12 खतौनी, आधार कार्ड, पैन कार्ड, फोटो, बैंक नो-ड्यूज।",
            "mr": "७/१२ व ८-अ उतारा, आधार कार्ड, पॅन कार्ड, २ फोटो, कर्ज नसलेचा दाखला.",
        },
        "how_to_apply": {
            "en": "Apply at your nearest nationalized / cooperative bank branch or via myscheme.gov.in.",
            "hi": "किसी भी बैंक शाखा में संपर्क करें या myscheme.gov.in से फॉर्म डाउनलोड करें।",
            "mr": "आपल्या गावातील राष्ट्रीयीकृत किंवा सहकारी बँक शाखेत अर्ज सादर करा.",
        }
    },
    {
        "id": "pkvy-organic",
        "category": "organic",
        "website_url": "https://pgsindia-ncof.gov.in/",
        "title": {
            "en": "Paramparagat Krishi Vikas Yojana (PKVY - Organic Farming)",
            "hi": "परंपरागत कृषि विकास योजना (पीकेवीवाई)",
            "mr": "परंपरागत कृषी विकास योजना (सेंद्रिय शेती)",
        },
        "description": {
            "en": "Promotes chemical-free organic farming through cluster approach with PGS certification and financial assistance of ₹50,000 per hectare over 3 years.",
            "hi": "जैविक खेती को बढ़ावा देने के लिए 3 वर्षों में ₹50,000 प्रति हेक्टेयर की वित्तीय सहायता और निःशुल्क जैविक प्रमाणीकरण।",
            "mr": "रासायनिक खतांशिवाय विषमुक्त सेंद्रिय शेतीला चालना देण्यासाठी ३ वर्षांत प्रति हेक्टर ₹५०,००० चे अनुदान व पीजीएस सेंद्रिय प्रमाणीकरण.",
        },
        "benefits": {
            "en": "Financial aid for organic seeds, bio-fertilizers, vermicompost units, cluster branding, packaging, and direct marketing.",
            "hi": "जैविक खाद, बीज, वर्मीकंपोस्ट और उत्पाद विपणन के लिए सीधा अनुदान।",
            "mr": "सेंद्रिय खते, गांडूळ खत युनिट, जीवामृत, बीजप्रक्रिया व उत्पादनाच्या पॅकिंग-विक्रीसाठी थेट अनुदान.",
        },
        "eligibility": {
            "en": "Groups of farmers forming clusters of 20 or more hectares for organic farming.",
            "hi": "20 हेक्टेयर या उससे अधिक के समूह (क्लस्टर) बनाकर जैविक खेती करने वाले किसान।",
            "mr": "किमान २० हेक्टरचे गट (क्लस्टर) करून सेंद्रिय शेती करणारे शेतकरी.",
        },
        "documents": {
            "en": "Farmer group registration, 7/12 extracts, Aadhaar, bank passbook.",
            "hi": "किसान समूह विवरण, जमीन के कागजात, आधार, बैंक खाता।",
            "mr": "शेतकरी गटाची नोंदणी, ७/१२ उतारा, आधार कार्ड, बँक खाते तपशील.",
        },
        "how_to_apply": {
            "en": "Apply through the Block Agriculture Office or register at pgsindia-ncof.gov.in.",
            "hi": "प्रखंड कृषि कार्यालय या pgsindia-ncof.gov.in के माध्यम से आवेदन करें।",
            "mr": "तालुका कृषी अधिकारी कार्यालयाशी संपर्क साधा किंवा pgsindia-ncof.gov.in वर नोंदणी करा.",
        }
    }
]


def get_all_schemes(language: str = "English", category: Optional[str] = None) -> List[Dict[str, Any]]:
    """Return all schemes formatted in the chosen language."""
    lang = language.strip().lower()
    lang_code = "mr" if lang in ["mr", "marathi"] else "hi" if lang in ["hi", "hindi"] else "en"

    results = []
    for s in GOVERNMENT_SCHEMES:
        if category and category.lower() != "all" and s["category"].lower() != category.lower():
            continue

        results.append({
            "id": s["id"],
            "category": s["category"],
            "title": s["title"].get(lang_code, s["title"]["en"]),
            "description": s["description"].get(lang_code, s["description"]["en"]),
            "benefits": s["benefits"].get(lang_code, s["benefits"]["en"]),
            "eligibility": s["eligibility"].get(lang_code, s["eligibility"]["en"]),
            "documents": s["documents"].get(lang_code, s["documents"]["en"]),
            "how_to_apply": s["how_to_apply"].get(lang_code, s["how_to_apply"]["en"]),
            "website_url": s["website_url"]
        })

    return results


def search_schemes(query: str, language: str = "English") -> Dict[str, Any]:
    """Search schemes matching a query and return detailed text and web links."""
    schemes = get_all_schemes(language)
    q = query.casefold().strip()

    matched = []
    for item in schemes:
        searchable = f"{item['title']} {item['description']} {item['benefits']}".casefold()
        if any(word in searchable for word in q.split() if len(word) > 2):
            matched.append(item)

    if not matched:
        matched = schemes[:3]  # return top 3 schemes if no specific match

    lang = language.strip().lower()
    lang_code = "mr" if lang in ["mr", "marathi"] else "hi" if lang in ["hi", "hindi"] else "en"

    if lang_code == "mr":
        prompt = "तुम्हाला यापैकी कोणत्या योजनेचा अर्ज किंवा आवश्यक कागदपत्रांची अधिक माहिती हवी आहे का?"
    elif lang_code == "hi":
        prompt = "क्या आप इनमें से किसी योजना के आवेदन या दस्तावेजों के बारे में और विस्तार से जानना चाहते हैं?"
    else:
        prompt = "Would you like more details on how to apply or document checklists for any of these schemes?"

    return {
        "count": len(matched),
        "schemes": matched,
        "interactive_prompt": prompt
    }
