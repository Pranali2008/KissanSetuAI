import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_theme.dart';

// -----------------------------------------------------------------------
//  ProfileScreen  –  Two-state: Edit form  ↔  Saved summary card
// -----------------------------------------------------------------------
class ProfileScreen extends StatefulWidget {
  final String lang; // 'en', 'hi', or 'mr'
  final Function(String)? onLanguageChanged;

  const ProfileScreen({
    super.key,
    required this.lang,
    this.onLanguageChanged,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  // ---- controllers ----
  final TextEditingController _nameController    = TextEditingController();
  final TextEditingController _phoneController   = TextEditingController();
  final TextEditingController _villageController = TextEditingController();
  final TextEditingController _landController    = TextEditingController();

  // ---- selections ----
  String _district   = 'Nashik';
  String _soil       = 'black';
  String _irrigation = 'drip';
  final Set<String> _crops = {'tomato', 'wheat'};

  // ---- UI state ----
  bool _isLoading  = true;   // initial SharedPrefs load
  bool _isSaved    = false;  // true  →  show summary card
  bool _isSaving   = false;  // true  →  button spinner

  // ---- animation (checkmark bounce in success banner) ----
  late final AnimationController _checkAnim;
  late final Animation<double>    _checkScale;

  // -------------------------------------------------------  LABELS
  static const Map<String, Map<String, String>> _l = {
    'title':      {'en': 'Farmer Profile', 'hi': 'किसान प्रोफ़ाइल',    'mr': 'शेतकरी प्रोफाइल'},
    'editSub':    {'en': 'Fill in your details to get personalised advice',
                   'hi': 'व्यक्तिगत सलाह के लिए जानकारी भरें',
                   'mr': 'वैयक्तिक सल्ल्यासाठी माहिती भरा'},
    'savedSub':   {'en': 'Your profile is saved offline  ✓',
                   'hi': 'आपकी प्रोफ़ाइल ऑफलाइन सहेजी गई  ✓',
                   'mr': 'तुमचे प्रोफाइल ऑफलाइन सेव्ह केले  ✓'},
    'basicInfo':  {'en': 'Personal Details',     'hi': 'व्यक्तिगत विवरण',   'mr': 'वैयक्तिक माहिती'},
    'name':       {'en': 'Farmer Name',          'hi': 'किसान का नाम',      'mr': 'शेतकऱ्याचे नाव'},
    'phone':      {'en': 'Mobile Number',        'hi': 'मोबाइल नंबर',       'mr': 'मोबाईल नंबर'},
    'location':   {'en': 'Region & Location',    'hi': 'क्षेत्र और स्थान', 'mr': 'प्रदेश आणि गाव'},
    'district':   {'en': 'District',             'hi': 'ज़िला',             'mr': 'जिल्हा'},
    'village':    {'en': 'Village / Taluka',     'hi': 'गाँव / तहसील',     'mr': 'गाव / तालुका'},
    'farmDet':    {'en': 'Farm & Soil Details',  'hi': 'खेत और मिट्टी',    'mr': 'जमीन व माती'},
    'landSize':   {'en': 'Total Land (Acres)',   'hi': 'कुल जमीन (एकड़)',   'mr': 'एकूण जमीन (एकर)'},
    'soilType':   {'en': 'Soil Type',            'hi': 'मिट्टी का प्रकार', 'mr': 'मातीचा प्रकार'},
    'irrigation': {'en': 'Irrigation Source',    'hi': 'सिंचाई साधन',      'mr': 'सिंचनाची सोय'},
    'crops':      {'en': 'Crops You Grow',       'hi': 'आपकी फसलें',       'mr': 'तुम्ही पिकवणारी पिके'},
    'save':       {'en': 'Save Profile',         'hi': 'सहेजें',            'mr': 'सेव्ह करा'},
    'savedMsg':   {'en': '🎉  Profile saved successfully!',
                   'hi': '🎉  प्रोफ़ाइल सफलतापूर्वक सहेजी गई!',
                   'mr': '🎉  माहिती यशस्वीरीत्या सेव्ह झाली!'},
    'editBtn':    {'en': 'Edit Profile',    'hi': 'प्रोफ़ाइल संपादित करें', 'mr': 'प्रोफाइल संपादित करा'},
    'switchAcc':  {'en': 'Switch Account',  'hi': 'खाता बदलें',            'mr': 'खाते बदला'},
    'switchMsg':  {'en': 'Profile cleared. Please enter new details.',
                   'hi': 'प्रोफ़ाइल साफ़ की गई। नई जानकारी दर्ज करें।',
                   'mr': 'प्रोफाइल साफ केले. नवीन माहिती टाका.'},
    'farmerSince':{'en': 'Farmer since',   'hi': 'किसान से',              'mr': 'शेतकरी'},
    'myProfile':  {'en': 'My Profile',     'hi': 'मेरी प्रोफाइल',         'mr': 'माझे प्रोफाइल'},
    'cropLabel':  {'en': 'My Crops',       'hi': 'मेरी फसलें',            'mr': 'माझी पिके'},
    'locLabel':   {'en': 'Location',       'hi': 'स्थान',                  'mr': 'स्थान'},
    'soilLabel':  {'en': 'Soil',           'hi': 'मिट्टी',                 'mr': 'माती'},
    'required':   {'en': 'Required',       'hi': 'आवश्यक है',              'mr': 'आवश्यक आहे'},
    'phoneErr':   {'en': 'Enter valid 10-digit number',
                   'hi': '10 अंकों का नंबर दर्ज करें',
                   'mr': '10 अंकी नंबर टाका'},
  };

  String _t(String key) => _l[key]?[widget.lang] ?? _l[key]?['en'] ?? key;

  // -------------------------------------------------------  DATA MAPS
  final List<String> _districts = [
    'Nashik', 'Pune', 'Ahmednagar', 'Satara', 'Kolhapur',
    'Solapur', 'Sangli', 'Aurangabad (Chh. Sambhajinagar)',
    'Jalgaon', 'Amravati', 'Nagpur',
  ];

  final Map<String, Map<String, String>> _soilOpts = {
    'black':  {'en': '⬛ Black',   'hi': 'काली मिट्टी',   'mr': 'काळी माती'},
    'red':    {'en': '🟥 Red',     'hi': 'लाल मिट्टी',    'mr': 'तांबडी माती'},
    'loamy':  {'en': '🟫 Loamy',   'hi': 'दोमट मिट्टी',   'mr': 'गाळाची माती'},
    'sandy':  {'en': '🏜️ Sandy',   'hi': 'बलुई मिट्टी',   'mr': 'रेताड माती'},
  };

  final Map<String, Map<String, String>> _irrigOpts = {
    'drip':      {'en': '💧 Drip',       'hi': 'ड्रिप',      'mr': 'ठिबक'},
    'sprinkler': {'en': '🌧️ Sprinkler',  'hi': 'फव्वारा',    'mr': 'तुषार'},
    'well':      {'en': '🪣 Well',        'hi': 'कुआं',       'mr': 'विहीर'},
    'canal':     {'en': '🌊 Canal',       'hi': 'नहर',        'mr': 'कालवा'},
    'rainfed':   {'en': '☔ Rainfed',     'hi': 'वर्षा',      'mr': 'कोरडवाहू'},
  };

  final Map<String, Map<String, String>> _cropOpts = {
    'tomato':    {'en': '🍅 Tomato',    'hi': 'टमाटर',    'mr': 'टोमॅटो'},
    'wheat':     {'en': '🌾 Wheat',     'hi': 'गेहूं',     'mr': 'गहू'},
    'rice':      {'en': '🌾 Rice',      'hi': 'धान',       'mr': 'भात'},
    'sugarcane': {'en': '🎋 Sugarcane', 'hi': 'गन्ना',     'mr': 'ऊस'},
    'cotton':    {'en': '🌿 Cotton',    'hi': 'कपास',      'mr': 'कापूस'},
    'onion':     {'en': '🧅 Onion',     'hi': 'प्याज',     'mr': 'कांदा'},
    'soybean':   {'en': '🫘 Soybean',   'hi': 'सोयाबीन',   'mr': 'सोयाबीन'},
    'marigold':  {'en': '🌼 Marigold',  'hi': 'गेंदा',     'mr': 'झेंडू'},
    'rose':      {'en': '🌹 Rose',      'hi': 'गुलाब',     'mr': 'गुलाब'},
  };

  // -------------------------------------------------------  LIFECYCLE
  @override
  void initState() {
    super.initState();
    _checkAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _checkScale = CurvedAnimation(parent: _checkAnim, curve: Curves.elasticOut);
    _loadProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _villageController.dispose();
    _landController.dispose();
    _checkAnim.dispose();
    super.dispose();
  }

  // -------------------------------------------------------  PERSISTENCE
  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('farmer_name') ?? '';
    setState(() {
      _nameController.text    = name;
      _phoneController.text   = prefs.getString('farmer_phone') ?? '';
      _villageController.text = prefs.getString('farmer_village') ?? '';
      _landController.text    = prefs.getString('farmer_land_size') ?? '';
      _district   = prefs.getString('farmer_district')   ?? 'Nashik';
      _soil       = prefs.getString('farmer_soil')       ?? 'black';
      _irrigation = prefs.getString('farmer_irrigation') ?? 'drip';
      final savedCrops = prefs.getStringList('farmer_crops');
      if (savedCrops != null && savedCrops.isNotEmpty) {
        _crops
          ..clear()
          ..addAll(savedCrops);
      }
      // If a name already exists, open directly in summary view
      _isSaved  = name.trim().isNotEmpty;
      _isLoading = false;
    });
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('farmer_name',     _nameController.text.trim());
    await prefs.setString('farmer_phone',    _phoneController.text.trim());
    await prefs.setString('farmer_village',  _villageController.text.trim());
    await prefs.setString('farmer_land_size',_landController.text.trim());
    await prefs.setString('farmer_district', _district);
    await prefs.setString('farmer_soil',     _soil);
    await prefs.setString('farmer_irrigation', _irrigation);
    await prefs.setStringList('farmer_crops', _crops.toList());

    if (!mounted) return;
    setState(() {
      _isSaving = false;
      _isSaved  = true;
    });

    // Animate the checkmark and show the success banner
    _checkAnim.forward(from: 0);
    _showSuccessBanner();
  }

  Future<void> _switchAccount() async {
    final brand = brandOf(context);
    // Confirm dialog
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(children: [
          Icon(Icons.swap_horiz_rounded, color: brand),
          const SizedBox(width: 10),
          Text(_t('switchAcc'), style: const TextStyle(fontWeight: FontWeight.w800)),
        ]),
        content: Text(
          widget.lang == 'hi'
              ? 'क्या आप सच में खाता बदलना चाहते हैं? सभी जानकारी हट जाएगी।'
              : widget.lang == 'mr'
                  ? 'तुम्हाला खरोखर खाते बदलायचे आहे? सर्व माहिती हटेल.'
                  : 'Are you sure you want to switch accounts? All saved info will be cleared.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: brand),
            onPressed: () => Navigator.pop(context, true),
            child: Text(_t('switchAcc')),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;

    // Clear everything
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    setState(() {
      _nameController.clear();
      _phoneController.clear();
      _villageController.clear();
      _landController.clear();
      _district   = 'Nashik';
      _soil       = 'black';
      _irrigation = 'drip';
      _crops
        ..clear()
        ..addAll({'tomato', 'wheat'});
      _isSaved = false;
    });

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(children: [
          const Icon(Icons.swap_horiz_rounded, color: Colors.white),
          const SizedBox(width: 10),
          Expanded(child: Text(_t('switchMsg'))),
        ]),
        backgroundColor: Colors.orange.shade700,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccessBanner() {
    final brand = brandOf(context);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 3),
          backgroundColor: const Color(0xFF14532D),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          content: Row(children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                _t('savedMsg'),
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
              ),
            ),
          ]),
          action: SnackBarAction(
            label: widget.lang == 'hi' ? 'ठीक है' : widget.lang == 'mr' ? 'ठीक आहे' : 'OK',
            textColor: const Color(0xFF86EFAC),
            onPressed: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
          ),
        ),
      );
    // ignore: unused_local_variable
    final _ = brand; // keep brand in scope so linter is happy
  }

  // -------------------------------------------------------  BUILD
  @override
  Widget build(BuildContext context) {
    final cs    = Theme.of(context).colorScheme;
    final brand = brandOf(context);

    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(color: brand),
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          transitionBuilder: (child, anim) => FadeTransition(
            opacity: anim,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.06),
                end: Offset.zero,
              ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
              child: child,
            ),
          ),
          child: _isSaved
              ? _summaryView(cs, brand)   // ← SUMMARY CARD
              : _editForm(cs, brand),     // ← EDIT FORM
        ),
      ),
    );
  }

  // =====================================================================
  //  EDIT FORM
  // =====================================================================
  Widget _editForm(ColorScheme cs, Color brand) {
    return Form(
      key: _formKey,
      child: ListView(
        key: const ValueKey('form'),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
        children: [
          // ── Header ──────────────────────────────────────────────────
          _headerCard(brand, isEdit: true),
          const SizedBox(height: 22),

          // ── Section 1: Personal ──────────────────────────────────────
          _sectionHeader(_t('basicInfo'), Icons.badge_outlined, brand, cs),
          const SizedBox(height: 10),
          _card(cs, child: Column(children: [
            _field(
              controller: _nameController,
              label: _t('name'),
              icon: Icons.person_outline_rounded,
              validator: (v) => (v == null || v.trim().isEmpty) ? _t('required') : null,
            ),
            const SizedBox(height: 14),
            _field(
              controller: _phoneController,
              label: _t('phone'),
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return _t('required');
                if (!RegExp(r'^\d{10}$').hasMatch(v.trim())) return _t('phoneErr');
                return null;
              },
            ),
          ])),
          const SizedBox(height: 20),

          // ── Section 2: Location ──────────────────────────────────────
          _sectionHeader(_t('location'), Icons.location_on_outlined, brand, cs),
          const SizedBox(height: 10),
          _card(cs, child: Column(children: [
            DropdownButtonFormField<String>(
              initialValue: _district,
              decoration: InputDecoration(
                labelText: _t('district'),
                prefixIcon: const Icon(Icons.map_outlined),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              ),
              items: _districts
                  .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                  .toList(),
              onChanged: (v) { if (v != null) setState(() => _district = v); },
            ),
            const SizedBox(height: 14),
            _field(
              controller: _villageController,
              label: _t('village'),
              icon: Icons.home_work_outlined,
              hint: 'e.g. Niphad / Baramati',
            ),
          ])),
          const SizedBox(height: 20),

          // ── Section 3: Farm & Soil ───────────────────────────────────
          _sectionHeader(_t('farmDet'), Icons.terrain_rounded, brand, cs),
          const SizedBox(height: 10),
          _card(cs, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _field(
              controller: _landController,
              label: _t('landSize'),
              icon: Icons.straighten_rounded,
              hint: 'e.g. 3.5',
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 16),
            _chipLabel(_t('soilType'), cs),
            const SizedBox(height: 8),
            _chipGroup(
              options: _soilOpts,
              selected: (k) => _soil == k,
              onTap:    (k) => setState(() => _soil = k),
              brand: brand,
              multi: false,
            ),
            const SizedBox(height: 16),
            _chipLabel(_t('irrigation'), cs),
            const SizedBox(height: 8),
            _chipGroup(
              options: _irrigOpts,
              selected: (k) => _irrigation == k,
              onTap:    (k) => setState(() => _irrigation = k),
              brand: brand,
              multi: false,
            ),
          ])),
          const SizedBox(height: 20),

          // ── Section 4: Crops ─────────────────────────────────────────
          _sectionHeader(_t('crops'), Icons.eco_rounded, brand, cs),
          const SizedBox(height: 10),
          _card(cs, child: _chipGroup(
            options: _cropOpts,
            selected: _crops.contains,
            onTap: (k) => setState(() {
              if (_crops.contains(k)) {
                if (_crops.length > 1) _crops.remove(k);
              } else {
                _crops.add(k);
              }
            }),
            brand: brand,
            multi: true,
          )),
          const SizedBox(height: 28),

          // ── Save Button ──────────────────────────────────────────────
          FilledButton.icon(
            onPressed: _isSaving ? null : _saveProfile,
            icon: _isSaving
                ? const SizedBox(
                    width: 18, height: 18,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                : const Icon(Icons.save_rounded),
            label: Text(
              _t('save'),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            style: FilledButton.styleFrom(
              backgroundColor: brand,
              foregroundColor: Colors.white,
              disabledBackgroundColor: alpha(brand, 0.6),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ],
      ),
    );
  }

  // =====================================================================
  //  SUMMARY / PROFILE CARD  (shown after saving)
  // =====================================================================
  Widget _summaryView(ColorScheme cs, Color brand) {
    final name    = _nameController.text.trim();
    final phone   = _phoneController.text.trim();
    final village = _villageController.text.trim();
    final land    = _landController.text.trim();

    // Readable labels
    final soilLabel  = _soilOpts[_soil]?[widget.lang]  ?? _soilOpts[_soil]!['en']!;
    final irrigLabel = _irrigOpts[_irrigation]?[widget.lang] ?? _irrigOpts[_irrigation]!['en']!;
    final cropLabels = _crops
        .map((k) => _cropOpts[k]?[widget.lang] ?? _cropOpts[k]!['en']!)
        .toList();

    // ── Success animated checkmark (plays on first appearance) ──────
    final checkWidget = ScaleTransition(
      scale: _checkScale,
      child: Container(
        width: 56, height: 56,
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(50),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.check_rounded, color: Colors.white, size: 32),
      ),
    );

    return ListView(
      key: const ValueKey('summary'),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
      children: [

        // ── Success banner header ──────────────────────────────────────
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [brand, const Color(0xFF2EB86A)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: alpha(brand, 0.38),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(children: [
                checkWidget,
                const SizedBox(width: 14),
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _t('savedMsg'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _t('savedSub'),
                      style: const TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ],
                )),
              ]),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // ── Avatar + Name card ─────────────────────────────────────────
        _card(cs, child: Row(children: [
          // Avatar circle with initials
          Container(
            width: 64, height: 64,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [brand, const Color(0xFF2EB86A)],
              ),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : '🌾',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name.isNotEmpty ? name : '—',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: cs.onSurface,
                ),
              ),
              if (phone.isNotEmpty) ...[
                const SizedBox(height: 4),
                Row(children: [
                  Icon(Icons.phone_rounded, size: 14, color: alpha(cs.onSurface, 0.6)),
                  const SizedBox(width: 5),
                  Text(phone,
                    style: TextStyle(fontSize: 14, color: alpha(cs.onSurface, 0.7)),
                  ),
                ]),
              ],
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: alpha(brand, 0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: alpha(brand, 0.3)),
                ),
                child: Text(
                  '🌾 ${_t('farmerSince')} 2024',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: brand,
                  ),
                ),
              ),
            ],
          )),
        ])),

        const SizedBox(height: 14),

        // ── Location & Soil ───────────────────────────────────────────
        Row(children: [
          Expanded(child: _infoTile(
            cs, brand,
            icon: Icons.location_on_rounded,
            label: _t('locLabel'),
            value: [
              if (village.isNotEmpty) village,
              _district,
              'Maharashtra',
            ].join(', '),
          )),
          const SizedBox(width: 12),
          Expanded(child: _infoTile(
            cs, brand,
            icon: Icons.terrain_rounded,
            label: _t('soilLabel'),
            value: '$soilLabel\n$irrigLabel',
          )),
        ]),

        const SizedBox(height: 14),

        // ── Land size ─────────────────────────────────────────────────
        if (land.isNotEmpty)
          _infoTile(
            cs, brand,
            icon: Icons.straighten_rounded,
            label: _t('landSize'),
            value: '$land ${widget.lang == 'en' ? 'Acres' : widget.lang == 'hi' ? 'एकड़' : 'एकर'}',
          ),

        if (land.isNotEmpty) const SizedBox(height: 14),

        // ── Crops ─────────────────────────────────────────────────────
        _card(cs, child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(Icons.eco_rounded, size: 18, color: brand),
              const SizedBox(width: 8),
              Text(_t('cropLabel'),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: cs.onSurface,
                ),
              ),
            ]),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: cropLabels.map((label) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: alpha(brand, 0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: alpha(brand, 0.35)),
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: brand,
                  ),
                ),
              )).toList(),
            ),
          ],
        )),

        const SizedBox(height: 28),

        // ── Edit Profile Button ────────────────────────────────────────
        FilledButton.icon(
          onPressed: () => setState(() => _isSaved = false),
          icon: const Icon(Icons.edit_rounded),
          label: Text(
            _t('editBtn'),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          style: FilledButton.styleFrom(
            backgroundColor: brand,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        ),

        const SizedBox(height: 12),

        // ── Switch Account Button ─────────────────────────────────────
        OutlinedButton.icon(
          onPressed: _switchAccount,
          icon: Icon(Icons.swap_horiz_rounded, color: cs.error),
          label: Text(
            _t('switchAcc'),
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: cs.error,
            ),
          ),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
            side: BorderSide(color: alpha(cs.error, 0.6)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        ),
      ],
    );
  }

  // =====================================================================
  //  REUSABLE SMALL WIDGETS
  // =====================================================================

  /// Gradient header shared by both views
  Widget _headerCard(Color brand, {required bool isEdit}) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [brand, const Color(0xFF2EB86A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(children: [
        if (Navigator.canPop(context)) ...[
          IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          const SizedBox(width: 4),
        ],
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(50),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.person_rounded, color: Colors.white, size: 28),
        ),
        const SizedBox(width: 14),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_t('title'),
              style: const TextStyle(
                color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              isEdit ? _t('editSub') : _t('savedSub'),
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        )),
      ]),
    );
  }

  Widget _sectionHeader(String title, IconData icon, Color brand, ColorScheme cs) {
    return Row(children: [
      Icon(icon, size: 20, color: brand),
      const SizedBox(width: 8),
      Text(title,
        style: TextStyle(
          fontSize: 15, fontWeight: FontWeight.w800, color: cs.onSurface,
        ),
      ),
    ]);
  }

  Widget _card(ColorScheme cs, {required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: alpha(cs.surface, 0.96),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: alpha(cs.outlineVariant, 0.6)),
      ),
      child: child,
    );
  }

  /// Small info tile used in summary view
  Widget _infoTile(
    ColorScheme cs,
    Color brand, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: alpha(cs.surface, 0.96),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: alpha(cs.outlineVariant, 0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(icon, size: 15, color: brand),
            const SizedBox(width: 5),
            Text(label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: alpha(cs.onSurface, 0.55),
              ),
            ),
          ]),
          const SizedBox(height: 6),
          Text(value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: cs.onSurface,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        errorStyle: const TextStyle(fontSize: 12),
      ),
    );
  }

  Widget _chipLabel(String text, ColorScheme cs) {
    return Text(
      text,
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 13,
        color: cs.onSurface,
      ),
    );
  }

  Widget _chipGroup({
    required Map<String, Map<String, String>> options,
    required bool Function(String) selected,
    required void Function(String) onTap,
    required Color brand,
    required bool multi,
  }) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.entries.map((e) {
        final sel   = selected(e.key);
        final label = e.value[widget.lang] ?? e.value['en']!;
        return multi
            ? FilterChip(
                label: Text(label),
                selected: sel,
                selectedColor: alpha(brand, 0.22),
                checkmarkColor: brand,
                onSelected: (_) => onTap(e.key),
              )
            : ChoiceChip(
                label: Text(label),
                selected: sel,
                selectedColor: alpha(brand, 0.22),
                onSelected: (v) { if (v) onTap(e.key); },
              );
      }).toList(),
    );
  }
}
