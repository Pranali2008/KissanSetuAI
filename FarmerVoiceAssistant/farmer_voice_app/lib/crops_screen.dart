import 'package:flutter/material.dart';
import 'app_theme.dart';

class CropsScreen extends StatefulWidget {
  final String lang; // 'en', 'hi', or 'mr'

  const CropsScreen({super.key, required this.lang});

  @override
  State<CropsScreen> createState() => _CropsScreenState();
}

class CropDetailedInfo {
  final String id;
  final String emoji;
  final String category; // 'cereals', 'pulses', 'vegetables', 'fruits', 'cash', 'oilseeds'
  final String seasonType; // 'kharif', 'rabi', 'zaid'
  final bool isPopular;

  // 1. Crop Overview
  final Map<String, String> name;
  final Map<String, String> intro;
  final Map<String, String> cropTypeAndCategory;
  final Map<String, String> producingRegions;

  // 2. Climate Requirements
  final Map<String, String> suitableTemp;
  final Map<String, String> rainfall;
  final Map<String, String> humidity;
  final Map<String, String> growingSeason;

  // 3. Soil Requirements
  final Map<String, String> suitableSoil;
  final Map<String, String> idealPh;
  final Map<String, String> soilPrep;

  // 4. Sowing Information
  final Map<String, String> sowingSeason;
  final Map<String, String> seedVarieties;
  final Map<String, String> seedQuantityPerAcre;
  final Map<String, String> seedTreatment;

  // 5. Fertilizer Requirements
  final Map<String, String> recommendedNutrients;
  final Map<String, String> organicFertilizers;
  final Map<String, String> applicationStages;
  final Map<String, String> nutrientManagement;

  // 6. Irrigation Information
  final Map<String, String> waterRequirements;
  final Map<String, String> irrigationSchedule;
  final Map<String, String> criticalStages;
  final Map<String, String> waterSavingMethods;

  // 7. Crop Growth Stages
  final Map<String, String> stageGermination;
  final Map<String, String> stageSeedling;
  final Map<String, String> stageVegetative;
  final Map<String, String> stageFlowering;
  final Map<String, String> stageMaturity;
  final Map<String, String> stageHarvesting;

  const CropDetailedInfo({
    required this.id,
    required this.emoji,
    required this.category,
    required this.seasonType,
    required this.isPopular,
    required this.name,
    required this.intro,
    required this.cropTypeAndCategory,
    required this.producingRegions,
    required this.suitableTemp,
    required this.rainfall,
    required this.humidity,
    required this.growingSeason,
    required this.suitableSoil,
    required this.idealPh,
    required this.soilPrep,
    required this.sowingSeason,
    required this.seedVarieties,
    required this.seedQuantityPerAcre,
    required this.seedTreatment,
    required this.recommendedNutrients,
    required this.organicFertilizers,
    required this.applicationStages,
    required this.nutrientManagement,
    required this.waterRequirements,
    required this.irrigationSchedule,
    required this.criticalStages,
    required this.waterSavingMethods,
    required this.stageGermination,
    required this.stageSeedling,
    required this.stageVegetative,
    required this.stageFlowering,
    required this.stageMaturity,
    required this.stageHarvesting,
  });
}

