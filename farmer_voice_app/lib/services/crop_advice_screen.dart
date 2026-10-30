// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../app_theme.dart';

class CropAdviceScreen extends StatefulWidget {
  final String lang;
  const CropAdviceScreen({super.key, required this.lang});

  @override
  State<CropAdviceScreen> createState() => _CropAdviceScreenState();
}

class _CropAdviceScreenState extends State<CropAdviceScreen> {
  List<String> _userCrops = [];
  String _soil = 'black';
  String _district = 'Nashik';
  bool _isLoading = true;

  // --- Multilingual labels ---
  static const Map<String, Map<String, String>> _labels = {
    'title': {
      'en': 'Crop Advice',
      'hi': 'फसल सलाह',
      'mr': 'पीक सल्ला',
    },
    'yourCrops': {
      'en': 'Your Crops',
      'hi': 'आपकी फसलें',
      'mr': 'तुमची पिके',
    },
    'currentTask': {
      'en': 'Current Task',
      'hi': 'अभी का काम',
      'mr': 'सध्याचे काम',
    },
    'fertilizerTip': {
      'en': 'Fertilizer Tips',
      'hi': 'उर्वरक सुझाव',
      'mr': 'खत सुझाव',
    },
    'wateringTip': {
      'en': 'Watering',
      'hi': 'सिंचाई',
      'mr': 'सिंचन',
    },
    'pestAlert': {
      'en': 'Pest Alert',
      'hi': 'कीट चेतावनी',
      'mr': 'कीड इशारा',
    },
    'noCrops': {
      'en': 'No crops found in your profile.\nPlease set up your profile first.',
      'hi': 'आपकी प्रोफ़ाइल में कोई फसल नहीं मिली।\nकृपया पहले अपनी प्रोफ़ाइल सेट करें।',
      'mr': 'तुमच्या प्रोफाइलमध्ये कोणतेही पीक आढळले नाही.\nकृपया प्रथम तुमची प्रोफाइल सेट करा.',
    },
    'kharif': {'en': 'Kharif Season', 'hi': 'खरीफ मौसम', 'mr': 'खरीप हंगाम'},
    'rabi': {'en': 'Rabi Season', 'hi': 'रबी मौसम', 'mr': 'रब्बी हंगाम'},
    'zaid': {'en': 'Zaid Season', 'hi': 'जायद मौसम', 'mr': 'उन्हाळी हंगाम'},
    'kharifMonths': {
      'en': 'June – October',
      'hi': 'जून – अक्टूबर',
      'mr': 'जून – ऑक्टोबर',
    },
    'rabiMonths': {
      'en': 'November – February',
      'hi': 'नवंबर – फरवरी',
      'mr': 'नोव्हेंबर – फेब्रुवारी',
    },
    'zaidMonths': {
      'en': 'March – May',
      'hi': 'मार्च – मई',
      'mr': 'मार्च – मे',
    },
    'generalTips': {
      'en': 'General Season Tips',
      'hi': 'सामान्य मौसम सुझाव',
      'mr': 'सामान्य हंगाम सुझाव',
    },
    'soilTip': {
      'en': 'Soil-Specific Tip',
      'hi': 'मिट्टी-विशिष्ट सुझाव',
      'mr': 'माती-विशिष्ट सुझाव',
    },
    'noAdvice': {
      'en': 'No specific advice available for this crop.',
      'hi': 'इस फसल के लिए कोई विशिष्ट सलाह उपलब्ध नहीं है।',
      'mr': 'या पिकासाठी कोणतेही विशिष्ट सल्ला उपलब्ध नाही.',
    },
  };

  String _l(String key) => _labels[key]?[widget.lang] ?? _labels[key]?['en'] ?? key;

