import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'app_theme.dart';
import 'farmer_background.dart';
import 'profile_screen.dart';
import 'service_tile.dart';

// ======================================================================
//  TEXT IN 3 LANGUAGES  (en = English, hi = Hindi, mr = Marathi)
// ======================================================================
const Map<String, Map<String, String>> _ui = {
  'greetA': {'en': 'Namaste, ', 'hi': 'नमस्ते ', 'mr': 'नमस्कार '},
  'greetB': {'en': 'Farmer!', 'hi': 'किसान भाई!', 'mr': 'शेतकरी मित्रा!'},
  'badge': {
    'en': 'Multilingual · Offline-ready',
    'hi': 'बहुभाषी · ऑफ़लाइन सक्षम',
    'mr': 'बहुभाषिक · ऑफलाइन सक्षम'
  },
  'heroSub': {
    'en': 'Ask about crops, weather, diseases and mandi prices — in your own language, even without internet.',
    'hi': 'फसल, मौसम, रोग और मंडी भाव पूछें — अपनी भाषा में, बिना इंटरनेट भी।',
    'mr': 'पीक, हवामान, रोग आणि बाजारभाव विचारा — तुमच्या भाषेत, इंटरनेटशिवायही.'
  },
  'btnAsk': {'en': 'Ask by voice', 'hi': 'आवाज़ से पूछें', 'mr': 'आवाजाने विचारा'},
  'btnStop': {'en': 'Stop', 'hi': 'रोकें', 'mr': 'थांबा'},
  'listening': {'en': 'Listening…', 'hi': 'सुन रहा हूँ…', 'mr': 'ऐकत आहे…'},
  'offTitle': {'en': 'Offline mode', 'hi': 'ऑफ़लाइन मोड', 'mr': 'ऑफलाइन मोड'},
  'sunny': {'en': 'Sunny', 'hi': 'धूप', 'mr': 'ऊन'},
  'hum': {'en': 'Humidity 62%', 'hi': 'नमी 62%', 'mr': 'आर्द्रता 62%'},
  'wind': {'en': 'Wind 12 km/h', 'hi': 'हवा 12 किमी/घं', 'mr': 'वारा 12 किमी/तास'},
  'rain': {'en': 'Rain chance 10%', 'hi': 'बारिश 10%', 'mr': 'पाऊस 10%'},
  'quick': {'en': 'Quick services', 'hi': 'त्वरित सेवाएँ', 'mr': 'जलद सेवा'},
  'tips': {'en': 'Smart farming tips', 'hi': 'स्मार्ट खेती टिप्स', 'mr': 'स्मार्ट शेती टिप्स'},
  'calendar': {'en': 'Crop calendar', 'hi': 'फसल कैलेंडर', 'mr': 'पीक कॅलेंडर'},
  'schemes': {'en': 'Government schemes', 'hi': 'सरकारी योजनाएँ', 'mr': 'सरकारी योजना'},
  'nHome': {'en': 'Home', 'hi': 'होम', 'mr': 'मुख्यपृष्ठ'},
  'nCrops': {'en': 'Crops', 'hi': 'फसलें', 'mr': 'पिके'},
  'nMarket': {'en': 'Market', 'hi': 'मंडी', 'mr': 'बाजार'},
  'nProfile': {'en': 'Profile', 'hi': 'प्रोफ़ाइल', 'mr': 'प्रोफाइल'},
  'sCrop': {'en': 'Crop Advice', 'hi': 'फसल सलाह', 'mr': 'पीक सल्ला'},
  'sDisease': {'en': 'Disease Scan', 'hi': 'रोग जाँच', 'mr': 'रोग तपासणी'},
  'sMarket': {'en': 'Market Price', 'hi': 'मंडी भाव', 'mr': 'बाजारभाव'},
  'sWeather': {'en': 'Weather', 'hi': 'मौसम', 'mr': 'हवामान'},
  'sSoil': {'en': 'Soil Health', 'hi': 'मिट्टी स्वास्थ्य', 'mr': 'माती आरोग्य'},
  'sSchemes': {'en': 'Schemes', 'hi': 'योजनाएँ', 'mr': 'योजना'},
  'light': {'en': 'Light', 'hi': 'लाइट', 'mr': 'लाईट'},
  'darkM': {'en': 'Dark', 'hi': 'डार्क', 'mr': 'डार्क'},
  'system': {'en': 'System default', 'hi': 'सिस्टम डिफ़ॉल्ट', 'mr': 'सिस्टम डीफॉल्ट'},
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
  _Service('sCrop', Icons.grass_rounded, ServiceFx.sprout,
      [Color(0xFF11998E), Color(0xFF38EF7D)]),
  _Service('sDisease', Icons.eco_rounded, ServiceFx.scan,
      [Color(0xFFFF416C), Color(0xFFFF8E53)]),
  _Service('sMarket', Icons.payments_rounded, ServiceFx.bounce,
      [Color(0xFFF12711), Color(0xFFF5AF19)]),
  _Service('sWeather', Icons.cloud_rounded, ServiceFx.sun,
      [Color(0xFF0083B0), Color(0xFF00B4DB)]),
  _Service('sSoil', Icons.terrain_rounded, ServiceFx.drop,
      [Color(0xFF8E2DE2), Color(0xFF4A00E0)]),
  _Service('sSchemes', Icons.account_balance_rounded, ServiceFx.float,
      [Color(0xFFEC008C), Color(0xFFFC6767)]),
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
      'mr': 'ठिबक सिंचनाने ३०–५०% पाण्याची बचत होते आणि उत्पादन वाढते.'
    },
    [Color(0xFF0B6E8A), Color(0xFF1FA2C9)],
  ),
  _Tip(
    '🧪',
    {'en': 'Test soil before sowing', 'hi': 'बुवाई से पहले मिट्टी जाँचें', 'mr': 'पेरणीपूर्वी माती तपासा'},
    {
      'en': 'Know the right fertilizer dose, cut cost and protect your land.',
      'hi': 'सही खाद की मात्रा पता चलती है, खर्च घटता है।',
      'mr': 'योग्य खताची मात्रा समजते आणि खर्च कमी होतो.'
    },
    [Color(0xFF5B21B6), Color(0xFF7C3AED)],
  ),
  _Tip(
    '🔄',
    {'en': 'Rotate your crops', 'hi': 'फसल चक्र अपनाएँ', 'mr': 'पीक फेरपालट करा'},
    {
      'en': 'Pulses fix nitrogen in the soil and reduce pests for the next crop.',
      'hi': 'दलहनी फसलें मिट्टी में नाइट्रोजन बढ़ाती हैं और कीट घटाती हैं।',
      'mr': 'कडधान्य पिके जमिनीत नत्र वाढवतात आणि कीड कमी होते.'
    },
    [Color(0xFF14532D), Color(0xFF2E9E5B)],
  ),
  _Tip(
    '🌾',
    {'en': 'Mulch to save moisture', 'hi': 'मल्चिंग से नमी बचाएँ', 'mr': 'आच्छादनाने ओलावा टिकवा'},
    {
      'en': 'A layer of straw or leaves holds moisture and reduces weeds.',
      'hi': 'पुआल या पत्तों की परत नमी रोकती है और खरपतवार घटाती है।',
      'mr': 'पेंढा किंवा पाल्याचा थर ओलावा टिकवतो आणि तण कमी करतो.'
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
  const _Scheme(this.name, this.icon, this.info, this.colors);
}

const _schemeData = [
  _Scheme('PM-KISAN', Icons.savings_rounded, {
    'en': '₹6,000/year income support in 3 installments',
    'hi': '₹6,000 सालाना सहायता, 3 किस्तों में',
    'mr': '₹६,००० वार्षिक मदत, ३ हप्त्यांत',
  }, [Color(0xFF11998E), Color(0xFF38EF7D)]),
  _Scheme('PMFBY', Icons.shield_rounded, {
    'en': 'Crop insurance against drought, flood & pests',
    'hi': 'सूखा, बाढ़ और कीट से फसल बीमा',
    'mr': 'दुष्काळ, पूर व कीड यापासून पीक विमा',
  }, [Color(0xFF396AFC), Color(0xFF2948FF)]),
  _Scheme('Kisan Credit Card', Icons.credit_card_rounded, {
    'en': 'Low-interest credit for seeds, fertilizer & more',
    'hi': 'बीज-खाद के लिए कम ब्याज पर कर्ज',
    'mr': 'बियाणे-खतांसाठी कमी व्याजाचे कर्ज',
  }, [Color(0xFFFF512F), Color(0xFFF09819)]),
  _Scheme('Soil Health Card', Icons.science_rounded, {
    'en': 'Free soil test with fertilizer advice',
    'hi': 'मुफ्त मिट्टी जाँच व खाद सलाह',
    'mr': 'मोफत माती तपासणी व खत सल्ला',
  }, [Color(0xFF8E2DE2), Color(0xFFC471ED)]),
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
  late final Animation<double> _curve =
      CurvedAnimation(parent: _c, curve: Curves.easeOutCubic);

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
        position: Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero)
            .animate(_curve),
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
  String _farmerName = '';
  bool _offline = true;
  bool _listening = false;
  int _nav = 0;
  int _tipPage = 0;

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
    _loadFarmerName();
    _scrollCtrl.addListener(() {
      _offset.value =
          _scrollCtrl.hasClients ? math.max(0.0, _scrollCtrl.offset) : 0.0;
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
    super.dispose();
  }

  String _s(String key) => _ui[key]![_lang]!;
  String _p(Map<String, String> m) => m[_lang]!;

  void _toast(String msg) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _loadFarmerName() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('farmer_name') ?? '';
    if (mounted) {
      setState(() => _farmerName = name);
    }
  }

  // -------------------------------------------------------------- build
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final brand = brandOf(context);

    return PopScope(
      canPop: _nav == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _nav != 0) {
          setState(() => _nav = 0);
          _loadFarmerName();
        }
      },
      child: Scaffold(
        extendBody: true,
        body: FarmerBackground(
          scroll: _offset,
          child: SafeArea(
            child: IndexedStack(
              index: _nav,
              children: [
                _homeTab(cs, brand),
                _cropsTab(cs, brand),
                _marketTab(cs, brand),
                ProfileScreen(
                  lang: _lang,
                  onLanguageChanged: (l) => setState(() => _lang = l),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: _bottomBar(cs, brand),
      ),
    );
  }

  Widget _homeTab(ColorScheme cs, Color brand) {
    return ListView(
      controller: _scrollCtrl,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 110),
      children: [
        _Reveal(index: 0, child: _topBar(cs, brand)),
        const SizedBox(height: 10),
        _Reveal(index: 1, child: _languagePill(cs, brand)),
        _Reveal(index: 2, child: _hero(cs, brand)),
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
    );
  }

  Widget _cropsTab(ColorScheme cs, Color brand) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 110),
      children: [
        _topBar(cs, brand),
        const SizedBox(height: 10),
        _languagePill(cs, brand),
        const SizedBox(height: 18),
        _title(_s('calendar'), cs),
        const SizedBox(height: 12),
        ..._seasons.map((s) => _seasonCard(s, cs)),
        const SizedBox(height: 20),
        _title(_s('tips'), cs),
        const SizedBox(height: 12),
        _tipCarousel(brand),
      ],
    );
  }

  Widget _marketTab(ColorScheme cs, Color brand) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 110),
      children: [
        _topBar(cs, brand),
        const SizedBox(height: 10),
        _languagePill(cs, brand),
        const SizedBox(height: 18),
        _title(_s('schemes'), cs),
        const SizedBox(height: 12),
        ..._schemeData.map((s) => _schemeTile(s, cs)),
      ],
    );
  }

  // ------------------------------------------------------ small helpers
  Widget _card(ColorScheme cs,
      {required Widget child,
      EdgeInsets padding = const EdgeInsets.all(14),
      double radius = 20}) {
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
              gradient: LinearGradient(colors: [brand, const Color(0xFF2E9E5B)]),
            ),
            child: const Icon(Icons.agriculture_rounded,
                color: Colors.white, size: 20),
          ),
          const SizedBox(width: 10),
          Text(
            'Kisan Voice',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
              color: brand,
            ),
          ),
          const Spacer(),
          IconButton(
            tooltip: _s('nProfile'),
            icon: Icon(
              _nav == 3 ? Icons.person_rounded : Icons.person_outline_rounded,
              color: brand,
            ),
            onPressed: () {
              setState(() => _nav = 3);
            },
          ),
          // Android-style theme chooser: Light / Dark / System
          PopupMenuButton<ThemeMode>(
            tooltip: 'Theme',
            icon: Icon(
              cs.brightness == Brightness.dark
                  ? Icons.dark_mode_rounded
                  : Icons.light_mode_rounded,
              color: brand,
            ),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            onSelected: (m) => themeNotifier.value = m,
            itemBuilder: (_) => [
              PopupMenuItem(
                value: ThemeMode.light,
                child: Row(children: [
                  const Icon(Icons.light_mode_rounded, color: Colors.orange),
                  const SizedBox(width: 10),
                  Text(_s('light')),
                ]),
              ),
              PopupMenuItem(
                value: ThemeMode.dark,
                child: Row(children: [
                  const Icon(Icons.dark_mode_rounded, color: Colors.indigo),
                  const SizedBox(width: 10),
                  Text(_s('darkM')),
                ]),
              ),
              PopupMenuItem(
                value: ThemeMode.system,
                child: Row(children: [
                  const Icon(Icons.phone_android_rounded, color: Colors.teal),
                  const SizedBox(width: 10),
                  Text(_s('system')),
                ]),
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
                      colors: [brand, const Color(0xFF2EB86A)]),
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
                  onTap: () => setState(() => _lang = langs[i]),
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
                      shape: BoxShape.circle, color: green),
                ),
                const SizedBox(width: 8),
                Text(
                  _s('badge'),
                  style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: brand),
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
                  text: _farmerName.trim().isNotEmpty
                      ? '!'
                      : _s('greetB'),
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
      onTap: () => setState(() => _listening = !_listening),
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
                            color: Colors.white.withAlpha((90 * (1 - v)).round()),
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
              color: _offline ? brand : alpha(cs.outline, 0.5), width: 1.4),
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
                  color: brand, fontWeight: FontWeight.w700, fontSize: 15),
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
                        0.5 + 0.5 * math.sin(_anim.value * 4 * math.pi + i * 0.7);
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
                color: brand, fontWeight: FontWeight.w700, fontSize: 14),
          ),
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
              Text(text,
                  style: TextStyle(
                      fontSize: 12, color: alpha(cs.onSurface, 0.75))),
            ],
          ),
        );

    return _card(
      cs,
      child: Row(
        children: [
          RotationTransition(
            turns: _slow,
            child: const Icon(Icons.wb_sunny_rounded,
                size: 42, color: Color(0xFFFFA000)),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('28°C',
                  style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: cs.onSurface)),
              Text(_s('sunny'),
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: alpha(cs.onSurface, 0.7))),
            ],
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              stat(Icons.water_drop_rounded, _s('hum')),
              stat(Icons.air_rounded, _s('wind')),
              stat(Icons.grain_rounded, _s('rain')),
            ],
          ),
        ],
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
          onTap: () => _toast('${_s(s.key)} – coming soon'),
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
                          child: Text(t.emoji,
                              style: const TextStyle(fontSize: 82)),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(t.emoji,
                                    style: const TextStyle(fontSize: 26)),
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
                                  height: 1.4),
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
                Text(_p(s.name),
                    style: const TextStyle(
                        fontSize: 17, fontWeight: FontWeight.w900)),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(colors: s.colors),
                  ),
                  child: Text(s.months,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 12)),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: s.crops[_lang]!
                  .map((c) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: alpha(s.colors.last, 0.14),
                          border: Border.all(color: alpha(s.colors.last, 0.55)),
                        ),
                        child: Text(c,
                            style: const TextStyle(
                                fontWeight: FontWeight.w700, fontSize: 13)),
                      ))
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
                  Text(s.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.w900, fontSize: 15)),
                  const SizedBox(height: 2),
                  Text(_p(s.info),
                      style: TextStyle(
                          fontSize: 13, color: alpha(cs.onSurface, 0.75))),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: cs.primary),
          ],
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
            onDestinationSelected: (i) {
              setState(() => _nav = i);
              if (i == 0) _loadFarmerName();
            },
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
}