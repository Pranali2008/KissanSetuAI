"""
Crop Advisory Service for KissanSetu
Provides stage-by-stage crop cultivation guidelines, spacing, fertilization,
irrigation scheduling, and seasonal suggestions for ALL crops, vegetables, and fruits
in English, Hindi, and Marathi.
"""

from typing import Dict, Any, Optional


CROP_ADVICE_DATA = {
    "tomato": {
        "crop": {"en": "Tomato", "hi": "टमाटर", "mr": "टोमॅटो"},
        "season": {"en": "Kharif, Rabi, and Summer", "hi": "खरीफ, रबी और जायद", "mr": "खरीप, रब्बी आणि उन्हाळी"},
        "sowing_harvesting": {
            "en": "Transplant 25-30 day old healthy seedlings on raised beds. Harvesting starts 60-70 days after transplanting in 8-10 pickings.",
            "hi": "25-30 दिन के स्वस्थ पौधे क्यारियों पर लगाएं। रोपाई के 60-70 दिन बाद पहली तुड़ाई शुरू होती है।",
            "mr": "२५ ते ३० दिवसांची निरोगी रोपे गादीवाफ्यावर पुनर्लागवड करावी. लागवडीनंतर ६०-७० दिवसांनी तोडणी सुरू होते."
        },
        "soil_prep": {
            "en": "Well-drained sandy loam to clay loam rich in organic matter. Prepare raised beds (width 3 ft, height 1 ft).",
            "hi": "अच्छी जल निकासी वाली दोमट मिट्टी। 3 फीट चौड़ी और 1 फीट ऊंची उठी हुई क्यारियां (Raised Beds) बनाएं।",
            "mr": "उत्तम निचरा होणारी पोयट्याची किंवा मध्यम काळी जमीन. गादी वाफे (३ फूट रुंद, १ फूट उंच) तयार करावेत."
        },
        "spacing": {
            "en": "Row to row: 4 to 5 ft; Plant to plant: 1.5 to 2 ft with drip irrigation and silver-black mulching paper.",
            "hi": "कतार से कतार: 4-5 फीट; पौधे से पौधा: 1.5-2 फीट, ड्रिप और मल्चिंग पेपर के साथ।",
            "mr": "दोन ओळींमधील अंतर ४ ते ५ फूट; दोन रोपांमधील अंतर १.५ ते २ फूट. ठिबक व मल्चिंग पेपरचा वापर उत्तम."
        },
        "fertilizer_schedule": {
            "en": "Basal dose: Well-decomposed FYM 10 tons/acre + 10:26:26 (100 kg/acre). Fertigation: 19:19:19 during vegetative stage; 12:61:0 during flowering; 0:52:34 and 0:0:50 during fruit development.",
            "hi": "बुवाई पूर्व: 10 टन गोबर खाद + 10:26:26 (100 किग्रा)। ड्रिप से: 19:19:19 वानस्पतिक अवस्था में, 12:61:0 फूल आते समय और 0:0:50 फल विकास पर।",
            "mr": "लागवडीपूर्वी: एकरी ८-१० टन कुजलेले शेणखत + १०:२६:२६ (१०० किलो). ठिबकमधून: वाढीच्या काळात १९:१९:१९, फुलधारणेच्या वेळी १२:६१:० आणि फळे भरताना ०:५२:३४ व ०:०:५० द्यावे."
        },
        "irrigation": {
            "en": "Daily 1 to 2 hours via drip irrigation. Avoid heavy flood irrigation which causes fruit cracking and fungal root rot.",
            "hi": "ड्रिप से रोजाना 1-2 घंटे पानी दें। अत्यधिक पानी न दें जिससे फल फटने या जड़ सड़न की समस्या न हो।",
            "mr": "ठिबक सिंचनाने दररोज १ ते २ तास आवश्यकतेनुसार पाणी द्यावे. मोकळे जास्त पाणी देणे टाळावे, ज्यामुळे फळे तडकणे व मूळकुज रोखता येते."
        },
        "seasonal_suggestions": {
            "en": "In monsoon, stake plants using bamboo & twine to prevent rotting. In summer, use mulching to preserve soil moisture.",
            "hi": "बरसात में पौधों को तार और बांस का सहारा दें। गर्मियों में नमी बनाए रखने के लिए मल्चिंग करें।",
            "mr": "पावसाळ्यात फळे जमिनीला टेकू नयेत म्हणून बांबू-तारेवर बांधणी (स्टेकिंग) करावी. उन्हाळ्यात आच्छादन करावे."
        }
    },
    "ladyfinger": {
        "crop": {"en": "Ladyfinger (Okra / Bhindi)", "hi": "भिंडी (ओकरा)", "mr": "भेंडी"},
        "season": {"en": "Kharif (June–July) and Summer (Feb–March)", "hi": "खरीफ (जून-जुलाई) और जायद (फरवरी-मार्च)", "mr": "खरीप (जून-जुलै) आणि उन्हाळी (फेब्रुवारी-मार्च)"},
        "sowing_harvesting": {
            "en": "Sow directly @ 3.5-4 kg seeds/acre after treating with Trichoderma. First picking starts in 45-50 days; pick tender pods every alternate day.",
            "hi": "3.5-4 किग्रा बीज प्रति एकड़ सीधे बोएं। 45-50 दिन में पहली तुड़ाई शुरू होती है, हर दूसरे दिन नरम फल तोड़ें।",
            "mr": "एकरी ३.५ ते ४ किलो बियाणे ट्रायकोडर्मा प्रक्रिया करून पेरावे. ४५ ते ५० दिवसांनी कोवळ्या भेंडीची तोडणी सुरू होते, दर दोन दिवसांनी तोडणी करावी."
        },
        "soil_prep": {
            "en": "Sandy loam to medium black fertile soil with good organic matter and drainage (pH 6.0 to 7.5).",
            "hi": "दोमट से मध्यम उपजाऊ काली मिट्टी, उत्तम जल निकासी।",
            "mr": "मध्यम काळी, पोयट्याची सुपीक आणि पाण्याचा चांगला निचरा होणारी जमीन (सामू ६.० ते ७.५)."
        },
        "spacing": {
            "en": "Kharif: 60 x 30 cm; Summer: 45 x 30 cm on flat beds or ridges.",
            "hi": "खरीफ में 60 x 30 सेमी, जायद (गर्मी) में 45 x 30 सेमी दूरी रखें।",
            "mr": "खरीप हंगामात ६० x ३० सेमी; उन्हाळी हंगामात ४५ x ३० सेमी अंतरावर वरंब्यावर किंवा गादीवाफ्यावर टोकावे."
        },
        "fertilizer_schedule": {
            "en": "Basal: 10 tons FYM + 50 kg DAP + 25 kg MOP per acre. Top dress with 25 kg Urea at 30 days and 45 days after sowing.",
            "hi": "बुवाई पर: 10 टन गोबर खाद + 50 किग्रा डीएपी + 25 किग्रा पोटाश। 30 और 45 दिन पर 25 किग्रा यूरिया दें।",
            "mr": "पेरणीवेळी: एकरी ५ टन शेणखत + ५० किलो डीएपी + २५ किलो पोटॅश. उगवणीनंतर ३० व ४५ दिवसांनी प्रत्येकी २५ किलो युरिया द्यावा."
        },
        "irrigation": {
            "en": "First irrigation immediately after sowing. Summer crops require watering every 4-5 days; Kharif crops as needed.",
            "hi": "बुवाई के तुरंत बाद पहली सिंचाई। गर्मियों में हर 4-5 दिन में और बारिश में जरूरत अनुसार पानी दें।",
            "mr": "टोकणीनंतर लगेच हलके पाणी द्यावे. उन्हाळ्यात दर ४-५ दिवसांनी व खरीपात पावसाचा खंड पडल्यास पाणी द्यावे."
        },
        "seasonal_suggestions": {
            "en": "Select Yellow Vein Mosaic Virus (YVMV) resistant varieties like Parbhani Kranti, Arka Anamika, or Radhika.",
            "hi": "पीला मोज़ेक वायरस प्रतिरोधी किस्में जैसे राधिका, परभणी क्रांति या अर्का अनामिका लगाएं।",
            "mr": "पिवळा शिरा रोग (व्हायरस) प्रतिकारक्षम वाण जसे राधिका, परभणी क्रांती किंवा अर्का अनामिका निवडावेत."
        }
    },
    "chili": {
        "crop": {"en": "Chili (Green & Dry Pepper)", "hi": "हरी मिर्च", "mr": "मिरची"},
        "season": {"en": "Kharif, Rabi, and Summer", "hi": "खरीफ, रबी और जायद", "mr": "खरीप, रब्बी आणि उन्हाळी"},
        "sowing_harvesting": {
            "en": "Transplant 35-40 day old seedlings. Green chili harvesting begins in 60-75 days; red ripe chilies in 110-120 days.",
            "hi": "35-40 दिन की पौध रोपें। हरी मिर्च की तुड़ाई 60-75 दिन बाद और लाल पकी मिर्च 120 दिन बाद तोड़ी जाती है।",
            "mr": "३५ ते ४० दिवसांची रोपे लागवड करावीत. हिरव्या मिरचीची तोडणी ६०-७५ दिवसांनी आणि लाल पिकलेली मिरची १२० दिवसांनी काढणीस येते."
        },
        "soil_prep": {
            "en": "Well-drained medium black or red loamy soil rich in organic matter. Avoid poorly drained alkaline soils.",
            "hi": "अच्छी जल निकासी वाली दोमट या हल्की काली मिट्टी।",
            "mr": "उत्तम निचऱ्याची मध्यम काळी किंवा तांबडी पोयटा जमीन. चोपण जमिनीत लागवड टाळावी."
        },
        "spacing": {
            "en": "Single row: 3 x 1.5 ft; Paired row: 4.5 x 2.5 x 1.5 ft on drip with silver-black mulch.",
            "hi": "कतार से कतार 3 से 4 फीट, पौधे से पौधा 1.5 फीट ड्रिप व मल्चिंग के साथ।",
            "mr": "ठिबकवर जोडओळ पद्धत: ४.५ x २.५ फूट सरीत दोन रोपांत १.५ फूट अंतर व सिल्व्हर ब्लॅक मल्चिंग वापरावे."
        },
        "fertilizer_schedule": {
            "en": "Basal: FYM 8 tons + 10:26:26 (100 kg/acre). Fertigation: 19:19:19 @ 3 kg/acre weekly for vegetative growth; 0:52:34 for heavy flowering.",
            "hi": "बुवाई पूर्व: 8 टन गोबर खाद + 10:26:26 (100 किग्रा)। ड्रिप से 19:19:19 बढ़वार पर और 0:52:34 फूल आने पर दें।",
            "mr": "लागवडीवेळी: एकरी ८ टन शेणखत + १०:२६:२६ (१०० किलो). वाढीसाठी १९:१९:१९ आठवड्यातून एकदा ३ किलो ठिबकमधून द्यावे."
        },
        "irrigation": {
            "en": "Drip irrigation at 70-80% moisture. Avoid moisture stress during flowering which causes flower and fruit drop.",
            "hi": "फूल खिलते समय पानी की कमी न होने दें, अन्यथा फूल झड़ सकते हैं। ड्रिप से नियमित सिंचाई करें।",
            "mr": "फुलधारणेच्या काळात पाण्याचा ताण पडू देऊ नये, अन्यथा फुलगळ होते. ठिबकने नियमित पाणी द्यावे."
        },
        "seasonal_suggestions": {
            "en": "Install blue and yellow sticky traps (20 traps/acre) to control thrips and mites which cause leaf curling (Bokadya).",
            "hi": "चुरड़ा-मुरड़ा (बोकड्या) रोग फैलाने वाले थ्रिप्स और माइट्स के नियंत्रण हेतु नीले व पीले स्टिकी ट्रैप लगाएं।",
            "mr": "बोकड्या (चुरडा-मुरडा) रोग टाळण्यासाठी पांढरी माशी व थ्रिप्स रोखण्यासाठी एकरी २० निळे व पिवळे चिकट सापळे लावावेत."
        }
    },
    "broccoli": {
        "crop": {"en": "Broccoli (Exotic Cole Crop)", "hi": "ब्रोकोली", "mr": "ब्रोकोली"},
        "season": {"en": "Rabi (Cold winter season, Sept to Nov transplanting)", "hi": "रबी (सर्दियों का मौसम, सितंबर से नवंबर)", "mr": "रब्बी (थंड हवामानाचा हिवाळी हंगाम, सप्टे-नोव्हेंबर)"},
        "sowing_harvesting": {
            "en": "Raise seedlings in pro-trays and transplant at 25-30 days. Harvest tight, compact green heads in 60-75 days before florets open.",
            "hi": "प्रो-ट्रे में पौध तैयार कर 25 दिन पर रोपें। फूल खिलने से पहले 60-75 दिनों में ठोस गठे हुए सिर काटें।",
            "mr": "प्रोट्रेमध्ये रोपे तयार करून २५ दिवसांनी पुनर्लागवड करावी. गड्डा घट्ट असताना व कळ्या उमलण्यापूर्वी ६० ते ७५ दिवसांत काढणी करावी."
        },
        "soil_prep": {
            "en": "Rich fertile sandy loam with high organic carbon (pH 6.0 to 6.8). Deep tilth with raised beds.",
            "hi": "जैविक कार्बन युक्त उपजाऊ दोमट मिट्टी (pH 6.0 से 6.8)।",
            "mr": "भरपूर सेंद्रिय कर्ब असणारी पोयट्याची सुपीक जमीन (सामू ६.० ते ६.८). गादीवाफे तयार करावेत."
        },
        "spacing": {
            "en": "Row to row: 45 to 60 cm; Plant to plant: 45 cm.",
            "hi": "कतार से कतार: 45-60 सेमी, पौधे से पौधा: 45 सेमी।",
            "mr": "दोन ओळींत ४५ ते ६० सेमी आणि दोन रोपांत ४५ सेमी अंतर ठेवावे."
        },
        "fertilizer_schedule": {
            "en": "High Nitrogen feeder: FYM 10 tons + NPK 120:60:60 kg/ha. Spray Boron (2g/L) to prevent hollow stem disorder.",
            "hi": "10 टन गोबर खाद + 120:60:60 NPK प्रति हेक्टेयर। तना खोखला होने से रोकने के लिए बोरॉन (2g/L) छिड़कें।",
            "mr": "एकरी ८ टन शेणखत + हेक्टरी १२०:६०:६० किलो नत्र:स्फुरद:पालाश. खोड पोकळ पडू नये म्हणून बोरॉन २ ग्रॅम/लिटर फवारावे."
        },
        "irrigation": {
            "en": "Requires uniform soil moisture throughout head development. Water every 5-7 days or daily via drip.",
            "hi": "गड्ढा बनते समय समान नमी बनाए रखें। ड्रिप से रोजाना या 5-7 दिन में सिंचाई करें।",
            "mr": "गड्डा भरताना जमिनीत कायम ओलावा असावा. ठिबक सिंचनाने पाणी देणे फायदेशीर ठरते."
        },
        "seasonal_suggestions": {
            "en": "High market demand in urban supermarkets and hotels. Popular hybrid varieties: Green Magic, Lucky, KTS-1.",
            "hi": "शहरी मंडियों में उच्च मूल्य मिलता है। लोकप्रिय किस्में: ग्रीन मैजिक, लकी।",
            "mr": "शहरी बाजारपेठ व मॉलमध्ये चांगला दर मिळतो. ग्रीन मॅजिक, लकी हे संकरित वाण लोकप्रिय आहेत."
        }
    },
    "apple": {
        "crop": {"en": "Apple (Commercial Fruit)", "hi": "सेब", "mr": "सफरचंद"},
        "season": {"en": "Temperate climates (Chill hours 800-1200 hrs) and Low-Chill varieties (HRMN-99, Anna, Dorsett Golden)", "hi": "पहाड़ी क्षेत्र व कम ठंड वाली किस्में (HRMN-99, एना)", "mr": "थंड प्रदेश व कमी थंडी लागणारे वाण (एचआरएमएन-९९, अण्णा)"},
        "sowing_harvesting": {
            "en": "Plant 1-year grafted saplings in Dec-Feb. Fruit bearing starts from 3rd-4th year; harvesting between July and Oct.",
            "hi": "दिसंबर-फरवरी में कलमी पौधे लगाएं। तीसरे-चौथे साल से फल लगना शुरू होता है।",
            "mr": "डिसेंबर ते फेब्रुवारीमध्ये कलमी रोपे लावावीत. ३ ते ४ वर्षांत फळधारणा सुरू होते, जुलै ते ऑक्टोबरमध्ये फळे काढणीस येतात."
        },
        "soil_prep": {
            "en": "Deep loamy soils rich in organic matter with excellent drainage, minimum 2-3 meter soil depth (pH 5.5 to 6.8).",
            "hi": "गहरी, दोमट मिट्टी जिसमें पानी न जमे (pH 5.5 से 6.8)।",
            "mr": "किमान २-३ मीटर खोल, पाण्याचा उत्तम निचरा होणारी पोयट्याची जमीन (सामू ५.५ ते ६.८)."
        },
        "spacing": {
            "en": "Standard: 5 x 5 meters; High Density: 3 x 1.5 meters on trellising.",
            "hi": "मानक दूरी: 5 x 5 मीटर; सघन बागवानी: 3 x 1.5 मीटर।",
            "mr": "पारंपारिक: ५ x ५ मीटर; सघन लागवड (हाय डेन्सिटी): ३ x १.५ मीटर अंतरावर आधार देऊन."
        },
        "fertilizer_schedule": {
            "en": "Apply 30-40 kg well-rotten FYM + 500g N, 250g P2O5, 750g K2O per mature bearing tree in dormancy (Dec-Jan).",
            "hi": "प्रति वयस्क पेड़: 30-40 किग्रा गोबर खाद + 500 ग्राम नाइट्रोजन, 250 ग्राम फास्फोरस, 750 ग्राम पोटाश।",
            "mr": "प्रति झाड: ३० ते ४० किलो शेणखत + ५०० ग्रॅम नत्र, २५० ग्रॅम स्फुरद व ७५० ग्रॅम पालाश हिवाळ्यात विश्रांती काळात द्यावे."
        },
        "irrigation": {
            "en": "Critical during fruit set and rapid fruit growth periods (April to June). Drip irrigation ensures uniform sizing.",
            "hi": "फल बनते समय (अप्रैल-जून) नियमित पानी दें। ड्रिप से फलों का आकार अच्छा बनता है।",
            "mr": "फळे मोठी होताना (एप्रिल ते जून) नियमित पाणी द्यावे. ठिबक सिंचनाने फळांचा दर्जा व आकार उत्तम राहतो."
        },
        "seasonal_suggestions": {
            "en": "Perform annual winter pruning in January to balance vegetative growth and fruiting spurs.",
            "hi": "जनवरी में छंटाई (प्रूनिंग) करें ताकि नए फलदार स्पर बन सकें।",
            "mr": "जानेवारी महिन्यात योग्य छाटणी करून झाडाचा आकार व सूर्यप्रकाश व्यवस्थापन करावे."
        }
    },
    "mango": {
        "crop": {"en": "Mango (King of Fruits)", "hi": "आम", "mr": "आंबा (हापूस / केशर)"},
        "season": {"en": "Planting: July–August (Monsoon); Flowering: Dec–Jan; Harvest: March–June", "hi": "रोपाई: जुलाई-अगस्त; फूल: दिसंबर-जनवरी; फल: मार्च-जून", "mr": "लागवड: जुलै-ऑगस्ट; मोहर: डिसेंबर-जानेवारी; काढणी: मार्च-जून"},
        "sowing_harvesting": {
            "en": "Plant genuine grafted saplings in 1x1x1 meter pits filled with FYM and bone meal. Harvest at 85% maturity with 1 cm stalk.",
            "hi": "1x1x1 मीटर के गड्ढों में कलमी पौधे लगाएं। 85% परिपक्वता पर डंडी सहित तोड़ें।",
            "mr": "१x१x१ मीटर खड्ड्यांत शेणखत व पोयटा माती भरून कलमे लावावीत. ८५% पक्वतेवर देठासह काढणी करावी."
        },
        "soil_prep": {
            "en": "Deep, well-drained alluvial, red or laterite soil with at least 2 meter depth (pH 6.5 to 7.5). Avoid heavy waterlogged clays.",
            "hi": "गहरी, अच्छी जल निकासी वाली मिट्टी (कम से कम 2 मीटर गहरी)।",
            "mr": "जांभा, तांबडी किंवा गाळाची किमान २ मीटर खोल उत्तम निचऱ्याची जमीन. कोकणातील जांभा दगडी जमीन हापूससाठी प्रसिद्ध."
        },
        "spacing": {
            "en": "Traditional: 10 x 10 meters; Ultra High Density: 5 x 3 meters.",
            "hi": "पारंपरिक: 10 x 10 मीटर; सघन: 5 x 3 मीटर।",
            "mr": "पारंपारिक: १० x १० मीटर; सघन लागवड: ५ x ३ मीटर किंवा ६ x ४ मीटर."
        },
        "fertilizer_schedule": {
            "en": "Bearing tree: FYM 50 kg + 1 kg N, 500g P, 1 kg K in post-monsoon (August-Sept). Spray Paclobutrazol in Sept for uniform flowering.",
            "hi": "वयस्क पेड़: 50 किग्रा गोबर खाद + 1 किग्रा नाइट्रोजन, 500g फास्फोरस, 1 किग्रा पोटाश।",
            "mr": "उत्पादक झाडास: ५० किलो शेणखत + १ किलो नत्र, ५०० ग्रॅम स्फुरद, १ किलो पालाश ऑगस्ट-सप्टेंबरमध्ये द्यावे."
        },
        "irrigation": {
            "en": "Withhold water from Oct to Dec to induce flowering stress. Resume irrigation after fruit set (pea stage) every 7-10 days.",
            "hi": "फूल आने से पहले (अक्टूबर-दिसंबर) पानी रोकें। मटर के दाने जितने फल बनने पर नियमित सिंचाई करें।",
            "mr": "मोहर येण्यासाठी ऑक्टोबर ते डिसेंबर पाण्याचा ताण द्यावा. फळ वाटाण्याएवढे झाल्यावर नियमित पाणी सुरू करावे."
        },
        "seasonal_suggestions": {
            "en": "Spray for mango hopper & powdery mildew during flowering with Imidacloprid (0.3ml/L) + Wettable Sulfur (2g/L).",
            "hi": "बौर (फूल) आते समय भुंगा (हॉपर) और फफूंद से बचाव के लिए छिड़काव करें।",
            "mr": "मोहरावर तुडतुडे व भुरी रोगाच्या नियंत्रणासाठी इमिडाक्लोप्रिड ०.३ मिली + विद्राव्य गंधक २ ग्रॅम/लिटर फवारावे."
        }
    },
    "pomegranate": {
        "crop": {"en": "Pomegranate (Bhagwa)", "hi": "अनार (भगवा)", "mr": "डाळिंब (भगवा)"},
        "season": {"en": "Bahar treatment: Ambe Bahar (Jan-Feb), Mrig Bahar (June-July), Hasta Bahar (Sept-Oct)", "hi": "बहार प्रबंधन: अंबे (जनवरी), मृग (जून), हस्त (सितंबर)", "mr": "बहार व्यवस्थापन: आंबे बहार (जानेवारी), मृग बहार (जून), हस्त बहार (सप्टेंबर)"},
        "sowing_harvesting": {
            "en": "Air-layered or tissue culture saplings planted in monsoon. Harvesting begins 150-180 days after flowering.",
            "hi": "गुटी कलम या टिशू कल्चर पौधे लगाएं। फूल आने के 150-180 दिन बाद चमकदार लाल फल तैयार होते हैं।",
            "mr": "गुटी कलमे किंवा टिशू कल्चर रोपे लावावीत. फुलधारणेनंतर १५० ते १८० दिवसांत फळे पक्व होतात."
        },
        "soil_prep": {
            "en": "Light to medium well-drained gravelly soil (pH 6.5 to 8.0). Highly sensitive to water stagnation.",
            "hi": "हल्की से मध्यम जल निकासी वाली कंकरीली मिट्टी। जलभराव बिल्कुल न हो।",
            "mr": "हलकी ते मध्यम मुरमाड, पाण्याचा अतिशय वेगवान निचरा होणारी जमीन. पाणी साचल्यास मर रोग होतो."
        },
        "spacing": {
            "en": "Row to row: 4.5 to 5 meters; Plant to plant: 3 to 3.5 meters (approx 300 to 400 plants/acre).",
            "hi": "कतार से कतार: 4.5-5 मीटर, पौधे से पौधा: 3 मीटर।",
            "mr": "दोन ओळींत ४.५ ते ५ मीटर आणि झाडांमध्ये ३ ते ३.५ मीटर (एकरी ३५० ते ४०० झाडे)."
        },
        "fertilizer_schedule": {
            "en": "Apply 30 kg FYM + 625g N, 250g P, 500g K per plant/year. Apply Micronutrients (Zinc, Boron, Calcium) for fruit shine and cracking prevention.",
            "hi": "प्रति पेड़: 30 किग्रा गोबर खाद + 625g N, 250g P, 500g K। फल फटने से रोकने के लिए बोरॉन व कैल्शियम दें।",
            "mr": "प्रति झाड: ३० किलो शेणखत + ६२५ ग्रॅम नत्र, २५० ग्रॅम स्फुरद, ५०० ग्रॅम पालाश. फळे तडकणे रोखण्यासाठी बोरॉन व कॅल्शियम द्यावे."
        },
        "irrigation": {
            "en": "Strict regulated drip irrigation. Give 45 days water stress before chosen Bahar, then irrigate heavily with fertilizers.",
            "hi": "बहार से पहले 45 दिन का पानी का तनाव दें। बाद में ड्रिप से नियमित सिंचाई करें।",
            "mr": "बहार धरण्यापूर्वी ४० ते ५० दिवस पाण्याचा ताण द्यावा, नंतर हलके पाणी देऊन खतांचे डोस द्यावेत."
        },
        "seasonal_suggestions": {
            "en": "Guard strictly against Bacterial Blight (Telya). Spray Streptocycline (0.5g/L) + Copper Oxychloride (2.5g/L) preventively.",
            "hi": "तेलिया (जीवाणु झुलसा) से बचाव हेतु स्ट्रेप्टोसाइक्लिन व कॉपर का छिड़काव करें।",
            "mr": "तेलकट डाग (तेल्या) रोगापासून संरक्षणासाठी कॉपर ऑक्झिक्लोराईड २.५ ग्रॅम + स्ट्रेप्टोसायक्लीन ०.५ ग्रॅम प्रति लिटर फवारावे."
        }
    },
    "wheat": {
        "crop": {"en": "Wheat", "hi": "गेहूं", "mr": "गहू"},
        "season": {"en": "Rabi (Sowing Nov 1 to Nov 20)", "hi": "रबी (1 से 20 नवंबर)", "mr": "रब्बी (१ ते २० नोव्हेंबर)"},
        "sowing_harvesting": {
            "en": "Sow behind plow or using seed drill @ 40-50 kg/acre. Harvest at 105-120 days when moisture reaches 14%.",
            "hi": "40-50 किग्रा बीज प्रति एकड़ ड्रिल से बोएं। 110-120 दिनों में कटाई करें।",
            "mr": "एकरी ४० ते ५० किलो बियाणे पेरणी यंत्राने पेरावे. ११० ते १२० दिवसांत दाणे टणक झाल्यावर काढणी करावी."
        },
        "soil_prep": {
            "en": "Medium to heavy clay soil with fine tilth. 1 deep plowing followed by 2 cross harrowings.",
            "hi": "मध्यम से भारी मिट्टी, भुरभुरी जुताई।",
            "mr": "मध्यम ते भारी, उत्तम निचऱ्याची जमीन. १ खोल नांगरट आणि २ कुळवाच्या पाळ्या द्याव्यात."
        },
        "spacing": {
            "en": "Row spacing 20-22.5 cm; depth 5 cm.",
            "hi": "कतार से कतार 20-22.5 सेमी, गहराई 5 सेमी।",
            "mr": "दोन ओळींत २० ते २२.५ सेमी अंतर आणि ५ सेमी खोलीवर पेरणी करावी."
        },
        "fertilizer_schedule": {
            "en": "120:60:40 kg NPK/ha. 50% N + full P and K at sowing; remaining N at 21 days (CRI) and 45 days (booting).",
            "hi": "120:60:40 NPK प्रति हेक्टेयर। आधा नत्र और पूरा पी व के बुवाई पर, शेष यूरिया 21 और 45 दिन पर।",
            "mr": "हेक्टरी १२०:६०:४० किलो नत्र:स्फुरद:पालाश. निम्मे नत्र आणि पूर्ण स्फुरद-पालाश पेरणीवेळी, तर उर्वरित नत्र २१ व ४५ दिवसांनी द्यावे."
        },
        "irrigation": {
            "en": "Critical stages: 1. Crown Root (21d), 2. Tillering (40d), 3. Jointing (60d), 4. Flowering (75d), 5. Milking (90d), 6. Dough (105d).",
            "hi": "6 महत्वपूर्ण सिंचाई: 21 दिन, 40 दिन, 60 दिन, 75 दिन, 90 दिन और 105 दिन।",
            "mr": "पाण्याच्या ६ महत्त्वाच्या पाळ्या: २१ दिवस (मुकुटमुळे), ४० दिवस (फुटवे), ६० दिवस (कांडी), ७५ दिवस (फुलोरा), ९० दिवस (दूध भरणे)."
        },
        "seasonal_suggestions": {
            "en": "Lokwan, GW-496, Sharbati, HD-2967 are top yielding varieties.",
            "hi": "लोकवन, जीडब्ल्यू-496, एचडी-2967 अधिक उपज देने वाली किस्में हैं।",
            "mr": "लोकवन, शरद, समाधान, जीडब्ल्यू-४९६ हे अधिक उत्पादन देणारे वाण आहेत."
        }
    },
    "sugarcane": {
        "crop": {"en": "Sugarcane", "hi": "गन्ना", "mr": "ऊस"},
        "season": {"en": "Adsali (July-Aug), Pre-seasonal (Oct-Nov), Suru (Jan-Feb)", "hi": "अडसाली (जुलाई-अगस्त), पूर्व-मौसमी (अक्टूबर-नवंबर), सुरू (जनवरी-फरवरी)", "mr": "आडसाली (जुलै-ऑगस्ट), पूर्वहंगामी (ऑक्टोबर-नोव्हेंबर), सुरू (जानेवारी-फेब्रुवारी)"},
        "sowing_harvesting": {
            "en": "Plant 2-bud sets @ 25,000 to 30,000 sets/hectare. Harvest at peak sucrose maturity (12 to 18 months).",
            "hi": "दो आंख वाले टुकड़े 25,000 प्रति हेक्टेयर लगाएं। 12 से 16 महीने में कटाई करें।",
            "mr": "दोन डोळ्यांच्या २५ ते ३० हजार कांड्या प्रति हेक्टरी लावाव्यात. १२ ते १६ महिन्यांनी साखर उतारा जास्त असताना तोडणी करावी."
        },
        "soil_prep": {
            "en": "Deep, fertile medium to heavy soil with 4.5 to 5 ft broad furrow ridges.",
            "hi": "गहरी, उपजाऊ मिट्टी। 4.5 से 5 फीट की चौड़ी कतारें बनाएं।",
            "mr": "खोल, मध्यम ते भारी उत्तम निचऱ्याची जमीन. ४.५ ते ५ फुटांचे रुंद सरी-वरंबे पाडावेत."
        },
        "spacing": {
            "en": "Row to row: 4.5 to 5 feet.",
            "hi": "कतार से कतार: 4.5 से 5 फीट।",
            "mr": "दोन सऱ्यांमध्ये ४.५ ते ५ फूट अंतर ठेवावे."
        },
        "fertilizer_schedule": {
            "en": "For Suru: 250:115:115 kg NPK/ha. For Adsali: 400:170:170 kg NPK/ha in 4 split doses.",
            "hi": "सुरू के लिए 250:115:115 NPK; अडसाली के लिए 400:170:170 NPK चार बार में दें।",
            "mr": "सुरू उसासाठी हेक्टरी २५०:११५:११५ NPK; आडसालीसाठी ४००:१७०:१७० NPK ४ हप्त्यांमध्ये द्यावे."
        },
        "irrigation": {
            "en": "Drip irrigation saves 40% water and boosts cane yield. Ensure adequate soil moisture during summer tillering.",
            "hi": "ड्रिप से 40% पानी बचता है। गर्मियों में फुटान के समय पर्याप्त पानी दें।",
            "mr": "ठिबक सिंचनाने ४०% पाण्याची बचत होऊन टन क्षमता वाढते. उन्हाळ्यात फुटव्यांच्या वाढीवेळी पाण्याचा ताण पडू देऊ नये."
        },
        "seasonal_suggestions": {
            "en": "Co-86032 (Nira) and Co-0265 (Digvijay) are the highest yielding cultivars in Maharashtra.",
            "hi": "को-86032 और को-0265 सबसे लोकप्रिय किस्में हैं।",
            "mr": "को-८६०३२ (नीरा) आणि को-०२६५ (दिग्विजय) हे महाराष्ट्रात सर्वाधिक उत्पादन देणारे वाण आहेत."
        }
    },
    "cotton": {
        "crop": {"en": "Cotton (Bt Cotton)", "hi": "कपास", "mr": "कापूस"},
        "season": {"en": "Kharif (June to early July)", "hi": "खरीफ (मानसून आगमन पर)", "mr": "खरीप (मान्सूनच्या सुरुवातीस जून-जुलै)"},
        "sowing_harvesting": {
            "en": "Sow @ 1-2 seeds per hill after 75-100 mm rainfall. Clean manual picking in 3-4 rounds as bolls burst open.",
            "hi": "75-100 मिमी बारिश के बाद बुवाई करें। टिंडे पूरी तरह खिलने पर साफ तुड़ाई करें।",
            "mr": "७५ ते १०० मिमी पाऊस झाल्यावर टोकण करावी. बोंडे पूर्ण उमलल्यावर कोरड्या वातावरणात ३-४ वेचण्या कराव्यात."
        },
        "soil_prep": {
            "en": "Deep black cotton soil with high moisture retention and good drainage.",
            "hi": "गहरी काली कपासी मिट्टी।",
            "mr": "काळी कसदार भारी ते मध्यम जमीन, चांगला पाण्याचा निचरा असणारी."
        },
        "spacing": {
            "en": "Medium soil: 4 x 1.5 ft; Heavy black soil: 5 x 2 ft.",
            "hi": "मध्यम मिट्टी में 4 x 1.5 फीट; भारी मिट्टी में 5 x 2 फीट।",
            "mr": "मध्यम जमिनीत ४ x १.५ फूट; भारी काळ्या जमिनीत ५ x २ फूट अंतरावर लागवड करावी."
        },
        "fertilizer_schedule": {
            "en": "100:50:50 kg NPK/ha. 20% N + full P and K at sowing; remaining N in 3 splits at 30, 60, and 75 days.",
            "hi": "100:50:50 NPK प्रति हेक्टेयर। नत्र को 30, 60, 75 दिनों पर बांटकर दें।",
            "mr": "हेक्टरी १००:५०:५० NPK. २०% नत्र + पूर्ण स्फुरद व पालाश पेरणीवेळी, तर उर्वरित नत्र ३०, ६० व ७५ दिवसांनी द्यावे."
        },
        "irrigation": {
            "en": "Critical at square formation (45d), flowering (65d), and boll development (85d).",
            "hi": "डोडी बनते समय (45 दिन), फूल पर (65 दिन) और बोंड बनते समय (85 दिन) सिंचाई आवश्यक।",
            "mr": "पाते लागताना (४५ दिवस), फुलधारणेवेळी (६५ दिवस) आणि बोंडे भरताना (८५ दिवस) सिंचन करावे."
        },
        "seasonal_suggestions": {
            "en": "Monitor strictly for Pink Bollworm using pheromone traps. Avoid taking ratoon (Fardad) cotton.",
            "hi": "गुलाबी सुंडी से बचाव के लिए फेरोमोन ट्रैप लगाएं। फरदड़ कपास न लें।",
            "mr": "गुलाबी बोंडअळीच्या नियंत्रणासाठी एकरी ५ कामगंध सापळे लावा. फरदड (खोडवा) कापूस घेणे टाळावे."
        }
    }
}