  // --- Crop advice data ---
  static const Map<String, Map<String, dynamic>> _cropAdvice = {
    'tomato': {
      'icon': '🍅',
      'name': {'en': 'Tomato', 'hi': 'टमाटर', 'mr': 'टोमॅटो'},
      'season': 'kharif',
      'currentTask': {
        'en':
            'This is the ideal time for transplanting tomato seedlings. Ensure seedlings are 25-30 days old. Maintain 60x45 cm spacing. Apply starter dose of fertilizer at transplanting.',
        'hi':
            'यह टमाटर के पौधे रोपाई का आदर्श समय है। सुनिश्चित करें कि पौधे 25-30 दिन पुराने हों। 60x45 सेमी अंतर बनाए रखें। रोपाई पर उर्वरक की स्टार्टर खुराक दें।',
        'mr':
            'टोमॅटोच्या रोपांची पुनर्लागवड करण्याची ही आदर्श वेळ आहे. रोपे 25-30 दिवसांची असल्याची खात्री करा. 60x45 सेमी अंतर ठेवा. लागवडीच्या वेळी सुरुवातीचे खत द्या.',
      },
      'fertilizerTip': {
        'en':
            'Apply 120 kg N, 60 kg P, 60 kg K per hectare. Split nitrogen application: 1/3 at planting, 1/3 at flowering, 1/3 at fruiting. Use vermicompost (5 t/ha) for better results.',
        'hi':
            'प्रति हेक्टेयर 120 किग्रा N, 60 किग्रा P, 60 किग्रा K लगाएं। नाइट्रोजन को विभाजित करके दें: 1/3 रोपाई पर, 1/3 फूल आने पर, 1/3 फल लगने पर। बेहतर परिणाम के लिए वर्मीकम्पोस्ट (5 टन/हेक्टेयर) का उपयोग करें।',
        'mr':
            'प्रति हेक्टर 120 किलो N, 60 किलो P, 60 किलो K द्या. नायट्रोजन विभाजित करा: 1/3 लागवडीत, 1/3 फुलोऱ्यात, 1/3 फळधारणेत. चांगल्या परिणामासाठी गांडूळखत (5 टन/हेक्टर) वापरा.',
      },
      'wateringTip': {
        'en':
            'Water every 5-7 days. Use drip irrigation for optimal water use efficiency. Avoid waterlogging. Critical irrigation stages: transplanting, flowering, and fruit development.',
        'hi':
            'हर 5-7 दिनों में पानी दें। इष्टतम जल उपयोग दक्षता के लिए ड्रिप सिंचाई का उपयोग करें। जलभराव से बचें। महत्वपूर्ण सिंचाई चरण: रोपाई, फूल आना, और फल विकास।',
        'mr':
            'दर 5-7 दिवसांनी पाणी द्या. इष्टतम पाणी वापरासाठी ठिबक सिंचन वापरा. पाणी साचणे टाळा. महत्त्वाचे सिंचन टप्पे: पुनर्लागवड, फुलोरा आणि फळ विकास.',
      },
      'pestAlert': {
        'en':
            '⚠️ Watch for Fruit Borer (Helicoverpa armigera). Monitor with pheromone traps. Apply Spinosad 45 SC @ 0.3 ml/L if infestation exceeds 5% damaged fruits.',
        'hi':
            '⚠️ फल छेदक (हेलीकोवर्पा आर्मीजेरा) पर नज़र रखें। फेरोमोन जाल से निगरानी करें। यदि 5% से अधिक फलों में संक्रमण हो तो स्पिनोसैड 45 SC @ 0.3 मिली/लीटर लगाएं।',
        'mr':
            '⚠️ फळ पोखरणारी अळी (हेलीकोव्हर्पा आर्मिजेरा) यावर लक्ष ठेवा. फेरोमोन सापळ्यांनी निरीक्षण करा. 5%पेक्षा जास्त फळांवर संक्रमण असल्यास स्पिनोसॅड 45 SC @ 0.3 मिली/ली फवारा.',
      },
    },
    'wheat': {
      'icon': '🌾',
      'name': {'en': 'Wheat', 'hi': 'गेहूं', 'mr': 'गहू'},
      'season': 'rabi',
      'currentTask': {
        'en':
            'Sow wheat at the optimal time (Nov 1-15). Use certified seed at 100 kg/ha. Treat seeds with Thiram + Carbendazim (2.5g/kg seed). Ensure proper field preparation with 2-3 ploughings.',
        'hi':
            'गेहूं को इष्टतम समय (1-15 नवंबर) पर बोएं। प्रमाणित बीज का उपयोग 100 किग्रा/हेक्टेयर करें। बीज को थाइरम + कार्बेंडाजिम (2.5ग्रा/किग्रा बीज) से उपचारित करें।',
        'mr':
            'गव्हाची इष्टतम वेळी (1-15 नोव्हेंबर) पेरणी करा. प्रमाणित बियाणे 100 किलो/हेक्टर वापरा. बियाण्यावर थायरम + कार्बेंडाझिम (2.5 ग्रॅम/किलो बियाणे) उपचार करा.',
      },
      'fertilizerTip': {
        'en':
            'Apply 120 kg N, 60 kg P, 40 kg K/ha. Apply full P and K + 1/2 N at sowing. Remaining 1/2 N at first irrigation (Crown Root Initiation stage). Use Zinc Sulphate if deficiency observed.',
        'hi':
            '120 किग्रा N, 60 किग्रा P, 40 किग्रा K/हेक्टेयर लगाएं। बुआई पर पूरा P और K + 1/2 N लगाएं। शेष 1/2 N पहली सिंचाई (CRI अवस्था) पर दें।',
        'mr':
            '120 किलो N, 60 किलो P, 40 किलो K/हेक्टर द्या. पेरणीवेळी पूर्ण P आणि K + 1/2 N द्या. उर्वरित 1/2 N पहिल्या पाण्यावेळी (CRI अवस्था) द्या.',
      },
      'wateringTip': {
        'en':
            'Wheat requires 5-6 critical irrigations. Key stages: Crown Root Initiation (21 DAS), Tillering (40 DAS), Jointing (60 DAS), Flowering (80 DAS), Grain Filling (100 DAS).',
        'hi':
            'गेहूं को 5-6 महत्वपूर्ण सिंचाई की आवश्यकता होती है। मुख्य चरण: CRI (21 DAS), कंसे (40 DAS), जोड़ (60 DAS), फूल (80 DAS), दाना भराई (100 DAS)।',
        'mr':
            'गव्हाला 5-6 महत्त्वाच्या पाण्याची गरज असते. महत्त्वाचे टप्पे: CRI (21 DAS), फुटवा (40 DAS), सांधे (60 DAS), फुलोरा (80 DAS), दाणे भरणे (100 DAS).',
      },
      'pestAlert': {
        'en':
            '⚠️ Yellow Rust and Aphid alert during Feb-March. Scout fields twice a week. Apply Propiconazole for rust control. For aphids, use Dimethoate 30 EC @ 1.5 ml/L.',
        'hi':
            '⚠️ फरवरी-मार्च के दौरान पीला रस्ट और माहू की चेतावनी। सप्ताह में दो बार खेत की निगरानी करें। रस्ट नियंत्रण के लिए प्रोपिकोनाजोल लगाएं। माहू के लिए डाइमेथोएट 30 EC @ 1.5 मिली/लीटर।',
        'mr':
            '⚠️ फेब्रुवारी-मार्चमध्ये पिवळ्या गंजाचा आणि मावाचा इशारा. आठवड्यातून दोनदा शेत तपासा. गंज नियंत्रणासाठी प्रोपिकोनाझोल फवारा. मावासाठी डायमेथोएट 30 EC @ 1.5 मिली/ली.',
      },
    },
    'rice': {
      'icon': '🌾',
      'name': {'en': 'Rice', 'hi': 'धान', 'mr': 'भात'},
      'season': 'kharif',
      'currentTask': {
        'en':
            'Transplant paddy seedlings (25-30 days old) at 20x15 cm spacing. Maintain 2-3 cm water depth after transplanting. Ensure good puddling before transplanting for weed control.',
        'hi':
            'धान के पौधे (25-30 दिन पुराने) को 20x15 सेमी की दूरी पर रोपाई करें। रोपाई के बाद 2-3 सेमी पानी की गहराई बनाए रखें। खरपतवार नियंत्रण के लिए रोपाई से पहले अच्छी कदाई करें।',
        'mr':
            'भाताची रोपे (25-30 दिवस वयाची) 20x15 सेमी अंतरावर लावा. पुनर्लागवडीनंतर 2-3 सेमी पाण्याची खोली ठेवा. तण नियंत्रणासाठी लावणीपूर्वी चांगले चिखलणे करा.',
      },
      'fertilizerTip': {
        'en':
            'Apply 100 kg N, 50 kg P, 50 kg K/ha. Apply full P & K at transplanting. Split N: 1/3 basal + 1/3 at tillering + 1/3 at panicle initiation. Apply zinc sulphate @ 25 kg/ha.',
        'hi':
            '100 किग्रा N, 50 किग्रा P, 50 किग्रा K/हेक्टेयर लगाएं। रोपाई पर पूरा P & K लगाएं। N को विभाजित करें: 1/3 बेसल + 1/3 कंसे पर + 1/3 बाली बनने पर। जिंक सल्फेट @ 25 किग्रा/हेक्टेयर।',
        'mr':
            '100 किलो N, 50 किलो P, 50 किलो K/हेक्टर द्या. लावणीवेळी पूर्ण P & K द्या. N विभाजित करा: 1/3 मूलभूत + 1/3 फुटव्यावेळी + 1/3 लोंबी येताना. जिंक सल्फेट @ 25 किलो/हेक्टर.',
      },
      'wateringTip': {
        'en':
            'Maintain continuous flooding (5-7 cm) during vegetative stage. Use Alternate Wetting and Drying (AWD) technique to save 30% water. Drain field 2 weeks before harvest.',
        'hi':
            'वानस्पतिक अवस्था के दौरान लगातार जलभराव (5-7 सेमी) बनाए रखें। 30% पानी बचाने के लिए AWD तकनीक का उपयोग करें। कटाई से 2 सप्ताह पहले खेत से पानी निकालें।',
        'mr':
            'वनस्पती अवस्थेत सतत पाणी (5-7 सेमी) ठेवा. 30% पाणी वाचवण्यासाठी AWD तंत्र वापरा. कापणीच्या 2 आठवडे आधी शेत कोरडे करा.',
      },
      'pestAlert': {
        'en':
            '⚠️ Watch for Brown Planthopper (BPH) and Stem Borer. Set light traps to monitor moths. Apply Chlorpyrifos 20 EC for stem borer. Ensure no burning of stubble after harvest.',
        'hi':
            '⚠️ भूरा माहू (BPH) और तना छेदक की निगरानी करें। पतंगों की निगरानी के लिए प्रकाश जाल लगाएं। तना छेदक के लिए क्लोरपाइरीफोस 20 EC लगाएं।',
        'mr':
            '⚠️ तपकिरी मावा (BPH) आणि खोड किडीवर लक्ष ठेवा. पतंगांच्या निरीक्षणासाठी प्रकाश सापळे लावा. खोड किडीसाठी क्लोरपायरीफॉस 20 EC वापरा.',
      },
    },
    'cotton': {
      'icon': '🌿',
      'name': {'en': 'Cotton', 'hi': 'कपास', 'mr': 'कापूस'},
      'season': 'kharif',
      'currentTask': {
        'en':
            'Sow Bt cotton seeds at 90x60 cm spacing after pre-sowing irrigation. Thin to one plant per hill at 10 DAS. Apply pre-emergence herbicide Pendimethalin @ 1.5 kg a.i./ha.',
        'hi':
            'पूर्व-बुआई सिंचाई के बाद 90x60 सेमी की दूरी पर Bt कपास के बीज बोएं। 10 DAS पर प्रति थाला एक पौधा रखें। प्री-इमर्जेंस हर्बिसाइड पेंडीमेथालिन @ 1.5 किग्रा/हेक्टेयर।',
        'mr':
            'पूर्व-पेरणी सिंचनानंतर 90x60 सेमी अंतरावर Bt कापसाच्या बिया पेरा. 10 DAS ला प्रति चर एक झाड ठेवा. प्री-इमर्जन्स तणनाशक पेंडिमेथालिन @ 1.5 किलो/हेक्टर.',
      },
      'fertilizerTip': {
        'en':
            'Apply 150 kg N, 75 kg P, 75 kg K/ha. Apply full P & K at sowing. Split N: 1/3 basal + 1/3 at squaring + 1/3 at boll development. Foliar spray of micronutrients at flowering.',
        'hi':
            '150 किग्रा N, 75 किग्रा P, 75 किग्रा K/हेक्टेयर लगाएं। बुआई पर पूरा P & K दें। N को विभाजित करें: 1/3 बेसल + 1/3 कली बनने पर + 1/3 टिंडा विकास पर। फूल आने पर सूक्ष्म पोषक तत्वों का पर्णीय छिड़काव करें।',
        'mr':
            '150 किलो N, 75 किलो P, 75 किलो K/हेक्टर द्या. पेरणीवेळी पूर्ण P & K द्या. N विभाजित करा: 1/3 मूलभूत + 1/3 फूल कळी + 1/3 बोंड विकास. फुलोऱ्यात सूक्ष्म अन्नद्रव्यांची पर्णफवारणी करा.',
      },
      'wateringTip': {
        'en':
            'Cotton is drought-tolerant but needs irrigation at critical stages: flowering and boll development. Avoid waterlogging. Use furrow irrigation. Irrigate every 10-15 days in dry spells.',
        'hi':
            'कपास सूखा-सहिष्णु है लेकिन महत्वपूर्ण चरणों पर सिंचाई की जरूरत है: फूल आना और टिंडा विकास। जलभराव से बचें। कतार सिंचाई का उपयोग करें।',
        'mr':
            'कापूस दुष्काळ-सहिष्णु आहे पण महत्त्वाच्या टप्प्यांवर सिंचन हवे: फुलोरा आणि बोंड विकास. पाणी साचणे टाळा. सऱ्यांनी सिंचन करा. कोरड्या काळात दर 10-15 दिवसांनी सिंचन करा.',
      },
      'pestAlert': {
        'en':
            '⚠️ Pink Bollworm and Whitefly alert! Install pheromone traps @ 5/ha. If PBW damage >5%, apply Emamectin benzoate. Neem oil 2% for whitefly management.',
        'hi':
            '⚠️ गुलाबी टिंडा छेदक और सफेद मक्खी की चेतावनी! फेरोमोन जाल @ 5/हेक्टेयर लगाएं। यदि PBW क्षति >5%, तो इमामेक्टिन बेंजोएट लगाएं। सफेद मक्खी के लिए नीम का तेल 2%।',
        'mr':
            '⚠️ गुलाबी बोंड अळी आणि पांढरी माशी इशारा! फेरोमोन सापळे @ 5/हेक्टर लावा. PBW नुकसान >5% असल्यास इमामेक्टिन बेन्झोएट वापरा. पांढऱ्या माशीसाठी कडुनिंब तेल 2%.',
      },
    },
    'onion': {
      'icon': '🧅',
      'name': {'en': 'Onion', 'hi': 'प्याज', 'mr': 'कांदा'},
      'season': 'rabi',
      'currentTask': {
        'en':
            'Transplant onion seedlings (45-day-old) at 15x10 cm spacing. Apply pre-planting dose of fertilizer. Ensure good soil preparation. Use raised bed system for better drainage.',
        'hi':
            '45-दिन पुराने प्याज के पौधे 15x10 सेमी की दूरी पर रोपाई करें। रोपाई से पहले उर्वरक की खुराक दें। अच्छी भूमि तैयारी सुनिश्चित करें। बेहतर जल निकासी के लिए उठी हुई क्यारी प्रणाली का उपयोग करें।',
        'mr':
            '45-दिवसाची कांद्याची रोपे 15x10 सेमी अंतरावर लावा. लागवडीपूर्वी खताचा डोस द्या. चांगली जमीन तयारी सुनिश्चित करा. चांगल्या निचऱ्यासाठी उंचावलेले वाफे वापरा.',
      },
      'fertilizerTip': {
        'en':
            'Apply 100 kg N, 50 kg P, 50 kg K/ha. Apply full P & K + half N at planting. Remaining N in two splits at 30 and 45 DAS. Boron spray at 0.5% during bulb development.',
        'hi':
            '100 किग्रा N, 50 किग्रा P, 50 किग्रा K/हेक्टेयर। रोपाई पर पूरा P & K + आधा N दें। शेष N को 30 और 45 DAS पर दो भागों में दें। बल्ब विकास के दौरान बोरॉन स्प्रे 0.5%।',
        'mr':
            '100 किलो N, 50 किलो P, 50 किलो K/हेक्टर. लागवडीवेळी पूर्ण P & K + अर्धे N द्या. उर्वरित N 30 आणि 45 DAS ला द्या. गड्डा विकासादरम्यान बोरॉन फवारणी 0.5%.',
      },
      'wateringTip': {
        'en':
            'Irrigate every 7-10 days. Stop irrigation 10-15 days before harvest for good bulb maturity and storage quality. Drip irrigation saves 40% water and reduces disease incidence.',
        'hi':
            'हर 7-10 दिनों में सिंचाई करें। अच्छी बल्ब परिपक्वता और भंडारण गुणवत्ता के लिए कटाई से 10-15 दिन पहले सिंचाई बंद करें। ड्रिप सिंचाई 40% पानी बचाती है।',
        'mr':
            'दर 7-10 दिवसांनी सिंचन करा. चांगल्या गड्डा परिपक्वता आणि साठवण गुणवत्तेसाठी कापणीच्या 10-15 दिवस आधी सिंचन थांबवा. ठिबक सिंचन 40% पाणी वाचवते.',
      },
      'pestAlert': {
        'en':
            '⚠️ Thrips and Stemphylium blight are major threats. Monitor leaf tips for silvery discoloration (thrips sign). Apply Fipronil 5 SC @ 1.5 ml/L. For blight, use Chlorothalonil 75 WP.',
        'hi':
            '⚠️ थ्रिप्स और स्टेम्फिलियम झुलसा प्रमुख खतरे हैं। चांदी जैसे मलिनकिरण (थ्रिप्स संकेत) के लिए पत्ती युक्तियों की निगरानी करें। फिप्रोनिल 5 SC @ 1.5 मिली/लीटर लगाएं।',
        'mr':
            '⚠️ थ्रिप्स आणि स्टेम्फिलियम करपा प्रमुख धोके आहेत. चांदीसारख्या रंग बदलासाठी (थ्रिप्स चिन्ह) पानांच्या टोकांवर लक्ष ठेवा. फिप्रोनिल 5 SC @ 1.5 मिली/ली वापरा.',
      },
    },
  };