class _CropsScreenState extends State<CropsScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'all';
  String _selectedSeason = 'all';
  CropDetailedInfo? _selectedCropDetail;

  final List<CropDetailedInfo> _cropDatabase = [
    // --- 1. TOMATO ---
    CropDetailedInfo(
      id: 'tomato',
      emoji: '🍅',
      category: 'vegetables',
      seasonType: 'kharif',
      isPopular: true,
      name: {'en': 'Tomato', 'hi': 'टमाटर', 'mr': 'टोमॅटो'},
      intro: {
        'en': 'One of the most widely cultivated commercial vegetable crops in India, rich in Vitamin C, potassium, and lycopene antioxidant.',
        'hi': 'भारत में सबसे अधिक उगाई जाने वाली व्यावसायिक सब्जी, विटामिन सी और लाइकोपीन से भरपूर।',
        'mr': 'भारतात मोठ्या प्रमाणावर पिकवली जाणारी व्यावसायिक भाजी, व्हिटॅमिन सी आणि लायकोपीनने समृद्ध.'
      },
      cropTypeAndCategory: {
        'en': 'Vegetable / Solanaceous Fruit Vegetable',
        'hi': 'सब्जी / सोलेनेसी कुल की फल सब्जी',
        'mr': 'भाजीपाला / सोलेनेसी कुळातील फळभाजी'
      },
      producingRegions: {
        'en': 'Maharashtra (Nashik, Pune, Satara), Karnataka, Andhra Pradesh, Madhya Pradesh, Gujarat.',
        'hi': 'महाराष्ट्र (नाशिक, पुणे), कर्नाटक, आंध्र प्रदेश, मध्य प्रदेश, गुजरात।',
        'mr': 'महाराष्ट्र (नाशिक, पुणे, सातारा), कर्नाटक, आंध्र प्रदेश, मध्य प्रदेश.'
      },
      suitableTemp: {
        'en': '20°C to 28°C (optimum). Temperatures above 35°C cause blossom drop.',
        'hi': '20°C से 28°C। 35°C से अधिक तापमान पर फूल झड़ने लगते हैं।',
        'mr': '२०°C ते २८°C. ३५°C पेक्षा जास्त तापमानात फुलगळ होते.'
      },
      rainfall: {
        'en': '600–1000 mm annually. Heavy rain during flowering causes fungal rot.',
        'hi': '600-1000 मिमी। फूल आते समय अधिक वर्षा हानिकारक है।',
        'mr': '६०० ते १००० मिमी वार्षिक. फुलोऱ्यात अतिवृष्टी झाल्यास सड रोग होतो.'
      },
      humidity: {
        'en': '50% to 65% relative humidity. Excessive humidity invites early & late blight.',
        'hi': '50% से 65%। अधिक नमी से झुलसा रोग फैलता है।',
        'mr': '५०% ते ६५%. जास्त हवेतील आर्द्रतेमुळे करपा रोग बळावतो.'
      },
      growingSeason: {
        'en': 'Kharif (June–Oct), Rabi (Oct–Feb), and Summer (Jan–May).',
        'hi': 'खरीफ (जून-अक्टूबर), रबी (अक्टूबर-फरवरी) और जायद (जनवरी-मई)।',
        'mr': 'खरीप (जून-ऑक्टोबर), रब्बी (ऑक्टोबर-फेब्रुवारी) आणि उन्हाळी (जानेवारी-मे).'
      },
      suitableSoil: {
        'en': 'Well-drained fertile sandy loam to clay loam rich in organic matter.',
        'hi': 'उत्तम जल निकासी वाली दोमट या बलुई दोमट मिट्टी।',
        'mr': 'पाण्याचा उत्तम निचरा होणारी पोयट्याची किंवा मध्यम काळी कसदार जमीन.'
      },
      idealPh: {
        'en': 'pH 6.0 to 7.5',
        'hi': 'pH 6.0 से 7.5',
        'mr': 'सामू ६.० ते ७.५'
      },
      soilPrep: {
        'en': 'Deep plowing followed by 2 cross-harrowings. Form raised beds (width 3 ft, height 1 ft) with silver-black mulch.',
        'hi': 'गहरी जुताई के बाद 2 बार हैरो चलाएं। 3 फीट चौड़ी उठी क्यारियां व मल्चिंग बनाएं।',
        'mr': '१ खोल नांगरट व २ कुळवाच्या पाळ्या. ३ फूट रुंद व १ फूट उंच गादीवाफे तयार करून सिल्व्हर ब्लॅक मल्चिंग वापरावे.'
      },
      sowingSeason: {
        'en': 'Kharif nursery in May–June; Rabi in Sept–Oct; Summer in Dec–Jan.',
        'hi': 'खरीफ नर्सरी मई-जून; रबी सितंबर-अक्टूबर; गर्मी दिसंबर-जनवरी।',
        'mr': 'खरीप रोपवाटिका मे-जून; रब्बी सप्टे-ऑक्टो; उन्हाळी डिसेंबर-जानेवारी.'
      },
      seedVarieties: {
        'en': 'Abhinav, Saaho, US-440, To-1057, Arka Rakshak, Pusa Ruby.',
        'hi': 'अभिनव, साहो, यूएस-440, अर्का रक्षक, पूसा रूबी।',
        'mr': 'अभिनव, साहो, युएस-४४०, अर्का रक्षक, पुसा रुबी.'
      },
      seedQuantityPerAcre: {
        'en': '40 to 60 grams hybrid seeds per acre (approx 6,000–7,000 seedlings).',
        'hi': '40 से 60 ग्राम संकर बीज प्रति एकड़ (6,000-7,000 पौध)।',
        'mr': '४० ते ६० ग्रॅम संकरित बियाणे प्रति एकर (सुमारे ६,००० ते ७,००० रोपे).'
      },
      seedTreatment: {
        'en': 'Treat seeds with Trichoderma viride @ 5g/kg or Thiram @ 2g/kg to prevent damping-off.',
        'hi': 'डैम्पिंग-ऑफ से बचाव हेतु ट्राइकोडर्मा 5g/kg से बीजोपचार करें।',
        'mr': 'रोपे कुजणे टाळण्यासाठी ट्रायकोडर्मा व्हिरिडी ५ ग्रॅम प्रति किलो बियाण्यास चोळावे.'
      },
      recommendedNutrients: {
        'en': 'NPK 120:60:60 kg/acre + Secondary & Micronutrients (Calcium, Boron, Zinc).',
        'hi': 'NPK 120:60:60 किग्रा/एकड़ + कैल्शियम, बोरॉन, जिंक।',
        'mr': 'एकरी १२०:६०:६० किलो NPK + कॅल्शियम, बोरॉन, झिंक सूक्ष्मअन्नद्रव्ये.'
      },
      organicFertilizers: {
        'en': 'Apply 8–10 tons well-decomposed FYM or 2 tons Vermicompost + Neem cake 200 kg.',
        'hi': '8-10 टन सड़ी गोबर खाद या 2 टन वर्मीकम्पोस्ट + 200 किग्रा नीम खली।',
        'mr': '८ ते १० टन कुजलेले शेणखत किंवा २ टन गांडूळ खत + २०० किलो निंबोळी पेंड.'
      },
      applicationStages: {
        'en': 'Basal: 40% N, full P, 50% K; Fertigate 19:19:19 in vegetative, 12:61:0 at flowering, 0:52:34 and 0:0:50 at fruiting.',
        'hi': 'वानस्पतिक अवस्था में 19:19:19, फूल आने पर 12:61:0, फल पर 0:52:34 और 0:0:50 दें।',
        'mr': 'वाढीच्या काळात १९:१९:१९, फुलधारणेवेळी १२:६१:० आणि फळधारणेच्या काळात ०:५२:३४ व ०:०:५० द्यावे.'
      },
      nutrientManagement: {
        'en': 'Spray Boron (1.5g/L) and Calcium Nitrate (3g/L) at pea stage to prevent blossom end rot and fruit cracking.',
        'hi': 'फल फटने और सड़न से बचाव के लिए बोरॉन (1.5g/L) और कैल्शियम नाइट्रेट का छिड़काव करें।',
        'mr': 'फळे तडकणे व काळे डाग रोखण्यासाठी बोरॉन १.५ ग्रॅम आणि कॅल्शियम नायट्रेट ३ ग्रॅम/लिटर फवारावे.'
      },
      waterRequirements: {
        'en': '600–800 mm water throughout the 120-day lifecycle.',
        'hi': 'पूरी फसल में 600-800 मिमी पानी की आवश्यकता।',
        'mr': 'संपूर्ण पिकाच्या कालावधीत ६०० ते ८०० मिमी पाणी लागते.'
      },
      irrigationSchedule: {
        'en': 'Drip irrigation for 1 to 2 hours daily or every alternate day based on soil moisture.',
        'hi': 'ड्रिप द्वारा रोजाना या एक दिन छोड़कर 1-2 घंटे सिंचाई करें।',
        'mr': 'ठिबक सिंचनाने जमिनीच्या मगदुरानुसार दररोज किंवा दिवसाआड १ ते २ तास पाणी द्यावे.'
      },
      criticalStages: {
        'en': '1. Seedling establishment (0-15 days), 2. Flowering & fruit set (35-50 days), 3. Fruit development (60-90 days).',
        'hi': '1. पौध रोपाई, 2. फूल व फल बनना, 3. फल विकास।',
        'mr': '१. पुनर्लागवड, २. फुलधारणा व फळधारणा, ३. फळे भरणे.'
      },
      waterSavingMethods: {
        'en': 'Drip fertigation + 25-micron silver-black plastic mulch saves 45% water and reduces weed growth.',
        'hi': 'ड्रिप सिंचाई और प्लास्टिक मल्चिंग से 45% पानी बचता है।',
        'mr': 'ठिबक सिंचन आणि सिल्व्हर-ब्लॅक मल्चिंग पेपरमुळे ४५% पाण्याची बचत होते व तण होत नाही.'
      },
      stageGermination: {
        'en': 'Days 1–6: Seeds germinate in seedling trays with cocopeat.',
        'hi': 'दिन 1-6: कोकोपीट ट्रे में बीज अंकुरण।',
        'mr': 'दिवस १ ते ६: प्रोट्रेमधील कोकोपीठमध्ये बियाणे अंकुरण.'
      },
      stageSeedling: {
        'en': 'Days 7–25: True leaves develop; seedlings hardened before transplanting.',
        'hi': 'दिन 7-25: पत्तियां निकलना व पौध का विकास।',
        'mr': 'दिवस ७ ते २५: खरी पाने फुटून रोपे पुनर्लागवडीस तयार होतात.'
      },
      stageVegetative: {
        'en': 'Days 26–50: Rapid branch and foliage growth; bamboo staking and tying.',
        'hi': 'दिन 26-50: तने व शाखाओं का फैलाव; बांस से सहारा दें।',
        'mr': 'दिवस २६ ते ५०: झाडाची जोमदार वाढ; बांबू-तारेवर बांधणी (स्टेकिंग).'
      },
      stageFlowering: {
        'en': 'Days 50–70: Yellow flower clusters appear; pollination by wind and bees.',
        'hi': 'दिन 50-70: पीले फूलों के गुच्छे व परागण।',
        'mr': 'दिवस ५० ते ७०: पिवळ्या फुलांचे घोस लागणे व परागीभवन.'
      },
      stageMaturity: {
        'en': 'Days 70–90: Green fruit enlargement, turning breaker stage (pink/red).',
        'hi': 'दिन 70-90: फलों का आकार बढ़ना व लाल होना।',
        'mr': 'दिवस ७० ते ९०: फळे मोठी होणे व पक्व होऊन लाल रंग येणे.'
      },
      stageHarvesting: {
        'en': 'Days 75–120: Harvest firm ripe red tomatoes in 8 to 12 pickings every 3–4 days.',
        'hi': 'दिन 75-120: 8-12 तुड़ाई हर 3-4 दिन में करें।',
        'mr': 'दिवस ७५ ते १२०: दर ३-४ दिवसांनी लाल टणक फळांची ८ ते १२ तोडणी करावी.'
      },
    ),

    // --- 2. WHEAT ---
    CropDetailedInfo(
      id: 'wheat',
      emoji: '🌾',
      category: 'cereals',
      seasonType: 'rabi',
      isPopular: true,
      name: {'en': 'Wheat', 'hi': 'गेहूं', 'mr': 'गहू'},
      intro: {
        'en': 'The premier staple cereal crop of India, providing high energy, gluten proteins, and essential vitamins.',
        'hi': 'भारत की प्रमुख रबी खाद्यान्न फसल, ऊर्जा और प्रोटीन का मुख्य स्रोत।',
        'mr': 'भारतातील प्रमुख रब्बी अन्नधान्य पीक, कार्बोहायड्रेट्स व प्रथिनांचा महत्त्वाचा स्रोत.'
      },
      cropTypeAndCategory: {
        'en': 'Cereal / Gramineae Grass Family',
        'hi': 'अनाज / ग्रेमिनी घास कुल',
        'mr': 'अन्नधान्य (तृणधान्य) / गवत कुल'
      },
      producingRegions: {
        'en': 'Uttar Pradesh, Punjab, Madhya Pradesh, Haryana, Maharashtra, Rajasthan.',
        'hi': 'उत्तर प्रदेश, पंजाब, मध्य प्रदेश, हरियाणा, महाराष्ट्र, राजस्थान।',
        'mr': 'पंजाब, उत्तर प्रदेश, मध्य प्रदेश, हरियाणा, महाराष्ट्र.'
      },
      suitableTemp: {
        'en': '15°C to 22°C during growth; 25°C at maturity. Cool nights promote heavy tillering.',
        'hi': '15°C से 22°C बढ़वार पर, 25°C पकने पर। ठंड में कल्ले अधिक फूटते हैं।',
        'mr': 'वाढीच्या काळात १५°C ते २२°C; पक्वतेवेळी २५°C. थंड हवेमुळे फुटवे जास्त फुटतात.'
      },
      rainfall: {
        'en': 'Requires 400–650 mm water or 5 to 6 scheduled canal/tubewell irrigations.',
        'hi': '400-650 मिमी या 5-6 समयबद्ध सिंचाई।',
        'mr': '४०० ते ६५० मिमी पाणी किंवा ५ ते ६ पाण्याच्या पाळ्या.'
      },
      humidity: {
        'en': 'Moderate humidity 50-60%. Cloudy humid weather in Jan–Feb invites yellow rust.',
        'hi': '50-60%। बादलों वाले मौसम में रतुआ रोग की संभावना।',
        'mr': '५०-६०%. ढगाळ हवामानात तांबेरा रोग पडण्याची शक्यता असते.'
      },
      growingSeason: {
        'en': 'Rabi winter crop (Sowing Nov 1 to Nov 20).',
        'hi': 'रबी शीतकालीन फसल (1 से 20 नवंबर बुवाई)।',
        'mr': 'रब्बी हिवाळी हंगाम (१ ते २० नोव्हेंबरदरम्यान पेरणी).'
      },
      suitableSoil: {
        'en': 'Well-drained fertile loam or medium-to-heavy black cotton soil.',
        'hi': 'उपजाऊ दोमट या मध्यम से भारी काली मिट्टी।',
        'mr': 'उत्तम निचऱ्याची मध्यम ते भारी काळी किंवा पोयटा जमीन.'
      },
      idealPh: {
        'en': 'pH 6.5 to 7.8',
        'hi': 'pH 6.5 से 7.8',
        'mr': 'सामू ६.५ ते ७.८'
      },
      soilPrep: {
        'en': 'One deep plowing after Kharif crop followed by 2 harrowings and planking to create fine seedbed.',
        'hi': 'गहरी जुताई के बाद 2 बार कल्टीवेटर और पाटा चलाएं।',
        'mr': '१ खोल नांगरट आणि २ कुळवाच्या पाळ्या देऊन ढेकळे फोडून जमीन सपाट करावी.'
      },
      sowingSeason: {
        'en': 'Timely sowing: Nov 1 to Nov 20; Late sowing: Nov 25 to Dec 15.',
        'hi': 'समय पर बुवाई: 1 से 20 नवंबर; देर से: 25 नवंबर से 15 दिसंबर।',
        'mr': 'वेळेवर पेरणी: १ ते २० नोव्हेंबर; उशिरा पेरणी: २५ नोव्हेंबर ते १५ डिसेंबर.'
      },
      seedVarieties: {
        'en': 'Lokwan, GW-496, HD-2967, Sharbati, Samadhan, NIAW-301 (Trimbak).',
        'hi': 'लोकवन, जीडब्ल्यू-496, एचडी-2967, शरबती, समाधान।',
        'mr': 'लोकवन, समाधान, जीडब्ल्यू-४९६, त्र्यंबक, गोदावरी.'
      },
      seedQuantityPerAcre: {
        'en': '40 to 45 kg/acre for timely sowing; 50 kg/acre for late sowing.',
        'hi': 'समय पर बुवाई: 40-45 किग्रा/एकड़; देर से: 50 किग्रा/एकड़।',
        'mr': 'वेळेवर पेरणीसाठी एकरी ४० ते ४५ किलो; उशिरा पेरणीसाठी ५० किलो.'
      },
      seedTreatment: {
        'en': 'Treat seed with Carboxin + Thiram @ 2g/kg or Trichoderma @ 5g/kg + Azotobacter biofertilizer.',
        'hi': 'थिरम (2g/kg) व एज़ोटोबैक्टर कल्चर से बीज उपचारित करें।',
        'mr': 'पेरणीपूर्वी थायरम २ ग्रॅम/किलो किंवा अॅझोटोबॅक्टर २५ ग्रॅम प्रति किलो बियाण्यास चोळावे.'
      },
      recommendedNutrients: {
        'en': 'NPK 120:60:40 kg/ha (Irrigated). Half N + Full P & K at sowing; remaining N at 21d and 45d.',
        'hi': '120:60:40 किग्रा NPK प्रति हेक्टेयर। आधा नत्र बुवाई पर, आधा 2 बार में।',
        'mr': 'हेक्टरी १२०:६०:४० किलो NPK. निम्मे नत्र व पूर्ण स्फुरद-पालाश पेरणीवेळी, उर्वरित नत्र २ हप्त्यांत.'
      },
      organicFertilizers: {
        'en': '5 to 6 tons FYM/acre incorporated during final plowing.',
        'hi': '5-6 टन सड़ी गोबर खाद अंतिम जुताई के समय मिलाएं।',
        'mr': 'एकरी ५ ते ६ टन चांगले कुजलेले शेणखत शेवटच्या कुळवणीवेळी मिसळावे.'
      },
      applicationStages: {
        'en': '1st split at CRI stage (21 days), 2nd split at jointing/booting stage (45 days) with irrigation.',
        'hi': 'पहली टॉप ड्रेसिंग 21 दिन पर (CRI), दूसरी 45 दिन पर।',
        'mr': 'पहिली मात्रा २१ दिवसांनी (मुकुटमुळे फुटताना), दुसरी मात्रा ४५ दिवसांनी (कांडी अवस्था).'
      },
      nutrientManagement: {
        'en': 'Spray 19:19:19 (5g/L) + Zinc Sulfate (2g/L) at tillering to enhance grain weight.',
        'hi': 'फुटान के समय 19:19:19 और जिंक सल्फेट का छिड़काव करें।',
        'mr': 'फुटवे वाढीसाठी १९:१९:१९ आणि झिंक सल्फेट २ ग्रॅम/लिटर फवारावे.'
      },
      waterRequirements: {
        'en': '350–500 mm water across 5 to 6 irrigations.',
        'hi': '350-500 मिमी कुल जल मांग।',
        'mr': 'एकूण ३५० ते ५०० मिमी पाणी लागते.'
      },
      irrigationSchedule: {
        'en': 'Water at intervals of 18–22 days depending on winter temperatures.',
        'hi': 'तापमान अनुसार 18-22 दिनों के अंतराल पर पानी दें।',
        'mr': 'हिवाळ्यातील थंडीनुसार १८ ते २२ दिवसांच्या अंतराने पाणी द्यावे.'
      },
      criticalStages: {
        'en': '1. Crown Root Initiation (21d - DO NOT SKIP), 2. Tillering (42d), 3. Jointing (65d), 4. Flowering (80d), 5. Milking (95d), 6. Dough (110d).',
        'hi': '1. मुकुट जड़ (21 दिन - सबसे जरूरी), 2. कल्ले फूटना, 3. गांठे बनना, 4. फूल, 5. दूधिया दाना।',
        'mr': '१. मुकुट मुळे फुटणे (२१ दिवस - सर्वात महत्त्वाचे), २. फुटवे, ३. कांडी, ४. फुलोरा, ५. दाण्यांत दूध भरणे.'
      },
      waterSavingMethods: {
        'en': 'Sprinkler irrigation saves 35% water and prevents lodging on uneven terrain.',
        'hi': 'तुषार (स्प्रिंकलर) सिंचाई से 35% पानी की बचत होती है।',
        'mr': 'तुषार सिंचनाचा वापर केल्यास ३५% पाण्याची बचत होते आणि गहू लोळत नाही.'
      },
      stageGermination: {
        'en': 'Days 1–7: Coleoptile emerges from soil.',
        'hi': 'दिन 1-7: बीज से अंकुरण।',
        'mr': 'दिवस १ ते ७: जमिनीतून अंकुर बाहेर पडणे.'
      },
      stageSeedling: {
        'en': 'Days 8–20: 3–4 leaves develop; seminal roots establish.',
        'hi': 'दिन 8-20: 3-4 पत्तियों का विकास।',
        'mr': 'दिवस ८ ते २०: ३-४ पाने येणे व मुळे रुजणे.'
      },
      stageVegetative: {
        'en': 'Days 21–55: Crown root initiation and vigorous tillering.',
        'hi': 'दिन 21-55: कल्ले फूटना व तनों का विकास।',
        'mr': 'दिवस २१ ते ५५: मुकुटमुळे व भरपूर फुटवे फुटणे.'
      },
      stageFlowering: {
        'en': 'Days 65–85: Earhead emergence (heading) and anthesis/flowering.',
        'hi': 'दिन 65-85: बालियां निकलना व फूल आना।',
        'mr': 'दिवस ६५ ते ८५: ओंब्या बाहेर पडणे व परागीभवन.'
      },
      stageMaturity: {
        'en': 'Days 85–110: Milk stage, soft dough stage, and hard dough grain filling.',
        'hi': 'दिन 85-110: दानों में दूध व स्टार्च भरना।',
        'mr': 'दिवस ८५ ते ११०: दाण्यांमध्ये दूध व नंतर टणकपणा भरणे.'
      },
      stageHarvesting: {
        'en': 'Days 110–125: Golden yellow dry ears, grain moisture < 12%. Combine harvest.',
        'hi': 'दिन 110-125: सुनहरी बालियां सूखने पर कंबाइन से कटाई।',
        'mr': 'दिवस ११० ते १२५: ओंब्या सोनेरी पिवळ्या झाल्यावर मळणी यंत्राने काढणी.'
      },
    ),

    // --- 3. LADYFINGER (OKRA) ---
    CropDetailedInfo(
      id: 'ladyfinger',
      emoji: '🥬',
      category: 'vegetables',
      seasonType: 'zaid',
      isPopular: true,
      name: {'en': 'Ladyfinger (Okra / Bhindi)', 'hi': 'भिंडी (ओकरा)', 'mr': 'भेंडी'},
      intro: {
        'en': 'Popular warm-season vegetable packed with dietary fiber, folate, Vitamin K, and mucilage aiding digestion.',
        'hi': 'लोकप्रिय पौष्टिक हरी सब्जी, फाइबर और विटामिन्स से भरपूर, बाजार में नियमित मांग।',
        'mr': 'नियमित मागणी असणारी लोकप्रिय फळभाजी, फायबर व पोषक घटकांनी परिपूर्ण.'
      },
      cropTypeAndCategory: {
        'en': 'Vegetable / Malvaceae Mallow Family',
        'hi': 'सब्जी / मालवेसी कुल',
        'mr': 'भाजीपाला / मालवेसी कुल'
      },
      producingRegions: {
        'en': 'Gujarat, Maharashtra, Andhra Pradesh, West Bengal, Bihar, Uttar Pradesh.',
        'hi': 'गुजरात, महाराष्ट्र, आंध्र प्रदेश, पश्चिम बंगाल, बिहार।',
        'mr': 'महाराष्ट्र, गुजरात, आंध्र प्रदेश, पश्चिम बंगाल.'
      },
      suitableTemp: {
        'en': '24°C to 35°C (Warm tropical). Seeds fail to germinate below 17°C.',
        'hi': '24°C से 35°C। 17°C से कम पर अंकुरण नहीं होता।',
        'mr': '२४°C ते ३५°C (उष्ण हवामान). १७°C पेक्षा कमी तापमानात बियाणे उगवत नाही.'
      },
      rainfall: {
        'en': '600–900 mm. Well adapted to summer with assured irrigation.',
        'hi': '600-900 मिमी। सिंचाई उपलब्ध होने पर गर्मी में बेहतरीन।',
        'mr': '६०० ते ९०० मिमी. उन्हाळी हंगामात सिंचनाची सोय असल्यास उत्तम उत्पादन.'
      },
      humidity: {
        'en': '60% to 75%. Humid overcast monsoon promotes yellow vein mosaic virus.',
        'hi': '60% से 75%। अधिक नमी में सफेद मक्खी का प्रकोप बढ़ता है।',
        'mr': '६० ते ७५%. पावसाळ्यात पिवळा शिरा रोग पसरवणाऱ्या पांढऱ्या माशीचा धोका.'
      },
      growingSeason: {
        'en': 'Kharif (June–July) and Summer (Feb–March).',
        'hi': 'खरीफ (जून-जुलाई) और जायद (फरवरी-मार्च)।',
        'mr': 'खरीप (जून-जुलै) आणि उन्हाळी (फेब्रुवारी-मार्च).'
      },
      suitableSoil: {
        'en': 'Sandy loam to fertile medium black soil with good drainage and high organic carbon.',
        'hi': 'बलुई दोमट से मध्यम काली उपजाऊ मिट्टी।',
        'mr': 'मध्यम काळी, पोयट्याची सुपीक आणि पाण्याचा उत्तम निचरा असणारी जमीन.'
      },
      idealPh: {
        'en': 'pH 6.0 to 7.5',
        'hi': 'pH 6.0 से 7.5',
        'mr': 'सामू ६.० ते ७.५'
      },
      soilPrep: {
        'en': 'Plow field twice, apply FYM, and prepare ridges and furrows or raised beds with drip.',
        'hi': 'दो बार जुताई कर गोबर खाद मिलाएं, मेड़ें बनाएं।',
        'mr': '२ वेळा नांगरट करून शेणखत मिसळावे, वरंबे किंवा गादीवाफे तयार करावेत.'
      },
      sowingSeason: {
        'en': 'Summer crop: Feb 15 to March 15; Kharif crop: June 15 to July 15.',
        'hi': 'गर्मी: 15 फरवरी से 15 मार्च; खरीफ: 15 जून से 15 जुलाई।',
        'mr': 'उन्हाळी: १५ फेब्रुवारी ते १५ मार्च; खरीप: १५ जून ते १५ जुलै.'
      },
      seedVarieties: {
        'en': 'Radhika, Parbhani Kranti, Arka Anamika, Mahyco-10, Singham, Pusa Sawani.',
        'hi': 'राधिका, परभणी क्रांति, अर्का अनामिका, सिंघम, महिको-10।',
        'mr': 'राधिका, परभणी क्रांती, अर्का अनामिका, सिंघम, पुसा सावनी.'
      },
      seedQuantityPerAcre: {
        'en': 'Kharif: 3.5 to 4 kg/acre; Summer: 5 kg/acre (closer spacing).',
        'hi': 'खरीफ: 3.5-4 किग्रा/एकड़; जायद (गर्मी): 5 किग्रा/एकड़।',
        'mr': 'खरीप: ३.५ ते ४ किलो/एकर; उन्हाळी: ५ किलो/एकर.'
      },
      seedTreatment: {
        'en': 'Soak seeds in water for 12 hours for summer sowing. Treat with Imidacloprid @ 3g/kg + Trichoderma @ 5g/kg.',
        'hi': 'गर्मियों में बीज 12 घंटे भिगोएं। इमिडाक्लोप्रिड व ट्राइकोडर्मा से उपचार करें।',
        'mr': 'उन्हाळ्यात टोकणीपूर्वी बियाणे १२ तास पाण्यात भिजवावे. ट्रायकोडर्मा ५ ग्रॅम/किलो चोळावे.'
      },
      recommendedNutrients: {
        'en': 'NPK 100:50:50 kg/ha. Apply 50% N + full P and K at sowing; remaining N in two splits at 30 & 45 days.',
        'hi': '100:50:50 NPK प्रति हेक्टेयर। 30 और 45 दिन पर यूरिया दें।',
        'mr': 'हेक्टरी १००:५०:५० किलो NPK. निम्मे नत्र व पूर्ण स्फुरद-पालाश पेरणीवेळी, तर उर्वरित नत्र ३० व ४५ दिवसांनी द्यावे.'
      },
      organicFertilizers: {
        'en': '8 tons FYM/acre + 150 kg Neem cake to deter root-knot nematodes.',
        'hi': '8 टन गोबर खाद + 150 किग्रा नीम खली (सूत्रकृमि से बचाव)।',
        'mr': '८ टन शेणखत + १५० किलो निंबोळी पेंड (सूत्रकृमींचा प्रादुर्भाव रोखण्यासाठी).'
      },
      applicationStages: {
        'en': 'Top dress Urea at 30 days and 45 days. Spray 19:19:19 (3g/L) during active picking.',
        'hi': '30 व 45 दिन पर यूरिया डालें, फल तोड़ाई पर 19:19:19 छिड़कें।',
        'mr': '३० व ४५ दिवसांनी युरिया द्यावा. तोडणी सुरू असताना १९:१९:१९ ची फवारणी करावी.'
      },
      nutrientManagement: {
        'en': 'Foliar spray of Micronutrient mixture (Zinc, Iron, Boron @ 2g/L) keeps leaves green.',
        'hi': 'सूक्ष्म पोषक तत्व मिश्रण (2g/L) का छिड़काव पत्तियों को हरा रखता है।',
        'mr': 'सूक्ष्मअन्नद्रव्ये (झिंक, बोरॉन) २ ग्रॅम/लिटर फवारल्याने पाने हिरवीगार राहतात.'
      },
      waterRequirements: {
        'en': '400–600 mm. Requires frequent light irrigations in summer.',
        'hi': '400-600 मिमी। गर्मियों में हर 4-5 दिन में पानी जरूरी।',
        'mr': '४०० ते ६०० मिमी. उन्हाळ्यात दर ४-५ दिवसांनी हलके पाणी द्यावे.'
      },
      irrigationSchedule: {
        'en': 'Summer: Every 4–5 days; Kharif: Every 8–10 days depending on rain.',
        'hi': 'गर्मी में 4-5 दिन, खरीफ में बारिश अनुसार 8-10 दिन पर।',
        'mr': 'उन्हाळ्यात दर ४-५ दिवसांनी; पावसाळ्यात गरजेनुसार.'
      },
      criticalStages: {
        'en': '1. Seed germination, 2. Flowering initiation (35d), 3. Continuous pod development.',
        'hi': '1. अंकुरण, 2. फूल आना, 3. फल विकास।',
        'mr': '१. उगवण, २. फुलधारणा (३५ दिवस), ३. नियमित शेंगांची वाढ.'
      },
      waterSavingMethods: {
        'en': 'Drip irrigation with inline drippers saves 50% water and keeps walking alleys dry for picking.',
        'hi': 'ड्रिप सिंचाई से 50% पानी बचता है और तुड़ाई में आसानी होती है।',
        'mr': 'ठिबक सिंचनाने ५०% पाण्याची बचत होते व तोडणीसाठी फिरणे सोपे जाते.'
      },
      stageGermination: {
        'en': 'Days 1–5: Direct seeded sprout appears.',
        'hi': 'दिन 1-5: बीज अंकुरण।',
        'mr': 'दिवस १ ते ५: बियाणे टोकणीनंतर अंकुरण.'
      },
      stageSeedling: {
        'en': 'Days 6–20: 3–5 broad leaves; first weeding and earthing up.',
        'hi': 'दिन 6-20: पत्तियां आना व पहली निराई।',
        'mr': 'दिवस ६ ते २०: ३ ते ५ पाने व पहिली खुरपणी.'
      },
      stageVegetative: {
        'en': 'Days 21–38: Bushy plant frame develops with strong side branches.',
        'hi': 'दिन 21-38: पौधे का फैलाव।',
        'mr': 'दिवस २१ ते ३८: झाडाचा घेर वाढणे व फांद्या फुटणे.'
      },
      stageFlowering: {
        'en': 'Days 38–48: Large yellow hibiscus-like flowers bloom at leaf nodes.',
        'hi': 'दिन 38-48: पीले फूल खिलना।',
        'mr': 'दिवस ३८ ते ४८: पानाच्या बेचक्यात पिवळी फुले उमलणे.'
      },
      stageMaturity: {
        'en': 'Days 45–55: Tender green pods mature in 5–6 days after flower opening.',
        'hi': 'दिन 45-55: फूल खिलने के 5 दिन बाद कोमल फल तैयार।',
        'mr': 'दिवस ४५ ते ५५: फूल उमलल्यानंतर ५ दिवसांत कोवळी भेंडी तयार.'
      },
      stageHarvesting: {
        'en': 'Days 50–100: Pick tender 3–4 inch pods every alternate day in morning/evening.',
        'hi': 'दिन 50-100: हर दूसरे दिन सुबह-शाम नरम फल तोड़ें।',
        'mr': 'दिवस ५० ते १००: दर दोन दिवसांनी सकाळी किंवा संध्याकाळी कोवळ्या भेंडीची तोडणी करावी.'
      },
    ),

    // --- 4. CHILI ---
    CropDetailedInfo(
      id: 'chili',
      emoji: '🌶️',
      category: 'vegetables',
      seasonType: 'kharif',
      isPopular: true,
      name: {'en': 'Chili (Green & Dry)', 'hi': 'हरी व लाल मिर्च', 'mr': 'मिरची'},
      intro: {
        'en': 'Major commercial spice and vegetable crop providing pungency (capsaicin), natural color, and Vitamin C.',
        'hi': 'प्रमुख नकदी मसाला व सब्जी फसल, तीखेपन (कैप्साइसिन) और विटामिन सी से भरपूर।',
        'mr': 'अतिशय महत्त्वाची व्यावसायिक फळभाजी व मसाला पीक, तिखटपणा व जीवनसत्त्वांनी समृद्ध.'
      },
      cropTypeAndCategory: {
        'en': 'Spice & Vegetable / Solanaceae',
        'hi': 'मसाला व सब्जी / सोलेनेसी',
        'mr': 'भाजीपाला व मसाला पीक / सोलेनेसी कुल'
      },
      producingRegions: {
        'en': 'Andhra Pradesh (Guntur), Telangana, Maharashtra, Karnataka, Madhya Pradesh.',
        'hi': 'आंध्र प्रदेश (गुंटूर), तेलंगाना, महाराष्ट्र, कर्नाटक, मध्य प्रदेश।',
        'mr': 'महाराष्ट्र (नंदुरबार, नांदेड, नागपूर), आंध्र प्रदेश (गुंटूर), कर्नाटक.'
      },
      suitableTemp: {
        'en': '20°C to 30°C. Temperature above 35°C during flowering causes flower and bud drop.',
        'hi': '20°C से 30°C। 35°C से अधिक पर फूल झड़ जाते हैं।',
        'mr': '२०°C ते ३०°C. ३५°C पेक्षा जास्त उष्णतेमध्ये फुलगळ होते.'
      },
      rainfall: {
        'en': '600–1250 mm. Susceptible to water stagnation (causes wilt).',
        'hi': '600-1250 मिमी। जलभराव से उकठा (मुरझान) रोग होता है।',
        'mr': '६०० ते १२५० मिमी. पाणी साचल्यास मर रोग होतो.'
      },
      humidity: {
        'en': '60% to 70%. High humidity triggers Anthracnose fruit rot.',
        'hi': '60% से 70%। अधिक नमी में फल सड़न की समस्या आती है।',
        'mr': '६०% ते ७०%. दमट हवेत फळकुज व करपा रोगाचा प्रादुर्भाव वाढतो.'
      },
      growingSeason: {
        'en': 'Kharif, Rabi, and Summer (Year-round with drip).',
        'hi': 'खरीफ, रबी और जायद (वर्षभर)।',
        'mr': 'खरीप, रब्बी आणि उन्हाळी (वर्षभर लागवड शक्य).'
      },
      suitableSoil: {
        'en': 'Well-drained light-to-medium loamy or black soil with good humus.',
        'hi': 'जल निकासी युक्त दोमट या मध्यम काली उपजाऊ मिट्टी।',
        'mr': 'उत्तम निचऱ्याची मध्यम काळी किंवा तांबडी पोयटा जमीन.'
      },
      idealPh: {
        'en': 'pH 6.5 to 7.8',
        'hi': 'pH 6.5 से 7.8',
        'mr': 'सामू ६.५ ते ७.८'
      },
      soilPrep: {
        'en': 'Fine tilth prepared with 2 harrowings. Raised beds (width 3 ft) with silver-black mulch.',
        'hi': 'गहरी जुताई के बाद मेड़ें व ड्रिप मल्चिंग लगाएं।',
        'mr': 'गादीवाफे (३ फूट रुंद) तयार करून ठिबक नळ्या व मल्चिंग पेपर टाकावा.'
      },
      sowingSeason: {
        'en': 'Transplant 35-40 day old seedlings: Kharif (June-July), Rabi (Sept-Oct), Summer (Jan-Feb).',
        'hi': '35-40 दिन की पौध रोपें: खरीफ (जून-जुलाई), रबी (सितंबर-अक्टूबर)।',
        'mr': '३५-४० दिवसांची रोपे लावावीत: खरीप (जून-जुलै), रब्बी (सप्टे-ऑक्टो), उन्हाळी (जाने-फेब्रु).'
      },
      seedVarieties: {
        'en': 'Sitara, Teja-4, G-4, Phule Jyoti, US-341, Agnirekha, Pusa Jwala.',
        'hi': 'सितारा, तेजा-4, जी-4, फुले ज्योती, पूसा ज्वाला, यूएस-341।',
        'mr': 'सितारा, तेजा-४, फुले ज्योती, अग्निरेखा, पुसा ज्वाला, युएस-३४१.'
      },
      seedQuantityPerAcre: {
        'en': '80 to 100 grams hybrid seed per acre (approx 7,000 seedlings).',
        'hi': '80 से 100 ग्राम संकर बीज प्रति एकड़।',
        'mr': '८० ते १०० ग्रॅम संकरित बियाणे प्रति एकर.'
      },
      seedTreatment: {
        'en': 'Treat seed with Thiram @ 2.5g/kg and seedlings dip in Imidacloprid (0.5ml/L) + Carbendazim (1g/L).',
        'hi': 'रोपाई से पूर्व पौध को कीटनाशक व फफूंदनाशक घोल में डुबोएं।',
        'mr': 'पुनर्लागवडीपूर्वी रोपांची मुळे इमिडाक्लोप्रिड ०.५ मिली + कार्बेन्डाझिम १ ग्रॅम/लिटर द्रावणात बुडवावीत.'
      },
      recommendedNutrients: {
        'en': 'NPK 100:50:50 kg/acre + Sulphur (10 kg) and Micronutrients.',
        'hi': '100:50:50 NPK प्रति एकड़ + सल्फर व सूक्ष्म पोषक।',
        'mr': 'एकरी १००:५०:५० किलो NPK + सल्फर १० किलो आणि सूक्ष्मअन्नद्रव्ये.'
      },
      organicFertilizers: {
        'en': '8–10 tons FYM + 250 kg Neem cake to control soil grubs and nematodes.',
        'hi': '8-10 टन गोबर खाद + 250 किग्रा नीम खली।',
        'mr': '८-१० टन शेणखत + २५० किलो निंबोळी पेंड.'
      },
      applicationStages: {
        'en': 'Basal: 25% N, full P, 50% K. Fertigate 19:19:19 in growth, 12:61:0 at flowering, 0:52:34 at fruiting.',
        'hi': 'बढ़वार पर 19:19:19, फूल पर 12:61:0 और फल पर 0:52:34 दें।',
        'mr': 'वाढीसाठी १९:१९:१९, फुलोऱ्यात १२:६१:० आणि फळधारणेत ०:५२:३४ व ०:०:५० द्यावे.'
      },
      nutrientManagement: {
        'en': 'Spray Planofix (0.25ml/4.5L water) at flowering to prevent massive flower drop.',
        'hi': 'फूल झड़ने से रोकने के लिए प्लानोफिक्स का हल्का छिड़काव करें।',
        'mr': 'फुलगळ रोखण्यासाठी प्लॅनोफिक्स ०.२५ मिली प्रति ४.५ लिटर पाण्यात फवारावे.'
      },
      waterRequirements: {
        'en': '500–700 mm. Avoid water stress during flowering.',
        'hi': '500-700 मिमी। फूल आते समय पानी की कमी न होने दें।',
        'mr': '५०० ते ७०० मिमी. फुलधारणेच्या वेळी पाण्याचा ताण पडू देऊ नये.'
      },
      irrigationSchedule: {
        'en': 'Drip irrigation every 2–3 days for 1.5 hours.',
        'hi': 'ड्रिप से हर 2-3 दिन में 1.5 घंटे सिंचाई करें।',
        'mr': 'ठिबक सिंचनाने दर २-३ दिवसांनी १.५ तास पाणी द्यावे.'
      },
      criticalStages: {
        'en': '1. Seedling establishment (10-15d), 2. Flowering & fruit setting (45-65d), 3. Multiple fruit pickings.',
        'hi': '1. रोपाई, 2. फूल व फल बनना, 3. तुड़ाई का समय।',
        'mr': '१. पुनर्लागवड, २. फुलधारणा व फळधारणा, ३. नियमित तोडणीचा काळ.'
      },
      waterSavingMethods: {
        'en': 'Paired row planting (4.5 x 2.5 x 1.5 ft) on drip with mulching saves 50% water.',
        'hi': 'जोड़-कतार ड्रिप और मल्चिंग से 50% जल बचत।',
        'mr': 'जोडओळ पद्धत (४.५ x २.५ x १.५ फूट) ठिबक व मल्चिंगने ५०% पाण्याची बचत होते.'
      },
      stageGermination: {
        'en': 'Days 1–8: Pro-tray germination in nursery.',
        'hi': 'दिन 1-8: ट्रे में अंकुरण।',
        'mr': 'दिवस १ ते ८: प्रोट्रेमध्ये बियाणे अंकुरण.'
      },
      stageSeedling: {
        'en': 'Days 9–35: Seedling growth with 4–6 leaves ready for transplant.',
        'hi': 'दिन 9-35: पौध तैयार होना।',
        'mr': 'दिवस ९ ते ३५: रोपांची वाढ व पुनर्लागवडीस सज्ज.'
      },
      stageVegetative: {
        'en': 'Days 36–60: Rapid branching and canopy development.',
        'hi': 'दिन 36-60: शाखाओं का विकास।',
        'mr': 'दिवस ३६ ते ६०: झाडाला फुटवे फुटणे व विस्तार होणे.'
      },
      stageFlowering: {
        'en': 'Days 60–80: Abundant white star-shaped flowers appear.',
        'hi': 'दिन 60-80: सफेद फूलों का गुच्छा।',
        'mr': 'दिवस ६० ते ८०: पांढऱ्या फुलांचे घोस लागणे.'
      },
      stageMaturity: {
        'en': 'Days 75–100: Fruit attains full green size; red chillies ripen on plant in 120 days.',
        'hi': 'दिन 75-100: हरी मिर्च का विकास; 120 दिन में लाल पकना।',
        'mr': 'दिवस ७५ ते १००: हिरवी मिरची पक्व होणे; १२० दिवसांत लाल मिरची तयार.'
      },
      stageHarvesting: {
        'en': 'Days 70–180: Green chilies picked every 10–12 days; red chilies harvested in 2–3 pickings.',
        'hi': 'दिन 70-180: हरी मिर्च हर 10-12 दिन में तोड़ें।',
        'mr': 'दिवस ७० ते १८०: हिरव्या मिरचीची दर १०-१२ दिवसांनी तोडणी; लाल मिरची २-३ वेचण्या.'
      },
    ),

    // --- 5. BROCCOLI ---
    CropDetailedInfo(
      id: 'broccoli',
      emoji: '🥦',
      category: 'vegetables',
      seasonType: 'rabi',
      isPopular: false,
      name: {'en': 'Broccoli', 'hi': 'ब्रोकोली', 'mr': 'ब्रोकोली'},
      intro: {
        'en': 'Exotic cruciferous vegetable with high commercial value in urban markets, rich in Vitamin C, K, sulforaphane, and dietary fiber.',
        'hi': 'उच्च बाजार मूल्य वाली विदेशी पौष्टिक सब्जी, कैंसर रोधी सल्फोराफेन व विटामिन्स से भरपूर।',
        'mr': 'शहरी बाजारपेठेत उत्तम दर मिळणारी विदेशी भाजी, व्हिटॅमिन सी, के आणि सल्फोराफेनने समृद्ध.'
      },
      cropTypeAndCategory: {
        'en': 'Exotic Cole Crop / Brassicaceae Family',
        'hi': 'कोल क्रॉप / ब्रैसिका कुल',
        'mr': 'विदेशी भाजीपाला / ब्रासिका कुल'
      },
      producingRegions: {
        'en': 'Maharashtra (Pune, Nashik, Satara), Himachal Pradesh, Uttarakhand, Karnataka (Ooty, Belgaum).',
        'hi': 'महाराष्ट्र (पुणे, नाशिक), हिमाचल, उत्तराखंड, कर्नाटक।',
        'mr': 'महाराष्ट्र (पुणे, नाशिक, सातारा), हिमाचल प्रदेश, कर्नाटक.'
      },
      suitableTemp: {
        'en': '15°C to 22°C (Cool climate). Temperature above 25°C causes loose yellow heads and premature bolting.',
        'hi': '15°C से 22°C (ठंडा मौसम)। 25°C से अधिक पर फूल ढीले पड़ जाते हैं।',
        'mr': '१५°C ते २२°C (थंड हवामान). २५°C पेक्षा जास्त तापमानात गड्डा सैल पडतो.'
      },
      rainfall: {
        'en': '400–600 mm in winter season. Avoid overhead sprinkler after head formation.',
        'hi': '400-600 मिमी। हेड बनने के बाद ऊपर से पानी न डालें।',
        'mr': '४०० ते ६०० मिमी. गड्डा तयार झाल्यानंतर वरून पाणी फवारू नये.'
      },
      humidity: {
        'en': '60% to 75% relative humidity.',
        'hi': '60% से 75%।',
        'mr': '६०% ते ७५% आर्द्रता.'
      },
      growingSeason: {
        'en': 'Rabi winter season (Transplanting Sept to Nov).',
        'hi': 'रबी शीतकालीन मौसम (सितंबर से नवंबर रोपाई)।',
        'mr': 'रब्बी हिवाळी हंगाम (सप्टेंबर ते नोव्हेंबर लागवड).'
      },
      suitableSoil: {
        'en': 'Rich sandy loam to fertile medium loam with high organic carbon and excellent drainage.',
        'hi': 'जैविक कार्बन युक्त उपजाऊ दोमट मिट्टी।',
        'mr': 'भरपूर सेंद्रिय कर्ब असणारी पोयट्याची सुपीक आणि पाण्याचा उत्तम निचरा असणारी जमीन.'
      },
      idealPh: {
        'en': 'pH 6.0 to 6.8',
        'hi': 'pH 6.0 से 6.8',
        'mr': 'सामू ६.० ते ६.८'
      },
      soilPrep: {
        'en': 'Deep plowing with 10 tons FYM/acre. Raised beds (width 3 ft, height 1 ft) with drip lines.',
        'hi': '10 टन गोबर खाद मिलाएं, 3 फीट चौड़ी उठी क्यारियां बनाएं।',
        'mr': 'एकरी १० टन शेणखत मिसळून ३ फूट रुंद गादीवाफे तयार करावेत.'
      },
      sowingSeason: {
        'en': 'Nursery in Sept–Oct; transplanting in Oct–Nov.',
        'hi': 'नर्सरी सितंबर-अक्टूबर; रोपाई अक्टूबर-नवंबर।',
        'mr': 'रोपवाटिका सप्टे-ऑक्टोबर; पुनर्लागवड ऑक्टो-नोव्हेंबर.'
      },
      seedVarieties: {
        'en': 'Green Magic, Lucky, KTS-1, Fiesta, Pusa KTS-1, Sakata Marathon.',
        'hi': 'ग्रीन मैजिक, लकी, पुसा केटीएस-1, साकाटा मैराथन।',
        'mr': 'ग्रीन मॅजिक, लकी, पुसा केटीएस-१, साकाटा मॅरेथॉन.'
      },
      seedQuantityPerAcre: {
        'en': '100 to 120 grams seed per acre (approx 18,000 plants at 45x45 cm).',
        'hi': '100 से 120 ग्राम बीज प्रति एकड़।',
        'mr': '१०० ते १२० ग्रॅम बियाणे प्रति एकर.'
      },
      seedTreatment: {
        'en': 'Treat seed with Captan @ 2g/kg to prevent damping off in nursery trays.',
        'hi': 'कैप्टन (2g/kg) से बीजोपचार करें।',
        'mr': 'प्रोट्रेमध्ये मर रोग टाळण्यासाठी कॅप्टन २ ग्रॅम/किलो बियाण्यास चोळावे.'
      },
      recommendedNutrients: {
        'en': 'Heavy feeder: NPK 120:60:60 kg/acre + Boron and Molybdenum.',
        'hi': '120:60:60 NPK प्रति एकड़ + बोरॉन व मॉलिब्डेनम।',
        'mr': 'एकरी १२०:६०:६० किलो NPK + बोरॉन आणि मॉलिब्डेनम.'
      },
      organicFertilizers: {
        'en': '10 tons FYM + 2 tons Vermicompost + 200 kg Neem cake.',
        'hi': '10 टन गोबर खाद + 2 टन वर्मीकम्पोस्ट।',
        'mr': '१० टन शेणखत + २ टन गांडूळ खत + २०० किलो निंबोळी पेंड.'
      },
      applicationStages: {
        'en': 'Basal: 40% N, full P, 50% K; Top dress N at 25 days and 45 days. Spray Boron (2g/L) at 35 days.',
        'hi': '25 और 45 दिन पर यूरिया दें; 35 दिन पर बोरॉन का छिड़काव करें।',
        'mr': '२५ व ४५ दिवसांनी नत्र द्यावे; ३५ व्या दिवशी बोरॉन २ ग्रॅम/लिटर फवारावे.'
      },
      nutrientManagement: {
        'en': 'Boron deficiency causes hollow stem (Brown core). Spray Solubor @ 2g/L preventively.',
        'hi': 'बोरॉन की कमी से तना खोखला होता है, 2g/L बोरॉन अवश्य छिड़कें।',
        'mr': 'बोरॉनच्या कमतरतेमुळे खोड पोकळ पडते, म्हणून बोरॉन २ ग्रॅम/लिटर फवारावे.'
      },
      waterRequirements: {
        'en': '400–500 mm. Requires uniform soil moisture throughout head development.',
        'hi': '400-500 मिमी। हेड बनते समय नमी जरूरी।',
        'mr': '४०० ते ५०० मिमी. गड्डा भरताना जमिनीत कायम ओलावा असावा.'
      },
      irrigationSchedule: {
        'en': 'Drip irrigation for 1 hour every 2–3 days.',
        'hi': 'ड्रिप से हर 2-3 दिन में 1 घंटा पानी दें।',
        'mr': 'ठिबक सिंचनाने दर २-३ दिवसांनी १ तास पाणी द्यावे.'
      },
      criticalStages: {
        'en': '1. Seedling establishment (0-10d), 2. Head button formation (40d), 3. Rapid head expansion (55-70d).',
        'hi': '1. रोपाई, 2. हेड बनना, 3. हेड का फैलाव।',
        'mr': '१. पुनर्लागवड, २. गड्डा तयार होणे, ३. गड्ड्याचा विस्तार.'
      },
      waterSavingMethods: {
        'en': 'Inline drip with silver-black mulch suppresses weeds and keeps heads clean of soil splashes.',
        'hi': 'ड्रिप व मल्चिंग से 40% पानी बचता है और फल साफ रहता है।',
        'mr': 'ठिबक व मल्चिंगमुळे मातीचे डाग गड्ड्यावर उडत नाहीत व ४०% पाण्याची बचत होते.'
      },
      stageGermination: {
        'en': 'Days 1–4: Rapid germination in seedling trays.',
        'hi': 'दिन 1-4: ट्रे में अंकुरण।',
        'mr': 'दिवस १ ते ४: प्रोट्रेमध्ये जलद अंकुरण.'
      },
      stageSeedling: {
        'en': 'Days 5–25: Seedling growth with 4 true leaves ready to transplant.',
        'hi': 'दिन 5-25: 4 पत्तियों वाली स्वस्थ पौध।',
        'mr': 'दिवस ५ ते २५: ४ पानांची निरोगी रोपे पुनर्लागवडीस तयार.'
      },
      stageVegetative: {
        'en': 'Days 26–50: Broad waxy foliage canopy develops.',
        'hi': 'दिन 26-50: पत्तियों का फैलाव।',
        'mr': 'दिवस २६ ते ५०: मोठी पानांची जोमदार वाढ.'
      },
      stageFlowering: {
        'en': 'Days 50–65: Central tight green button/curd forms in leaf center.',
        'hi': 'दिन 50-65: केंद्र में ठोस हरा हेड बनना।',
        'mr': 'दिवस ५० ते ६५: मध्यभागी हिरवा घट्ट गड्डा तयार होणे.'
      },
      stageMaturity: {
        'en': 'Days 65–75: Central head reaches 350–600 grams weight.',
        'hi': 'दिन 65-75: हेड 400-600 ग्राम का होना।',
        'mr': 'दिवस ६५ ते ७५: गड्डा ४०० ते ६०० ग्रॅम वजनाचा होणे.'
      },
      stageHarvesting: {
        'en': 'Days 65–80: Harvest compact green head with 10 cm stalk before florets turn loose or yellow.',
        'hi': 'दिन 65-80: फूल खुलने से पहले ठोस हरा हेड 10 सेमी डंडी सहित काटें।',
        'mr': 'दिवस ६५ ते ८०: कळ्या पिवळ्या पडण्यापूर्वी घट्ट हिरवा गड्डा देठासह कापावा.'
      },
    ),

    // --- 6. APPLE ---
    CropDetailedInfo(
      id: 'apple',
      emoji: '🍎',
      category: 'fruits',
      seasonType: 'rabi',
      isPopular: false,
      name: {'en': 'Apple', 'hi': 'सेब', 'mr': 'सफरचंद'},
      intro: {
        'en': 'Premier temperate commercial fruit crop. Low-chill varieties (HRMN-99, Anna) now enable successful cultivation even in subtropical and plains regions.',
        'hi': 'प्रमुख शीतोष्ण फल। कम ठंड वाली नई किस्मों (HRMN-99) से अब मैदानी क्षेत्रों में भी सफल खेती संभव।',
        'mr': 'प्रमुख फळपीक. कमी थंडी लागणाऱ्या आधुनिक वाणांमुळे (HRMN-99, अण्णा) आता महाराष्ट्रातही यशस्वी लागवड शक्य.'
      },
      cropTypeAndCategory: {
        'en': 'Fruit / Rosaceae Rose Family Deciduous Tree',
        'hi': 'फल / रोज़ेसी कुल का पतझड़ी पेड़',
        'mr': 'फळपीक / रोझेसी कुळातील पानगळीचे झाड'
      },
      producingRegions: {
        'en': 'Jammu & Kashmir, Himachal Pradesh, Uttarakhand, and low-chill pilots in Maharashtra, Punjab, Karnataka.',
        'hi': 'जम्मू कश्मीर, हिमाचल प्रदेश, उत्तराखंड और नई किस्में अन्य राज्यों में।',
        'mr': 'जम्मू काश्मीर, हिमाचल प्रदेश; कमी थंडीचे वाण महाराष्ट्र व कर्नाटकात.'
      },
      suitableTemp: {
        'en': '21°C to 24°C in growing season; requires winter chilling (800-1200 hrs for traditional, 150-300 hrs for low-chill varieties).',
        'hi': '21°C से 24°C बढ़वार पर। कम ठंड वाली किस्मों को केवल 150-300 घंटे ठंड चाहिए।',
        'mr': 'वाढीसाठी २१°C ते २४°C; कमी थंडीच्या वाणांसाठी (HRMN-99) १५० ते ३०० तास थंडी पुरेशी असते.'
      },
      rainfall: {
        'en': '1000–1250 mm distributed evenly throughout growing season.',
        'hi': '1000-1250 मिमी वार्षिक।',
        'mr': '१००० ते १२५० मिमी वार्षिक पाऊस.'
      },
      humidity: {
        'en': '60% to 75%. Overly wet humid harvest weather encourages apple scab.',
        'hi': '60% से 75%। अधिक नमी से स्कैब रोग का खतरा।',
        'mr': '६०% ते ७५%. जास्त दमट हवेत खपल्या (स्कॅब) रोगाचा प्रादुर्भाव होतो.'
      },
      growingSeason: {
        'en': 'Planting in Dec–Feb; Flowering in March; Harvest July–October.',
        'hi': 'रोपाई दिसंबर-फरवरी; फूल मार्च में; फल जुलाई-अक्टूबर में।',
        'mr': 'लागवड डिसेंबर-फेब्रुवारी; मोहर मार्च; फळे काढणी जुलै-ऑक्टोबर.'
      },
      suitableSoil: {
        'en': 'Deep loamy soils rich in organic matter with excellent drainage, minimum 2-meter soil depth.',
        'hi': 'गहरी, उपजाऊ दोमट मिट्टी जिसमें पानी बिल्कुल न ठहरे।',
        'mr': 'पाण्याचा अत्यंत वेगवान निचरा होणारी, किमान २ मीटर खोल सुपीक पोयट्याची जमीन.'
      },
      idealPh: {
        'en': 'pH 5.5 to 6.8',
        'hi': 'pH 5.5 से 6.8',
        'mr': 'सामू ५.५ ते ६.८'
      },
      soilPrep: {
        'en': 'Dig 1x1x1 meter pits in Oct-Nov, expose to sun, fill with 50 kg FYM + 1 kg SSP + Neem cake.',
        'hi': '1x1x1 मीटर के गड्ढे खोदकर गोबर खाद व सिंगल सुपर फास्फेट भरें।',
        'mr': '१x१x१ मीटर आकाराचे खड्डे खणून शेणखत, सिंगल सुपर फॉस्फेट व निंबोळी पेंडीने भरावेत.'
      },
      sowingSeason: {
        'en': 'Plant 1-year grafted bare-root or polybag saplings during dormancy (Dec 15 to Feb 15).',
        'hi': 'दिसंबर से फरवरी (सुप्त अवस्था) में कलमी पौधे लगाएं।',
        'mr': 'डिसेंबर ते फेब्रुवारी महिन्यात विश्रांती काळात कलमे लावावीत.'
      },
      seedVarieties: {
        'en': 'Low-chill: HRMN-99, Anna, Dorsett Golden; Traditional: Royal Delicious, Red Delicious, Gala, Fuji.',
        'hi': 'कम ठंड वाली: HRMN-99, अन्ना, डोर्सेट गोल्डन; पारंपरिक: रॉयल डिलीशियस।',
        'mr': 'कमी थंडीचे वाण: HRMN-99, अण्णा, डोर्सेट गोल्डन; पारंपारिक: रॉयल डेलिशिअस, गाला.'
      },
      seedQuantityPerAcre: {
        'en': 'Standard (5x5m): 160 trees/acre; High Density (3x1.5m): 880 trees/acre on trellises.',
        'hi': 'मानक (5x5m): 160 पेड़/एकड़; सघन बागवानी: 800+ पेड़/एकड़।',
        'mr': 'पारंपारिक (५x५ मी): १६० झाडे/एकर; सघन पद्धत (३x१.५ मी): ८८० झाडे/एकर.'
      },
      seedTreatment: {
        'en': 'Dip roots in Carbendazim (2g/L) + Chlorpyrifos (2ml/L) solution before planting.',
        'hi': 'रोपाई से पहले जड़ों को फफूंदनाशक घोल में डुबोएं।',
        'mr': 'लागवडीपूर्वी मुळे कार्बेन्डाझिम २ ग्रॅम/लिटर द्रावणात बुडवावीत.'
      },
      recommendedNutrients: {
        'en': 'Mature tree: FYM 40 kg + 500g N, 250g P, 750g K annually.',
        'hi': 'प्रति वयस्क पेड़: 40 किग्रा गोबर खाद + 500g N, 250g P, 750g K।',
        'mr': 'प्रति झाड: ४० किलो शेणखत + ५०० ग्रॅम नत्र, २५० ग्रॅम स्फुरद, ७५० ग्रॅम पालाश.'
      },
      organicFertilizers: {
        'en': '40 kg well-rotted cow manure + Vermicompost 5 kg per tree applied in winter basin.',
        'hi': '40 किग्रा सड़ी गोबर खाद पेड़ के थाले में सर्दियों में डालें।',
        'mr': '४० किलो कुजलेले शेणखत हिवाळ्यात झाडाच्या आळ्यात द्यावे.'
      },
      applicationStages: {
        'en': 'Apply full P, K, and 50% N in Dec-Jan dormancy; remaining N after fruit set in April.',
        'hi': 'दिसंबर-जनवरी में पोटाश व फास्फोरस; अप्रैल में नाइट्रोजन दें।',
        'mr': 'डिसेंबर-जानेवारीत पालाश व स्फुरद; फळधारणेनंतर एप्रिलमध्ये नत्र द्यावे.'
      },
      nutrientManagement: {
        'en': 'Spray Calcium Chloride (0.5%) + Boric Acid (0.1%) in May–June to enhance fruit firmness and storage life.',
        'hi': 'फल को मजबूत बनाने हेतु कैल्शियम व बोरॉन का छिड़काव करें।',
        'mr': 'फळांची टिकाऊ क्षमता वाढवण्यासाठी कॅल्शियम व बोरॉनची फवारणी करावी.'
      },
      waterRequirements: {
        'en': '800–1000 mm. Strict moisture regulation: with dry winter and regular summer water.',
        'hi': '800-1000 मिमी। फल विकास के समय नियमित पानी जरूरी।',
        'mr': '८०० ते १००० मिमी. फळवाढीच्या काळात नियमित पाणी आवश्यक.'
      },
      irrigationSchedule: {
        'en': 'Drip irrigation every 5–7 days in summer (April–June). Stop water 15 days before harvest.',
        'hi': 'गर्मियों में हर 5-7 दिन में ड्रिप से पानी दें।',
        'mr': 'उन्हाळ्यात (एप्रिल ते जून) ठिबकने दर ५-७ दिवसांनी पाणी द्यावे.'
      },
      criticalStages: {
        'en': '1. Bud break and flowering (March), 2. Rapid fruit sizing (May–June), 3. Color development.',
        'hi': '1. फूल खिलना (मार्च), 2. फल का बढ़ना (मई-जून), 3. रंग चढ़ना।',
        'mr': '१. मोहर येणे (मार्च), २. फळांचा आकार वाढणे (मे-जून), ३. रंग भरणे.'
      },
      waterSavingMethods: {
        'en': 'Drip irrigation with inline drippers paired with straw/woodchip mulching saves 45% water.',
        'hi': 'ड्रिप व थाले में पुआल की मल्चिंग से 45% पानी बचता है।',
        'mr': 'ठिबक सिंचन आणि आळ्यामध्ये गवताचे आच्छादन (मल्चिंग) केल्यास ४५% पाणी वाचते.'
      },
      stageGermination: {
        'en': 'Dormancy break in late Feb: Silver tip stage and green tip bud swelling.',
        'hi': 'फरवरी अंत: कलियों का फूटना (ग्रीन टिप)।',
        'mr': 'फेब्रुवारी अखेर: विश्रांती संपून कोंब फुटणे.'
      },
      stageSeedling: {
        'en': 'Early March: Tight cluster and pink bud stage.',
        'hi': 'मार्च शुरुआत: गुलाबी कलियां दिखना।',
        'mr': 'मार्च: गुलाबी कळ्यांची अवस्था.'
      },
      stageVegetative: {
        'en': 'March–April: Full foliage expansion and shoot elongation.',
        'hi': 'मार्च-अप्रैल: नई पत्तियों व शाखाओं का विकास।',
        'mr': 'मार्च-एप्रिल: नवीन पालवी व फांद्यांची वाढ.'
      },
      stageFlowering: {
        'en': 'Mid-March: Full bloom with fragrant white-pink blossoms; honeybee pollination.',
        'hi': 'मार्च मध्य: पूरे फूल खिलना व मधुमक्खी परागण।',
        'mr': 'मार्च मध्यावर: पांढरी-गुलाबी फुले उमलणे व मधमाशांद्वारे परागीभवन.'
      },
      stageMaturity: {
        'en': 'May–June: Fruit set, thinning to 1 fruit per cluster, rapid fruit enlargement.',
        'hi': 'मई-जून: फलों का आकार बड़ा होना।',
        'mr': 'मे-जून: फळधारणा, एका घोसामध्ये १-२ फळे ठेवून विरळणी व फळवाढ.'
      },
      stageHarvesting: {
        'en': 'July–September: Characteristic red blush, sweet aroma, easy detachment with stem.',
        'hi': 'जुलाई-सितंबर: लाल रंग व मीठी खुशबू आने पर डंडी सहित तोड़ें।',
        'mr': 'जुलै ते सप्टेंबर: फळांना आकर्षक लाल रंग व गोड सुगंध आल्यावर देठासह काढणी.'
      },
    ),

    // --- 7. COTTON ---
    CropDetailedInfo(
      id: 'cotton',
      emoji: '🌱',
      category: 'cash',
      seasonType: 'kharif',
      isPopular: true,
      name: {'en': 'Cotton', 'hi': 'कपास', 'mr': 'कापूस'},
      intro: {
        'en': 'The White Gold of Indian agriculture, providing natural fiber for textile industry and edible cottonseed oil.',
        'hi': 'भारतीय कृषि का सफेद सोना, कपड़ा उद्योग के लिए प्राकृतिक रेशा और बिनौला तेल।',
        'mr': 'भारतातील प्रमुख पांढरे सोने मानले जाणारे नगदी पीक, कापड उद्योग व सरकी तेलासाठी प्रसिद्ध.'
      },
      cropTypeAndCategory: {
        'en': 'Cash Crop & Natural Fiber / Malvaceae',
        'hi': 'नकदी फसल व प्राकृतिक रेशा / मालवेसी',
        'mr': 'नगदी पीक व नैसर्गिक धागा / मालवेसी कुल'
      },
      producingRegions: {
        'en': 'Gujarat, Maharashtra (Vidarbha, Marathwada, Khandesh), Telangana, Andhra Pradesh, Rajasthan.',
        'hi': 'गुजरात, महाराष्ट्र (विदर्भ, मराठवाड़ा, खानदेश), तेलंगाना।',
        'mr': 'महाराष्ट्र (विदर्भ, मराठवाडा, खान्देश), गुजरात, तेलंगणा.'
      },
      suitableTemp: {
        'en': '25°C to 35°C during vegetative growth; abundant sunshine during boll opening.',
        'hi': '25°C से 35°C बढ़वार पर; टिंडे खिलते समय खिली धूप चाहिए।',
        'mr': '२५°C ते ३५°C वाढीसाठी; बोंडे उमलण्यासाठी कडक ऊन आवश्यक.'
      },
      rainfall: {
        'en': '600–900 mm. Well-distributed monsoon rains followed by dry picking season.',
        'hi': '600-900 मिमी वर्षा।',
        'mr': '६०० ते ९०० मिमी वार्षिक पाऊस. वेचणीच्या वेळी कोरडे हवामान आवश्यक.'
      },
      humidity: {
        'en': 'Moderate humidity 50-70%. Excess humidity invites leaf spot and fungal boll rot.',
        'hi': '50-70%। अधिक नमी में बोंड सड़न रोग होता है।',
        'mr': '५०-७०%. जास्त दमट हवेत बोंड सडण्याची शक्यता असते.'
      },
      growingSeason: {
        'en': 'Kharif monsoon crop (June to December).',
        'hi': 'खरीफ मानसूनी फसल (जून से दिसंबर)।',
        'mr': 'खरीप पावसाळी हंगाम (जून ते डिसेंबर).'
      },
      suitableSoil: {
        'en': 'Deep black cotton soil (Regur) with high moisture retentive capacity.',
        'hi': 'गहरी काली कपासी मिट्टी (रेगुर) जिसमें नमी रोकने की क्षमता हो।',
        'mr': 'काळी कसदार भारी ते मध्यम जमीन (रेगूर माती), ओलावा टिकवणारी.'
      },
      idealPh: {
        'en': 'pH 6.5 to 8.2',
        'hi': 'pH 6.5 से 8.2',
        'mr': 'सामू ६.५ ते ८.२'
      },
      soilPrep: {
        'en': '1 deep plowing every 3 years, 2 harrowings. Form ridges and furrows at 4–5 ft spacing.',
        'hi': 'गहरी जुताई के बाद 2 बार हैरो चलाएं, 4-5 फीट पर मेड़ें बनाएं।',
        'mr': '१ खोल नांगरट व २ कुळवाच्या पाळ्या. ४ ते ५ फुटांवर सरी-वरंबे पाडावेत.'
      },
      sowingSeason: {
        'en': 'Sow immediately after 75–100 mm monsoon rainfall (June 15 to July 10).',
        'hi': '75-100 मिमी बारिश के बाद बुवाई करें (15 जून से 10 जुलाई)।',
        'mr': '७५ ते १०० मिमी पाऊस झाल्यावर लगेच टोकण करावी (१५ जून ते १० जुलै).'
      },
      seedVarieties: {
        'en': 'Bollgard-II Hybrids: RCH-659, Ajit-155, Jadoo, Ajeet-199, Ankur-3028.',
        'hi': 'आरसीएच-659, अजीत-155, जादू, अंकुर-3028।',
        'mr': 'आरसीएच-६५९, अजित-१५५, जादू, अंकुर-३०२८, राशी.'
      },
      seedQuantityPerAcre: {
        'en': '1 to 2 packets (450g each) per acre based on spacing.',
        'hi': '1 से 2 पैकेट (450 ग्राम प्रत्येक) प्रति एकड़।',
        'mr': 'एकरी १ ते २ पाकिटे (प्रत्येकी ४५० ग्रॅम).'
      },
      seedTreatment: {
        'en': 'Commercial hybrid packets are pre-treated. Treat with Azotobacter + PSB @ 25g/kg for root vigor.',
        'hi': 'संकर बीज उपचारित आते हैं; एज़ोटोबैक्टर से जैविक उपचार करें।',
        'mr': 'पाकिटातील बियाणे प्रक्रिया केलेले असते; अॅझोटोबॅक्टर २५ ग्रॅम/किलो चोळावे.'
      },
      recommendedNutrients: {
        'en': 'NPK 100:50:50 kg/ha for rainfed; 120:60:60 kg/ha for irrigated.',
        'hi': '100:50:50 NPK प्रति हेक्टेयर (असिंचित); 120:60:60 (सिंचित)।',
        'mr': 'कोरडवाहूसाठी १००:५०:५० NPK; बागायतीसाठी १२०:६०:६० किलो प्रति हेक्टर.'
      },
      organicFertilizers: {
        'en': '5 tons FYM + 250 kg Castor or Neem cake per acre.',
        'hi': '5 टन गोबर खाद + 250 किग्रा अरंडी या नीम खली।',
        'mr': 'एकरी ५ टन शेणखत + २५० किलो एरंडी किंवा निंबोळी पेंड.'
      },
      applicationStages: {
        'en': '20% N + full P & K at sowing; remaining N split at 30, 60, and 75 days.',
        'hi': 'नत्र को 30, 60 और 75 दिन पर तीन बार में बांटकर दें।',
        'mr': '२०% नत्र व पूर्ण स्फुरद-पालाश पेरणीवेळी; उर्वरित नत्र ३०, ६० व ७५ दिवसांनी द्यावे.'
      },
      nutrientManagement: {
        'en': 'Spray 13:00:45 (10g/L) + Boron (1g/L) at boll formation to prevent boll drop and reddening.',
        'hi': 'बोंड बनते समय 13:00:45 व बोरॉन का छिड़काव लाल पत्ती रोग से बचाता है।',
        'mr': 'कापूस लाल पडणे व बोंडगळ रोखण्यासाठी १३:००:४५ (१० ग्रॅम) + बोरॉन १ ग्रॅम/लिटर फवारावे.'
      },
      waterRequirements: {
        'en': '600–700 mm. Deep roots utilize subsoil moisture.',
        'hi': '600-700 मिमी। गहरी जड़ें जमीन के नीचे से पानी खींचती हैं।',
        'mr': '६०० ते ७०० मिमी. खोल मुळांमुळे जमिनीतील खालचा ओलावा घेते.'
      },
      irrigationSchedule: {
        'en': 'Water if monsoon breaks for >15 days. Regular drip irrigation every 4–5 days.',
        'hi': 'बारिश का लंबा सूखा पड़ने पर सिंचाई करें; ड्रिप से 4-5 दिन में।',
        'mr': 'पावसाचा खंड पडल्यास संरक्षक पाणी द्यावे; ठिबक असल्यास दर ४-५ दिवसांनी.'
      },
      criticalStages: {
        'en': '1. Square formation (45d), 2. Flowering (65d), 3. Boll development (85d).',
        'hi': '1. डोडी (स्क्वायर), 2. फूल आना, 3. टिंडे (बोंड) बनना।',
        'mr': '१. पाते लागणे (४५ दिवस), २. फुलधारणा (६५ दिवस), ३. बोंडे भरणे (८५ दिवस).'
      },
      waterSavingMethods: {
        'en': 'Drip irrigation with alternate furrow irrigation saves 40% water.',
        'hi': 'एकान्तर नाली (एक नाली छोड़कर) सिंचाई या ड्रिप से 40% पानी बचता है।',
        'mr': 'एक आड एक सरी सिंचन किंवा ठिबक सिंचनाने ४०% पाण्याची बचत होते.'
      },
      stageGermination: {
        'en': 'Days 1–6: Emergence of cotyledon leaves.',
        'hi': 'दिन 1-6: बीज अंकुरण।',
        'mr': 'दिवस १ ते ६: बियाणे उगवण व दोन डाळ पाने बाहेर येणे.'
      },
      stageSeedling: {
        'en': 'Days 7–25: True leaves emerge; gap filling and thinning.',
        'hi': 'दिन 7-25: पौधों की छंटाई व पहला निराई।',
        'mr': 'दिवस ७ ते २५: खरी पाने फुटणे व नांग्या भरणे.'
      },
      stageVegetative: {
        'en': 'Days 26–50: Monopodial and sympodial branching.',
        'hi': 'दिन 26-50: मुख्य तने व शाखाओं का विकास।',
        'mr': 'दिवस २६ ते ५०: मुख्य खोड व फळफांद्यांची जोमदार वाढ.'
      },
      stageFlowering: {
        'en': 'Days 50–75: Square (flower bud) formation; blooms into cream-yellow flower.',
        'hi': 'दिन 50-75: डोडी बनना व फूल खिलना।',
        'mr': 'दिवस ५० ते ७५: पाते लागणे व फिकट पिवळी फुले उमलणे.'
      },
      stageMaturity: {
        'en': 'Days 75–120: Green boll enlargement, fiber development, and boll cracking.',
        'hi': 'दिन 75-120: बोंडों का विकास व परिपक्व होना।',
        'mr': 'दिवस ७५ ते १२०: बोंडांची वाढ व बोंडे तडकणे.'
      },
      stageHarvesting: {
        'en': 'Days 120–160: Manual clean picking of fluffy white cotton in 3–4 rounds.',
        'hi': 'दिन 120-160: धूप में खिली साफ सफेद कपास की 3-4 बार में तुड़ाई।',
        'mr': 'दिवस १२० ते १६०: कोरड्या स्वच्छ कापसाची ३ ते ४ टप्प्यांत वेचणी.'
      },
    ),

    // --- 8. SOYBEAN ---
    CropDetailedInfo(
      id: 'soybean',
      emoji: '🌱',
      category: 'oilseeds',
      seasonType: 'kharif',
      isPopular: true,
      name: {'en': 'Soybean', 'hi': 'सोयाबीन', 'mr': 'सोयाबीन'},
      intro: {
        'en': 'Wonder crop rich in both high quality vegetable protein (40%) and edible oil (20%), enriching soil nitrogen.',
        'hi': 'अद्भुत तिलहन फसल, 40% प्रोटीन और 20% खाद्य तेल से भरपूर, जमीन की उर्वरता बढ़ाती है।',
        'mr': 'कमी कालावधीत उत्तम उत्पादन देणारे गळितधान्य पीक, ४०% प्रथिने व २०% तेल असणारे.'
      },
      cropTypeAndCategory: {
        'en': 'Oilseed & Legume / Fabaceae Legume Family',
        'hi': 'तिलहन व दलहन / लेग्युमिनोसी कुल',
        'mr': 'गळितधान्य व द्विदल पीक / फॅबेसी कुल'
      },
      producingRegions: {
        'en': 'Madhya Pradesh (Malwa), Maharashtra (Marathwada, Vidarbha), Rajasthan, Karnataka.',
        'hi': 'मध्य प्रदेश, महाराष्ट्र (लातूर, अकोला), राजस्थान।',
        'mr': 'महाराष्ट्र (लातूर, नांदेड, अकोला, अमरावती), मध्य प्रदेश.'
      },
      suitableTemp: {
        'en': '22°C to 32°C. Rapid germination when soil temperature is above 20°C.',
        'hi': '22°C से 32°C।',
        'mr': '२२°C ते ३२°C. योग्य तापमानात बियाण्याची उगवण जलद होते.'
      },
      rainfall: {
        'en': '600–850 mm well-distributed rainfall throughout June to September.',
        'hi': '600-850 मिमी समान मानसूनी वर्षा।',
        'mr': '६०० ते ८५० मिमी समप्रमाणात पडणारा पाऊस.'
      },
      humidity: {
        'en': '60% to 75% relative humidity.',
        'hi': '60% से 75%।',
        'mr': '६०% ते ७५% हवेतील आर्द्रता.'
      },
      growingSeason: {
        'en': 'Kharif monsoon season (June to October).',
        'hi': 'खरीफ मानसूनी मौसम (जून से अक्टूबर)।',
        'mr': 'खरीप पावसाळी हंगाम (जून ते ऑक्टोबर).'
      },
      suitableSoil: {
        'en': 'Well-drained fertile medium-to-deep black or alluvial soil rich in phosphorus.',
        'hi': 'जल निकासी युक्त मध्यम से भारी काली मिट्टी।',
        'mr': 'पाण्याचा चांगला निचरा होणारी मध्यम ते भारी काळी किंवा पोयटा जमीन.'
      },
      idealPh: {
        'en': 'pH 6.5 to 7.5',
        'hi': 'pH 6.5 से 7.5',
        'mr': 'सामू ६.५ ते ७.५'
      },
      soilPrep: {
        'en': 'Summer plowing followed by 2 harrowings. Prepare broad bed furrows (BBF) to prevent waterlogging.',
        'hi': 'ग्रीष्मकालीन जुताई और बीबीएफ (ब्रॉड बेड फरो) विधि बनाएं।',
        'mr': 'उन्हाळी नांगरट व २ कुळवाच्या पाळ्या. बीबीएफ (रुंद वरंबा-सरी) पद्धतीने पेरणी केल्यास पाणी साचत नाही.'
      },
      sowingSeason: {
        'en': 'June 20 to July 10 after minimum 75–100 mm rainfall has soaked the subsoil.',
        'hi': '75-100 मिमी बारिश होने पर (20 जून से 10 जुलाई)।',
        'mr': '७५ ते १०० मिमी पाऊस झाल्यावर २० जून ते १० जुलैदरम्यान पेरणी करावी.'
      },
      seedVarieties: {
        'en': 'JS-335, JS-9305, JS-9560, Phule Sangam (KDS-726), Phule Kimaya (KDS-753), DS-228.',
        'hi': 'फुले संगम (KDS-726), फुले किमया, जेएस-335, जेएस-9560।',
        'mr': 'फुले संगम (केडीएस-७२६), फुले किमया (केडीएस-७५३), जेएस-३३५, जेएस-९३०५.'
      },
      seedQuantityPerAcre: {
        'en': '25 to 30 kg/acre (depending on seed size & germination percentage > 70%).',
        'hi': '25 से 30 किग्रा प्रति एकड़ (अंकुरण 70% से अधिक होना चाहिए)।',
        'mr': 'एकरी २५ ते ३० किलो (बियाण्याची उगवण क्षमता ७०% पेक्षा जास्त असावी).'
      },
      seedTreatment: {
        'en': 'Mandatory: Thiram + Carbendazim @ 3g/kg or Trichoderma @ 5g/kg + Bradyrhizobium japonicum culture.',
        'hi': 'थिरम (3g/kg) व राइजोबियम कल्चर से बीजोपचार अवश्य करें।',
        'mr': 'अतिशय महत्त्वाचे: थायरम ३ ग्रॅम/किलो + रायझोबियम जीवाणू संवर्धक २५ ग्रॅम/किलो बियाण्यास चोळावे.'
      },
      recommendedNutrients: {
        'en': 'NPK 30:60:30 kg/ha + 20 kg Sulphur per hectare at sowing.',
        'hi': '30:60:30 NPK प्रति हेक्टेयर + 20 किग्रा सल्फर।',
        'mr': 'हेक्टरी ३०:६०:३० किलो NPK + २० किलो सल्फर पेरणीवेळी द्यावे.'
      },
      organicFertilizers: {
        'en': 'Apply 4 tons FYM or 1 ton Vermicompost/acre.',
        'hi': '4 टन गोबर खाद या 1 टन केंचुआ खाद प्रति एकड़।',
        'mr': 'एकरी ४ टन शेणखत किंवा १ टन गांडूळ खत द्यावे.'
      },
      applicationStages: {
        'en': 'Apply full fertilizer dose at time of sowing behind the seed drill.',
        'hi': 'पेरणी के समय ड्रिल से पूरा खाद एक साथ दें।',
        'mr': 'पेरणी यंत्राने पेरणीवेळीच खतांचा संपूर्ण डोस द्यावा.'
      },
      nutrientManagement: {
        'en': 'Spray 0:52:34 (5g/L) + Boron (1g/L) at pod filling stage to prevent flat pods (pod blighting).',
        'hi': 'फलियां भरते समय 0:52:34 का छिड़काव दानों को मोटा बनाता है।',
        'mr': 'शेंगा भरताना ०:५२:३४ (५ ग्रॅम) + बोरॉन १ ग्रॅम/लिटर फवारल्याने दाणे टपोरे भरतात.'
      },
      waterRequirements: {
        'en': '450–600 mm. Highly sensitive to waterlogging as well as drought at pod fill.',
        'hi': '450-600 मिमी। फलियां भरते समय सूखा न पड़ने दें।',
        'mr': '४५० ते ६०० मिमी. शेंगा भरताना पाण्याचा ताण पडल्यास उत्पादन घटते.'
      },
      irrigationSchedule: {
        'en': 'Rainfed crop. If dry spell exceeds 12–15 days, provide protective sprinkler irrigation.',
        'hi': 'वर्षा आधारित फसल; सूखा पड़ने पर स्प्रिंकलर से पानी दें।',
        'mr': 'पावसावर आधारित पीक; पावसाचा खंड पडल्यास तुषार सिंचनाने संरक्षित पाणी द्यावे.'
      },
      criticalStages: {
        'en': '1. Flowering (35-45d), 2. Pod development and seed filling (60-75d).',
        'hi': '1. फूल खिलना (35-45 दिन), 2. फलियों में दाना भरना (60-75 दिन)।',
        'mr': '१. फुलधारणा (३५-४५ दिवस), २. शेंगांमध्ये दाणे भरणे (६०-७५ दिवस).'
      },
      waterSavingMethods: {
        'en': 'Broad Bed Furrow (BBF) technology drains excess rainwater and retains soil moisture during dry spells.',
        'hi': 'बीबीएफ तकनीक से अधिक पानी बह जाता है और सूखे में नमी बनी रहती है।',
        'mr': 'बीबीएफ (रुंद वरंबा-सरी) तंत्रज्ञानामुळे जास्तीचे पाणी वाहून जाते व दुष्काळात ओलावा टिकतो.'
      },
      stageGermination: {
        'en': 'Days 1–5: Rapid hypocotyl emergence from soil.',
        'hi': 'दिन 1-5: अंकुरण।',
        'mr': 'दिवस १ ते ५: जलद अंकुरण.'
      },
      stageSeedling: {
        'en': 'Days 6–20: First trifoliate leaf emerges; root nodules start fixing nitrogen.',
        'hi': 'दिन 6-20: तीन पत्तियों का विकास व जड़ों में गांठे बनना।',
        'mr': 'दिवस ६ ते २०: त्रिपर्णी पाने फुटणे व मुळांवरील गाठींद्वारे नत्र स्थिरीकरण.'
      },
      stageVegetative: {
        'en': 'Days 21–40: Rapid canopy formation and branching.',
        'hi': 'दिन 21-40: पौधे की बढ़वार।',
        'mr': 'दिवस २१ ते ४०: फांद्यांची जोमदार वाढ.'
      },
      stageFlowering: {
        'en': 'Days 40–55: Small purple or white flowers open in leaf axils.',
        'hi': 'दिन 40-55: छोटे बैंगनी या सफेद फूल खिलना।',
        'mr': 'दिवस ४० ते ५५: पानाच्या बेचक्यात जांभळी किंवा पांढरी फुले उमलणे.'
      },
      stageMaturity: {
        'en': 'Days 60–85: Pod elongation and grain swelling; leaves turn yellow and drop.',
        'hi': 'दिन 60-85: फलियां भरना व पत्तियां पीली होकर गिरना।',
        'mr': 'दिवस ६० ते ८५: शेंगा भरणे, पाने पिवळी पडून गळणे.'
      },
      stageHarvesting: {
        'en': 'Days 90–105: Pods turn dry brown/yellow, rattling seeds inside. Harvest immediately to prevent pod shattering.',
        'hi': 'दिन 90-105: फलियां सूखने पर तुरंत कटाई करें ताकि दाने न छिटकें।',
        'mr': 'दिवस ९० ते १०५: शेंगा तपकिरी होऊन हलवल्यास आवाज आल्यावर लगेच काढणी करावी.'
      },
    ),
  ];

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<CropDetailedInfo> get _filteredCrops {
    List<CropDetailedInfo> list = _cropDatabase;

    if (_selectedCategory != 'all') {
      list = list.where((c) => c.category == _selectedCategory).toList();
    }

    if (_selectedSeason != 'all') {
      list = list.where((c) => c.seasonType == _selectedSeason).toList();
    }

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list.where((c) {
        final nameEn = (c.name['en'] ?? '').toLowerCase();
        final nameHi = (c.name['hi'] ?? '').toLowerCase();
        final nameMr = (c.name['mr'] ?? '').toLowerCase();
        return nameEn.contains(q) || nameHi.contains(q) || nameMr.contains(q) || c.id.contains(q);
      }).toList();
    }

    return list;
  }

  String _t(Map<String, String> map) => map[widget.lang] ?? map['en'] ?? '';

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final brand = brandOf(context);

    if (_selectedCropDetail != null) {
      return _buildDetailedView(_selectedCropDetail!, cs, brand);
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
          children: [
            // Header
            Row(
              children: [
                Icon(Icons.agriculture_rounded, color: brand, size: 28),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    widget.lang == 'mr'
                        ? 'पीक माहिती व मार्गदर्शक'
                        : widget.lang == 'hi'
                            ? 'फसल ज्ञान एवं संपूर्ण गाइड'
                            : 'Crop Encyclopedia & Guide',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: cs.onSurface,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              widget.lang == 'mr'
                  ? 'अन्नधान्य, कडधान्य, भाज्या, फळे व नगदी पिकांविषयी सविस्तर माहिती'
                  : widget.lang == 'hi'
                      ? 'अनाज, दलहन, तिलहन, फल, सब्जी और नकदी फसलों की पूरी जानकारी'
                      : 'Comprehensive practices for cereals, pulses, vegetables & fruits',
              style: TextStyle(fontSize: 13, color: cs.onSurface.withAlpha(180)),
            ),
            const SizedBox(height: 16),

            // 1. Search Bar
            TextField(
              controller: _searchCtrl,
              onChanged: (val) => setState(() => _searchQuery = val.trim()),
              decoration: InputDecoration(
                hintText: widget.lang == 'mr'
                    ? 'पिकाचे नाव शोधा (उदा. टोमॅटो, गहू, भेंडी, मिरची...)'
                    : widget.lang == 'hi'
                        ? 'फसल का नाम खोजें (उदा. टमाटर, गेहूं, भिंडी, मिर्च...)'
                        : 'Search Crops – Search by crop name (e.g. Tomato, Chili, Okra...)',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                filled: true,
                fillColor: cs.surface,
                contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              ),
            ),
            const SizedBox(height: 18),

            // 2. Crop Categories
            _sectionHeader(
              widget.lang == 'mr'
                  ? 'पिकांचे प्रकार (वर्गवारी)'
                  : widget.lang == 'hi'
                      ? 'फसल श्रेणियां'
                      : 'Crop Categories',
              Icons.category_rounded,
              brand,
              cs,
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _categoryChip('all', widget.lang == 'mr' ? 'सर्व पिके' : widget.lang == 'hi' ? 'सभी' : 'All', brand),
                  _categoryChip('cereals', widget.lang == 'mr' ? 'तृणधान्य 🌾' : widget.lang == 'hi' ? 'अनाज 🌾' : 'Cereals 🌾', brand),
                  _categoryChip('pulses', widget.lang == 'mr' ? 'कडधान्य 🫘' : widget.lang == 'hi' ? 'दलहन 🫘' : 'Pulses 🫘', brand),
                  _categoryChip('vegetables', widget.lang == 'mr' ? 'भाज्या 🍅' : widget.lang == 'hi' ? 'सब्जियां 🍅' : 'Vegetables 🍅', brand),
                  _categoryChip('fruits', widget.lang == 'mr' ? 'फळे 🍎' : widget.lang == 'hi' ? 'फल 🍎' : 'Fruits 🍎', brand),
                  _categoryChip('cash', widget.lang == 'mr' ? 'नगदी पिके 🎋' : widget.lang == 'hi' ? 'नकदी 🎋' : 'Cash Crops 🎋', brand),
                  _categoryChip('oilseeds', widget.lang == 'mr' ? 'गळितधान्य 🌱' : widget.lang == 'hi' ? 'तिलहन 🌱' : 'Oilseeds 🌱', brand),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 3. Popular Crops Section (Wheat, rice, cotton, soybean, onion, tomato, etc.)
            _sectionHeader(
              widget.lang == 'mr'
                  ? 'लोकप्रिय पिके (गहू, भात, कापूस, सोयाबीन, कांदा, टोमॅटो...)'
                  : widget.lang == 'hi'
                      ? 'लोकप्रिय फसलें (गेहूं, धान, कपास, सोयाबीन, प्याज, टमाटर...)'
                      : 'Popular Crops (Wheat, Rice, Cotton, Soybean, Onion, Tomato...)',
              Icons.star_rounded,
              brand,
              cs,
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _cropDatabase.where((c) => c.isPopular).map((c) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ActionChip(
                      avatar: Text(c.emoji, style: const TextStyle(fontSize: 16)),
                      label: Text(_t(c.name)),
                      onPressed: () => setState(() => _selectedCropDetail = c),
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 16),

            // 4. Seasonal Crops (Kharif, Rabi, Zaid)
            _sectionHeader(
              widget.lang == 'mr'
                  ? 'हंगामी पिके (खरीप, रब्बी व उन्हाळी पिके)'
                  : widget.lang == 'hi'
                      ? 'मौसमी फसलें (खरीफ, रबी व जायद फसलें)'
                      : 'Seasonal Crops (Kharif, Rabi and Zaid crops)',
              Icons.calendar_month_rounded,
              brand,
              cs,
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _seasonChip('all', widget.lang == 'mr' ? 'सर्व हंगाम' : widget.lang == 'hi' ? 'सभी मौसम' : 'All Seasons', brand),
                  _seasonChip('kharif', widget.lang == 'mr' ? 'खरीप हंगाम 🌧️' : widget.lang == 'hi' ? 'खरीफ फसल 🌧️' : 'Kharif Crops 🌧️', brand),
                  _seasonChip('rabi', widget.lang == 'mr' ? 'रब्बी हंगाम ❄️' : widget.lang == 'hi' ? 'रबी फसल ❄️' : 'Rabi Crops ❄️', brand),
                  _seasonChip('zaid', widget.lang == 'mr' ? 'उन्हाळी / जायद ☀️' : widget.lang == 'hi' ? 'जायद (गर्मी) ☀️' : 'Zaid (Summer) ☀️', brand),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Crop Cards List
            ..._filteredCrops.map((crop) => _cropSummaryCard(crop, cs, brand)),
          ],
        ),
      ),
    );
  }

  Widget _categoryChip(String key, String label, Color brand) {
    final isSelected = _selectedCategory == key;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        selectedColor: alpha(brand, 0.22),
        onSelected: (selected) {
          if (selected) setState(() => _selectedCategory = key);
        },
      ),
    );
  }

  Widget _seasonChip(String key, String label, Color brand) {
    final isSelected = _selectedSeason == key;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        selectedColor: alpha(brand, 0.22),
        onSelected: (selected) {
          if (selected) setState(() => _selectedSeason = key);
        },
      ),
    );
  }

  Widget _sectionHeader(String title, IconData icon, Color brand, ColorScheme cs) {
    return Row(
      children: [
        Icon(icon, size: 20, color: brand),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: cs.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _cropSummaryCard(CropDetailedInfo crop, ColorScheme cs, Color brand) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: alpha(cs.surface, 0.96),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: alpha(cs.outlineVariant, 0.6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(12),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => setState(() => _selectedCropDetail = crop),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(crop.emoji, style: const TextStyle(fontSize: 34)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _t(crop.name),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: cs.onSurface,
                            ),
                          ),
                          Text(
                            _t(crop.cropTypeAndCategory),
                            style: TextStyle(
                              fontSize: 12.5,
                              color: alpha(cs.onSurface, 0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios_rounded, size: 16, color: brand),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  _t(crop.intro),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 13, color: cs.onSurface.withAlpha(200)),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 6,
                  children: [
                    _badge(_t(crop.growingSeason), Colors.blue, cs),
                    _badge(_t(crop.idealPh), Colors.purple, cs),
                    _badge(crop.seasonType.toUpperCase(), Colors.orange, cs),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _badge(String text, Color col, ColorScheme cs) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: alpha(col, 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: alpha(col, 0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: col),
      ),
    );
  }

  // --- DETAILED 7-SECTION CROP VIEW ---
  Widget _buildDetailedView(CropDetailedInfo crop, ColorScheme cs, Color brand) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 120),
          children: [
            // Back button
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_rounded),
                  onPressed: () => setState(() => _selectedCropDetail = null),
                ),
                const SizedBox(width: 4),
                Text(
                  widget.lang == 'mr'
                      ? 'मागे जा'
                      : widget.lang == 'hi'
                          ? 'वापस'
                          : 'Back to Crops',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Header banner
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [brand, const Color(0xFF2EB86A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Row(
                children: [
                  Text(crop.emoji, style: const TextStyle(fontSize: 48)),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _t(crop.name),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Text(
                          _t(crop.cropTypeAndCategory),
                          style: const TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // 1. CROP OVERVIEW
            _detailCard(
              title: widget.lang == 'mr'
                  ? '१. पीक आढावा (Crop Overview)'
                  : widget.lang == 'hi'
                      ? '1. फसल का विवरण (Crop Overview)'
                      : '1. Crop Overview',
              icon: Icons.info_outline_rounded,
              color: Colors.teal,
              cs: cs,
              rows: [
                _detailRow(
                  widget.lang == 'mr' ? 'पिकाचे नाव व छायाचित्र' : widget.lang == 'hi' ? 'फसल का नाम व चित्र' : 'Crop Name & Image',
                  '${crop.emoji} ${_t(crop.name)}',
                ),
                _detailRow(
                  widget.lang == 'mr' ? 'परिचय व उपयोग' : widget.lang == 'hi' ? 'परिचय व उपयोग' : 'Introduction & Uses',
                  _t(crop.intro),
                ),
                _detailRow(
                  widget.lang == 'mr' ? 'पिकाचा प्रकार व वर्गवारी' : widget.lang == 'hi' ? 'फसल प्रकार व श्रेणी' : 'Crop Type & Category',
                  _t(crop.cropTypeAndCategory),
                ),
                _detailRow(
                  widget.lang == 'mr' ? 'प्रमुख उत्पादक प्रदेश' : widget.lang == 'hi' ? 'प्रमुख उत्पादक क्षेत्र' : 'Main Producing Regions',
                  _t(crop.producingRegions),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // 2. CLIMATE REQUIREMENTS
            _detailCard(
              title: widget.lang == 'mr'
                  ? '२. हवामान आवश्यकता (Climate Requirements)'
                  : widget.lang == 'hi'
                      ? '2. जलवायु आवश्यकताएं (Climate Requirements)'
                      : '2. Climate Requirements',
              icon: Icons.thermostat_rounded,
              color: Colors.orange,
              cs: cs,
              rows: [
                _detailRow(
                  widget.lang == 'mr' ? 'योग्य तापमान' : widget.lang == 'hi' ? 'उपयुक्त तापमान' : 'Suitable Temperature',
                  _t(crop.suitableTemp),
                ),
                _detailRow(
                  widget.lang == 'mr' ? 'पर्जन्यमान आवश्यकता' : widget.lang == 'hi' ? 'वर्षा आवश्यकताएं' : 'Rainfall Requirements',
                  _t(crop.rainfall),
                ),
                _detailRow(
                  widget.lang == 'mr' ? 'हवेतील आर्द्रता' : widget.lang == 'hi' ? 'आर्द्रता स्थिति' : 'Humidity Conditions',
                  _t(crop.humidity),
                ),
                _detailRow(
                  widget.lang == 'mr' ? 'वाढीचा योग्य काळ' : widget.lang == 'hi' ? 'उपयुक्त मौसम' : 'Suitable Growing Season',
                  _t(crop.growingSeason),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // 3. SOIL REQUIREMENTS
            _detailCard(
              title: widget.lang == 'mr'
                  ? '३. जमीन व मशागत (Soil Requirements)'
                  : widget.lang == 'hi'
                      ? '3. मिट्टी की आवश्यकता (Soil Requirements)'
                      : '3. Soil Requirements',
              icon: Icons.terrain_rounded,
              color: Colors.brown,
              cs: cs,
              rows: [
                _detailRow(
                  widget.lang == 'mr' ? 'योग्य जमिनीचा प्रकार' : widget.lang == 'hi' ? 'उपयुक्त मिट्टी का प्रकार' : 'Suitable Soil Types',
                  _t(crop.suitableSoil),
                ),
                _detailRow(
                  widget.lang == 'mr' ? 'मातीचा आदर्श सामू (pH)' : widget.lang == 'hi' ? 'आदर्श मिट्टी pH' : 'Ideal Soil pH',
                  _t(crop.idealPh),
                ),
                _detailRow(
                  widget.lang == 'mr' ? 'जमिनीची मशागत' : widget.lang == 'hi' ? 'खेत की तैयारी' : 'Soil Preparation',
                  _t(crop.soilPrep),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // 4. SOWING INFORMATION
            _detailCard(
              title: widget.lang == 'mr'
                  ? '४. पेरणी व लागवड (Sowing Information)'
                  : widget.lang == 'hi'
                      ? '4. बुवाई की जानकारी (Sowing Information)'
                      : '4. Sowing Information',
              icon: Icons.eco_rounded,
              color: Colors.green,
              cs: cs,
              rows: [
                _detailRow(
                  widget.lang == 'mr' ? 'पेरणीचा सर्वोत्तम काळ' : widget.lang == 'hi' ? 'बुवाई का सर्वोत्तम समय' : 'Best Sowing Season',
                  _t(crop.sowingSeason),
                ),
                _detailRow(
                  widget.lang == 'mr' ? 'सुधारित व संकरित वाण' : widget.lang == 'hi' ? 'उन्नत किस्में' : 'Seed Varieties',
                  _t(crop.seedVarieties),
                ),
                _detailRow(
                  widget.lang == 'mr' ? 'एकरी बियाणे प्रमाण' : widget.lang == 'hi' ? 'बीज दर प्रति एकड़' : 'Seed Quantity Per Acre',
                  _t(crop.seedQuantityPerAcre),
                ),
                _detailRow(
                  widget.lang == 'mr' ? 'बीजप्रक्रिया' : widget.lang == 'hi' ? 'बीज उपचार' : 'Seed Treatment',
                  _t(crop.seedTreatment),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // 5. FERTILIZER REQUIREMENTS
            _detailCard(
              title: widget.lang == 'mr'
                  ? '५. खत व्यवस्थापन (Fertilizer Requirements)'
                  : widget.lang == 'hi'
                      ? '5. उर्वरक आवश्यकताएं (Fertilizer Requirements)'
                      : '5. Fertilizer Requirements',
              icon: Icons.science_rounded,
              color: Colors.purple,
              cs: cs,
              rows: [
                _detailRow(
                  widget.lang == 'mr' ? 'शिफारस केलेली खते' : widget.lang == 'hi' ? 'अनुशंसित उर्वरक' : 'Recommended Nutrients',
                  _t(crop.recommendedNutrients),
                ),
                _detailRow(
                  widget.lang == 'mr' ? 'सेंद्रिय व जैविक खते' : widget.lang == 'hi' ? 'जैविक व देसी खाद' : 'Organic Fertilizers',
                  _t(crop.organicFertilizers),
                ),
                _detailRow(
                  widget.lang == 'mr' ? 'खते देण्याच्या अवस्था' : widget.lang == 'hi' ? 'उर्वरक देने की अवस्थाएं' : 'Application Stages',
                  _t(crop.applicationStages),
                ),
                _detailRow(
                  widget.lang == 'mr' ? 'अन्नद्रव्य व्यवस्थापन' : widget.lang == 'hi' ? 'पोषक तत्व प्रबंधन' : 'Nutrient Management',
                  _t(crop.nutrientManagement),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // 6. IRRIGATION INFORMATION
            _detailCard(
              title: widget.lang == 'mr'
                  ? '६. पाणी व्यवस्थापन (Irrigation Information)'
                  : widget.lang == 'hi'
                      ? '6. सिंचाई जानकारी (Irrigation Information)'
                      : '6. Irrigation Information',
              icon: Icons.water_drop_rounded,
              color: Colors.blue,
              cs: cs,
              rows: [
                _detailRow(
                  widget.lang == 'mr' ? 'पाण्याची आवश्यकता' : widget.lang == 'hi' ? 'जल आवश्यकताएं' : 'Water Requirements',
                  _t(crop.waterRequirements),
                ),
                _detailRow(
                  widget.lang == 'mr' ? 'पाणी देण्याचे वेळापत्रक' : widget.lang == 'hi' ? 'सिंचाई समय सारणी' : 'Irrigation Schedule',
                  _t(crop.irrigationSchedule),
                ),
                _detailRow(
                  widget.lang == 'mr' ? 'पाणी देण्यासाठी नाजूक अवस्था' : widget.lang == 'hi' ? 'सिंचाई की नाजुक अवस्थाएं' : 'Critical Watering Stages',
                  _t(crop.criticalStages),
                ),
                _detailRow(
                  widget.lang == 'mr' ? 'पाणी बचत पद्धती' : widget.lang == 'hi' ? 'जल संरक्षण विधियां' : 'Water-saving Methods',
                  _t(crop.waterSavingMethods),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // 7. CROP GROWTH STAGES
            _detailCard(
              title: widget.lang == 'mr'
                  ? '७. पिकाच्या वाढीच्या अवस्था (Growth Stages)'
                  : widget.lang == 'hi'
                      ? '7. फसल वृद्धि की अवस्थाएं (Growth Stages)'
                      : '7. Crop Growth Stages',
              icon: Icons.timeline_rounded,
              color: Colors.deepOrange,
              cs: cs,
              rows: [
                _detailRow(
                  widget.lang == 'mr' ? '१. उगवण अवस्था' : widget.lang == 'hi' ? '1. अंकुरण अवस्था' : '1. Germination',
                  _t(crop.stageGermination),
                ),
                _detailRow(
                  widget.lang == 'mr' ? '२. रोप अवस्था' : widget.lang == 'hi' ? '2. पौध अवस्था' : '2. Seedling',
                  _t(crop.stageSeedling),
                ),
                _detailRow(
                  widget.lang == 'mr' ? '३. शाकीय वाढ अवस्था' : widget.lang == 'hi' ? '3. वानस्पतिक बढ़वार' : '3. Vegetative Growth',
                  _t(crop.stageVegetative),
                ),
                _detailRow(
                  widget.lang == 'mr' ? '४. फुलधारणा अवस्था' : widget.lang == 'hi' ? '4. फूल आने की अवस्था' : '4. Flowering',
                  _t(crop.stageFlowering),
                ),
                _detailRow(
                  widget.lang == 'mr' ? '५. परिपक्वता अवस्था' : widget.lang == 'hi' ? '5. परिपक्वता अवस्था' : '5. Maturity',
                  _t(crop.stageMaturity),
                ),
                _detailRow(
                  widget.lang == 'mr' ? '६. काढणी अवस्था' : widget.lang == 'hi' ? '6. कटाई अवस्था' : '6. Harvesting',
                  _t(crop.stageHarvesting),
                ),
              ],
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _detailCard({
    required String title,
    required IconData icon,
    required Color color,
    required ColorScheme cs,
    required List<Widget> rows,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: alpha(cs.surface, 0.96),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: alpha(color, 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: alpha(color, 0.14),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: cs.onSurface,
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 20),
          ...rows,
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(fontSize: 13.5, height: 1.4),
          ),
        ],
      ),
    );
  }
}