def get_crop_advice(crop_name: Optional[str] = "tomato", language: str = "English") -> Dict[str, Any]:
    """Return detailed cultivation advice for any requested crop, vegetable, or fruit."""
    lang = language.strip().lower()
    lang_code = "mr" if lang in ["mr", "marathi"] else "hi" if lang in ["hi", "hindi"] else "en"

    key = "tomato"
    clean_crop = (crop_name or "tomato").strip().casefold()

    # Match aliases
    if any(w in clean_crop for w in ["bhindi", "bhendi", "okra", "ladyfinger", "भिंडी", "भेंडी"]):
        key = "ladyfinger"
    elif any(w in clean_crop for w in ["chili", "chilli", "mirch", "mirchi", "मिर्च", "मिरची"]):
        key = "chili"
    elif any(w in clean_crop for w in ["broccoli", "ब्रोकोली"]):
        key = "broccoli"
    elif any(w in clean_crop for w in ["apple", "seb", "safarchand", "सेब", "सफरचंद"]):
        key = "apple"
    elif any(w in clean_crop for w in ["mango", "aam", "amba", "आम", "आंबा", "हापूस", "केशर"]):
        key = "mango"
    elif any(w in clean_crop for w in ["pomegranate", "anaar", "anar", "dalimb", "अनार", "डाळिंब"]):
        key = "pomegranate"
    elif any(w in clean_crop for w in ["wheat", "gehu", "gahu", "गेहूं", "गहू"]):
        key = "wheat"
    elif any(w in clean_crop for w in ["sugarcane", "ganna", "us", "ऊस", "गन्ना"]):
        key = "sugarcane"
    elif any(w in clean_crop for w in ["cotton", "kapas", "kapus", "कपास", "कापूस"]):
        key = "cotton"
    elif any(w in clean_crop for w in ["tomato", "tamatar", "टमाटर", "टोमॅटो"]):
        key = "tomato"
    else:
        # Dynamic fallback for any other crop (e.g. Potato, Onion, Rice, Banana, Guava, Papaya, etc.)
        return _generate_dynamic_crop_advice(crop_name, lang_code)

    data = CROP_ADVICE_DATA[key]
    c_name = data["crop"].get(lang_code, data["crop"]["en"])
    season = data["season"].get(lang_code, data["season"]["en"])
    sowing = data.get("sowing_harvesting", {}).get(lang_code, "")
    soil = data["soil_prep"].get(lang_code, data["soil_prep"]["en"])
    spacing = data["spacing"].get(lang_code, data["spacing"]["en"])
    fert = data["fertilizer_schedule"].get(lang_code, data["fertilizer_schedule"]["en"])
    irri = data["irrigation"].get(lang_code, data["irrigation"]["en"])
    sugg = data.get("seasonal_suggestions", {}).get(lang_code, "")

    if lang_code == "mr":
        text = (
            f"🌾 पीक सल्ला: {c_name}\n\n"
            f"📅 योग्य हंगाम: {season}\n\n"
            f"🌱 पेरणी व काढणी मार्गदर्शन: {sowing}\n\n"
            f"🌍 जमीन व मशागत: {soil}\n\n"
            f"📏 लागवड अंतर: {spacing}\n\n"
            f"🧪 खत व्यवस्थापन (शिफारस): {fert}\n\n"
            f"💧 पाणी व्यवस्थापन (सिंचन): {irri}\n\n"
            f"💡 हंगामी सल्ला व वाण: {sugg}"
        )
        prompt = f"तुमच्या {c_name} पिकाची सध्या कोणती वाढीची अवस्था सुरू आहे? (उदा. पेरणी, वाढ, फुलोरा की फळधारणा?) हे सांगितल्यास मी पुढील खते आणि फवारणीचे अचूक नियोजन सांगू शकेन."
    elif lang_code == "hi":
        text = (
            f"🌾 फसल सलाह: {c_name}\n\n"
            f"📅 उपयुक्त मौसम: {season}\n\n"
            f"🌱 बुवाई व कटाई मार्गदर्शन: {sowing}\n\n"
            f"🌍 खेत की तैयारी व मिट्टी: {soil}\n\n"
            f"📏 बुवाई दूरी व अंतर: {spacing}\n\n"
            f"🧪 उर्वरक सिफारिशें (खाद): {fert}\n\n"
            f"💧 सिंचाई मार्गदर्शन: {irri}\n\n"
            f"💡 मौसमी सुझाव व किस्में: {sugg}"
        )
        prompt = f"आपकी {c_name} की फसल अभी किस अवस्था में है (जैसे बुवाई, बढ़वार, फूल या फल)? यह बताने पर हम आगे के खाद और स्प्रे का सटीक शेड्यूल बता सकते हैं।"
    else:
        text = (
            f"🌾 Crop Advisory: {c_name}\n\n"
            f"📅 Suitable Season: {season}\n\n"
            f"🌱 Sowing & Harvesting Guidance: {sowing}\n\n"
            f"🌍 Soil Preparation: {soil}\n\n"
            f"📏 Spacing & Planting Method: {spacing}\n\n"
            f"🧪 Fertilizer Recommendations: {fert}\n\n"
            f"💧 Irrigation Guidance: {irri}\n\n"
            f"💡 Seasonal Crop Suggestions: {sugg}"
        )
        prompt = f"What is the current growth stage of your {c_name} crop (seedling, vegetative, flowering, or fruiting)? Letting me know helps provide specific nutrition and spraying schedules."

    return {
        "success": True,
        "crop_id": key,
        "crop_name": c_name,
        "advice_text": text,
        "interactive_prompt": prompt
    }