  // --- General season tips ---
  static const Map<String, Map<String, String>> _seasonTips = {
    'kharif': {
      'en':
          '🌧️ Kharif Season Tips:\n• Monitor drainage in low-lying areas\n• Check for fungal diseases due to high humidity\n• Ensure proper weed management in the first 30 days\n• Keep a watch on pest pressure after monsoon onset',
      'hi':
          '🌧️ खरीफ मौसम सुझाव:\n• निचले क्षेत्रों में जल निकासी की निगरानी करें\n• उच्च आर्द्रता के कारण फफूंद रोगों की जांच करें\n• पहले 30 दिनों में खरपतवार प्रबंधन सुनिश्चित करें\n• मानसून के बाद कीट दबाव पर नजर रखें',
      'mr':
          '🌧️ खरीप हंगाम सुझाव:\n• सखल भागात निचऱ्यावर लक्ष ठेवा\n• जास्त आर्द्रतेमुळे बुरशीजन्य रोगांकडे लक्ष द्या\n• पहिल्या 30 दिवसांत तण व्यवस्थापन सुनिश्चित करा\n• मान्सून नंतर कीडीच्या दबावावर लक्ष ठेवा',
    },
    'rabi': {
      'en':
          '❄️ Rabi Season Tips:\n• Protect crops from frost damage using smoke or sprinkler\n• Conserve soil moisture with mulching\n• Monitor for aphids and powdery mildew\n• Plan irrigation schedule before cold waves',
      'hi':
          '❄️ रबी मौसम सुझाव:\n• धुआं या स्प्रिंकलर से पाले की क्षति से फसल बचाएं\n• मल्चिंग से मिट्टी की नमी बचाएं\n• माहू और ख़स्ता फफूंदी की निगरानी करें\n• ठंडी लहरों से पहले सिंचाई कार्यक्रम की योजना बनाएं',
      'mr':
          '❄️ रब्बी हंगाम सुझाव:\n• धूर किंवा स्प्रिंकलरने दंव नुकसानापासून पिके वाचवा\n• आच्छादनाने मातीतील ओलावा टिकवा\n• मावा आणि भुरी रोगाकडे लक्ष द्या\n• थंडीच्या लाटेपूर्वी सिंचन वेळापत्रक आखा',
    },
    'zaid': {
      'en':
          '☀️ Zaid Season Tips:\n• Mulch heavily to reduce moisture evaporation\n• Water early morning or evening to reduce evaporation\n• Watch for heat stress symptoms in crops\n• Consider short-duration crop varieties',
      'hi':
          '☀️ जायद मौसम सुझाव:\n• नमी वाष्पीकरण कम करने के लिए भारी मल्चिंग करें\n• वाष्पीकरण कम करने के लिए सुबह या शाम को पानी दें\n• फसलों में ताप तनाव के लक्षणों पर नजर रखें\n• कम अवधि वाली फसल किस्मों पर विचार करें',
      'mr':
          '☀️ उन्हाळी हंगाम सुझाव:\n• बाष्पीभवन कमी करण्यासाठी जड आच्छादन करा\n• बाष्पीभवन कमी करण्यासाठी सकाळी किंवा संध्याकाळी पाणी द्या\n• पिकांमध्ये उष्णता ताणाची लक्षणे पाहा\n• कमी कालावधीच्या पीक वाणांचा विचार करा',
    },
  };

