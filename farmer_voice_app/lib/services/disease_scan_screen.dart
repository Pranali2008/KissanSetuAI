// ignore_for_file: deprecated_member_use

import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../app_theme.dart';

class DiseaseScanScreen extends StatefulWidget {
  final String lang;
  const DiseaseScanScreen({super.key, required this.lang});

  @override
  State<DiseaseScanScreen> createState() => _DiseaseScanScreenState();
}

class _DiseaseScanScreenState extends State<DiseaseScanScreen>
    with SingleTickerProviderStateMixin {
  File? _image;
  bool _isAnalyzing = false;
  Map<String, dynamic>? _result;
  String? _errorMsg;
  late TabController _tabController;

  final List<Map<String, dynamic>> _diseases = [
    {
      'name': 'Late Blight',
      'scientific': 'Phytophthora infestans',
      'severity': 'High',
      'affects': 'Tomato / Potato',
      'color': 0xFFDC3545,
      'symptoms': {
        'en':
            'Dark brown lesions on leaves and stems. White mold appears on leaf undersides in humid conditions. Infected fruits develop brown, firm rot.',
        'hi':
            'पत्तियों और तनों पर गहरे भूरे धब्बे। नम परिस्थितियों में पत्तियों के नीचे सफेद फफूंद दिखती है। संक्रमित फलों पर भूरा, सख्त सड़ांध होती है।',
        'mr':
            'पानांवर आणि देठांवर गडद तपकिरी डाग. दमट हवामानात पानांच्या खाली पांढरी बुरशी दिसते. संक्रमित फळांवर तपकिरी, कठीण कुजणे होते.',
      },
      'treatment': {
        'en':
            'Apply copper-based fungicides (Mancozeb or Metalaxyl) every 7 days. Remove and destroy infected plant parts immediately. Use systemic fungicides like Cymoxanil for severe infections.',
        'hi':
            'हर 7 दिनों में कॉपर-आधारित फफूंदनाशक (मैनकोजेब या मेटालैक्सिल) लगाएं। संक्रमित पौधे के हिस्सों को तुरंत हटाएं और नष्ट करें। गंभीर संक्रमण के लिए साइमोक्सानिल जैसे सिस्टमिक फफूंदनाशक का उपयोग करें।',
        'mr':
            'दर 7 दिवसांनी तांबे-आधारित बुरशीनाशक (मॅन्कोझेब किंवा मेटालैक्सिल) फवारा. संक्रमित वनस्पतींचे भाग त्वरित काढा व नष्ट करा. तीव्र संक्रमणासाठी सायमोक्सॅनिलसारखे सिस्टमिक बुरशीनाशक वापरा.',
      },
      'prevention': {
        'en':
            'Use certified blight-resistant varieties. Maintain proper plant spacing for air circulation. Avoid overhead irrigation. Rotate crops every season.',
        'hi':
            'प्रमाणित ब्लाइट-प्रतिरोधी किस्मों का उपयोग करें। वायु संचार के लिए उचित पौध अंतर बनाए रखें। ऊपरी सिंचाई से बचें। हर मौसम में फसल चक्रण करें।',
        'mr':
            'प्रमाणित ब्लाइट-प्रतिरोधक वाण वापरा. हवा खेळती राहण्यासाठी योग्य अंतर ठेवा. वरून सिंचन टाळा. प्रत्येक हंगामात पीक फेरपालट करा.',
      },
    },
    {
      'name': 'Early Blight',
      'scientific': 'Alternaria solani',
      'severity': 'Medium',
      'affects': 'Tomato / Potato',
      'color': 0xFFFD7E14,
      'symptoms': {
        'en':
            'Circular brown spots with concentric rings (target-board pattern) on older leaves. Yellowing around spots. Severe cases cause defoliation.',
        'hi':
            'पुराने पत्तियों पर केंद्रित छल्लों (टारगेट-बोर्ड पैटर्न) वाले गोलाकार भूरे धब्बे। धब्बों के आसपास पीलापन। गंभीर मामलों में पत्तियां झड़ जाती हैं।',
        'mr':
            'जुन्या पानांवर केंद्रित वर्तुळांसह (लक्ष्यफलक नमुना) गोलाकार तपकिरी डाग. डागांभोवती पिवळेपणा. गंभीर प्रकरणांमध्ये पाने गळतात.',
      },
      'treatment': {
        'en':
            'Apply Chlorothalonil or Mancozeb fungicide. Remove lower infected leaves. Ensure good drainage. Apply neem oil as an organic alternative.',
        'hi':
            'क्लोरोथालोनिल या मैनकोजेब फफूंदनाशक लगाएं। निचली संक्रमित पत्तियों को हटाएं। अच्छी जल निकासी सुनिश्चित करें। जैविक विकल्प के रूप में नीम का तेल लगाएं।',
        'mr':
            'क्लोरोथॅलोनिल किंवा मॅन्कोझेब बुरशीनाशक फवारा. खालच्या संक्रमित पानांना काढा. चांगला निचरा सुनिश्चित करा. सेंद्रिय पर्याय म्हणून कडुनिंब तेल फवारा.',
      },
      'prevention': {
        'en':
            'Use disease-free seeds. Mulch around plant base. Avoid wetting foliage when watering. Practice crop rotation with non-solanaceous plants.',
        'hi':
            'रोग-मुक्त बीजों का उपयोग करें। पौधे के आधार के आसपास मल्च करें। सिंचाई करते समय पत्तियों को गीला होने से बचाएं। गैर-सोलानेसियस पौधों के साथ फसल चक्रण करें।',
        'mr':
            'रोगमुक्त बियाणे वापरा. झाडाच्या तळाशी आच्छादन घाला. पाणी देताना पाने ओली होणे टाळा. सोलानेसी नसलेल्या वनस्पतींसोबत पीक फेरपालट करा.',
      },
    },
    {
      'name': 'Leaf Curl Virus',
      'scientific': 'Tomato Yellow Leaf Curl Virus (TYLCV)',
      'severity': 'High',
      'affects': 'Tomato / Chilli',
      'color': 0xFFDC3545,
      'symptoms': {
        'en':
            'Upward curling and yellowing of young leaves. Stunted plant growth. Reduced fruit set. Leaves become thick and leathery. Transmitted by whiteflies.',
        'hi':
            'युवा पत्तियों का ऊपर की ओर मुड़ना और पीला पड़ना। पौधे की बाधित वृद्धि। कम फल लगना। पत्तियां मोटी और चमड़े जैसी हो जाती हैं। सफेद मक्खियों द्वारा फैलता है।',
        'mr':
            'तरुण पानांचे वरच्या दिशेने वळणे आणि पिवळे होणे. वनस्पतीची खुंटलेली वाढ. कमी फळधारणा. पाने जाड व चामड्यासारखी होतात. पांढऱ्या माशांमार्फत पसरतो.',
      },
      'treatment': {
        'en':
            'No cure for infected plants. Remove and destroy affected plants. Control whitefly vector with Imidacloprid or Thiamethoxam insecticides. Use yellow sticky traps.',
        'hi':
            'संक्रमित पौधों का कोई इलाज नहीं। प्रभावित पौधों को हटाएं और नष्ट करें। इमिडाक्लोप्रिड या थायमेथोक्सम कीटनाशकों से सफेद मक्खी को नियंत्रित करें। पीले चिपकने वाले जाल का उपयोग करें।',
        'mr':
            'संक्रमित वनस्पतींवर कोणताही उपाय नाही. प्रभावित वनस्पती काढून नष्ट करा. इमिडाक्लोप्रिड किंवा थायामेथोक्सॅम कीटकनाशकांनी पांढऱ्या माशी नियंत्रित करा. पिवळे चिकट सापळे वापरा.',
      },
      'prevention': {
        'en':
            'Use virus-resistant varieties. Install insect-proof nets. Monitor and control whitefly population early. Remove volunteer plants and weeds. Reflective mulches deter whiteflies.',
        'hi':
            'वायरस-प्रतिरोधी किस्मों का उपयोग करें। कीट-रोधी जाल लगाएं। सफेद मक्खी की आबादी की जल्दी निगरानी और नियंत्रण करें। स्वयंसेवी पौधों और खरपतवारों को हटाएं।',
        'mr':
            'विषाणू-प्रतिरोधक वाण वापरा. कीटक-रोधक जाळी लावा. पांढऱ्या माशींची लोकसंख्या लवकर नियंत्रित करा. स्वयंस्फूर्त वनस्पती व तण काढा.',
      },
    },
    {
      'name': 'Powdery Mildew',
      'scientific': 'Erysiphales (various species)',
      'severity': 'Medium',
      'affects': 'Cucurbits / Grapes / Various',
      'color': 0xFFFFC107,
      'symptoms': {
        'en':
            'White powdery coating on leaf surfaces and stems. Leaves may curl, yellow, and drop. Reduced photosynthesis. Common in warm, dry conditions with cool nights.',
        'hi':
            'पत्ती की सतह और तनों पर सफेद पाउडरी परत। पत्तियां मुड़, पीली और गिर सकती हैं। प्रकाश संश्लेषण में कमी। गर्म, शुष्क दिनों और ठंडी रातों में आम।',
        'mr':
            'पानांच्या पृष्ठभागावर आणि देठांवर पांढरी भुकटीसारखी थर. पाने वळू, पिवळी होऊन गळू शकतात. प्रकाशसंश्लेषण कमी होते. उबदार, कोरड्या दिवस व थंड रात्रींमध्ये सामान्य.',
      },
      'treatment': {
        'en':
            'Apply sulfur-based fungicides or potassium bicarbonate. Neem oil spray is effective. Remove heavily infected parts. Apply Propiconazole for severe cases.',
        'hi':
            'सल्फर-आधारित फफूंदनाशक या पोटेशियम बाइकार्बोनेट लगाएं। नीम का तेल स्प्रे प्रभावी है। बुरी तरह संक्रमित हिस्सों को हटाएं। गंभीर मामलों के लिए प्रोपिकोनाजोल लगाएं।',
        'mr':
            'सल्फर-आधारित बुरशीनाशक किंवा पोटॅशियम बायकार्बोनेट फवारा. कडुनिंब तेलाची फवारणी प्रभावी आहे. जास्त संक्रमित भाग काढा. तीव्र प्रकरणांसाठी प्रोपिकोनाझोल वापरा.',
      },
      'prevention': {
        'en':
            'Choose resistant varieties. Ensure proper plant spacing. Avoid excess nitrogen fertilizer. Provide adequate air circulation. Remove plant debris after harvest.',
        'hi':
            'प्रतिरोधक किस्में चुनें। उचित पौध अंतर सुनिश्चित करें। अतिरिक्त नाइट्रोजन उर्वरक से बचें। पर्याप्त वायु संचार प्रदान करें। फसल के बाद पौधे का मलबा हटाएं।',
        'mr':
            'प्रतिरोधक वाण निवडा. योग्य अंतर सुनिश्चित करा. जास्त नायट्रोजन खत टाळा. पुरेशी हवा खेळती ठेवा. कापणीनंतर वनस्पतींचे अवशेष काढा.',
      },
    },
    {
      'name': 'Wheat Rust',
      'scientific': 'Puccinia striiformis / P. triticina',
      'severity': 'High',
      'affects': 'Wheat / Barley',
      'color': 0xFFDC3545,
      'symptoms': {
        'en':
            'Orange-yellow (stripe rust) or reddish-brown (leaf rust) pustules on leaves and stems. Severe infections turn leaves yellow and cause lodging. Reduces grain quality significantly.',
        'hi':
            'पत्तियों और तनों पर नारंगी-पीले (धारी रस्ट) या लालिमा-भूरे (पत्ती रस्ट) फुंसी। गंभीर संक्रमण से पत्तियां पीली हो जाती हैं। अनाज की गुणवत्ता काफी कम हो जाती है।',
        'mr':
            'पानांवर आणि देठांवर नारिंगी-पिवळ्या (पट्टी गंज) किंवा लालसर-तपकिरी (पर्णगंज) फोड. तीव्र संक्रमणाने पाने पिवळी होतात. धान्याचा दर्जा लक्षणीयरित्या कमी होतो.',
      },
      'treatment': {
        'en':
            'Apply Propiconazole or Tebuconazole fungicide at first sign of infection. Two sprays 15 days apart are recommended. Early detection is critical for effective control.',
        'hi':
            'संक्रमण के पहले संकेत पर प्रोपिकोनाजोल या टेबुकोनाजोल फफूंदनाशक लगाएं। 15 दिनों के अंतराल पर दो स्प्रे की सिफारिश की जाती है। प्रभावी नियंत्रण के लिए जल्दी पहचान महत्वपूर्ण है।',
        'mr':
            'संक्रमणाच्या पहिल्या चिन्हावर प्रोपिकोनाझोल किंवा टेबुकोनाझोल बुरशीनाशक फवारा. 15 दिवसांच्या अंतराने दोन फवारण्या शिफारस केल्या जातात.',
      },
      'prevention': {
        'en':
            'Use certified rust-resistant varieties. Sow at optimal time. Avoid late sowing which increases susceptibility. Balanced nutrition especially potassium. Monitor fields regularly.',
        'hi':
            'प्रमाणित रस्ट-प्रतिरोधी किस्मों का उपयोग करें। इष्टतम समय पर बोएं। देर से बुआई से बचें जो संवेदनशीलता बढ़ाती है। संतुलित पोषण विशेष रूप से पोटेशियम। खेतों की नियमित निगरानी करें।',
        'mr':
            'प्रमाणित गंज-प्रतिरोधक वाण वापरा. योग्य वेळी पेरणी करा. उशिरा पेरणी टाळा. संतुलित पोषण विशेषतः पोटॅशियम. शेताची नियमित देखरेख करा.',
      },
    },
    {
      'name': 'Rice Blast',
      'scientific': 'Magnaporthe oryzae',
      'severity': 'High',
      'affects': 'Rice',
      'color': 0xFFDC3545,
      'symptoms': {
        'en':
            'Diamond-shaped lesions with grey centers and brown borders on leaves. Neck rot causes panicles to turn white (white ear). Affects all above-ground plant parts.',
        'hi':
            'पत्तियों पर भूरे किनारों के साथ ग्रे केंद्र वाले हीरे के आकार के घाव। गर्दन सड़न से बालियां सफेद हो जाती हैं (सफेद कान)। जमीन के ऊपर के सभी पौधे के हिस्से प्रभावित होते हैं।',
        'mr':
            'पानांवर राखाडी केंद्र व तपकिरी कडा असलेले हिऱ्याच्या आकाराचे व्रण. मानेच्या सडण्यामुळे लोंबे पांढरे होतात (पांढरे कान). जमिनीवरील सर्व वनस्पती भाग प्रभावित होतात.',
      },
      'treatment': {
        'en':
            'Apply Tricyclazole or Isoprothiolane fungicide. Drain field for 3-4 days then re-flood. Avoid excess nitrogen application. Apply fungicide at tillering and panicle initiation stages.',
        'hi':
            'ट्राइसाइक्लाजोल या आइसोप्रोथियोलेन फफूंदनाशक लगाएं। 3-4 दिनों के लिए खेत को सुखाएं फिर दोबारा भरें। अत्यधिक नाइट्रोजन प्रयोग से बचें। कंसा और बाली निकलने की अवस्था में फफूंदनाशक लगाएं।',
        'mr':
            'ट्रायसायक्लाझोल किंवा आयसोप्रोथायोलेन बुरशीनाशक फवारा. 3-4 दिवस शेत कोरडे करा नंतर पुन्हा भरा. जास्त नायट्रोजन टाळा. फुटवा व लोंबी येण्याच्या अवस्थेत फवारा.',
      },
      'prevention': {
        'en':
            'Use blast-resistant varieties. Apply balanced NPK fertilizers. Avoid excessive nitrogen. Maintain proper water management. Treat seeds with Carbendazim before sowing.',
        'hi':
            'ब्लास्ट-प्रतिरोधी किस्मों का उपयोग करें। संतुलित NPK उर्वरक लगाएं। अत्यधिक नाइट्रोजन से बचें। उचित जल प्रबंधन बनाए रखें। बुआई से पहले बीज को कार्बेंडाजिम से उपचारित करें।',
        'mr':
            'ब्लास्ट-प्रतिरोधक वाण वापरा. संतुलित NPK खत वापरा. जास्त नायट्रोजन टाळा. योग्य पाणी व्यवस्थापन ठेवा. पेरणीपूर्वी बियाणे कार्बेंडाझिमने उपचार करा.',
      },
    },
    {
      'name': 'Downy Mildew',
      'scientific': 'Peronospora sp. / Pseudoperonospora sp.',
      'severity': 'Medium',
      'affects': 'Grapes / Onion / Cucurbits',
      'color': 0xFFFD7E14,
      'symptoms': {
        'en':
            'Yellow angular spots on upper leaf surface. Grey-purple fluffy growth on lower surface. Rapid spread in cool, wet weather. Leaves dry out and curl upward.',
        'hi':
            'पत्ती की ऊपरी सतह पर पीले कोणीय धब्बे। निचली सतह पर भूरे-बैंगनी रोयेंदार वृद्धि। ठंडे, गीले मौसम में तेजी से फैलाव। पत्तियां सूख जाती हैं और ऊपर मुड़ जाती हैं।',
        'mr':
            'पानांच्या वरच्या पृष्ठभागावर पिवळे कोनीय डाग. खालच्या पृष्ठभागावर राखाडी-जांभळ्या रंगाची केसाळ वाढ. थंड, ओल्या हवामानात वेगाने पसरते. पाने वाळतात व वरच्या दिशेने वळतात.',
      },
      'treatment': {
        'en':
            'Apply Metalaxyl + Mancozeb combination fungicide. Improve field drainage. Reduce humidity by improving air circulation. Remove and destroy infected crop debris.',
        'hi':
            'मेटालैक्सिल + मैनकोजेब संयोजन फफूंदनाशक लगाएं। खेत की जल निकासी में सुधार करें। वायु संचार में सुधार करके आर्द्रता कम करें। संक्रमित फसल के मलबे को हटाएं और नष्ट करें।',
        'mr':
            'मेटालैक्सिल + मॅन्कोझेब संयोजन बुरशीनाशक फवारा. शेताचा निचरा सुधारा. हवा खेळती करून आर्द्रता कमी करा. संक्रमित पिकाचे अवशेष काढून नष्ट करा.',
      },
      'prevention': {
        'en':
            'Select resistant varieties. Avoid overhead irrigation. Space plants adequately. Apply preventive fungicide sprays before disease onset in high-risk weather.',
        'hi':
            'प्रतिरोधी किस्में चुनें। ऊपरी सिंचाई से बचें। पौधों को पर्याप्त दूरी पर लगाएं। उच्च जोखिम वाले मौसम में रोग शुरू होने से पहले निवारक फफूंदनाशक स्प्रे करें।',
        'mr':
            'प्रतिरोधक वाण निवडा. वरून सिंचन टाळा. वनस्पती पुरेशा अंतरावर लावा. जोखमीच्या हवामानात रोग येण्यापूर्वी प्रतिबंधात्मक बुरशीनाशक फवारा.',
      },
    },
    {
      'name': 'Healthy Plant - No Disease Detected',
      'scientific': 'No pathogen detected',
      'severity': 'None',
      'affects': 'N/A',
      'color': 0xFF28A745,
      'symptoms': {
        'en':
            'Plant appears healthy with vibrant green leaves, normal stem thickness, and no visible lesions, spots, or discoloration. Continue routine monitoring.',
        'hi':
            'पौधा जीवंत हरी पत्तियों, सामान्य तने की मोटाई और कोई दृश्यमान घाव, धब्बे या मलिनकिरण के साथ स्वस्थ दिखता है। नियमित निगरानी जारी रखें।',
        'mr':
            'वनस्पती जोमदार हिरव्या पानांसह, सामान्य देठाची जाडी आणि कोणतेही दृश्यमान व्रण, डाग किंवा रंग बदल नसलेली निरोगी दिसते. नियमित निरीक्षण सुरू ठेवा.',
      },
      'treatment': {
        'en':
            'No treatment required. Continue regular care: balanced watering, appropriate fertilization, and periodic monitoring for early signs of any disease.',
        'hi':
            'कोई उपचार आवश्यक नहीं। नियमित देखभाल जारी रखें: संतुलित सिंचाई, उचित उर्वरण, और किसी भी बीमारी के शुरुआती संकेतों के लिए समय-समय पर निगरानी।',
        'mr':
            'कोणताही उपचार आवश्यक नाही. नियमित काळजी सुरू ठेवा: संतुलित पाणी, योग्य खत आणि कोणत्याही रोगाच्या सुरुवातीच्या लक्षणांसाठी वेळोवेळी निरीक्षण.',
      },
      'prevention': {
        'en':
            'Maintain good agricultural practices: crop rotation, balanced fertilization, proper irrigation, pest monitoring, and using certified disease-free seeds each season.',
        'hi':
            'अच्छी कृषि पद्धतियां बनाए रखें: फसल चक्रण, संतुलित उर्वरण, उचित सिंचाई, कीट निगरानी, और हर मौसम में प्रमाणित रोग-मुक्त बीजों का उपयोग।',
        'mr':
            'चांगल्या कृषी पद्धती ठेवा: पीक फेरपालट, संतुलित खत, योग्य सिंचन, कीड निरीक्षण आणि प्रत्येक हंगामात प्रमाणित रोगमुक्त बियाणे वापरा.',
      },
    },
  ];

  // --- Multilingual labels ---
  static const Map<String, Map<String, String>> _labels = {
    'title': {'en': 'Disease Scanner', 'hi': 'रोग स्कैनर', 'mr': 'रोग स्कॅनर'},
    'pickCamera': {'en': '📷 Camera', 'hi': '📷 कैमरा', 'mr': '📷 कॅमेरा'},
    'pickGallery': {'en': '🖼️ Gallery', 'hi': '🖼️ गैलरी', 'mr': '🖼️ गॅलरी'},
    'analyzing': {
      'en': '🤖 Analyzing plant health...',
      'hi': '🤖 पौधे की स्वास्थ्य जांच हो रही है...',
      'mr': '🤖 वनस्पतीच्या आरोग्याचे विश्लेषण होत आहे...',
    },
    'instruction': {
      'en': 'Take or upload a photo of\nyour plant leaf or stem',
      'hi': 'अपने पौधे की पत्ती या तने की\nफोटो लें या अपलोड करें',
      'mr': 'तुमच्या वनस्पतीच्या पान किंवा\nदेठाचा फोटो घ्या किंवा अपलोड करा',
    },
    'symptoms': {'en': 'Symptoms', 'hi': 'लक्षण', 'mr': 'लक्षणे'},
    'treatment': {'en': 'Treatment', 'hi': 'उपचार', 'mr': 'उपचार'},
    'prevention': {'en': 'Prevention', 'hi': 'रोकथाम', 'mr': 'प्रतिबंध'},
    'confidence': {
      'en': 'AI Confidence',
      'hi': 'AI विश्वास',
      'mr': 'AI विश्वास',
    },
    'retake': {'en': 'Retake', 'hi': 'दोबारा लें', 'mr': 'पुन्हा घ्या'},
    'newScan': {'en': 'New Scan', 'hi': 'नया स्कैन', 'mr': 'नवीन स्कॅन'},
    'changePhoto': {
      'en': 'Change Photo',
      'hi': 'फ़ोटो बदलें',
      'mr': 'फोटो बदला',
    },
    'disclaimer': {
      'en':
          '⚠️ This is a simulated AI analysis for demonstration purposes. For accurate crop disease diagnosis, please consult your nearest Krishi Vigyan Kendra (KVK) or agricultural expert.',
      'hi':
          '⚠️ यह प्रदर्शन उद्देश्यों के लिए एक सिमुलेटेड AI विश्लेषण है। सटीक फसल रोग निदान के लिए, कृपया अपने निकटतम कृषि विज्ञान केंद्र (KVK) या कृषि विशेषज्ञ से परामर्श करें।',
      'mr':
          '⚠️ हे प्रात्यक्षिक उद्देशांसाठी एक अनुकरणीय AI विश्लेषण आहे. अचूक पीक रोग निदानासाठी, कृपया आपल्या जवळच्या कृषी विज्ञान केंद्र (KVK) किंवा कृषी तज्ञांशी संपर्क साधा.',
    },
    'altDiagnoses': {
      'en': 'Alternative Diagnoses',
      'hi': 'वैकल्पिक निदान',
      'mr': 'पर्यायी निदान',
    },
    'severity': {'en': 'Severity', 'hi': 'गंभीरता', 'mr': 'तीव्रता'},
    'affects': {'en': 'Affects', 'hi': 'प्रभावित करता है', 'mr': 'प्रभावित'},
    'noResults': {
      'en': 'No results found',
      'hi': 'कोई परिणाम नहीं',
      'mr': 'कोणतेही परिणाम नाही',
    },
  };

  String _l(String key) => _labels[key]?[widget.lang] ?? _labels[key]?['en'] ?? key;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _analyzeImage() async {
    setState(() {
      _isAnalyzing = true;
      _result = null;
      _errorMsg = null;
    });

    // Simulate AI processing delay
    await Future.delayed(Duration(seconds: 2 + Random().nextInt(2)));

    final seed = _image!.lengthSync() % _diseases.length;
    final primaryConf = (65 + (seed * 3) % 30).toDouble();

    // Pick 2 different alternates
    final List<int> altIndices = [];
    for (int i = 0; i < _diseases.length; i++) {
      if (i != seed) altIndices.add(i);
    }
    altIndices.shuffle(Random(seed));
    final alt1Idx = altIndices[0];
    final alt2Idx = altIndices[1];

    final remaining = 100.0 - primaryConf;
    final alt1Conf = (remaining * 0.6).roundToDouble();
    final alt2Conf = (remaining * 0.4).roundToDouble();

    final result = {
      'primary': _diseases[seed],
      'primaryConf': primaryConf,
      'alts': [
        {'disease': _diseases[alt1Idx], 'conf': alt1Conf},
        {'disease': _diseases[alt2Idx], 'conf': alt2Conf},
      ],
      'imageFile': _image,
    };

    if (mounted) {
      setState(() {
        _isAnalyzing = false;
        _result = result;
      });
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: source, imageQuality: 80);
      if (picked != null && mounted) {
        setState(() {
          _image = File(picked.path);
          _result = null;
          _errorMsg = null;
        });
        await _analyzeImage();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMsg = 'Could not pick image: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final brand = brandOf(context);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [brand.withOpacity(0.08), Colors.white],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildTopBar(context, brand),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: _buildBody(context, brand),
                ),
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

  Widget _buildBody(BuildContext context, Color brand) {
    if (_image == null) {
      return _buildPickerUI(context, brand);
    } else if (_isAnalyzing) {
      return _buildAnalyzingUI(context, brand);
    } else if (_result != null) {
      return _buildResultUI(context, brand);
    }
    return _buildPickerUI(context, brand);
  }

  Widget _buildPickerUI(BuildContext context, Color brand) {
    return Column(
      children: [
        const SizedBox(height: 24),
        // Dashed border upload area
        Container(
          height: 220,
          width: double.infinity,
          decoration: BoxDecoration(
            color: brand.withOpacity(0.04),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: brand.withOpacity(0.3),
              width: 2,
              strokeAlign: BorderSide.strokeAlignInside,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('🌿', style: TextStyle(fontSize: 60)),
              const SizedBox(height: 16),
              Text(
                _l('instruction'),
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        if (_errorMsg != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _errorMsg!,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
        const SizedBox(height: 28),
        Row(
          children: [
            Expanded(
              child: _BigPickButton(
                label: _l('pickCamera'),
                onTap: () => _pickImage(ImageSource.camera),
                brand: brand,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _BigPickButton(
                label: _l('pickGallery'),
                onTap: () => _pickImage(ImageSource.gallery),
                brand: brand,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildAnalyzingUI(BuildContext context, Color brand) {
    return Column(
      children: [
        const SizedBox(height: 16),
        _buildImageCard(height: 200),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: brand.withOpacity(0.12),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Text(
                _l('analyzing'),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              LinearProgressIndicator(
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(brand),
                minHeight: 6,
                borderRadius: BorderRadius.circular(8),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _buildChangePhotoButton(brand),
      ],
    );
  }

  Widget _buildResultUI(BuildContext context, Color brand) {
    final primary = _result!['primary'] as Map<String, dynamic>;
    final primaryConf = _result!['primaryConf'] as double;
    final alts = _result!['alts'] as List<dynamic>;
    final diseaseColor = Color(primary['color'] as int);
    final severity = primary['severity'] as String;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        _buildImageCard(height: 180),
        const SizedBox(height: 16),
        // Main result card
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: diseaseColor.withOpacity(0.15),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top accent bar
              Container(
                height: 5,
                decoration: BoxDecoration(
                  color: diseaseColor,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Severity badge
                    Row(
                      children: [
                        _SeverityBadge(severity: severity, color: diseaseColor),
                        const Spacer(),
                        Text(
                          primary['affects'] as String,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // Disease name
                    Text(
                      primary['name'] as String,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: diseaseColor,
                      ),
                    ),
                    Text(
                      primary['scientific'] as String,
                      style: TextStyle(
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                        color: Colors.grey[500],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Confidence bar
                    Row(
                      children: [
                        Text(
                          '${_l('confidence')}: ',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '${primaryConf.toInt()}%',
                          style: TextStyle(
                            fontSize: 13,
                            color: diseaseColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    LinearProgressIndicator(
                      value: primaryConf / 100,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(diseaseColor),
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    const SizedBox(height: 16),
                    // Alternate diagnoses
                    Text(
                      _l('altDiagnoses'),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...alts.map((alt) {
                      final d = alt['disease'] as Map<String, dynamic>;
                      final c = alt['conf'] as double;
                      final ac = Color(d['color'] as int);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: ac,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                d['name'] as String,
                                style: const TextStyle(fontSize: 13),
                              ),
                            ),
                            Text(
                              '${c.toInt()}%',
                              style: TextStyle(
                                fontSize: 13,
                                color: ac,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Tabs
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              TabBar(
                controller: _tabController,
                labelColor: brand,
                unselectedLabelColor: Colors.grey,
                indicatorColor: brand,
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                tabs: [
                  Tab(text: _l('symptoms')),
                  Tab(text: _l('treatment')),
                  Tab(text: _l('prevention')),
                ],
              ),
              Container(height: 1, color: Colors.grey[200]),
              SizedBox(
                height: 160,
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _TabContent(
                      text: (primary['symptoms']
                              as Map<String, dynamic>)[widget.lang] ??
                          (primary['symptoms'] as Map<String, dynamic>)['en'],
                    ),
                    _TabContent(
                      text: (primary['treatment']
                              as Map<String, dynamic>)[widget.lang] ??
                          (primary['treatment'] as Map<String, dynamic>)['en'],
                    ),
                    _TabContent(
                      text: (primary['prevention']
                              as Map<String, dynamic>)[widget.lang] ??
                          (primary['prevention'] as Map<String, dynamic>)['en'],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Action buttons
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _pickImage(ImageSource.camera),
                icon: const Icon(Icons.camera_alt_rounded),
                label: Text(_l('retake')),
                style: OutlinedButton.styleFrom(
                  foregroundColor: brand,
                  side: BorderSide(color: brand),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton.icon(
                onPressed: () {
                  setState(() {
                    _image = null;
                    _result = null;
                    _errorMsg = null;
                  });
                },
                icon: const Icon(Icons.qr_code_scanner_rounded),
                label: Text(_l('newScan')),
                style: FilledButton.styleFrom(
                  backgroundColor: brand,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Disclaimer card
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF3CD),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFFFCA2C).withOpacity(0.5)),
          ),
          child: Text(
            _l('disclaimer'),
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF664D03),
              height: 1.5,
            ),
          ),
        ),
        const SizedBox(height: 12),
        _buildChangePhotoButton(brand),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildImageCard({required double height}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Image.file(
        _image!,
        height: height,
        width: double.infinity,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _buildChangePhotoButton(Color brand) {
    return Center(
      child: TextButton.icon(
        onPressed: () => _pickImage(ImageSource.gallery),
        icon: Icon(Icons.photo_library_rounded, size: 18, color: brand),
        label: Text(_l('changePhoto'), style: TextStyle(color: brand)),
      ),
    );
  }
}

// --- Helper Widgets ---

class _BigPickButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final Color brand;

  const _BigPickButton({
    required this.label,
    required this.onTap,
    required this.brand,
  });

  @override
  Widget build(BuildContext context) {
    return FilledButton.tonal(
      onPressed: onTap,
      style: FilledButton.styleFrom(
        backgroundColor: brand.withOpacity(0.12),
        foregroundColor: brand,
        padding: const EdgeInsets.symmetric(vertical: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _SeverityBadge extends StatelessWidget {
  final String severity;
  final Color color;

  const _SeverityBadge({required this.severity, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        severity == 'None'
            ? '✅ $severity'
            : severity == 'High'
                ? '🔴 $severity Risk'
                : '🟡 $severity Risk',
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _TabContent extends StatelessWidget {
  final String? text;

  const _TabContent({required this.text});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Text(
        text ?? '',
        style: const TextStyle(fontSize: 14, height: 1.6, color: Colors.black87),
      ),
    );
  }
}