def _generate_dynamic_crop_advice(crop_name: str, lang_code: str) -> Dict[str, Any]:
    """Generates structured advice for any other crop/vegetable/fruit entered by user."""
    c_name = (crop_name or "Crop").capitalize()

    if lang_code == "mr":
        text = (
            f"🌾 पीक सल्ला: {c_name}\n\n"
            f"📅 योग्य हंगाम: खरीप, रब्बी किंवा उन्हाळी (हवामानानुसार)\n\n"
            f"🌱 पेरणी व काढणी मार्गदर्शन: चांगल्या प्रतीचे बियाणे वापरून बीजप्रक्रिया करून पेरणी करावी. पक्वतेची लक्षणे दिसताच वेळेवर काढणी करावी.\n\n"
            f"🌍 जमीन व मशागत: उत्तम पाण्याचा निचरा होणारी, भरपूर सेंद्रिय घटक असणारी जमीन निवडावी. १ खोल नांगरट व २ कुळवाच्या पाळ्या द्याव्यात.\n\n"
            f"📏 लागवड अंतर: पिकाच्या विस्तारानुसार योग्य अंतर ठेवावे, ज्यामुळे हवा व सूर्यप्रकाश चांगला मिळतो.\n\n"
            f"🧪 खत व्यवस्थापन: लागवडीपूर्वी कुजलेले शेणखत किंवा गांडूळ खत द्यावे. वाढीच्या काळात संतुलित नत्र, स्फुरद व पालाश खते द्यावीत.\n\n"
            f"💧 पाणी व्यवस्थापन: ठिबक सिंचनाने पाणी द्यावे. फुलधारणा व फळधारणा या काळात पाण्याचा ताण पडू देऊ नये."
        )
        prompt = f"तुमच्या {c_name} पिकाची सध्या कोणती अवस्था आहे आणि जमिनीचा प्रकार कोणता आहे? हे सांगितल्यास मी सविस्तर खते व फवारणी नियोजन सांगू शकेन."
    elif lang_code == "hi":
        text = (
            f"🌾 फसल सलाह: {c_name}\n\n"
            f"📅 उपयुक्त मौसम: खरीफ, रबी या जायद (मौसम अनुसार)\n\n"
            f"🌱 बुवाई व कटाई मार्गदर्शन: प्रमाणित बीज का उपचार करके बुवाई करें। फसल पकने पर सही समय पर कटाई करें।\n\n"
            f"🌍 खेत की तैयारी: अच्छी जल निकासी वाली दोमट या मध्यम मिट्टी उपयुक्त है। गहरी जुताई करके खेत तैयार करें।\n\n"
            f"📏 बुवाई दूरी: फसल के फैलाव के अनुसार उपयुक्त कतार व पौधे की दूरी रखें।\n\n"
            f"🧪 उर्वरक सिफारिशें: बुवाई से पहले सड़ी गोबर खाद डालें। संतुलित NPK उर्वरकों का उपयोग करें।\n\n"
            f"💧 सिंचाई मार्गदर्शन: ड्रिप से पानी दें। फूल और फल बनते समय पर्याप्त नमी बनाए रखें।"
        )
        prompt = f"आपकी {c_name} की फसल अभी किस अवस्था में है और मिट्टी का प्रकार क्या है? बताने पर हम सटीक जानकारी दे सकते हैं।"
    else:
        text = (
            f"🌾 Crop Advisory: {c_name}\n\n"
            f"📅 Suitable Season: Kharif, Rabi, or Summer depending on regional climate.\n\n"
            f"🌱 Sowing & Harvesting Guidance: Treat certified seeds with biological fungicide before sowing. Harvest at optimum maturity.\n\n"
            f"🌍 Soil Preparation: Well-drained fertile loam with high organic matter. Plowing and harrowing for fine tilth.\n\n"
            f"📏 Spacing & Planting: Maintain adequate row-to-row spacing for sunlight penetration and airflow.\n\n"
            f"🧪 Fertilizer Recommendations: Apply well-decomposed FYM/compost as basal dose; supply balanced N-P-K at critical vegetative and flowering stages.\n\n"
            f"💧 Irrigation Guidance: Drip irrigation provides 40-50% water savings. Ensure regular moisture during flowering and yield formation."
        )
        prompt = f"What is the current growth stage and soil type of your {c_name} crop? Letting me know helps provide specific spray and nutrition schedules."

    return {
        "success": True,
        "crop_id": "custom",
        "crop_name": c_name,
        "advice_text": text,
        "interactive_prompt": prompt
    }