  // --- Soil-specific tips ---
  static const Map<String, Map<String, String>> _soilTips = {
    'black': {
      'en':
          '🖤 Black Soil Tip: Black (cotton) soil has high water retention. Avoid over-irrigation. Add organic matter to improve drainage. Suitable for cotton, soybean, wheat, and chickpea.',
      'hi':
          '🖤 काली मिट्टी सुझाव: काली (कपास) मिट्टी में उच्च जल धारण क्षमता होती है। अत्यधिक सिंचाई से बचें। जल निकासी सुधारने के लिए जैविक पदार्थ जोड़ें। कपास, सोयाबीन, गेहूं और चने के लिए उपयुक्त।',
      'mr':
          '🖤 काळी माती सुझाव: काळ्या (कापूस) मातीत जास्त पाणी टिकण्याची क्षमता असते. जास्त पाणी देणे टाळा. निचरा सुधारण्यासाठी सेंद्रिय पदार्थ घाला. कापूस, सोयाबीन, गहू आणि हरभऱ्यासाठी योग्य.',
    },
    'red': {
      'en':
          '🔴 Red Soil Tip: Red soil is well-drained but low in fertility. Apply more organic manure. Frequent small irrigations work better than heavy irrigation. Suitable for groundnut, millets, vegetables.',
      'hi':
          '🔴 लाल मिट्टी सुझाव: लाल मिट्टी अच्छी जल निकासी वाली लेकिन उर्वरता में कम है। अधिक जैविक खाद लगाएं। भारी सिंचाई की बजाय बार-बार कम सिंचाई बेहतर काम करती है।',
      'mr':
          '🔴 लाल माती सुझाव: लाल माती चांगल्या निचऱ्याची पण सुपीकतेत कमी आहे. जास्त सेंद्रिय खत वापरा. जड सिंचनापेक्षा वारंवार कमी सिंचन चांगले कार्य करते.',
    },
    'loamy': {
      'en':
          '🟤 Loamy Soil Tip: Loamy soil is ideal for most crops. Maintain organic matter content. Practice crop rotation to prevent nutrient depletion. Suitable for almost all vegetables and cereals.',
      'hi':
          '🟤 दोमट मिट्टी सुझाव: दोमट मिट्टी अधिकांश फसलों के लिए आदर्श है। जैविक पदार्थ की मात्रा बनाए रखें। पोषक तत्वों की कमी को रोकने के लिए फसल चक्रण का अभ्यास करें।',
      'mr':
          '🟤 चिकण माती सुझाव: चिकण माती बहुतेक पिकांसाठी आदर्श आहे. सेंद्रिय पदार्थांचे प्रमाण ठेवा. पोषणाची कमतरता टाळण्यासाठी पीक फेरपालट करा.',
    },
    'sandy': {
      'en':
          '🟡 Sandy Soil Tip: Sandy soil drains quickly. Frequent light irrigations are needed. Add compost heavily to improve water retention. Suitable for vegetables, groundnut, watermelon.',
      'hi':
          '🟡 बलुई मिट्टी सुझाव: बलुई मिट्टी जल्दी सूख जाती है। बार-बार हल्की सिंचाई की जरूरत होती है। जल धारण में सुधार के लिए खूब कम्पोस्ट डालें। सब्जियों, मूंगफली, तरबूज के लिए उपयुक्त।',
      'mr':
          '🟡 वालुकामय माती सुझाव: वालुकामय माती लवकर कोरडी होते. वारंवार हलके सिंचन हवे. पाणी टिकवण्यासाठी भरपूर कंपोस्ट घाला. भाजीपाला, शेंगदाणा, कलिंगडासाठी योग्य.',
    },
  };

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userCrops = prefs.getStringList('farmer_crops') ?? [];
      _soil = prefs.getString('farmer_soil') ?? 'black';
      _district = prefs.getString('farmer_district') ?? 'Nashik';
      _isLoading = false;
    });
  }

  String _currentSeason() {
    final month = DateTime.now().month;
    if (month >= 6 && month <= 10) return 'kharif';
    if (month >= 11 || month <= 2) return 'rabi';
    return 'zaid';
  }

  String _seasonEmoji(String season) {
    switch (season) {
      case 'kharif':
        return '🌧️';
      case 'rabi':
        return '❄️';
      default:
        return '☀️';
    }
  }

  Color _seasonColor(String season) {
    switch (season) {
      case 'kharif':
        return const Color(0xFF1565C0);
      case 'rabi':
        return const Color(0xFF6A1B9A);
      default:
        return const Color(0xFFE65100);
    }
  }

  String l(String key) => _labels[key]?[widget.lang] ?? _labels[key]?['en'] ?? key;

  String _cropName(Map<String, dynamic> advice) {
    final name = advice['name'] as Map<String, dynamic>;
    return name[widget.lang] ?? name['en'] ?? '';
  }

  String _adviceText(Map<String, dynamic> advice, String field) {
    final map = advice[field] as Map<String, dynamic>;
    return map[widget.lang] ?? map['en'] ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final brand = brandOf(context);
    final season = _currentSeason();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [brand.withOpacity(0.06), Colors.white],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildTopBar(context, brand),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _buildContent(context, brand, season),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, Color brand) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            color: brand,
            onPressed: () => Navigator.of(context).pop(),
          ),
          Expanded(
            child: Text(
              _l('title'),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: brand,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, Color brand, String season) {
    final seasonColor = _seasonColor(season);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Season banner
        _buildSeasonBanner(season, seasonColor),
        const SizedBox(height: 16),
        // Your crops header
        Text(
          _l('yourCrops'),
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        // Crop chips
        _buildCropChips(brand),
        const SizedBox(height: 16),
        // Crop advice cards
        if (_userCrops.isEmpty)
          _buildNoCropsState(brand)
        else
          ..._userCrops.map((crop) {
            final advice = _cropAdvice[crop.toLowerCase()];
            if (advice == null) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _CropAdviceCard(
                advice: advice,
                cropName: _cropName(advice),
                brand: brand,
                lang: widget.lang,
                currentTaskLabel: _l('currentTask'),
                fertilizerLabel: _l('fertilizerTip'),
                wateringLabel: _l('wateringTip'),
                pestLabel: _l('pestAlert'),
                currentTaskText: _adviceText(advice, 'currentTask'),
                fertilizerText: _adviceText(advice, 'fertilizerTip'),
                wateringText: _adviceText(advice, 'wateringTip'),
                pestText: _adviceText(advice, 'pestAlert'),
              ),
            );
          }),
        const SizedBox(height: 8),
        // General season tips
        _buildGeneralTipsCard(season, seasonColor),
        const SizedBox(height: 16),
        // Soil-specific tip
        _buildSoilTipCard(brand),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildSeasonBanner(String season, Color seasonColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [seasonColor, seasonColor.withOpacity(0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: seasonColor.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Text(_seasonEmoji(season), style: const TextStyle(fontSize: 48)),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _l(season),
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _l('${season}Months'),
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.85),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _district,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.white.withOpacity(0.75),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCropChips(Color brand) {
    if (_userCrops.isEmpty) return const SizedBox.shrink();
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _userCrops.map((crop) {
        final advice = _cropAdvice[crop.toLowerCase()];
        final emoji = advice?['icon'] as String? ?? '🌱';
        return Chip(
          label: Text('$emoji ${crop[0].toUpperCase()}${crop.substring(1)}'),
          backgroundColor: brand.withOpacity(0.1),
          labelStyle: TextStyle(color: brand, fontWeight: FontWeight.w500),
        );
      }).toList(),
    );
  }

  Widget _buildNoCropsState(Color brand) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        children: [
          const Text('🌱', style: TextStyle(fontSize: 52)),
          const SizedBox(height: 16),
          Text(
            _l('noCrops'),
            style: TextStyle(fontSize: 15, color: Colors.grey[600], height: 1.5),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.person_outline_rounded),
            label: const Text('Go to Profile'),
            style: FilledButton.styleFrom(backgroundColor: brand),
          ),
        ],
      ),
    );
  }

  Widget _buildGeneralTipsCard(String season, Color seasonColor) {
    final tips = _seasonTips[season]?[widget.lang] ??
        _seasonTips[season]?['en'] ??
        '';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: seasonColor.withOpacity(0.07),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: seasonColor.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _l('generalTips'),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: seasonColor,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            tips,
            style: const TextStyle(fontSize: 14, height: 1.6),
          ),
        ],
      ),
    );
  }

  Widget _buildSoilTipCard(Color brand) {
    final tip = _soilTips[_soil]?[widget.lang] ??
        _soilTips[_soil]?['en'] ??
        _soilTips['black']?['en'] ??
        '';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5E6D3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD4A574).withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _l('soilTip'),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF5D4037),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            tip,
            style: const TextStyle(
              fontSize: 14,
              height: 1.6,
              color: Color(0xFF4E342E),
            ),
          ),
        ],
      ),
    );
  }
}

