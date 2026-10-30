import 'dart:async';
import 'dart:convert';
import 'dart:io' as io;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:url_launcher/url_launcher.dart';

import 'farmer_background.dart';
import 'app_theme.dart';
import 'service_tile.dart';
import 'services/farmer_api_service.dart';
import 'services/sound_service.dart';
import 'crops_screen.dart';
import 'market_screen.dart';
import 'profile_screen.dart';

// ======================================================================
//  TEXT IN 3 LANGUAGES  (en = English, hi = Hindi, mr = Marathi)
// ======================================================================
const Map<String, Map<String, String>> _ui = {
  'greetA': {'en': 'Namaste, ', 'hi': 'नमस्ते ', 'mr': 'नमस्कार '},
  'greetB': {'en': 'Farmer!', 'hi': 'किसान भाई!', 'mr': 'शेतकरी मित्रा!'},
  'badge': {
    'en': 'Multilingual · Offline-ready',
    'hi': 'बहुभाषी · ऑफ़लाइन सक्षम',
    'mr': 'बहुभाषिक · ऑफलाइन सक्षम',
  },
  'heroSub': {
    'en': 'Ask about crops, weather, diseases and mandi prices — in your own language, even without internet.',
    'hi': 'फसल, मौसम, रोग और मंडी भाव पूछें — अपनी भाषा में, बिना इंटरनेट भी।',
    'mr':
        'पीक, हवामान, रोग आणि बाजारभाव विचारा — तुमच्या भाषेत, इंटरनेटशिवायही.',
  },
  'btnAsk': {
    'en': 'Ask by voice',
    'hi': 'आवाज़ से पूछें',
    'mr': 'आवाजाने विचारा',
  },
  'btnStop': {'en': 'Stop', 'hi': 'रोकें', 'mr': 'थांबा'},
  'listening': {'en': 'Listening…', 'hi': 'सुन रहा हूँ…', 'mr': 'ऐकत आहे…'},
  'offTitle': {'en': 'Offline mode', 'hi': 'ऑफ़लाइन मोड', 'mr': 'ऑफलाइन मोड'},
  'sunny': {'en': 'Sunny', 'hi': 'धूप', 'mr': 'ऊन'},
  'hum': {'en': 'Humidity 62%', 'hi': 'नमी 62%', 'mr': 'आर्द्रता 62%'},
  'wind': {
    'en': 'Wind 12 km/h',
    'hi': 'हवा 12 किमी/घं',
    'mr': 'वारा 12 किमी/तास',
  },
  'rain': {'en': 'Rain chance 10%', 'hi': 'बारिश 10%', 'mr': 'पाऊस 10%'},
  'quick': {'en': 'Quick services', 'hi': 'त्वरित सेवाएँ', 'mr': 'जलद सेवा'},
  'tips': {
    'en': 'Smart farming tips',
    'hi': 'स्मार्ट खेती टिप्स',
    'mr': 'स्मार्ट शेती टिप्स',
  },
  'calendar': {'en': 'Crop calendar', 'hi': 'फसल कैलेंडर', 'mr': 'पीक कॅलेंडर'},
  'schemes': {
    'en': 'Government schemes',
    'hi': 'सरकारी योजनाएँ',
    'mr': 'सरकारी योजना',
  },
  'nHome': {'en': 'Home', 'hi': 'होम', 'mr': 'मुख्यपृष्ठ'},
  'nCrops': {'en': 'Crops', 'hi': 'फसलें', 'mr': 'पिके'},
  'nMarket': {'en': 'Market', 'hi': 'मंडी', 'mr': 'बाजार'},
  'nProfile': {'en': 'Profile', 'hi': 'प्रोफ़ाइल', 'mr': 'प्रोफाइल'},
  'sCrop': {'en': 'Crop Advice', 'hi': 'फसल सलाह', 'mr': 'पीक सल्ला'},
  'sDisease': {'en': 'Disease Scan', 'hi': 'रोग जाँच', 'mr': 'रोग तपासणी'},
  'sMarket': {'en': 'Market Price', 'hi': 'मंडी भाव', 'mr': 'बाजारभाव'},
  'sWeather': {'en': 'Weather', 'hi': 'मौसम', 'mr': 'हवामान'},
  'sSoil': {'en': 'Soil Health', 'hi': 'मिट्टी स्वास्थ्य', 'mr': 'माती आरोग्य'},
  'sCalculator': {'en': 'Smart Calculator', 'hi': 'स्मार्ट कैलकुलेटर', 'mr': 'स्मार्ट कॅल्क्युलेटर'},
  'sMachinery': {'en': 'Farm Machinery', 'hi': 'कृषि यंत्र गाइड', 'mr': 'शेती यंत्रे'},
  'sSchemes': {'en': 'Schemes', 'hi': 'योजनाएँ', 'mr': 'योजना'},
  'light': {'en': 'Light', 'hi': 'लाइट', 'mr': 'लाईट'},
  'darkM': {'en': 'Dark', 'hi': 'डार्क', 'mr': 'डार्क'},
  'system': {
    'en': 'System default',
    'hi': 'सिस्टम डिफ़ॉल्ट',
    'mr': 'सिस्टम डीफॉल्ट',
  },
};

// ---------------------------------------------------------------- data
class _Service {
  final String key;
  final IconData icon;
  final ServiceFx fx;
  final List<Color> colors;
  const _Service(this.key, this.icon, this.fx, this.colors);
}

const _services = [
  _Service('sCrop', Icons.grass_rounded, ServiceFx.sprout, [
    Color(0xFF11998E),
    Color(0xFF38EF7D),
  ]),
  _Service('sDisease', Icons.camera_alt_rounded, ServiceFx.scan, [
    Color(0xFFFF416C),
    Color(0xFFFF8E53),
  ]),
  _Service('sWeather', Icons.cloud_rounded, ServiceFx.sun, [
    Color(0xFF0083B0),
    Color(0xFF00B4DB),
  ]),
  _Service('sSoil', Icons.terrain_rounded, ServiceFx.drop, [
    Color(0xFF8E2DE2),
    Color(0xFF4A00E0),
  ]),
  _Service('sCalculator', Icons.calculate_rounded, ServiceFx.bounce, [
    Color(0xFFF12711),
    Color(0xFFF5AF19),
  ]),
  _Service('sMachinery', Icons.agriculture_rounded, ServiceFx.float, [
    Color(0xFF1E7E34),
    Color(0xFF28A745),
  ]),
];

class _Tip {
  final String emoji;
  final Map<String, String> title;
  final Map<String, String> body;
  final List<Color> colors;
  const _Tip(this.emoji, this.title, this.body, this.colors);
}

const _tipData = [
  _Tip(
    '💧',
    {'en': 'Drip irrigation', 'hi': 'ड्रिप सिंचाई', 'mr': 'ठिबक सिंचन'},
    {
      'en': 'Drip irrigation can save 30–50% water and often improves yield.',
      'hi': 'टपक सिंचाई से 30–50% तक पानी की बचत होती है और पैदावार बढ़ती है।',
      'mr': 'ठिबक सिंचनाने ३०–५०% पाण्याची बचत होते आणि उत्पादन वाढते.',
    },
    [Color(0xFF0B6E8A), Color(0xFF1FA2C9)],
  ),
  _Tip(
    '🧪',
    {
      'en': 'Test soil before sowing',
      'hi': 'बुवाई से पहले मिट्टी जाँचें',
      'mr': 'पेरणीपूर्वी माती तपासा',
    },
    {
      'en': 'Know the right fertilizer dose, cut cost and protect your land.',
      'hi': 'सही खाद की मात्रा पता चलती है, खर्च घटता है।',
      'mr': 'योग्य खताची मात्रा समजते आणि खर्च कमी होतो.',
    },
    [Color(0xFF5B21B6), Color(0xFF7C3AED)],
  ),
  _Tip(
    '🔄',
    {
      'en': 'Rotate your crops',
      'hi': 'फसल चक्र अपनाएँ',
      'mr': 'पीक फेरपालट करा',
    },
    {
      'en':
          'Pulses fix nitrogen in the soil and reduce pests for the next crop.',
      'hi': 'दलहनी फसलें मिट्टी में नाइट्रोजन बढ़ाती हैं और कीट घटाती हैं।',
      'mr': 'कडधान्य पिके जमिनीत नत्र वाढवतात आणि कीड कमी होते.',
    },
    [Color(0xFF14532D), Color(0xFF2E9E5B)],
  ),
  _Tip(
    '🌾',
    {
      'en': 'Mulch to save moisture',
      'hi': 'मल्चिंग से नमी बचाएँ',
      'mr': 'आच्छादनाने ओलावा टिकवा',
    },
    {
      'en': 'A layer of straw or leaves holds moisture and reduces weeds.',
      'hi': 'पुआल या पत्तों की परत नमी रोकती है और खरपतवार घटाती है।',
      'mr': 'पेंढा किंवा पाल्याचा थर ओलावा टिकवतो आणि तण कमी करतो.',
    },
    [Color(0xFFB45309), Color(0xFFF59E0B)],
  ),
];

class _Season {
  final String emoji;
  final Map<String, String> name;
  final String months;
  final Map<String, List<String>> crops;
  final List<Color> colors;
  const _Season(this.emoji, this.name, this.months, this.crops, this.colors);
}

const _seasons = [
  _Season(
    '🌧️',
    {'en': 'Kharif', 'hi': 'खरीफ', 'mr': 'खरीप'},
    'Jun – Oct',
    {
      'en': ['Rice', 'Maize', 'Cotton', 'Soybean', 'Bajra'],
      'hi': ['धान', 'मक्का', 'कपास', 'सोयाबीन', 'बाजरा'],
      'mr': ['भात', 'मका', 'कापूस', 'सोयाबीन', 'बाजरी'],
    },
    [Color(0xFF00C6FF), Color(0xFF0072FF)],
  ),
  _Season(
    '❄️',
    {'en': 'Rabi', 'hi': 'रबी', 'mr': 'रब्बी'},
    'Oct – Mar',
    {
      'en': ['Wheat', 'Gram', 'Mustard', 'Barley'],
      'hi': ['गेहूँ', 'चना', 'सरसों', 'जौ'],
      'mr': ['गहू', 'हरभरा', 'मोहरी', 'बार्ली'],
    },
    [Color(0xFFFFB347), Color(0xFFFF7E00)],
  ),
  _Season(
    '☀️',
    {'en': 'Zaid', 'hi': 'जायद', 'mr': 'उन्हाळी'},
    'Mar – Jun',
    {
      'en': ['Watermelon', 'Cucumber', 'Moong'],
      'hi': ['तरबूज़', 'खीरा', 'मूँग'],
      'mr': ['कलिंगड', 'काकडी', 'मूग'],
    },
    [Color(0xFFF953C6), Color(0xFFB91D73)],
  ),
];

class _Scheme {
  final String name;
  final IconData icon;
  final Map<String, String> info;
  final List<Color> colors;
  final String url;
  const _Scheme(this.name, this.icon, this.info, this.colors, this.url);
}

const _schemeData = [
  _Scheme(
    'PM-KISAN',
    Icons.savings_rounded,
    {
      'en': '₹6,000/year income support in 3 installments',
      'hi': '₹6,000 सालाना सहायता, 3 किस्तों में',
      'mr': '₹६,००० वार्षिक मदत, ३ हप्त्यांत',
    },
    [Color(0xFF11998E), Color(0xFF38EF7D)],
    'https://pmkisan.gov.in/',
  ),
  _Scheme(
    'PMFBY',
    Icons.shield_rounded,
    {
      'en': 'Crop insurance against drought, flood & pests',
      'hi': 'सूखा, बाढ़ और कीट से फसल बीमा',
      'mr': 'दुष्काळ, पूर व कीड यापासून पीक विमा',
    },
    [Color(0xFF396AFC), Color(0xFF2948FF)],
    'https://pmfby.gov.in/',
  ),
  _Scheme(
    'MahaDBT Farmer',
    Icons.agriculture_rounded,
    {
      'en': '50-80% subsidy on tractor, drip & machinery',
      'hi': 'ट्रैक्टर, ड्रिप व कृषि यंत्रों पर 50-80% अनुदान',
      'mr': 'ट्रॅक्टर, ठिबक व अवजारांवर ५०-८०% शासकीय अनुदान',
    },
    [Color(0xFF0083B0), Color(0xFF00B4DB)],
    'https://mahadbt.maharashtra.gov.in/Farmer/FarmerHome/FarmerHome',
  ),
  _Scheme(
    'PM-KUSUM',
    Icons.solar_power_rounded,
    {
      'en': '90% subsidy for solar irrigation water pumps',
      'hi': 'सोलर कृषि पंप पर 90% तक सब्सिडी',
      'mr': 'सौर कृषी पंपासाठी ९०% पर्यंत शासकीय अनुदान',
    },
    [Color(0xFFF12711), Color(0xFFF5AF19)],
    'https://pmkusum.mnre.gov.in/',
  ),
  _Scheme(
    'Kisan Credit Card',
    Icons.credit_card_rounded,
    {
      'en': 'Low-interest credit for seeds, fertilizer & more',
      'hi': 'बीज-खाद के लिए कम ब्याज पर कर्ज',
      'mr': 'बियाणे-खतांसाठी कमी व्याजाचे कर्ज',
    },
    [Color(0xFFFF512F), Color(0xFFF09819)],
    'https://www.myscheme.gov.in/schemes/kcc',
  ),
  _Scheme(
    'Soil Health Card',
    Icons.science_rounded,
    {
      'en': 'Free soil test with fertilizer advice',
      'hi': 'मुफ्त मिट्टी जाँच व खाद सलाह',
      'mr': 'मोफत माती तपासणी व खत सल्ला',
    },
    [Color(0xFF8E2DE2), Color(0xFFC471ED)],
    'https://soilhealth.dac.gov.in/',
  ),
];

// ======================================================================
//  Small fade + slide-up animation used when sections appear
// ======================================================================
class _Reveal extends StatefulWidget {
  final int index;
  final Widget child;
  const _Reveal({required this.index, required this.child});

  @override
  State<_Reveal> createState() => _RevealState();
}

class _RevealState extends State<_Reveal> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 550),
  );
  late final Animation<double> _curve = CurvedAnimation(
    parent: _c,
    curve: Curves.easeOutCubic,
  );

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 90 * widget.index.clamp(0, 6)), () {
      if (mounted) _c.forward();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _curve,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.08),
          end: Offset.zero,
        ).animate(_curve),
        child: widget.child,
      ),
    );
  }
}