// --- Crop Advice Card Widget ---

class _CropAdviceCard extends StatefulWidget {
  final Map<String, dynamic> advice;
  final String cropName;
  final Color brand;
  final String lang;
  final String currentTaskLabel;
  final String fertilizerLabel;
  final String wateringLabel;
  final String pestLabel;
  final String currentTaskText;
  final String fertilizerText;
  final String wateringText;
  final String pestText;

  const _CropAdviceCard({
    required this.advice,
    required this.cropName,
    required this.brand,
    required this.lang,
    required this.currentTaskLabel,
    required this.fertilizerLabel,
    required this.wateringLabel,
    required this.pestLabel,
    required this.currentTaskText,
    required this.fertilizerText,
    required this.wateringText,
    required this.pestText,
  });

  @override
  State<_CropAdviceCard> createState() => _CropAdviceCardState();
}

class _CropAdviceCardState extends State<_CropAdviceCard> {
  int _expanded = -1;

  @override
  Widget build(BuildContext context) {
    final icon = widget.advice['icon'] as String;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: widget.brand.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Left accent bar
            Container(
              width: 5,
              decoration: BoxDecoration(
                color: widget.brand,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      children: [
                        Text(icon, style: const TextStyle(fontSize: 32)),
                        const SizedBox(width: 12),
                        Text(
                          widget.cropName,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Divider(height: 1),
                    // Expandable sections
                    _ExpandableSection(
                      index: 0,
                      expanded: _expanded,
                      icon: Icons.task_alt_rounded,
                      label: widget.currentTaskLabel,
                      text: widget.currentTaskText,
                      brand: widget.brand,
                      onTap: (i) => setState(() => _expanded = _expanded == i ? -1 : i),
                    ),
                    _ExpandableSection(
                      index: 1,
                      expanded: _expanded,
                      icon: Icons.science_rounded,
                      label: widget.fertilizerLabel,
                      text: widget.fertilizerText,
                      brand: widget.brand,
                      onTap: (i) => setState(() => _expanded = _expanded == i ? -1 : i),
                    ),
                    _ExpandableSection(
                      index: 2,
                      expanded: _expanded,
                      icon: Icons.water_drop_rounded,
                      label: widget.wateringLabel,
                      text: widget.wateringText,
                      brand: widget.brand,
                      onTap: (i) => setState(() => _expanded = _expanded == i ? -1 : i),
                    ),
                    _ExpandableSection(
                      index: 3,
                      expanded: _expanded,
                      icon: Icons.bug_report_rounded,
                      label: widget.pestLabel,
                      text: widget.pestText,
                      brand: widget.brand,
                      color: Colors.orange,
                      onTap: (i) => setState(() => _expanded = _expanded == i ? -1 : i),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExpandableSection extends StatelessWidget {
  final int index;
  final int expanded;
  final IconData icon;
  final String label;
  final String text;
  final Color brand;
  final Color? color;
  final void Function(int) onTap;

  const _ExpandableSection({
    required this.index,
    required this.expanded,
    required this.icon,
    required this.label,
    required this.text,
    required this.brand,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isExpanded = expanded == index;
    final c = color ?? brand;
    return Column(
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Icon(icon, color: c, size: 20),
          title: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: c,
            ),
          ),
          trailing: Icon(
            isExpanded
                ? Icons.keyboard_arrow_up_rounded
                : Icons.keyboard_arrow_down_rounded,
            color: Colors.grey,
          ),
          onTap: () => onTap(index),
        ),
        if (isExpanded)
          Padding(
            padding: const EdgeInsets.only(bottom: 12, left: 4, right: 4),
            child: Text(
              text,
              style: const TextStyle(fontSize: 13, height: 1.6, color: Colors.black87),
            ),
          ),
        const Divider(height: 1),
      ],
    );
  }
}