// ======================================================================
//  HOME SCREEN
// ======================================================================
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  String _lang = 'en';
  bool _offline = true;
  bool _listening = false;
  int _nav = 0;

  int _tipPage = 0;
  final TextEditingController _questionController = TextEditingController();

  bool _isAsking = false;
  // Identifies the current request so cancelled/old answers are ignored.
  int _requestId = 0;
  // Voice input and spoken answers
  final SpeechToText _speech = SpeechToText();
  final FlutterTts _tts = FlutterTts();

  bool _speechAvailable = false;
  bool _isSpeaking = false;
  bool _voiceSubmitted = false;
  String? _answer;
  String? _answerSource;
  String? _answerLanguage;
  String? _answerType;
  String? _answerError;
  Map<String, dynamic>? _answerExplanation;
  String? _answerWarning;
  bool _databaseMatch = false;
  String? _matchedQuestion;

  // Real-time live weather state
  String _liveTemp = '32°C';
  String _liveWeatherCondition = 'Sunny';
  String _liveHumidity = 'Humidity 39%';
  String _liveWind = 'Wind 6 km/h';
  String _liveRainChance = 'Rain 10%';
  final String _liveLocation = 'Pune';

  late final AnimationController _anim = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 2),
  )..repeat();
  late final AnimationController _slow = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 14),
  )..repeat();

  final ScrollController _scrollCtrl = ScrollController();
  final ValueNotifier<double> _offset = ValueNotifier<double>(0);
  final PageController _tipCtrl = PageController(viewportFraction: 0.88);
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    unawaited(_initializeVoice());
    unawaited(_fetchLiveWeather());
    _scrollCtrl.addListener(() {
      _offset.value = _scrollCtrl.hasClients
          ? math.max(0.0, _scrollCtrl.offset)
          : 0.0;
    });
    // tips slide automatically every 5 seconds
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!_tipCtrl.hasClients) return;
      _tipCtrl.animateToPage(
        (_tipPage + 1) % _tipData.length,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _anim.dispose();
    _slow.dispose();
    _scrollCtrl.dispose();
    _offset.dispose();
    _tipCtrl.dispose();
    _questionController.dispose();

    unawaited(_speech.cancel());
    unawaited(_tts.stop());

    super.dispose();
  }

  String _s(String key) => _ui[key]![_lang]!;
  String _p(Map<String, String> m) => m[_lang]!;

  void _toast(String msg) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _cancelQuestion() async {
    // Ignore any API response that arrives after cancellation.
    _requestId++;

    try {
      await _speech.stop();
    } catch (e) {
      debugPrint('Could not stop listening: $e');
    }

    try {
      await _tts.stop();
    } catch (e) {
      debugPrint('Could not stop spoken answer: $e');
    }

    if (!mounted) return;
    setState(() {
      _isAsking = false;
      _listening = false;
      _isSpeaking = false;
      _voiceSubmitted = false;
      _answerError = 'Request cancelled.';
    });
  }

  void _changeLanguage(String newLanguage) {
    if (_lang == newLanguage) return;

    // Make any pending request stale before changing language.
    _requestId++;
    unawaited(_speech.stop());
    unawaited(_tts.stop());

    setState(() {
      _lang = newLanguage;
      _questionController.clear();
      _answer = null;
      _answerSource = null;
      _answerLanguage = null;
      _answerType = null;
      _answerError = null;
      _answerExplanation = null;
      _answerWarning = null;
      _databaseMatch = false;
      _matchedQuestion = null;
      _isAsking = false;
      _listening = false;
      _isSpeaking = false;
      _voiceSubmitted = false;
    });
  }

  Future<void> _askQuestion() async {
    final question = _questionController.text.trim();
    if (question.length < 2 || _isAsking) return;

    final int currentRequestId = ++_requestId;
    final String requestedLanguage = {
      'en': 'English',
      'hi': 'Hindi',
      'mr': 'Marathi',
    }[_lang]!;

    setState(() {
      _isAsking = true;
      _answerError = null;
      _answer = null;
      _answerSource = null;
      _answerLanguage = null;
      _answerType = null;
      _answerExplanation = null;
      _answerWarning = null;
      _databaseMatch = false;
      _matchedQuestion = null;
    });

    try {
      final result = await FarmerApiService.askQuestion(
        question: question,
        language: requestedLanguage,
      );

      if (!mounted || currentRequestId != _requestId) return;

      final answerText = (result['answer'] ?? '').toString().trim();
      final explanationData = result['explanation'] is Map<String, dynamic>
          ? result['explanation'] as Map<String, dynamic>
          : (result['explanation'] is Map
                ? Map<String, dynamic>.from(result['explanation'])
                : null);

      setState(() {
        _answer = answerText.isEmpty ? null : answerText;
        _answerSource = result['source']?.toString();
        _answerLanguage = result['language']?.toString();
        _answerType = result['answer_type']?.toString();
        _databaseMatch = result['database_match'] == true;
        _matchedQuestion = result['matched_question']?.toString();
        _answerWarning = result['warning']?.toString();
        _answerExplanation = explanationData;
        _answerError = answerText.isEmpty
            ? 'No answer was returned. Please try again.'
            : null;
        _isAsking = false;
      });

      if (answerText.isNotEmpty && mounted && currentRequestId == _requestId) {
        await _speakAnswer(answerText);
      }
    } catch (e) {
      if (!mounted || currentRequestId != _requestId) return;

      debugPrint('Question request failed: $e');
      setState(() {
        _answerError = 'Unable to get an answer. Please check your backend connection and try again.';
      });
    } finally {
      if (mounted && currentRequestId == _requestId && _isAsking) {
        setState(() {
          _isAsking = false;
        });
      }
    }
  }

  // ------------------------------------------------------
  // Voice initialization
  Future<void> _initializeVoice() async {
    try {
      final available = await _speech.initialize(
        onStatus: (status) {
          if (!mounted) return;

          if (status == 'done' || status == 'notListening') {
            setState(() => _listening = false);
          }
        },
        onError: (error) {
          if (!mounted) return;

          setState(() => _listening = false);
          _toast('Microphone error: ${error.errorMsg}');
        },
      );

      await _tts.setSpeechRate(0.95);
      await _tts.setVolume(1.0);
      await _tts.awaitSpeakCompletion(true);

      if (!mounted) return;
      setState(() => _speechAvailable = available);
    } catch (e) {
      if (!mounted) return;
      setState(() => _speechAvailable = false);
      debugPrint('Voice initialization failed: $e');
    }
  }

  // ------------------------------------------------------
  // Language settings for speech recognition and speaking
  String get _voiceLocale {
    switch (_lang) {
      case 'hi':
        return 'hi-IN';
      case 'mr':
        return 'mr-IN';
      default:
        return 'en-IN';
    }
  }

  // ------------------------------------------------------
  // Start listening to the farmer
  Future<void> _startListening() async {
    if (_isAsking) return;

    if (!_speechAvailable) {
      await _initializeVoice();
    }

    if (!_speechAvailable) {
      _toast(
        'Speech recognition is unavailable. Check microphone permissions.',
      );
      return;
    }

    await _tts.stop();
    _voiceSubmitted = false;
    _questionController.clear();
    await SoundService.playListeningStart();

    try {
      await _speech.listen(
        onResult: (result) {
          if (!mounted) return;

          setState(() {
            _questionController.text = result.recognizedWords;
          });

          if (result.finalResult && !_voiceSubmitted) {
            final question = result.recognizedWords.trim();

            if (question.length >= 2) {
              _voiceSubmitted = true;
              unawaited(_stopListening());
              unawaited(_askQuestion());
            }
          }
        },
        listenOptions: SpeechListenOptions(
          localeId: _voiceLocale,
          listenFor: const Duration(seconds: 30),
          pauseFor: const Duration(seconds: 4),
          partialResults: true,
        ),
      );

      if (mounted) {
        setState(() {
          _listening = true;
        });
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _listening = false;
      });

      _toast('Could not start voice recognition: $e');
    }
  }

  // ------------------------------------------------------
  // Stop listening
  Future<void> _stopListening() async {
    try {
      await _speech.stop();
      await SoundService.playListeningStop();
    } catch (e) {
      debugPrint('Could not stop speech recognition: $e');
    }

    if (mounted) {
      setState(() => _listening = false);
    }
  }

  // ------------------------------------------------------
  // Speak the answer aloud
  Future<void> _speakAnswer(String text) async {
    if (text.trim().isEmpty) return;

    try {
      await _tts.stop();

      await _tts.setLanguage(_voiceLocale);

      if (!mounted) return;
      setState(() => _isSpeaking = true);

      await _tts.speak(text);
    } catch (e) {
      debugPrint('Text-to-speech error: $e');
      if (mounted) {
        _toast(
          'Could not speak the answer. '
          'Check the available browser voices.',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSpeaking = false);
      }
    }
  }

  // ------------------------------------------------------
  // Stop speaking
  Future<void> _stopSpeaking() async {
    await _tts.stop();

    if (mounted) {
      setState(() => _isSpeaking = false);
    }
  }

  // -------------------------------------------------------------- build
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final brand = brandOf(context);

    return Scaffold(
      extendBody: true,
      body: FarmerBackground(
        scroll: _offset,
        child: IndexedStack(
          index: _nav,
          children: [
            _homeTab(cs, brand),
            CropsScreen(lang: _lang),
            MarketScreen(lang: _lang),
            ProfileScreen(
              lang: _lang,
              onLanguageChanged: (newLang) => _changeLanguage(newLang),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _bottomBar(cs, brand),
    );
  }

  Widget _homeTab(ColorScheme cs, Color brand) {
    return SafeArea(
      child: ListView(
        controller: _scrollCtrl,
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 110),
        children: [
          _Reveal(index: 0, child: _topBar(cs, brand)),
          const SizedBox(height: 10),
          _Reveal(index: 1, child: _languagePill(cs, brand)),
          _Reveal(index: 2, child: _hero(cs, brand)),
          _questionCard(cs, brand),

          const SizedBox(height: 18),
          _Reveal(index: 3, child: _weatherCard(cs)),

          const SizedBox(height: 22),
          _title(_s('quick'), cs),
          const SizedBox(height: 12),
          _servicesGrid(),
          const SizedBox(height: 24),
          _title(_s('tips'), cs),
          const SizedBox(height: 12),
          _tipCarousel(brand),
          const SizedBox(height: 24),
          _title(_s('calendar'), cs),
          const SizedBox(height: 12),
          ..._seasons.map((s) => _seasonCard(s, cs)),
          const SizedBox(height: 12),
          _title(_s('schemes'), cs),
          const SizedBox(height: 12),
          ..._schemeData.map((s) => _schemeTile(s, cs)),
        ],
      ),
    );
  }

  // ------------------------------------------------------ small helpers
  Widget _card(
    ColorScheme cs, {
    required Widget child,
    EdgeInsets padding = const EdgeInsets.all(14),
    double radius = 20,
  }) {
    final dark = cs.brightness == Brightness.dark;
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: alpha(cs.surface, 0.97),
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: alpha(cs.outlineVariant, 0.7)),
        boxShadow: [
          BoxShadow(
            color: alpha(Colors.black, dark ? 0.30 : 0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _title(String text, ColorScheme cs) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(3),
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF2EB86A), Color(0xFF00B0FF)],
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          text,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.2,
            color: cs.onSurface,
          ),
        ),
      ],
    );
  }

  // ------------------------------------------------------------ top bar
  Widget _topBar(ColorScheme cs, Color brand) {
    return _card(
      cs,
      radius: 18,
      padding: const EdgeInsets.fromLTRB(14, 8, 6, 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              gradient: LinearGradient(
                colors: [brand, const Color(0xFF2E9E5B)],
              ),
            ),
            child: const Icon(
              Icons.agriculture_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            'KissanSetu AI',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
              color: brand,
            ),
          ),
          const Spacer(),
          // Android-style theme chooser: Light / Dark / System
          PopupMenuButton<ThemeMode>(
            tooltip: 'Theme',
            icon: Icon(
              cs.brightness == Brightness.dark
                  ? Icons.dark_mode_rounded
                  : Icons.light_mode_rounded,
              color: brand,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            onSelected: (m) => themeNotifier.value = m,
            itemBuilder: (_) => [
              PopupMenuItem(
                value: ThemeMode.light,
                child: Row(
                  children: [
                    const Icon(Icons.light_mode_rounded, color: Colors.orange),
                    const SizedBox(width: 10),
                    Text(_s('light')),
                  ],
                ),
              ),
              PopupMenuItem(
                value: ThemeMode.dark,
                child: Row(
                  children: [
                    const Icon(Icons.dark_mode_rounded, color: Colors.indigo),
                    const SizedBox(width: 10),
                    Text(_s('darkM')),
                  ],
                ),
              ),
              PopupMenuItem(
                value: ThemeMode.system,
                child: Row(
                  children: [
                    const Icon(Icons.phone_android_rounded, color: Colors.teal),
                    const SizedBox(width: 10),
                    Text(_s('system')),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// English | हिन्दी | मराठी with a sliding highlight.
  Widget _languagePill(ColorScheme cs, Color brand) {
    const langs = ['en', 'hi', 'mr'];
    const labels = ['English', 'हिन्दी', 'मराठी'];
    final idx = langs.indexOf(_lang);

    return Container(
      height: 44,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: alpha(cs.surface, 0.97),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: alpha(cs.outlineVariant, 0.8)),
      ),
      child: Stack(
        children: [
          AnimatedAlign(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            alignment: Alignment(-1.0 + idx.toDouble(), 0),
            child: FractionallySizedBox(
              widthFactor: 1 / 3,
              heightFactor: 1,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  gradient: LinearGradient(
                    colors: [brand, const Color(0xFF2EB86A)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: alpha(brand, 0.35),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Row(
            children: List.generate(3, (i) {
              return Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => _changeLanguage(langs[i]),
                  child: Center(
                    child: AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 200),
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                        color: i == idx ? Colors.white : cs.onSurface,
                      ),
                      child: Text(labels[i]),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------------------- hero
  Widget _hero(ColorScheme cs, Color brand) {
    final green = cs.brightness == Brightness.dark
        ? const Color(0xFF4CC26F)
        : const Color(0xFF1B7A34);

    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 24, 4, 26),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // small outlined badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: alpha(cs.surface, 0.85),
              border: Border.all(color: alpha(brand, 0.35)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: green,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _s('badge'),
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: brand,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(text: _s('greetA')),
                TextSpan(
                  text: _s('greetB'),
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    color: green,
                    fontFamily: _lang == 'en' ? 'serif' : null,
                  ),
                ),
              ],
            ),
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w800,
              height: 1.12,
              letterSpacing: -0.8,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _s('heroSub'),
            style: TextStyle(
              fontSize: 15,
              height: 1.5,
              color: alpha(cs.onSurface, 0.72),
            ),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [_askButton(brand), _offlineButton(cs, brand)],
          ),

          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
            alignment: Alignment.topLeft,
            child: _listening
                ? Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: _listeningPill(cs, brand),
                  )
                : const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }

  /// Dark-green pill button with an animated microphone.
  Widget _askButton(Color brand) {
    const red = Color(0xFFB3261E);
    final color = _listening ? red : brand;
    return GestureDetector(
      onTap: () {
        if (_listening) {
          unawaited(_stopListening());
        } else {
          unawaited(_startListening());
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: alpha(color, 0.38),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 26,
              height: 26,
              child: AnimatedBuilder(
                animation: _anim,
                builder: (context, _) {
                  final v = _anim.value;
                  return Stack(
                    alignment: Alignment.center,
                    clipBehavior: Clip.none,
                    children: [
                      if (_listening)
                        Container(
                          width: 26 + 18 * v,
                          height: 26 + 18 * v,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withAlpha(
                              (90 * (1 - v)).round(),
                            ),
                          ),
                        ),
                      Transform.scale(
                        scale: 1 + 0.08 * math.sin(v * 2 * math.pi),
                        child: Icon(
                          _listening ? Icons.stop_rounded : Icons.mic_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(width: 10),
            Text(
              _listening ? _s('btnStop') : _s('btnAsk'),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Outlined pill button (toggle).
  Widget _offlineButton(ColorScheme cs, Color brand) {
    return GestureDetector(
      onTap: () => setState(() => _offline = !_offline),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: alpha(cs.surface, 0.9),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: _offline ? brand : alpha(cs.outline, 0.5),
            width: 1.4,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _offline ? Icons.offline_bolt_rounded : Icons.cloud_done_rounded,
              color: _offline ? const Color(0xFFF59E0B) : brand,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              _s('offTitle'),
              style: TextStyle(
                color: brand,
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 9,
              height: 9,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _offline ? const Color(0xFF22C55E) : cs.outline,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _listeningPill(ColorScheme cs, Color brand) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: alpha(brand, 0.08),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: alpha(brand, 0.28)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: _anim,
            builder: (context, _) {
              return SizedBox(
                height: 26,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: List.generate(12, (i) {
                    final s =
                        0.5 +
                        0.5 * math.sin(_anim.value * 4 * math.pi + i * 0.7);
                    return Container(
                      width: 4,
                      height: 6 + 18 * s,
                      margin: const EdgeInsets.only(right: 3),
                      decoration: BoxDecoration(
                        color: brand,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    );
                  }),
                ),
              );
            },
          ),
          const SizedBox(width: 10),
          Text(
            _s('listening'),
            style: TextStyle(
              color: brand,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _questionCard(ColorScheme cs, Color brand) {
    return _card(
      cs,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.chat_bubble_outline_rounded, color: brand),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _lang == 'hi'
                      ? 'खेती के बारे में पूछें'
                      : _lang == 'mr'
                      ? 'शेतीबद्दल प्रश्न विचारा'
                      : 'Ask your farming question',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: cs.onSurface,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          TextField(
            controller: _questionController,
            minLines: 1,
            maxLines: 3,
            textInputAction: TextInputAction.send,
            onSubmitted: (_) {
              if (!_isAsking) {
                _askQuestion();
              }
            },
            decoration: InputDecoration(
              hintText: _lang == 'hi'
                  ? 'जैसे: गेहूँ की सिंचाई कब करें?'
                  : _lang == 'mr'
                  ? 'उदा.: गव्हाला पाणी कधी द्यावे?'
                  : 'e.g. When should I irrigate wheat?',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              prefixIcon: const Icon(Icons.edit_outlined),
            ),
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: _isAsking ? null : _askQuestion,
                  icon: _isAsking
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.send_rounded),
                  label: Text(
                    _isAsking
                        ? (_lang == 'mr'
                              ? 'उत्तर शोधत आहे...'
                              : _lang == 'hi'
                              ? 'उत्तर खोज रहे हैं...'
                              : 'Getting answer...')
                        : (_lang == 'mr'
                              ? 'प्रश्न विचारा'
                              : _lang == 'hi'
                              ? 'प्रश्न पूछें'
                              : 'Ask question'),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: brand,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              OutlinedButton.icon(
                onPressed: (_isAsking || _listening || _isSpeaking)
                    ? () => unawaited(_cancelQuestion())
                    : null,
                icon: const Icon(Icons.pause_circle_outline_rounded),
                label: Text(
                  _lang == 'mr'
                      ? 'थांबवा'
                      : _lang == 'hi'
                      ? 'रोकें'
                      : 'Cancel',
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 14,
                  ),
                ),
              ),
            ],
          ),

          if (_answerError != null) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: cs.errorContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _answerError!,
                style: TextStyle(color: cs.onErrorContainer),
              ),
            ),
          ],

          if (_answer != null) ...[
            const SizedBox(height: 16),
            Divider(color: cs.outlineVariant),
            const SizedBox(height: 8),

            Row(
              children: [
                Icon(Icons.lightbulb_outline_rounded, color: brand),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _lang == 'mr'
                        ? 'तुमचे उत्तर'
                        : _lang == 'hi'
                        ? 'आपका उत्तर'
                        : 'Your answer',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: cs.onSurface,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            SelectableText(
              _answer!,
              style: TextStyle(fontSize: 15, height: 1.5, color: cs.onSurface),
            ),
            const SizedBox(height: 12),

            Wrap(
              spacing: 10,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: _isSpeaking
                      ? null
                      : () => unawaited(_speakAnswer(_answer ?? '')),
                  icon: const Icon(Icons.volume_up_rounded),
                  label: Text(
                    _lang == 'mr'
                        ? 'उत्तर ऐका'
                        : _lang == 'hi'
                        ? 'उत्तर सुनें'
                        : 'Replay answer',
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: () => unawaited(_stopSpeaking()),
                  icon: const Icon(Icons.stop_circle_outlined),
                  label: Text(
                    _lang == 'mr'
                        ? 'आवाज थांबवा'
                        : _lang == 'hi'
                        ? 'आवाज़ रोकें'
                        : 'Stop audio',
                  ),
                ),
              ],
            ),

            _explainabilityCard(cs, brand),
          ],
        ],
      ),
    );
  }

  Widget _explainabilityCard(ColorScheme cs, Color brand) {
    final isDb = _databaseMatch;
    final keywords = _answerExplanation?['matched_keywords'] as List<dynamic>?;
    final score = _answerExplanation?['matching_score_percent'];
    final crop =
        _answerExplanation?['requested_crop'] ??
        _answerExplanation?['matched_crop'];
    final method = _answerExplanation?['method']?.toString();

    final badgeColor = isDb ? const Color(0xFF16A34A) : const Color(0xFFEA580C);

    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: alpha(badgeColor, 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: alpha(badgeColor, 0.35), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isDb ? Icons.verified_rounded : Icons.psychology_alt_rounded,
                color: badgeColor,
                size: 22,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _lang == 'mr'
                      ? 'या सल्ल्यामागील कारण (XAI)'
                      : _lang == 'hi'
                      ? 'सलाह का कारण (XAI विवरण)'
                      : 'Why this advice? (Explainable AI)',
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w900,
                    color: cs.onSurface,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: badgeColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  isDb
                      ? (_lang == 'mr'
                            ? 'सत्यापित माहिती'
                            : _lang == 'hi'
                            ? 'सत्यापित डेटाबेस'
                            : 'Verified Knowledge')
                      : (_lang == 'mr'
                            ? 'स्थानिक AI मॉडेल'
                            : _lang == 'hi'
                            ? 'लोकल एआई'
                            : 'Local AI Model'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          if (score != null) ...[
            Row(
              children: [
                Text(
                  _lang == 'mr'
                      ? 'विश्वसनीयता जुळणी:'
                      : _lang == 'hi'
                      ? 'सटीकता स्कोर:'
                      : 'Confidence Match:',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: alpha(cs.onSurface, 0.8),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: (score is num ? score.toDouble() : 50.0) / 100.0,
                      minHeight: 7,
                      backgroundColor: alpha(badgeColor, 0.2),
                      valueColor: AlwaysStoppedAnimation<Color>(badgeColor),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '$score%',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12.5,
                    color: badgeColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],

          if (crop != null && crop.toString().isNotEmpty) ...[
            Row(
              children: [
                Text(
                  _lang == 'mr'
                      ? 'ओळखलेले पीक: '
                      : _lang == 'hi'
                      ? 'पहचानी गई फसल: '
                      : 'Identified Crop: ',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: alpha(cs.onSurface, 0.8),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: alpha(brand, 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    crop.toString().toUpperCase(),
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.bold,
                      color: brand,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],

          if (keywords != null && keywords.isNotEmpty) ...[
            Text(
              _lang == 'mr'
                  ? 'प्रश्नातील जुळलेले मुख्य शब्द:'
                  : _lang == 'hi'
                  ? 'पहचाने गए मुख्य शब्द:'
                  : 'Matched Question Keywords:',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: alpha(cs.onSurface, 0.75),
              ),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: keywords.map((k) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: alpha(cs.surface, 0.9),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: alpha(badgeColor, 0.4)),
                  ),
                  child: Text(
                    '#$k',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: badgeColor,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 10),
          ],

          if (_matchedQuestion != null && _matchedQuestion!.isNotEmpty) ...[
            Text(
              _lang == 'mr'
                  ? 'जुळलेला संदर्भ प्रश्न: "$_matchedQuestion"'
                  : _lang == 'hi'
                  ? 'संदर्भ प्रश्न: "$_matchedQuestion"'
                  : 'Matched Question: "$_matchedQuestion"',
              style: TextStyle(
                fontSize: 11.5,
                fontStyle: FontStyle.italic,
                color: alpha(cs.onSurface, 0.7),
              ),
            ),
            const SizedBox(height: 4),
          ],

          if (_answerSource != null && _answerSource!.isNotEmpty) ...[
            Text(
              _lang == 'mr'
                  ? 'माहिती स्त्रोत: $_answerSource'
                  : _lang == 'hi'
                  ? 'स्रोत: $_answerSource'
                  : 'Knowledge Source: $_answerSource',
              style: TextStyle(fontSize: 11.5, color: alpha(cs.onSurface, 0.7)),
            ),
          ],

          if (_answerLanguage != null && _answerLanguage!.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              'Language: $_answerLanguage  •  Type: ${_answerType ?? "standard"}',
              style: TextStyle(fontSize: 11, color: alpha(cs.onSurface, 0.55)),
            ),
          ],

          if (method != null && method.isNotEmpty) ...[
            const SizedBox(height: 3),
            Text(
              'Method: $method',
              style: TextStyle(
                fontSize: 11,
                fontStyle: FontStyle.italic,
                color: alpha(cs.onSurface, 0.6),
              ),
            ),
          ],

          if (_answerWarning != null && _answerWarning!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.amber.withAlpha(35),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.amber.shade700),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    size: 18,
                    color: Colors.amber.shade800,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _answerWarning!,
                      style: TextStyle(
                        fontSize: 11.5,
                        height: 1.35,
                        color: cs.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ------------------------------------------------------------ weather
  Widget _weatherCard(ColorScheme cs) {
    Widget stat(IconData icon, String text) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFF0083B0)),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(fontSize: 12, color: alpha(cs.onSurface, 0.75)),
          ),
        ],
      ),
    );

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: _showWeatherSheet,
      child: _card(
        cs,
        child: Row(
          children: [
            RotationTransition(
              turns: _slow,
              child: const Icon(
                Icons.wb_sunny_rounded,
                size: 42,
                color: Color(0xFFFFA000),
              ),
            ),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _liveTemp,
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: cs.onSurface,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4CAF50).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'LIVE',
                        style: TextStyle(
                          color: Color(0xFF2E7D32),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                Text(
                  _liveWeatherCondition.isNotEmpty ? _liveWeatherCondition : _s('sunny'),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: alpha(cs.onSurface, 0.7),
                  ),
                ),
              ],
            ),
            const Spacer(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                stat(Icons.water_drop_rounded, _liveHumidity),
                stat(Icons.air_rounded, _liveWind),
                stat(Icons.grain_rounded, _liveRainChance),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------- services grid
  Widget _servicesGrid() {
    return GridView.builder(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _services.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        mainAxisExtent: 104,
      ),
      itemBuilder: (context, i) {
        final s = _services[i];
        return ServiceTile(
          label: _s(s.key),
          icon: s.icon,
          fx: s.fx,
          colors: s.colors,
          onTap: () => _onServiceTapped(s.key),
        );
      },
    );
  }

  // -------------------------------------------------------- tips carousel
  Widget _tipCarousel(Color brand) {
    return Column(
      children: [
        SizedBox(
          height: 150,
          child: PageView.builder(
            controller: _tipCtrl,
            padEnds: false,
            itemCount: _tipData.length,
            onPageChanged: (i) => setState(() => _tipPage = i),
            itemBuilder: (context, i) {
              final t = _tipData[i];
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Container(
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: t.colors,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: alpha(t.colors.first, 0.40),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        right: -6,
                        bottom: -14,
                        child: Opacity(
                          opacity: 0.22,
                          child: Text(
                            t.emoji,
                            style: const TextStyle(fontSize: 82),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  t.emoji,
                                  style: const TextStyle(fontSize: 26),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    _p(t.title),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 17,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              _p(t.body),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_tipData.length, (i) {
            final active = i == _tipPage;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: active ? 22 : 7,
              height: 7,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: active ? brand : alpha(brand, 0.25),
              ),
            );
          }),
        ),
      ],
    );
  }

  // -------------------------------------------------------- crop calendar
  Widget _seasonCard(_Season s, ColorScheme cs) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: _card(
        cs,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(s.emoji, style: const TextStyle(fontSize: 26)),
                const SizedBox(width: 8),
                Text(
                  _p(s.name),
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(colors: s.colors),
                  ),
                  child: Text(
                    s.months,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: s.crops[_lang]!
                  .map(
                    (c) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: alpha(s.colors.last, 0.14),
                        border: Border.all(color: alpha(s.colors.last, 0.55)),
                      ),
                      child: Text(
                        c,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  // --------------------------------------------------------------- schemes
  Widget _schemeTile(_Scheme s, ColorScheme cs) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () async {
          final uri = Uri.parse(s.url);
          try {
            if (await canLaunchUrl(uri)) {
              await launchUrl(uri, mode: LaunchMode.externalApplication);
            } else {
              _toast('${s.name}: ${s.url}');
            }
          } catch (_) {
            _toast('${s.name}: ${s.url}');
          }
        },
        child: _card(
          cs,
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(colors: s.colors),
                ),
                child: Icon(s.icon, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          s.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: cs.primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Portal',
                                style: TextStyle(
                                  color: cs.primary,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 2),
                              Icon(Icons.open_in_new_rounded, size: 10, color: cs.primary),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _p(s.info),
                      style: TextStyle(
                        fontSize: 13,
                        color: alpha(cs.onSurface, 0.75),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded, size: 14, color: cs.primary),
            ],
          ),
        ),
      ),
    );
  }

  // ------------------------------------------------------------ bottom bar
  Widget _bottomBar(ColorScheme cs, Color brand) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: alpha(Colors.black, 0.18),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: NavigationBar(
            height: 66,
            backgroundColor: cs.surface,
            indicatorColor: alpha(brand, 0.16),
            selectedIndex: _nav,
            onDestinationSelected: (i) => setState(() => _nav = i),
            destinations: [
              NavigationDestination(
                icon: const Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home_rounded, color: brand),
                label: _s('nHome'),
              ),
              NavigationDestination(
                icon: const Icon(Icons.agriculture_outlined),
                selectedIcon: Icon(Icons.agriculture_rounded, color: brand),
                label: _s('nCrops'),
              ),
              NavigationDestination(
                icon: const Icon(Icons.storefront_outlined),
                selectedIcon: Icon(Icons.storefront_rounded, color: brand),
                label: _s('nMarket'),
              ),
              NavigationDestination(
                icon: const Icon(Icons.person_outline_rounded),
                selectedIcon: Icon(Icons.person_rounded, color: brand),
                label: _s('nProfile'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ======================================================================
  //  QUICK SERVICES INTERACTIVE SHEETS & LIVE LOGIC
  // ======================================================================

  Future<void> _fetchLiveWeather() async {
    try {
      final res = await FarmerApiService.getLiveWeather(
        location: _liveLocation,
        language: _lang == 'mr' ? 'Marathi' : (_lang == 'hi' ? 'Hindi' : 'English'),
      );
      if (mounted) {
        setState(() {
          final temp = res['temperature_celsius'];
          if (temp != null) {
            _liveTemp = '${(temp as num).round()}°C';
          }
          final cond = res['weather_condition'];
          if (cond != null) {
            _liveWeatherCondition = cond.toString();
          }
          final hum = res['humidity_percent'];
          if (hum != null) {
            _liveHumidity = _lang == 'mr' ? 'आर्द्रता $hum%' : (_lang == 'hi' ? 'नमी $hum%' : 'Humidity $hum%');
          }
          final wind = res['wind_speed_kmh'];
          if (wind != null) {
            _liveWind = _lang == 'mr' ? 'वारा ${(wind as num).round()} किमी/तास' : (_lang == 'hi' ? 'हवा ${(wind as num).round()} किमी/घं' : 'Wind ${(wind as num).round()} km/h');
          }
          final rain = res['rain_probability_percent'];
          if (rain != null) {
            _liveRainChance = _lang == 'mr' ? 'पाऊस $rain%' : (_lang == 'hi' ? 'बारिश $rain%' : 'Rain $rain%');
          }
        });
      }
    } catch (_) {}
  }

  void _onServiceTapped(String key) {
    switch (key) {
      case 'sCrop':
        _showCropAdviceSheet();
        break;
      case 'sDisease':
        _showDiseaseScanSheet();
        break;
      case 'sMarket':
        _showMarketPriceSheet();
        break;
      case 'sWeather':
        _showWeatherSheet();
        break;
      case 'sSoil':
        _showSoilHealthSheet();
        break;
      case 'sSchemes':
        _showSchemesSheet();
        break;
      case 'sCalculator':
        _showCalculatorSheet();
        break;
      case 'sMachinery':
        _showMachinerySheet();
        break;
      default:
        _toast('${_s(key)} – coming soon');
    }
  }

  // --- 1. WEATHER SHEET ---
  void _showWeatherSheet() {
    final cs = Theme.of(context).colorScheme;
    final langName = _lang == 'mr' ? 'Marathi' : (_lang == 'hi' ? 'Hindi' : 'English');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.85,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (_, scrollCtrl) {
            return Container(
              decoration: BoxDecoration(
                color: cs.surface,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: FutureBuilder<Map<String, dynamic>>(
                future: FarmerApiService.getLiveWeather(location: _liveLocation, language: langName),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator()));
                  }
                  final data = snapshot.data ?? {};
                  final temp = data['temperature_celsius'] ?? 32;
                  final cond = data['weather_condition'] ?? (_lang == 'mr' ? 'स्वच्छ ऊन' : _lang == 'hi' ? 'धूप' : 'Sunny');
                  final hum = data['humidity_percent'] ?? 40;
                  final wind = data['wind_speed_kmh'] ?? 8;
                  final rain = data['rain_probability_percent'] ?? 10;
                  final summary = data['voice_summary'] ?? '';
                  final prompt = data['interactive_prompt'] ?? '';
                  final List<dynamic> forecast7Day = data['forecast_7day'] is List ? data['forecast_7day'] : [];

                  // Smart weather alert based on metrics
                  String alertTitle = '';
                  String alertMsg = '';
                  Color alertColor = const Color(0xFF2E7D32);
                  IconData alertIcon = Icons.check_circle_rounded;

                  final rainVal = (rain is num) ? rain.toInt() : int.tryParse(rain.toString()) ?? 0;
                  final tempVal = (temp is num) ? temp.toDouble() : double.tryParse(temp.toString()) ?? 30.0;

                  if (rainVal >= 40) {
                    alertTitle = _lang == 'mr' ? 'पाऊस सतर्कता इशारा' : (_lang == 'hi' ? 'वर्षा चेतावनी व कृषि सलाह' : 'Rain Warning & Farming Alert');
                    alertMsg = _lang == 'mr'
                        ? 'पुढील काळात पावसाची शक्यता ($rainVal%) आहे. रासायनिक फवारणी आणि खत देणे पुढे ढकलावे. काढणी केलेले पीक सुरक्षित साठवावे.'
                        : (_lang == 'hi'
                            ? 'आगामी दिनों में वर्षा की संभावना ($rainVal%) है। कीटनाशक छिड़काव व यूरिया डालना टालें। कटी हुई फसल सुरक्षित रखें।'
                            : 'High rain probability ($rainVal%). Postpone pesticide spraying and urea application. Move harvested produce to dry storage.');
                    alertColor = Colors.orange.shade800;
                    alertIcon = Icons.warning_amber_rounded;
                  } else if (tempVal >= 36) {
                    alertTitle = _lang == 'mr' ? 'उष्णता व बाष्पीभवन इशारा' : (_lang == 'hi' ? 'अधिक तापमान चेतावनी' : 'High Heat Advisory');
                    alertMsg = _lang == 'mr'
                        ? 'तापमान $tempVal°C पर्यंत वाढले आहे. पिकांना पाण्याचा ताण पडू नये म्हणून सकाळच्या किंवा संध्याकाळच्या सत्रात ठिबकने पाणी द्यावे.'
                        : (_lang == 'hi'
                            ? 'तापमान $tempVal°C है। फसलों में नमी की कमी न होने दें, सुबह या शाम के समय ड्रिप से हल्की सिंचाई करें।'
                            : 'High temperatures ($tempVal°C). Provide light morning or evening drip irrigation to prevent moisture stress.');
                    alertColor = Colors.deepOrange;
                    alertIcon = Icons.thermostat_rounded;
                  } else {
                    alertTitle = _lang == 'mr' ? 'हवामान शेतीसाठी अनुकूल' : (_lang == 'hi' ? 'मौसम कृषि अनुकूल' : 'Weather Favorable For Farming');
                    alertMsg = _lang == 'mr'
                        ? 'सध्या हवामान शेतीकामांसाठी, आंतरमशागतीसाठी आणि फवारणीसाठी अतिशय अनुकूल आहे.'
                        : (_lang == 'hi'
                            ? 'वर्तमान मौसम खेत की तैयारी, निराई-गुड़ाई और सामान्य कृषि कार्यों के लिए उत्तम है।'
                            : 'Current atmospheric conditions are optimal for normal farm operations and spraying.');
                  }

                  return ListView(
                    controller: scrollCtrl,
                    padding: const EdgeInsets.all(20),
                    children: [
                      Center(
                        child: Container(
                          width: 44,
                          height: 5,
                          decoration: BoxDecoration(
                            color: Colors.grey.withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Icon(Icons.wb_sunny_rounded, color: Color(0xFFFFA000), size: 30),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _lang == 'mr' ? 'थेट हवामान व ७ दिवसांचा अंदाज' : (_lang == 'hi' ? 'लाइव मौसम व ७ दिवसीय पूर्वानुमान' : 'Live Weather & 7-Day Forecast'),
                              style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Current weather hero banner
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF0083B0), Color(0xFF00B4DB)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(22),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF0083B0).withValues(alpha: 0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.location_on_rounded, color: Colors.white, size: 18),
                                    const SizedBox(width: 4),
                                    Text(
                                      _liveLocation,
                                      style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.25),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    _lang == 'mr' ? 'थेट उपग्रह' : (_lang == 'hi' ? 'लाइव सैटेलाइट' : 'LIVE'),
                                    style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              '$temp°C',
                              style: const TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.w900),
                            ),
                            Text(
                              '$cond',
                              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  Column(
                                    children: [
                                      const Icon(Icons.water_drop_rounded, color: Colors.white, size: 18),
                                      const SizedBox(height: 4),
                                      Text(_lang == 'mr' ? 'आर्द्रता $hum%' : (_lang == 'hi' ? 'नमी $hum%' : 'Humidity $hum%'), style: const TextStyle(color: Colors.white, fontSize: 12)),
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      const Icon(Icons.air_rounded, color: Colors.white, size: 18),
                                      const SizedBox(height: 4),
                                      Text(_lang == 'mr' ? 'वारा $wind किमी/तास' : (_lang == 'hi' ? 'हवा $wind किमी/घं' : 'Wind $wind km/h'), style: const TextStyle(color: Colors.white, fontSize: 12)),
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      const Icon(Icons.grain_rounded, color: Colors.white, size: 18),
                                      const SizedBox(height: 4),
                                      Text(_lang == 'mr' ? 'पाऊस $rain%' : (_lang == 'hi' ? 'बारिश $rain%' : 'Rain $rain%'), style: const TextStyle(color: Colors.white, fontSize: 12)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 18),

                      // Weather Alert & Farm Action Suggestion
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: alertColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: alertColor.withValues(alpha: 0.4)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(alertIcon, color: alertColor, size: 24),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    alertTitle,
                                    style: TextStyle(color: alertColor, fontWeight: FontWeight.bold, fontSize: 15),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    alertMsg,
                                    style: TextStyle(fontSize: 13, color: cs.onSurface.withValues(alpha: 0.85), height: 1.4),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 18),

                      // 7-Day Weather Forecast Section
                      Row(
                        children: [
                          const Icon(Icons.calendar_month_rounded, color: Color(0xFF0083B0), size: 20),
                          const SizedBox(width: 8),
                          Text(
                            _lang == 'mr' ? '७ दिवसांचा हवामान अंदाज (7-Day Forecast)' : (_lang == 'hi' ? '७ दिवसीय मौसम पूर्वानुमान (7-Day Forecast)' : '7-Day Weather Forecast'),
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      if (forecast7Day.isNotEmpty) ...[
                        Column(
                          children: forecast7Day.map<Widget>((day) {
                            final dDate = day['date']?.toString() ?? '';
                            final dCond = day['condition']?.toString() ?? '';
                            final dMax = day['max_temp']?.toString() ?? '';
                            final dMin = day['min_temp']?.toString() ?? '';
                            final dRain = day['rain_probability']?.toString() ?? '0';

                            IconData dIcon = Icons.wb_sunny_rounded;
                            Color dIconColor = const Color(0xFFFFA000);
                            final condLower = dCond.toLowerCase();
                            if (condLower.contains('rain') || condLower.contains('पाऊस') || condLower.contains('बारिश')) {
                              dIcon = Icons.thunderstorm_rounded;
                              dIconColor = Colors.blue;
                            } else if (condLower.contains('cloud') || condLower.contains('ढग') || condLower.contains('बादल')) {
                              dIcon = Icons.cloud_rounded;
                              dIconColor = Colors.blueGrey;
                            }

                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: cs.surface,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
                              ),
                              child: Row(
                                children: [
                                  Icon(dIcon, color: dIconColor, size: 24),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(dDate, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                        Text(dCond, style: TextStyle(fontSize: 12, color: cs.onSurface.withValues(alpha: 0.7))),
                                      ],
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      const Icon(Icons.grain_rounded, size: 14, color: Colors.blue),
                                      const SizedBox(width: 3),
                                      Text('$dRain%', style: const TextStyle(fontSize: 12, color: Colors.blue, fontWeight: FontWeight.w600)),
                                      const SizedBox(width: 14),
                                      Text('$dMax° / $dMin°', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ] else ...[
                        Text(
                          _lang == 'mr' ? 'थेट अंदाज उपलब्ध होत आहे...' : (_lang == 'hi' ? 'पूर्वानुमान लोड हो रहा है...' : 'Forecast is loading...'),
                          style: TextStyle(fontSize: 12, color: cs.onSurface.withValues(alpha: 0.6)),
                        ),
                      ],

                      const SizedBox(height: 16),
                      Text(
                        _lang == 'mr' ? 'सविस्तर शेती सल्ला:' : (_lang == 'hi' ? 'विस्तृत कृषि सलाह:' : 'Farming Advisory:'),
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      Text(summary, style: const TextStyle(fontSize: 13.5, height: 1.5)),

                      if (prompt.isNotEmpty) ...[
                        const SizedBox(height: 14),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: cs.primary.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: cs.primary.withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.chat_bubble_outline_rounded, color: cs.primary, size: 18),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  prompt,
                                  style: TextStyle(color: cs.primary, fontWeight: FontWeight.w600, fontSize: 13),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  // --- 2. SCHEMES SHEET ---
  void _showSchemesSheet() {
    final cs = Theme.of(context).colorScheme;
    final langName = _lang == 'mr' ? 'Marathi' : (_lang == 'hi' ? 'Hindi' : 'English');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.85,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (_, scrollCtrl) {
            return Container(
              decoration: BoxDecoration(
                color: cs.surface,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: FutureBuilder<Map<String, dynamic>>(
                future: FarmerApiService.getSchemes(language: langName),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final list = (snapshot.data?['schemes'] as List?) ?? [];

                  return ListView(
                    controller: scrollCtrl,
                    padding: const EdgeInsets.all(20),
                    children: [
                      Center(
                        child: Container(
                          width: 44,
                          height: 5,
                          decoration: BoxDecoration(
                            color: Colors.grey.withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Icon(Icons.account_balance_rounded, color: Color(0xFFEC008C), size: 30),
                          const SizedBox(width: 10),
                          Text(
                            _lang == 'mr' ? 'शासकीय शेतकरी योजना' : (_lang == 'hi' ? 'सरकारी कृषि योजनाएं' : 'Government Farmer Schemes'),
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      ...list.map((item) {
                        final title = item['title'] ?? '';
                        final desc = item['description'] ?? '';
                        final benefits = item['benefits'] ?? '';
                        final url = item['website_url'] ?? '';

                        return Container(
                          margin: const EdgeInsets.only(bottom: 14),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: cs.surface,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.6)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 6),
                              Text(desc, style: TextStyle(fontSize: 13, color: cs.onSurface.withValues(alpha: 0.8))),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text('🎁 $benefits', style: const TextStyle(fontSize: 12, color: Color(0xFF2E7D32))),
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: cs.primary,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  icon: const Icon(Icons.open_in_browser_rounded, size: 18),
                                  label: Text(_lang == 'mr' ? 'अधिकृत वेबसाईट उघडा' : (_lang == 'hi' ? 'आधिकारिक वेबसाइट खोलें' : 'Open Official Portal')),
                                  onPressed: () async {
                                    if (url.isNotEmpty) {
                                      final uri = Uri.parse(url);
                                      if (await canLaunchUrl(uri)) {
                                        await launchUrl(uri, mode: LaunchMode.externalApplication);
                                      } else {
                                        _toast(url);
                                      }
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  // --- 3. DISEASE SCAN SHEET ---
  void _showDiseaseScanSheet() {
    final cs = Theme.of(context).colorScheme;
    final langName = _lang == 'mr' ? 'Marathi' : (_lang == 'hi' ? 'Hindi' : 'English');
    String selectedCrop = 'tomato';
    final TextEditingController symptomTextCtrl = TextEditingController();
    XFile? pickedPhoto;
    String? pickedImageBase64;
    Map<String, dynamic>? diagnosisResult;
    bool analyzing = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return DraggableScrollableSheet(
              initialChildSize: 0.9,
              minChildSize: 0.5,
              maxChildSize: 0.95,
              builder: (_, scrollCtrl) {
                return Container(
                  decoration: BoxDecoration(
                    color: cs.surface,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                  ),
                  child: ListView(
                    controller: scrollCtrl,
                    padding: const EdgeInsets.all(20),
                    children: [
                      Center(
                        child: Container(
                          width: 44,
                          height: 5,
                          decoration: BoxDecoration(
                            color: Colors.grey.withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Icon(Icons.eco_rounded, color: Color(0xFFFF416C), size: 30),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _lang == 'mr' ? 'एआय पीक व फळ रोग तपासणी' : (_lang == 'hi' ? 'एआई फसल व फल रोग जाँच' : 'AI Crop Disease Scanner'),
                              style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF416C).withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _lang == 'mr'
                              ? 'पाने, फळे किंवा रोपांचा फोटो काढून किंवा गॅलरीतून निवडून अपलोड करा. आमचे एआय रोग, लक्षणे व प्रतिबंधात्मक उपाय तात्काळ शोधून देईल.'
                              : (_lang == 'hi'
                                  ? 'पत्ती, फल या पौधे का फोटो खींचें या गैलरी से अपलोड करें। एआई तुरंत रोग का नाम, लक्षण और उपचार बताएगा।'
                                  : 'Capture or upload leaf/crop photos. AI automatically identifies crop diseases, symptoms, prevention, and treatment recommendations.'),
                          style: TextStyle(fontSize: 12.5, color: cs.onSurface.withValues(alpha: 0.75), height: 1.4),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Crop Selector Chips
                      Text(
                        _lang == 'mr' ? 'पीक / फळ निवडा:' : (_lang == 'hi' ? 'फसल / फल चुनें:' : 'Select Crop / Fruit:'),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          {'id': 'tomato', 'mr': 'टोमॅटो 🍅', 'hi': 'टमाटर 🍅', 'en': 'Tomato 🍅'},
                          {'id': 'ladyfinger', 'mr': 'भेंडी 🥬', 'hi': 'भिंडी 🥬', 'en': 'Ladyfinger 🥬'},
                          {'id': 'chili', 'mr': 'मिरची 🌶️', 'hi': 'मिर्च 🌶️', 'en': 'Chili 🌶️'},
                          {'id': 'broccoli', 'mr': 'ब्रोकोली 🥦', 'hi': 'ब्रोकली 🥦', 'en': 'Broccoli 🥦'},
                          {'id': 'apple', 'mr': 'सफरचंद 🍎', 'hi': 'सेब 🍎', 'en': 'Apple 🍎'},
                          {'id': 'cotton', 'mr': 'कापूस ☁️', 'hi': 'कपास ☁️', 'en': 'Cotton ☁️'},
                          {'id': 'sugarcane', 'mr': 'ऊस 🎋', 'hi': 'गन्ना 🎋', 'en': 'Sugarcane 🎋'},
                          {'id': 'grapes', 'mr': 'द्राक्ष 🍇', 'hi': 'अंगूर 🍇', 'en': 'Grapes 🍇'},
                          {'id': 'onion', 'mr': 'कांदा 🧅', 'hi': 'प्याज 🧅', 'en': 'Onion 🧅'},
                          {'id': 'wheat', 'mr': 'गहू 🌾', 'hi': 'गेहूं 🌾', 'en': 'Wheat 🌾'},
                          {'id': 'mango', 'mr': 'आंबा 🥭', 'hi': 'आम 🥭', 'en': 'Mango 🥭'},
                          {'id': 'potato', 'mr': 'बटाटा 🥔', 'hi': 'आलू 🥔', 'en': 'Potato 🥔'},
                        ].map((c) {
                          final isSel = selectedCrop == c['id'];
                          return ChoiceChip(
                            label: Text(c[_lang] ?? c['en']!),
                            selected: isSel,
                            selectedColor: const Color(0xFFFF416C).withValues(alpha: 0.18),
                            onSelected: (val) {
                              setSheetState(() => selectedCrop = c['id']!);
                            },
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 16),

                      // Photo Upload / Capture Section
                      Text(
                        _lang == 'mr' ? 'फोटो अपलोड किंवा कॅप्चर करा:' : (_lang == 'hi' ? 'फोटो अपलोड या कैप्चर करें:' : 'Capture or Upload Crop Photo:'),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      const SizedBox(height: 8),

                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Color(0xFFFF416C)),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                              icon: const Icon(Icons.camera_alt_rounded, color: Color(0xFFFF416C), size: 20),
                              label: Text(
                                _lang == 'mr' ? 'कॅमेरा (फोटो घ्या)' : (_lang == 'hi' ? 'कैमरा (फोटो लें)' : 'Take Photo'),
                                style: const TextStyle(color: Color(0xFFFF416C), fontSize: 13, fontWeight: FontWeight.w600),
                              ),
                              onPressed: () async {
                                final picker = ImagePicker();
                                final file = await picker.pickImage(source: ImageSource.camera, maxWidth: 1024, maxHeight: 1024, imageQuality: 85);
                                if (file != null) {
                                  final bytes = await file.readAsBytes();
                                  setSheetState(() {
                                    pickedPhoto = file;
                                    pickedImageBase64 = base64Encode(bytes);
                                  });
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Color(0xFFFF416C)),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                              icon: const Icon(Icons.photo_library_rounded, color: Color(0xFFFF416C), size: 20),
                              label: Text(
                                _lang == 'mr' ? 'गॅलरी / फाइल' : (_lang == 'hi' ? 'गैलरी / फाइल' : 'Upload File'),
                                style: const TextStyle(color: Color(0xFFFF416C), fontSize: 13, fontWeight: FontWeight.w600),
                              ),
                              onPressed: () async {
                                final picker = ImagePicker();
                                final file = await picker.pickImage(source: ImageSource.gallery, maxWidth: 1024, maxHeight: 1024, imageQuality: 85);
                                if (file != null) {
                                  final bytes = await file.readAsBytes();
                                  setSheetState(() {
                                    pickedPhoto = file;
                                    pickedImageBase64 = base64Encode(bytes);
                                  });
                                }
                              },
                            ),
                          ),
                        ],
                      ),

                      // Image preview container if image is selected
                      if (pickedPhoto != null) ...[
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: cs.surface,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFFFF416C).withValues(alpha: 0.5)),
                          ),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  width: 50,
                                  height: 50,
                                  color: Colors.grey.shade200,
                                  child: kIsWeb
                                      ? const Icon(Icons.image, color: Colors.grey)
                                      : Image.file(
                                          io.File(pickedPhoto!.path),
                                          width: 50,
                                          height: 50,
                                          fit: BoxFit.cover,
                                        ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _lang == 'mr' ? 'फोटो निवडला आहे' : (_lang == 'hi' ? 'फोटो चुना गया' : 'Photo Attached'),
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                    ),
                                    Text(
                                      pickedPhoto!.name,
                                      style: TextStyle(fontSize: 11, color: cs.onSurface.withValues(alpha: 0.6)),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close_rounded, color: Colors.red, size: 20),
                                onPressed: () {
                                  setSheetState(() {
                                    pickedPhoto = null;
                                    pickedImageBase64 = null;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 14),

                      // Symptom text input
                      Text(
                        _lang == 'mr' ? 'लक्षणे लिहा (ऐच्छिक):' : (_lang == 'hi' ? 'लक्षण लिखें (वैकल्पिक):' : 'Describe Symptoms (optional):'),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: symptomTextCtrl,
                        maxLines: 2,
                        decoration: InputDecoration(
                          hintText: _lang == 'mr'
                              ? 'उदा. पाने पिवळी पडणे, फळांवर काळे डाग, पाने आकसणे...'
                              : (_lang == 'hi'
                                  ? 'उदा. पत्ते पीले होना, सड़े टमाटर, फलों पर काले धब्बे...'
                                  : 'e.g. decayed tomato, yellow leaves, curled foliage, black spots...'),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          contentPadding: const EdgeInsets.all(12),
                        ),
                      ),

                      const SizedBox(height: 16),

                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF416C),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          icon: analyzing
                              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : const Icon(Icons.search_rounded),
                          label: Text(
                            _lang == 'mr' ? 'रोग निदान व उपाय शोधा (AI Scan)' : (_lang == 'hi' ? 'रोग निदान व उपाय खोजें (AI Scan)' : 'Detect Disease & Get Remedies'),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          onPressed: analyzing
                              ? null
                              : () async {
                                  setSheetState(() => analyzing = true);
                                  try {
                                    final symText = symptomTextCtrl.text.trim();
                                    final res = await FarmerApiService.scanDisease(
                                      crop: selectedCrop,
                                      symptoms: symText.isEmpty ? null : symText,
                                      imageBase64: pickedImageBase64,
                                      language: langName,
                                    );
                                    setSheetState(() {
                                      diagnosisResult = res;
                                      analyzing = false;
                                    });
                                  } catch (e) {
                                    setSheetState(() => analyzing = false);
                                    _toast('Scan error: $e');
                                  }
                                },
                        ),
                      ),

                      if (diagnosisResult != null) ...[
                        const SizedBox(height: 18),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: cs.surface,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: const Color(0xFFFF416C).withValues(alpha: 0.4)),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFFF416C).withValues(alpha: 0.08),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.health_and_safety_rounded, color: Color(0xFFFF416C), size: 24),
                                  const SizedBox(width: 8),
                                  Text(
                                    _lang == 'mr' ? 'रोग निदान निकाल' : (_lang == 'hi' ? 'रोग निदान रिपोर्ट' : 'Diagnosis Report'),
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                                ],
                              ),
                              const Divider(height: 20),
                              Text(
                                diagnosisResult!['diagnosis_text'] ?? '',
                                style: const TextStyle(fontSize: 13.5, height: 1.5),
                              ),
                              if (diagnosisResult!['interactive_prompt'] != null && diagnosisResult!['interactive_prompt'].toString().isNotEmpty) ...[
                                const SizedBox(height: 14),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: cs.primary.withValues(alpha: 0.08),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Icon(Icons.help_outline_rounded, color: cs.primary, size: 20),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          diagnosisResult!['interactive_prompt'].toString(),
                                          style: TextStyle(color: cs.primary, fontWeight: FontWeight.bold, fontSize: 13),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  // --- 4. MARKET PRICE SHEET ---
  void _showMarketPriceSheet() {
    final cs = Theme.of(context).colorScheme;
    final langName = _lang == 'mr' ? 'Marathi' : (_lang == 'hi' ? 'Hindi' : 'English');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.85,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (_, scrollCtrl) {
            return Container(
              decoration: BoxDecoration(
                color: cs.surface,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: FutureBuilder<Map<String, dynamic>>(
                future: FarmerApiService.getMarketPrices(language: langName),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final list = (snapshot.data?['rates'] as List?) ?? [];

                  return ListView(
                    controller: scrollCtrl,
                    padding: const EdgeInsets.all(20),
                    children: [
                      Center(
                        child: Container(
                          width: 44,
                          height: 5,
                          decoration: BoxDecoration(
                            color: Colors.grey.withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Icon(Icons.payments_rounded, color: Color(0xFFF12711), size: 30),
                          const SizedBox(width: 10),
                          Text(
                            _lang == 'mr' ? 'थेट कृषी बाजारभाव (मंडी दर)' : (_lang == 'hi' ? 'ताजा मंडी भाव' : 'Live Mandi Market Rates'),
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      ...list.map((item) {
                        final cropName = item['crop_name'] ?? '';
                        final market = item['market'] ?? '';
                        final modal = item['modal_price'] ?? 0;
                        final minP = item['min_price'] ?? 0;
                        final maxP = item['max_price'] ?? 0;
                        final unit = item['unit'] ?? '₹/Quintal';
                        final advisory = item['advisory'] ?? '';

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: cs.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.6)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(cropName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                  Text('₹$modal', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF2E7D32))),
                                ],
                              ),
                              Text(market, style: TextStyle(fontSize: 12, color: cs.onSurface.withValues(alpha: 0.7))),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Text('किमान: ₹$minP', style: const TextStyle(fontSize: 12)),
                                  const SizedBox(width: 14),
                                  Text('कमाल: ₹$maxP', style: const TextStyle(fontSize: 12)),
                                  const Spacer(),
                                  Text(unit, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                                ],
                              ),
                              if (advisory.isNotEmpty) ...[
                                const SizedBox(height: 6),
                                Text('💡 $advisory', style: const TextStyle(fontSize: 12, color: Color(0xFF0083B0))),
                              ],
                            ],
                          ),
                        );
                      }),
                    ],
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  // --- 5. SOIL HEALTH SHEET ---
  void _showSoilHealthSheet() {
    final cs = Theme.of(context).colorScheme;
    final langName = _lang == 'mr' ? 'Marathi' : (_lang == 'hi' ? 'Hindi' : 'English');
    int activeSoilTab = 0; // 0: Soil Types, 1: Soil pH, 2: NPK Nutrients, 3: Soil Testing, 4: Soil Health Card
    String selectedSoil = 'black';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final tabs = [
              {'mr': 'माती प्रकार', 'hi': 'मिट्टी प्रकार', 'en': 'Soil Types'},
              {'mr': 'सामू (pH)', 'hi': 'मिट्टी pH', 'en': 'Soil pH'},
              {'mr': 'NPK पोषण', 'hi': 'NPK पोषक', 'en': 'NPK Levels'},
              {'mr': 'माती परीक्षण', 'hi': 'मिट्टी परीक्षण', 'en': 'Soil Testing'},
              {'mr': 'आरोग्य पत्रिका', 'hi': 'हेल्थ कार्ड', 'en': 'Health Card'},
            ];

            return DraggableScrollableSheet(
              initialChildSize: 0.88,
              minChildSize: 0.5,
              maxChildSize: 0.95,
              builder: (_, scrollCtrl) {
                return Container(
                  decoration: BoxDecoration(
                    color: cs.surface,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                  ),
                  child: ListView(
                    controller: scrollCtrl,
                    padding: const EdgeInsets.all(20),
                    children: [
                      Center(
                        child: Container(
                          width: 44,
                          height: 5,
                          decoration: BoxDecoration(
                            color: Colors.grey.withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Icon(Icons.terrain_rounded, color: Color(0xFF8E2DE2), size: 30),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _lang == 'mr' ? 'माती आरोग्य व सुपिकता मार्गदर्शक' : (_lang == 'hi' ? 'मिट्टी स्वास्थ्य व उर्वरता मार्गदर्शिका' : 'Soil Quality & Fertility Guide'),
                              style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Segmented selector tabs for 5 components
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: List.generate(tabs.length, (i) {
                            final isSel = activeSoilTab == i;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ChoiceChip(
                                label: Text(tabs[i][_lang] ?? tabs[i]['en']!),
                                selected: isSel,
                                selectedColor: const Color(0xFF8E2DE2).withValues(alpha: 0.2),
                                onSelected: (val) {
                                  if (val) setSheetState(() => activeSoilTab = i);
                                },
                              ),
                            );
                          }),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // TAB 0: SOIL TYPES & ADVISORY
                      if (activeSoilTab == 0) ...[
                        Text(
                          _lang == 'mr' ? 'जमिनीचा प्रकार निवडा:' : (_lang == 'hi' ? 'मिट्टी का प्रकार चुनें:' : 'Select Soil Type:'),
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: [
                            {'id': 'black', 'mr': 'काळी कसदार माती (रेगूर)', 'hi': 'काली मिट्टी (रेगुर)', 'en': 'Black Cotton Soil'},
                            {'id': 'red', 'mr': 'तांबडी माती (लाल)', 'hi': 'लाल मिट्टी', 'en': 'Red Soil'},
                            {'id': 'alluvial', 'mr': 'गाळाची पोयटा जमीन', 'hi': 'जलोढ़ दोमट मिट्टी', 'en': 'Alluvial Loam'},
                          ].map((s) {
                            final isSel = selectedSoil == s['id'];
                            return ChoiceChip(
                              label: Text(s[_lang] ?? s['en']!),
                              selected: isSel,
                              onSelected: (val) {
                                setSheetState(() => selectedSoil = s['id']!);
                              },
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 14),
                        FutureBuilder<Map<String, dynamic>>(
                          future: FarmerApiService.getSoilHealth(soilType: selectedSoil, language: langName),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()));
                            }
                            final adv = snapshot.data?['advisory_text'] ?? '';
                            return Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: cs.surface,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: const Color(0xFF8E2DE2).withValues(alpha: 0.35)),
                              ),
                              child: Text(adv, style: const TextStyle(fontSize: 13.5, height: 1.5)),
                            );
                          },
                        ),
                      ],

                      // TAB 1: SOIL pH INFORMATION & CORRECTIONS
                      if (activeSoilTab == 1) ...[
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: cs.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.purple.withValues(alpha: 0.3)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _lang == 'mr' ? 'मातीचा सामू (Soil pH) व त्याचा पिकांवरील परिणाम:' : (_lang == 'hi' ? 'मिट्टी का pH मान व फसलों पर प्रभाव:' : 'Soil pH Scale & Crop Growth Impact:'),
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF8E2DE2)),
                              ),
                              const SizedBox(height: 12),
                              _infoBullet(
                                '• 6.5 ते 7.5 (उदासीन / आदर्श सामू - Neutral):',
                                _lang == 'mr'
                                    ? 'सर्व पिकांसाठी सर्वोत्तम. नत्र, स्फुरद व पालाश सर्व अन्नद्रव्ये मुळांना मुबलक उपलब्ध होतात.'
                                    : (_lang == 'hi' ? 'सभी फसलों के लिए सर्वोत्तम। सभी NPK पोषक तत्व पौधे को आसानी से मिलते हैं।' : 'Ideal for most crops. Maximum availability of N, P, K and micronutrients.'),
                                Colors.green,
                              ),
                              const SizedBox(height: 10),
                              _infoBullet(
                                '• 6.5 पेक्षा कमी (आम्लधर्मीय जमीन - Acidic):',
                                _lang == 'mr'
                                    ? 'स्फुरद व कॅल्शियम उपलब्ध होत नाही. उपाय: एकरी २५० ते ५०० किलो चुन्याची (कृषी चुना / Lime) पावडर जमिनीत मिसळावी.'
                                    : (_lang == 'hi' ? 'फास्फोरस व कैल्शियम की कमी। उपचार: प्रति एकड़ 250-400 किग्रा कृषि चूना (Lime) मिलाएं।' : 'P and Ca deficiency. Treatment: Apply agricultural limestone (250-400 kg/acre).'),
                                Colors.amber.shade800,
                              ),
                              const SizedBox(height: 10),
                              _infoBullet(
                                '• 7.5 ते 8.5 पेक्षा जास्त (अल्कधर्मीय / चोपण - Alkaline / Sodic):',
                                _lang == 'mr'
                                    ? 'लोह, जस्त व तांबे या सूक्ष्मअन्नद्रव्यांची कमतरता होते. उपाय: एकरी ५०० किलो जिप्सम (Gypsum), सेंद्रिय शेणखत व सल्फर (गंधक) वापरावे.'
                                    : (_lang == 'hi' ? 'जिंक व लोहे की कमी। उपचार: जिप्सम (500 किग्रा/एकड़), सड़ी गोबर खाद व सल्फर का उपयोग करें।' : 'Micronutrient lockup. Treatment: Apply gypsum (500 kg/acre), heavy organic manure, and sulfur.'),
                                Colors.red.shade700,
                              ),
                            ],
                          ),
                        ),
                      ],

                      // TAB 2: NPK NUTRIENT LEVELS & FUNCTIONS
                      if (activeSoilTab == 2) ...[
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: cs.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _lang == 'mr' ? 'मुख्य अन्नद्रव्ये (NPK) कार्य व कमतरतेची लक्षणे:' : (_lang == 'hi' ? 'मुख्य पोषक तत्व (NPK) कार्य व कमी के लक्षण:' : 'Primary Nutrients (NPK) Functions & Symptoms:'),
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF8E2DE2)),
                              ),
                              const SizedBox(height: 12),
                              _infoBullet(
                                '🟢 नत्र (Nitrogen - N):',
                                _lang == 'mr'
                                    ? 'कार्य: झाडांची शाकीय वाढ व पाने हिरवीगार ठेवणे. कमतरतेमुळे जुनी पाने पिवळी पडतात. स्रोत: युरिया (46% N), अमोनियम सल्फेट.'
                                    : (_lang == 'hi' ? 'कार्य: वानस्पतिक बढ़वार व हरा रंग। कमी से पुरानी पत्तियां पीली होती हैं। स्रोत: यूरिया।' : 'Promotes vegetative growth & chlorophyll. Deficiency causes pale yellowing of older leaves. Sources: Urea.'),
                                Colors.green,
                              ),
                              const SizedBox(height: 10),
                              _infoBullet(
                                '🟠 स्फुरद (Phosphorus - P):',
                                _lang == 'mr'
                                    ? 'कार्य: मजबूत मुळांची वाढ, फुलोरा व दाणे भरणे. कमतरतेमुळे पानांच्या कडा जांभळट होतात. स्रोत: डीएपी (18:46:0), एसएसपी (16% P).'
                                    : (_lang == 'hi' ? 'कार्य: जड़ों का विकास व फूल-फल। कमी से पत्तियां बैंगनी होती हैं। स्रोत: DAP, सिंगल सुपर फास्फेट।' : 'Root system development & heavy flowering. Deficiency causes purplish leaf edges. Sources: DAP, SSP.'),
                                Colors.orange,
                              ),
                              const SizedBox(height: 10),
                              _infoBullet(
                                '🔵 पालाश (Potassium - K):',
                                _lang == 'mr'
                                    ? 'कार्य: रोगप्रतिकारशक्ती, फळांचा आकार, चकाकी व गोडी वाढवणे. स्रोत: म्युरेट ऑफ पोटॅश (MOP 60% K), 0:0:50.'
                                    : (_lang == 'hi' ? 'कार्य: रोग प्रतिरोधक क्षमता, फल का आकार व चमक। स्रोत: म्यूटेट ऑफ पोटाश (MOP).' : 'Disease resistance, fruit sizing, sugar content, and drought tolerance. Sources: MOP, SOP.'),
                                Colors.blue,
                              ),
                            ],
                          ),
                        ),
                      ],

                      // TAB 3: SOIL TESTING GUIDANCE
                      if (activeSoilTab == 3) ...[
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: cs.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.teal.withValues(alpha: 0.3)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _lang == 'mr' ? 'माती परीक्षण नमुना काढण्याची योग्य पद्धत:' : (_lang == 'hi' ? 'मिट्टी का नमूना लेने की सही वैज्ञानिक विधि:' : 'Step-by-Step Soil Sampling Procedure:'),
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.teal),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                _lang == 'mr'
                                    ? '१. शेतातील पिके निघाल्यानंतर किंवा नांगरणीपूर्वी नमुना घ्यावा.\n'
                                      '२. शेतातून इंग्रजी "V" आकाराचा १५ ते २० सेमी खोल खड्डा खणावा.\n'
                                      '३. खड्ड्याच्या बाजूची २ सेमी जाडीची मातीची चकती वरपासून खालपर्यंत खरवडून घ्यावी.\n'
                                      '४. अशा प्रकारे एक एकरातून ८ ते १० वेगवेगळ्या ठिकाणचे नमुने एकत्र करावेत.\n'
                                      '५. गोळा केलेली माती सावलीत वाळवावी आणि चार भाग (Quartering) करून ५०० ग्रॅम माती कापडी पिशवीत प्रयोगशाळेत पाठवावी.'
                                    : (_lang == 'hi'
                                        ? '१. फसल कटाई के बाद या जुताई से पहले नमूना लें।\n'
                                          '२. खेत में "V" आकार का 15-20 सेमी गहरा गड्ढा बनाएं।\n'
                                          '३. गड्ढे की दीवार से ऊपर से नीचे तक 2 सेमी परत खुरच लें।\n'
                                          '४. एक एकड़ में 8-10 अलग-अलग स्थानों से नमूने एकत्र कर एक साफ बाल्टी में मिलाएं।\n'
                                          '५. धूप में नहीं बल्कि छाया में सुखाएं और 500 ग्राम मिट्टी प्रयोगशाला भेजें।'
                                        : '1. Sample after harvest or before plowing.\n'
                                          '2. Dig a V-shaped hole 15 to 20 cm deep (plow layer).\n'
                                          '3. Collect a 2 cm uniform slice from top to bottom.\n'
                                          '4. Repeat across 8-10 zigzag spots in each field acre.\n'
                                          '5. Thoroughly mix, shade-dry, discard stones/roots, and send 500g in clean cloth bag to lab.'),
                                style: const TextStyle(fontSize: 13, height: 1.5),
                              ),
                            ],
                          ),
                        ),
                      ],

                      // TAB 4: SOIL HEALTH CARD INFORMATION
                      if (activeSoilTab == 4) ...[
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: cs.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _lang == 'mr' ? 'मृदा आरोग्य पत्रिका (Soil Health Card Scheme):' : (_lang == 'hi' ? 'मृदा स्वास्थ्य कार्ड (Soil Health Card) योजना:' : 'Soil Health Card (SHC) Scheme & Fertilizer Adjustments:'),
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.green),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                _lang == 'mr'
                                    ? '• शासनाच्या कृषी विभागामार्फत दर ३ वर्षांनी शेतकऱ्यांना मोफत किंवा माफक दरात सॉईल हेल्थ कार्ड दिले जाते.\n'
                                      '• तपासणीचे १२ घटक: pH, EC, सेंद्रिय कर्ब (OC), नत्र (N), स्फुरद (P), पालाश (K), गंधक (S), जस्त (Zn), लोह (Fe), तांबे (Cu), मँगेनीज (Mn) व बोरॉन (B).\n'
                                      '• खत डोस समायोजन: जर जमिनीत स्फुरद/पालाश जास्त असेल तर रासायनिक खते २५% कमी करावीत; कमी असल्यास २५% वाढवावीत. यामुळे शेतकऱ्यांचा खतावरील अनावश्यक खर्च ३०% वाचतो.'
                                    : (_lang == 'hi'
                                        ? '• कृषि विभाग द्वारा हर 3 साल पर किसानों को सॉइल हेल्थ कार्ड उपलब्ध कराया जाता है।\n'
                                          '• जांच के 12 मानक: pH, EC, जैविक कार्बन, N, P, K, सल्फर, जिंक, आयरन, तांबा, मैंगनीज और बोरॉन।\n'
                                          '• रिपोर्ट अनुसार खाद समायोजन: उच्च स्तर होने पर 25% खाद कम करें, मध्यम पर सामान्य दें। इससे खेती लागत 20-30% घटती है।'
                                        : '• Government scheme providing 12-parameter soil assessment every 3 years.\n'
                                          '• 12 Parameters: pH, EC, Organic Carbon, Available N, P, K, Sulfur, Zinc, Iron, Copper, Manganese, Boron.\n'
                                          '• Dose Tuning: Reduce fertilizer by 25% for high nutrient soils; increase by 25% for low soils, saving 20-30% input costs.'),
                                style: const TextStyle(fontSize: 13, height: 1.5),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _infoBullet(String heading, String desc, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(heading, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5, color: color)),
        const SizedBox(height: 2),
        Text(desc, style: const TextStyle(fontSize: 12.5, height: 1.35)),
      ],
    );
  }

  // --- 6. CROP ADVICE SHEET ---
  void _showCropAdviceSheet() {
    final cs = Theme.of(context).colorScheme;
    final langName = _lang == 'mr' ? 'Marathi' : (_lang == 'hi' ? 'Hindi' : 'English');
    String selectedCrop = 'tomato';
    final TextEditingController searchCtrl = TextEditingController();
    String searchQuery = '';

    final List<Map<String, String>> allCrops = [
      {'id': 'tomato', 'mr': 'टोमॅटो 🍅', 'hi': 'टमाटर 🍅', 'en': 'Tomato 🍅'},
      {'id': 'ladyfinger', 'mr': 'भेंडी 🥬', 'hi': 'भिंडी 🥬', 'en': 'Ladyfinger 🥬'},
      {'id': 'chili', 'mr': 'मिरची 🌶️', 'hi': 'मिर्च 🌶️', 'en': 'Chili 🌶️'},
      {'id': 'broccoli', 'mr': 'ब्रोकोली 🥦', 'hi': 'ब्रोकली 🥦', 'en': 'Broccoli 🥦'},
      {'id': 'apple', 'mr': 'सफरचंद 🍎', 'hi': 'सेब 🍎', 'en': 'Apple 🍎'},
      {'id': 'wheat', 'mr': 'गहू 🌾', 'hi': 'गेहूं 🌾', 'en': 'Wheat 🌾'},
      {'id': 'sugarcane', 'mr': 'ऊस 🎋', 'hi': 'गन्ना 🎋', 'en': 'Sugarcane 🎋'},
      {'id': 'cotton', 'mr': 'कापूस ☁️', 'hi': 'कपास ☁️', 'en': 'Cotton ☁️'},
      {'id': 'onion', 'mr': 'कांदा 🧅', 'hi': 'प्याज 🧅', 'en': 'Onion 🧅'},
      {'id': 'rice', 'mr': 'तांदूळ 🌾', 'hi': 'धान 🌾', 'en': 'Rice 🌾'},
      {'id': 'soybean', 'mr': 'सोयाबीन 🌱', 'hi': 'सोयाबीन 🌱', 'en': 'Soybean 🌱'},
      {'id': 'mango', 'mr': 'आंबा 🥭', 'hi': 'आम 🥭', 'en': 'Mango 🥭'},
      {'id': 'potato', 'mr': 'बटाटा 🥔', 'hi': 'आलू 🥔', 'en': 'Potato 🥔'},
      {'id': 'grapes', 'mr': 'द्राक्ष 🍇', 'hi': 'अंगूर 🍇', 'en': 'Grapes 🍇'},
      {'id': 'pomegranate', 'mr': 'डाळिंब 🔴', 'hi': 'अनार 🔴', 'en': 'Pomegranate 🔴'},
      {'id': 'banana', 'mr': 'केळी 🍌', 'hi': 'केला 🍌', 'en': 'Banana 🍌'},
      {'id': 'cauliflower', 'mr': 'फुलकोबी 🥦', 'hi': 'फूलगोभी 🥦', 'en': 'Cauliflower 🥦'},
      {'id': 'cabbage', 'mr': 'कोबी 🥬', 'hi': 'पत्तागोभी 🥬', 'en': 'Cabbage 🥬'},
      {'id': 'groundnut', 'mr': 'भुईमूग 🥜', 'hi': 'मूंगफली 🥜', 'en': 'Groundnut 🥜'},
      {'id': 'watermelon', 'mr': 'कलिंगड 🍉', 'hi': 'तरबूज 🍉', 'en': 'Watermelon 🍉'},
      {'id': 'ginger', 'mr': 'आले 🫚', 'hi': 'अदरक 🫚', 'en': 'Ginger 🫚'},
      {'id': 'garlic', 'mr': 'लसून 🧄', 'hi': 'लहसुन 🧄', 'en': 'Garlic 🧄'},
      {'id': 'turmeric', 'mr': 'हळद 🟡', 'hi': 'हल्दी 🟡', 'en': 'Turmeric 🟡'},
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final filtered = searchQuery.isEmpty
                ? allCrops
                : allCrops.where((c) {
                    final q = searchQuery.toLowerCase();
                    return (c['en']!.toLowerCase().contains(q)) ||
                        (c['hi']!.contains(searchQuery)) ||
                        (c['mr']!.contains(searchQuery)) ||
                        (c['id']!.contains(q));
                  }).toList();

            return DraggableScrollableSheet(
              initialChildSize: 0.9,
              minChildSize: 0.5,
              maxChildSize: 0.95,
              builder: (_, scrollCtrl) {
                return Container(
                  decoration: BoxDecoration(
                    color: cs.surface,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                  ),
                  child: ListView(
                    controller: scrollCtrl,
                    padding: const EdgeInsets.all(20),
                    children: [
                      Center(
                        child: Container(
                          width: 44,
                          height: 5,
                          decoration: BoxDecoration(
                            color: Colors.grey.withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Icon(Icons.grass_rounded, color: Color(0xFF11998E), size: 30),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _lang == 'mr' ? 'सविस्तर पीक लागवड सल्ला' : (_lang == 'hi' ? 'विस्तृत फसल सलाह व कृषि प्रबंधन' : 'Crop Cultivation & Advisory'),
                              style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Search bar with enter/submit support for ANY crop
                      TextField(
                        controller: searchCtrl,
                        textInputAction: TextInputAction.search,
                        onSubmitted: (val) {
                          if (val.trim().isNotEmpty) {
                            setSheetState(() {
                              selectedCrop = val.trim().toLowerCase();
                            });
                          }
                        },
                        decoration: InputDecoration(
                          hintText: _lang == 'mr'
                              ? 'कोणत्याही पिकाचे नाव शोधा किंवा टाइप करा (उदा. भेंडी, मिरची, सफरचंद, ब्रोकोली)...'
                              : (_lang == 'hi'
                                  ? 'किसी भी फसल का नाम खोजें या टाइप करें (उदा. भिंडी, मिर्च, सेब, ब्रोकोली)...'
                                  : 'Search or type any crop name (e.g. Ladyfinger, Chili, Apple, Broccoli)...'),
                          prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF11998E)),
                          suffixIcon: searchCtrl.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear_rounded),
                                  onPressed: () {
                                    searchCtrl.clear();
                                    setSheetState(() => searchQuery = '');
                                  },
                                )
                              : null,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(color: Color(0xFF11998E), width: 2),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        ),
                        onChanged: (val) => setSheetState(() => searchQuery = val.trim()),
                      ),
                      const SizedBox(height: 12),

                      // Crop selection chips
                      Text(
                        _lang == 'mr' ? 'पिकांची यादी निवडा:' : (_lang == 'hi' ? 'फसल चुनें:' : 'Select Crop:'),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      const SizedBox(height: 8),

                      if (filtered.isNotEmpty) ...[
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          children: filtered.map((c) {
                            final isSel = selectedCrop == c['id'];
                            return ChoiceChip(
                              label: Text(c[_lang] ?? c['en']!),
                              selected: isSel,
                              selectedColor: const Color(0xFF11998E).withValues(alpha: 0.22),
                              onSelected: (val) {
                                setSheetState(() => selectedCrop = c['id']!);
                              },
                            );
                          }).toList(),
                        ),
                      ] else ...[
                        // Custom typed crop button
                        ActionChip(
                          avatar: const Icon(Icons.check_rounded, color: Color(0xFF11998E), size: 18),
                          label: Text(
                            _lang == 'mr' ? '"$searchQuery" चा सल्ला पहा' : (_lang == 'hi' ? '"$searchQuery" की सलाह देखें' : 'Get advice for "$searchQuery"'),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          onPressed: () {
                            setSheetState(() => selectedCrop = searchQuery.toLowerCase());
                          },
                        ),
                      ],

                      const SizedBox(height: 16),

                      FutureBuilder<Map<String, dynamic>>(
                        future: FarmerApiService.getCropAdvice(crop: selectedCrop, language: langName),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: Padding(padding: EdgeInsets.all(30), child: CircularProgressIndicator()));
                          }
                          final cropDisplayName = snapshot.data?['crop_name'] ?? selectedCrop.toUpperCase();
                          final adv = snapshot.data?['advice_text'] ?? '';
                          final prompt = snapshot.data?['interactive_prompt'] ?? '';

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: cs.surface,
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(color: const Color(0xFF11998E).withValues(alpha: 0.45)),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF11998E).withValues(alpha: 0.08),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
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
                                            color: const Color(0xFF11998E).withValues(alpha: 0.15),
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: const Icon(Icons.eco_rounded, color: Color(0xFF11998E), size: 22),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Text(
                                            cropDisplayName,
                                            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const Divider(height: 22),
                                    Text(
                                      adv,
                                      style: const TextStyle(fontSize: 13.5, height: 1.55),
                                    ),
                                  ],
                                ),
                              ),
                              if (prompt.isNotEmpty) ...[
                                const SizedBox(height: 14),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: cs.primary.withValues(alpha: 0.08),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(color: cs.primary.withValues(alpha: 0.3)),
                                  ),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Icon(Icons.help_outline_rounded, color: cs.primary, size: 20),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          prompt,
                                          style: TextStyle(color: cs.primary, fontWeight: FontWeight.bold, fontSize: 13),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  // --- 7. CALCULATOR SHEET ---
  void _showCalculatorSheet() {
    final cs = Theme.of(context).colorScheme;
    int selectedTab = 0;

    final seedAreaCtrl = TextEditingController();
    final seedRateCtrl = TextEditingController();
    double? seedResult;

    final fertAreaCtrl = TextEditingController();
    final fertDoseCtrl = TextEditingController();
    double? fertResult;

    final areaLenCtrl = TextEditingController();
    final areaWidCtrl = TextEditingController();
    Map<String, double>? areaResult;

    final cpSeedCostCtrl = TextEditingController();
    final cpFertCostCtrl = TextEditingController();
    final cpLaborCostCtrl = TextEditingController();
    final cpYieldCtrl = TextEditingController();
    final cpPriceCtrl = TextEditingController();
    Map<String, double>? cpResult;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final tabs = [
              {'mr': 'बियाणे', 'hi': 'बीज', 'en': 'Seed'},
              {'mr': 'खत', 'hi': 'खाद', 'en': 'Fertilizer'},
              {'mr': 'क्षेत्रफळ', 'hi': 'क्षेत्रफल', 'en': 'Area'},
              {'mr': 'खर्च-नफा', 'hi': 'लागत-लाभ', 'en': 'Cost & Profit'},
            ];

            Widget buildSeedCalc() {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _lang == 'mr' ? 'जमीन (एकर):' : (_lang == 'hi' ? 'भूमि (एकड़):' : 'Land (acres):'),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: seedAreaCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      hintText: _lang == 'mr' ? 'एकरांची संख्या' : (_lang == 'hi' ? 'एकड़ की संख्या' : 'Number of acres'),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _lang == 'mr' ? 'बीज दर (किग्रा/एकर):' : (_lang == 'hi' ? 'बीज दर (किग्रा/एकड़):' : 'Seed rate (kg/acre):'),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: seedRateCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      hintText: _lang == 'mr' ? 'किग्रा प्रति एकर' : (_lang == 'hi' ? 'किग्रा प्रति एकड़' : 'kg per acre'),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF11998E),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: const Icon(Icons.calculate_rounded),
                      label: Text(_lang == 'mr' ? 'गणना करा' : (_lang == 'hi' ? 'गणना करें' : 'Calculate')),
                      onPressed: () {
                        final area = double.tryParse(seedAreaCtrl.text);
                        final rate = double.tryParse(seedRateCtrl.text);
                        if (area != null && rate != null) {
                          setSheetState(() => seedResult = area * rate);
                        }
                      },
                    ),
                  ),
                  if (seedResult != null) ...[
                    const SizedBox(height: 14),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF11998E).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFF11998E).withValues(alpha: 0.4)),
                      ),
                      child: Text(
                        _lang == 'mr'
                            ? '🌱 एकूण बियाणे लागणार: ${seedResult!.toStringAsFixed(2)} किग्रा'
                            : (_lang == 'hi'
                                ? '🌱 कुल बीज आवश्यक: ${seedResult!.toStringAsFixed(2)} किग्रा'
                                : '🌱 Total seed needed: ${seedResult!.toStringAsFixed(2)} kg'),
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF11998E)),
                      ),
                    ),
                  ],
                ],
              );
            }

            Widget buildFertCalc() {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _lang == 'mr' ? 'जमीन (एकर):' : (_lang == 'hi' ? 'भूमि (एकड़):' : 'Land (acres):'),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: fertAreaCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      hintText: _lang == 'mr' ? 'एकरांची संख्या' : (_lang == 'hi' ? 'एकड़ की संख्या' : 'Number of acres'),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _lang == 'mr' ? 'खत प्रमाण (किग्रा/एकर):' : (_lang == 'hi' ? 'खाद मात्रा (किग्रा/एकड़):' : 'Fertilizer dose (kg/acre):'),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: fertDoseCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      hintText: _lang == 'mr' ? 'किग्रा प्रति एकर' : (_lang == 'hi' ? 'किग्रा प्रति एकड़' : 'kg per acre'),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF11998E),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: const Icon(Icons.calculate_rounded),
                      label: Text(_lang == 'mr' ? 'गणना करा' : (_lang == 'hi' ? 'गणना करें' : 'Calculate')),
                      onPressed: () {
                        final area = double.tryParse(fertAreaCtrl.text);
                        final dose = double.tryParse(fertDoseCtrl.text);
                        if (area != null && dose != null) {
                          setSheetState(() => fertResult = area * dose);
                        }
                      },
                    ),
                  ),
                  if (fertResult != null) ...[
                    const SizedBox(height: 14),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF11998E).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFF11998E).withValues(alpha: 0.4)),
                      ),
                      child: Text(
                        _lang == 'mr'
                            ? '🌿 एकूण खत लागणार: ${fertResult!.toStringAsFixed(2)} किग्रा'
                            : (_lang == 'hi'
                                ? '🌿 कुल खाद आवश्यक: ${fertResult!.toStringAsFixed(2)} किग्रा'
                                : '🌿 Total fertilizer needed: ${fertResult!.toStringAsFixed(2)} kg'),
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF11998E)),
                      ),
                    ),
                  ],
                ],
              );
            }

            Widget buildAreaCalc() {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _lang == 'mr' ? 'लांबी (फूट):' : (_lang == 'hi' ? 'लंबाई (फीट):' : 'Length (feet):'),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: areaLenCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      hintText: _lang == 'mr' ? 'फुटांत लांबी' : (_lang == 'hi' ? 'फीट में लंबाई' : 'Length in feet'),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _lang == 'mr' ? 'रुंदी (फूट):' : (_lang == 'hi' ? 'चौड़ाई (फीट):' : 'Width (feet):'),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: areaWidCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      hintText: _lang == 'mr' ? 'फुटांत रुंदी' : (_lang == 'hi' ? 'फीट में चौड़ाई' : 'Width in feet'),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF11998E),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: const Icon(Icons.calculate_rounded),
                      label: Text(_lang == 'mr' ? 'गणना करा' : (_lang == 'hi' ? 'गणना करें' : 'Calculate')),
                      onPressed: () {
                        final len = double.tryParse(areaLenCtrl.text);
                        final wid = double.tryParse(areaWidCtrl.text);
                        if (len != null && wid != null) {
                          final sqft = len * wid;
                          setSheetState(() => areaResult = {
                            'sqft': sqft,
                            'sqm': sqft * 0.0929,
                            'cent': sqft / 435.56,
                            'acre': sqft / 43560,
                            'bigha': sqft / 27000,
                          });
                        }
                      },
                    ),
                  ),
                  if (areaResult != null) ...[
                    const SizedBox(height: 14),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF11998E).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFF11998E).withValues(alpha: 0.4)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('📐 ${areaResult!['sqft']!.toStringAsFixed(2)} sq ft', style: const TextStyle(fontSize: 14)),
                          Text('📐 ${areaResult!['sqm']!.toStringAsFixed(2)} sq m', style: const TextStyle(fontSize: 14)),
                          Text('📐 ${areaResult!['cent']!.toStringAsFixed(4)} cents', style: const TextStyle(fontSize: 14)),
                          Text('📐 ${areaResult!['acre']!.toStringAsFixed(4)} acres', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                          Text('📐 ${areaResult!['bigha']!.toStringAsFixed(4)} bigha', style: const TextStyle(fontSize: 14)),
                        ],
                      ),
                    ),
                  ],
                ],
              );
            }

            Widget buildCostProfit() {
              final inputFields = [
                {'ctrl': cpSeedCostCtrl, 'mr': 'बियाणे खर्च (₹):', 'hi': 'बीज लागत (₹):', 'en': 'Seed cost (₹):'},
                {'ctrl': cpFertCostCtrl, 'mr': 'खत खर्च (₹):', 'hi': 'खाद लागत (₹):', 'en': 'Fertilizer cost (₹):'},
                {'ctrl': cpLaborCostCtrl, 'mr': 'मजुरी खर्च (₹):', 'hi': 'श्रम लागत (₹):', 'en': 'Labor cost (₹):'},
                {'ctrl': cpYieldCtrl, 'mr': 'अपेक्षित उत्पन्न (क्विंटल):', 'hi': 'अपेक्षित उपज (क्विंटल):', 'en': 'Expected yield (quintal):'},
                {'ctrl': cpPriceCtrl, 'mr': 'विक्री किंमत (₹/क्विंटल):', 'hi': 'बिक्री मूल्य (₹/क्विंटल):', 'en': 'Selling price (₹/quintal):'},
              ];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...inputFields.map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text((_lang == 'mr' ? item['mr'] : (_lang == 'hi' ? item['hi'] : item['en'])) as String, style: const TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 6),
                        TextField(
                          controller: item['ctrl'] as TextEditingController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: InputDecoration(
                            hintText: '0',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ],
                    ),
                  )),
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF11998E),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: const Icon(Icons.calculate_rounded),
                      label: Text(_lang == 'mr' ? 'गणना करा' : (_lang == 'hi' ? 'गणना करें' : 'Calculate')),
                      onPressed: () {
                        final seed = double.tryParse(cpSeedCostCtrl.text) ?? 0;
                        final fert = double.tryParse(cpFertCostCtrl.text) ?? 0;
                        final labor = double.tryParse(cpLaborCostCtrl.text) ?? 0;
                        final yieldQ = double.tryParse(cpYieldCtrl.text) ?? 0;
                        final price = double.tryParse(cpPriceCtrl.text) ?? 0;
                        final totalCost = seed + fert + labor;
                        final revenue = yieldQ * price;
                        setSheetState(() => cpResult = {
                          'cost': totalCost,
                          'revenue': revenue,
                          'profit': revenue - totalCost,
                        });
                      },
                    ),
                  ),
                  if (cpResult != null) ...[
                    const SizedBox(height: 14),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: (cpResult!['profit']! >= 0 ? Colors.green : Colors.red).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: (cpResult!['profit']! >= 0 ? Colors.green : Colors.red).withValues(alpha: 0.4)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _lang == 'mr' ? '💰 एकूण खर्च: ₹${cpResult!['cost']!.toStringAsFixed(2)}' : (_lang == 'hi' ? '💰 कुल लागत: ₹${cpResult!['cost']!.toStringAsFixed(2)}' : '💰 Total cost: ₹${cpResult!['cost']!.toStringAsFixed(2)}'),
                            style: const TextStyle(fontSize: 14),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _lang == 'mr' ? '📈 अपेक्षित उत्पन्न: ₹${cpResult!['revenue']!.toStringAsFixed(2)}' : (_lang == 'hi' ? '📈 अपेक्षित आय: ₹${cpResult!['revenue']!.toStringAsFixed(2)}' : '📈 Expected revenue: ₹${cpResult!['revenue']!.toStringAsFixed(2)}'),
                            style: const TextStyle(fontSize: 14),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            cpResult!['profit']! >= 0
                                ? (_lang == 'mr' ? '🟢 अंदाजे नफा: ₹${cpResult!['profit']!.toStringAsFixed(2)}' : (_lang == 'hi' ? '🟢 अनुमानित लाभ: ₹${cpResult!['profit']!.toStringAsFixed(2)}' : '🟢 Estimated profit: ₹${cpResult!['profit']!.toStringAsFixed(2)}'))
                                : (_lang == 'mr' ? '🔴 अंदाजे तोटा: ₹${cpResult!['profit']!.abs().toStringAsFixed(2)}' : (_lang == 'hi' ? '🔴 अनुमानित हानि: ₹${cpResult!['profit']!.abs().toStringAsFixed(2)}' : '🔴 Estimated loss: ₹${cpResult!['profit']!.abs().toStringAsFixed(2)}')),
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: cpResult!['profit']! >= 0 ? Colors.green : Colors.red),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              );
            }

            return DraggableScrollableSheet(
              initialChildSize: 0.9,
              minChildSize: 0.5,
              maxChildSize: 0.95,
              builder: (_, scrollCtrl) {
                return Container(
                  decoration: BoxDecoration(
                    color: cs.surface,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                  ),
                  child: ListView(
                    controller: scrollCtrl,
                    padding: const EdgeInsets.all(20),
                    children: [
                      Center(
                        child: Container(
                          width: 44,
                          height: 5,
                          decoration: BoxDecoration(
                            color: Colors.grey.withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Icon(Icons.calculate_rounded, color: Color(0xFF11998E), size: 30),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _lang == 'mr' ? 'स्मार्ट शेती कॅल्क्युलेटर' : (_lang == 'hi' ? 'स्मार्ट कृषि कैलकुलेटर' : 'Smart Farming Calculator'),
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: List.generate(tabs.length, (i) {
                            final isSelected = selectedTab == i;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ChoiceChip(
                                label: Text(tabs[i][_lang] ?? tabs[i]['en']!),
                                selected: isSelected,
                                selectedColor: const Color(0xFF11998E).withValues(alpha: 0.2),
                                onSelected: (_) => setSheetState(() => selectedTab = i),
                              ),
                            );
                          }),
                        ),
                      ),
                      const SizedBox(height: 20),
                      if (selectedTab == 0) buildSeedCalc(),
                      if (selectedTab == 1) buildFertCalc(),
                      if (selectedTab == 2) buildAreaCalc(),
                      if (selectedTab == 3) buildCostProfit(),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  // --- 8. MACHINERY SHEET ---
  void _showMachinerySheet() {
    final cs = Theme.of(context).colorScheme;

    final List<Map<String, dynamic>> machineryList = [
      {
        'emoji': '🚜',
        'en': 'Tractor', 'hi': 'ट्रैक्टर', 'mr': 'ट्रॅक्टर',
        'desc_en': 'Primary power source for all farm operations — plowing, sowing, hauling.',
        'desc_hi': 'सभी कृषि कार्यों के लिए प्राथमिक शक्ति स्रोत — जुताई, बुआई, ढुलाई।',
        'desc_mr': 'शेतीच्या सर्व कामांसाठी प्रमुख यंत्र — नांगरणी, पेरणी, वाहतूक.',
        'cost_en': '₹5 – 15 lakh (purchase)', 'cost_hi': '₹5 – 15 लाख (खरीद)', 'cost_mr': '₹5 – 15 लाख (खरेदी)',
        'rental_en': '₹600 – 800 / hour', 'rental_hi': '₹600 – 800 / घंटा', 'rental_mr': '₹600 – 800 / तास',
        'usage_en': 'Use 35–50 HP tractor for medium farms. Best for clay-loam soils.',
        'usage_hi': 'मध्यम खेतों के लिए 35–50 HP ट्रैक्टर उपयुक्त। चिकनी-दोमट मिट्टी के लिए श्रेष्ठ।',
        'usage_mr': 'मध्यम शेतासाठी 35–50 HP ट्रॅक्टर योग्य. चिकणमाती जमिनीसाठी उत्तम.',
        'maint_en': 'Change engine oil every 200 hours. Check air filter monthly.',
        'maint_hi': 'हर 200 घंटे पर इंजन ऑयल बदलें। एयर फिल्टर मासिक जांचें।',
        'maint_mr': 'दर 200 तासांनी इंजिन ऑइल बदला. हवा फिल्टर दरमहा तपासा.',
      },
      {
        'emoji': '⚙️',
        'en': 'Rotavator', 'hi': 'रोटावेटर', 'mr': 'रोटाव्हेटर',
        'desc_en': 'Tills and mixes soil in one pass, breaking clods and preparing seedbed.',
        'desc_hi': 'एक पास में मिट्टी जोतता और मिलाता है, ढेले तोड़ता है।',
        'desc_mr': 'एका फेरीत माती नांगरते आणि मिसळते, ढेकळे फोडते.',
        'cost_en': '₹80,000 – 1.5 lakh', 'cost_hi': '₹80,000 – 1.5 लाख', 'cost_mr': '₹80,000 – 1.5 लाख',
        'rental_en': '₹400 – 600 / hour', 'rental_hi': '₹400 – 600 / घंटा', 'rental_mr': '₹400 – 600 / तास',
        'usage_en': 'Ideal after paddy harvest for rabi crop preparation. 2–3 rounds recommended.',
        'usage_hi': 'धान कटाई के बाद रबी फसल की तैयारी के लिए आदर्श। 2–3 चक्कर अनुशंसित।',
        'usage_mr': 'धान कापणीनंतर रब्बी पिकासाठी जमीन तयार करण्यासाठी आदर्श. 2–3 फेऱ्या शिफारस.',
        'maint_en': 'Grease blades weekly. Replace worn blades each season.',
        'maint_hi': 'साप्ताहिक ब्लेड में ग्रीस लगाएं। प्रत्येक सीजन में घिसे ब्लेड बदलें।',
        'maint_mr': 'आठवड्याने पाते ग्रीस करा. प्रत्येक हंगामात झिजलेले पाते बदला.',
      },
      {
        'emoji': '🌾',
        'en': 'Seed Drill', 'hi': 'सीड ड्रिल', 'mr': 'सीड ड्रिल',
        'desc_en': 'Sows seeds at uniform depth and spacing for better germination.',
        'desc_hi': 'बेहतर अंकुरण के लिए एक समान गहराई और दूरी पर बीज बोता है।',
        'desc_mr': 'उत्तम उगवणीसाठी समान खोली व अंतरावर बियाणे पेरते.',
        'cost_en': '₹25,000 – 60,000', 'cost_hi': '₹25,000 – 60,000', 'cost_mr': '₹25,000 – 60,000',
        'rental_en': '₹250 – 400 / acre', 'rental_hi': '₹250 – 400 / एकड़', 'rental_mr': '₹250 – 400 / एकर',
        'usage_en': 'Best for wheat, soybean, and gram sowing. Reduces seed wastage by 20%.',
        'usage_hi': 'गेहूं, सोयाबीन और चने की बुआई के लिए श्रेष्ठ। बीज की बर्बादी 20% कम।',
        'usage_mr': 'गहू, सोयाबीन आणि हरभरा पेरणीसाठी उत्तम. बियाणे वाया 20% कमी.',
        'maint_en': 'Clean seed hoppers after each use. Check coulters for wear.',
        'maint_hi': 'हर उपयोग के बाद बीज हॉपर साफ करें। कोल्टर की घिसावट जांचें।',
        'maint_mr': 'प्रत्येक वापरानंतर बीज हॉपर स्वच्छ करा. कोल्टर झीज तपासा.',
      },
      {
        'emoji': '💧',
        'en': 'Sprayer (Pump)', 'hi': 'स्प्रेयर (पंप)', 'mr': 'स्प्रेयर (पंप)',
        'desc_en': 'Used for pesticide, herbicide, and foliar fertilizer application.',
        'desc_hi': 'कीटनाशक, खरपतवारनाशक और पत्तेदार खाद छिड़काव के लिए।',
        'desc_mr': 'कीटकनाशक, तणनाशक व पर्णखत फवारणीसाठी वापरतात.',
        'cost_en': '₹3,000 – 15,000', 'cost_hi': '₹3,000 – 15,000', 'cost_mr': '₹3,000 – 15,000',
        'rental_en': '₹200 – 400 / day', 'rental_hi': '₹200 – 400 / दिन', 'rental_mr': '₹200 – 400 / दिवस',
        'usage_en': 'Spray in early morning or evening. Avoid spraying before rain.',
        'usage_hi': 'सुबह जल्दी या शाम को छिड़काव करें। बारिश से पहले छिड़काव न करें।',
        'usage_mr': 'सकाळी लवकर किंवा संध्याकाळी फवारणी करा. पावसापूर्वी फवारणी टाळा.',
        'maint_en': 'Flush with clean water after each use. Replace nozzles annually.',
        'maint_hi': 'हर उपयोग के बाद साफ पानी से धोएं। नोजल सालाना बदलें।',
        'maint_mr': 'प्रत्येक वापरानंतर स्वच्छ पाण्याने धुवा. नोझल दरवर्षी बदला.',
      },
      {
        'emoji': '🌽',
        'en': 'Harvester / Combine', 'hi': 'हार्वेस्टर / कंबाइन', 'mr': 'हार्वेस्टर / कंबाईन',
        'desc_en': 'Reaps, threshes, and cleans grain in a single operation.',
        'desc_hi': 'एक ऑपरेशन में कटाई, मड़ाई और सफाई।',
        'desc_mr': 'एकाच वेळी कापणी, मळणी व स्वच्छता.',
        'cost_en': '₹25 – 35 lakh', 'cost_hi': '₹25 – 35 लाख', 'cost_mr': '₹25 – 35 लाख',
        'rental_en': '₹1,500 – 2,500 / acre', 'rental_hi': '₹1,500 – 2,500 / एकड़', 'rental_mr': '₹1,500 – 2,500 / एकर',
        'usage_en': 'Best for wheat and paddy. Book in advance during harvest season.',
        'usage_hi': 'गेहूं और धान के लिए श्रेष्ठ। कटाई सीजन में पहले से बुकिंग करें।',
        'usage_mr': 'गहू व धानासाठी उत्तम. कापणी हंगामात आगाऊ बुकिंग करा.',
        'maint_en': 'Service before season. Check threshing cylinder and sieves.',
        'maint_hi': 'सीजन से पहले सर्विस करें। थ्रेशिंग सिलेंडर और चलनी जांचें।',
        'maint_mr': 'हंगामापूर्वी सर्व्हिसिंग करा. मळणी सिलेंडर व चाळण तपासा.',
      },
      {
        'emoji': '🚿',
        'en': 'Drip Irrigation Set', 'hi': 'ड्रिप सिंचाई सेट', 'mr': 'ठिबक सिंचन संच',
        'desc_en': 'Delivers water directly to root zone, saving 30–60% water.',
        'desc_hi': 'पानी सीधे जड़ क्षेत्र में पहुंचाता है, 30–60% पानी बचाता है।',
        'desc_mr': 'थेट मुळाशी पाणी देते, 30–60% पाणी बचत.',
        'cost_en': '₹35,000 – 60,000 / acre (subsidy under PM-KUSUM)',
        'cost_hi': '₹35,000 – 60,000 / एकड़ (PM-KUSUM अंतर्गत सब्सिडी उपलब्ध)',
        'cost_mr': '₹35,000 – 60,000 / एकर (PM-KUSUM अंतर्गत अनुदान उपलब्ध)',
        'rental_en': 'N/A – ownership recommended', 'rental_hi': 'लागू नहीं – स्वामित्व अनुशंसित', 'rental_mr': 'लागू नाही – स्वामित्व शिफारस',
        'usage_en': 'Ideal for sugarcane, grapes, vegetables. Works well on sloped land.',
        'usage_hi': 'गन्ना, अंगूर, सब्जियों के लिए आदर्श। ढलान वाली जमीन पर भी अच्छा काम करता है।',
        'usage_mr': 'ऊस, द्राक्ष, भाजीपाल्यासाठी आदर्श. उताराच्या जमिनीवरही उत्तम.',
        'maint_en': 'Flush laterals monthly. Check emitters for clogging.',
        'maint_hi': 'मासिक लेटरल फ्लश करें। एमिटर बंद होने की जांच करें।',
        'maint_mr': 'दरमहा लॅटरल फ्लश करा. एमिटर बंद तपासा.',
      },
      {
        'emoji': '🔧',
        'en': 'Power Tiller', 'hi': 'पावर टिलर', 'mr': 'पॉवर टिलर',
        'desc_en': 'Compact 2-wheeled tractor for small/marginal farmers and hilly terrain.',
        'desc_hi': 'छोटे/सीमांत किसानों और पहाड़ी इलाकों के लिए कॉम्पैक्ट 2-पहिया ट्रैक्टर।',
        'desc_mr': 'लहान/सीमांत शेतकरी व डोंगराळ भागासाठी कॉम्पॅक्ट 2-चाकी ट्रॅक्टर.',
        'cost_en': '₹1 – 2 lakh', 'cost_hi': '₹1 – 2 लाख', 'cost_mr': '₹1 – 2 लाख',
        'rental_en': '₹400 – 500 / hour', 'rental_hi': '₹400 – 500 / घंटा', 'rental_mr': '₹400 – 500 / तास',
        'usage_en': 'Excellent for paddy fields and vegetable plots. Easy to maneuver.',
        'usage_hi': 'धान के खेतों और सब्जी के भूखंडों के लिए उत्कृष्ट। चलाना आसान।',
        'usage_mr': 'भात शेत व भाजीपाला वाफ्यांसाठी उत्कृष्ट. चालवणे सोपे.',
        'maint_en': 'Change gear oil every season. Keep tines sharp.',
        'maint_hi': 'हर सीजन में गियर ऑयल बदलें। टाइन्स को तेज रखें।',
        'maint_mr': 'दर हंगामी गीअर ऑईल बदला. टाईन्स धारदार ठेवा.',
      },
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.9,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (_, scrollCtrl) {
            return Container(
              decoration: BoxDecoration(
                color: cs.surface,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: ListView(
                controller: scrollCtrl,
                padding: const EdgeInsets.all(20),
                children: [
                  Center(
                    child: Container(
                      width: 44,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(Icons.agriculture_rounded, color: Color(0xFF7B61FF), size: 30),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _lang == 'mr' ? 'शेती यंत्रे मार्गदर्शन' : (_lang == 'hi' ? 'कृषि यंत्र गाइड' : 'Farm Machinery Guide'),
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ...machineryList.map((m) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      decoration: BoxDecoration(
                        color: cs.surface,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: const Color(0xFF7B61FF).withValues(alpha: 0.3)),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 6, offset: const Offset(0, 2)),
                        ],
                      ),
                      child: Theme(
                        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                        child: ExpansionTile(
                          leading: Text(m['emoji'] as String, style: const TextStyle(fontSize: 28)),
                          title: Text(
                            _lang == 'mr' ? m['mr'] as String : (_lang == 'hi' ? m['hi'] as String : m['en'] as String),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          subtitle: Text(
                            _lang == 'mr' ? m['desc_mr'] as String : (_lang == 'hi' ? m['desc_hi'] as String : m['desc_en'] as String),
                            style: TextStyle(fontSize: 12, color: cs.onSurface.withValues(alpha: 0.65)),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Divider(),
                                  _machineryInfoRow(Icons.shopping_cart_rounded, _lang == 'mr' ? 'खरेदी किंमत:' : (_lang == 'hi' ? 'खरीद मूल्य:' : 'Purchase cost:'), _lang == 'mr' ? m['cost_mr'] as String : (_lang == 'hi' ? m['cost_hi'] as String : m['cost_en'] as String), cs),
                                  const SizedBox(height: 6),
                                  _machineryInfoRow(Icons.handshake_rounded, _lang == 'mr' ? 'भाड्याने दर:' : (_lang == 'hi' ? 'किराया दर:' : 'Rental rate:'), _lang == 'mr' ? m['rental_mr'] as String : (_lang == 'hi' ? m['rental_hi'] as String : m['rental_en'] as String), cs),
                                  const SizedBox(height: 6),
                                  _machineryInfoRow(Icons.lightbulb_rounded, _lang == 'mr' ? 'वापर टिप्स:' : (_lang == 'hi' ? 'उपयोग सुझाव:' : 'Usage tips:'), _lang == 'mr' ? m['usage_mr'] as String : (_lang == 'hi' ? m['usage_hi'] as String : m['usage_en'] as String), cs),
                                  const SizedBox(height: 6),
                                  _machineryInfoRow(Icons.build_rounded, _lang == 'mr' ? 'देखभाल:' : (_lang == 'hi' ? 'रखरखाव:' : 'Maintenance:'), _lang == 'mr' ? m['maint_mr'] as String : (_lang == 'hi' ? m['maint_hi'] as String : m['maint_en'] as String), cs),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _machineryInfoRow(IconData icon, String label, String value, ColorScheme cs) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: const Color(0xFF7B61FF)),
        const SizedBox(width: 6),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: TextStyle(fontSize: 13, color: cs.onSurface),
              children: [
                TextSpan(text: '$label ', style: const TextStyle(fontWeight: FontWeight.bold)),
                TextSpan(text: value),
              ],
            ),
          ),
        ),
      ],
    );
  }

}
