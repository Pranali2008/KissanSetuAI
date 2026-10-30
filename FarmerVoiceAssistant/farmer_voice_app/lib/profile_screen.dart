import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_theme.dart';
import 'services/farmer_api_service.dart';

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

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _villageController = TextEditingController();
  final TextEditingController _landSizeController = TextEditingController();
  final TextEditingController _serverHostController = TextEditingController();

  String _selectedState = 'Maharashtra';
  String _selectedDistrict = 'Nashik';
  String _selectedSoil = 'black';
  String _selectedIrrigation = 'drip';
  final Set<String> _selectedCrops = {'tomato', 'wheat'};
  bool _isLoading = true;
  bool _isEditing = false;
  bool _hasSavedProfile = false;

  // Localized texts
  static const Map<String, Map<String, String>> _labels = {
    'title': {
      'en': 'Farmer Profile',
      'hi': 'किसान प्रोफ़ाइल',
      'mr': 'शेतकरी प्रोफाइल',
    },
    'subtitle': {
      'en': 'Personalize your farming advice & crop recommendations',
      'hi': 'सटीक खेती सलाह के लिए अपनी जानकारी दर्ज करें',
      'mr': 'अचूक शेती सल्ल्यासाठी तुमची माहिती नोंदवा',
    },
    'basicInfo': {
      'en': 'Personal Details',
      'hi': 'व्यक्तिगत विवरण',
      'mr': 'वैयक्तिक माहिती',
    },
    'name': {
      'en': 'Farmer Name',
      'hi': 'किसान का नाम',
      'mr': 'शेतकऱ्याचे नाव',
    },
    'phone': {
      'en': 'Mobile Number',
      'hi': 'मोबाइल नंबर',
      'mr': 'मोबाईल नंबर',
    },
    'location': {
      'en': 'Region & Location',
      'hi': 'क्षेत्र और स्थान',
      'mr': 'प्रदेश आणि गाव',
    },
    'state': {
      'en': 'State',
      'hi': 'राज्य',
      'mr': 'राज्य',
    },
    'district': {
      'en': 'District',
      'hi': 'ज़िला',
      'mr': 'जिल्हा',
    },
    'village': {
      'en': 'Village / Taluka',
      'hi': 'गाँव / तहसील',
      'mr': 'गाव / तालुका',
    },
    'farmDetails': {
      'en': 'Farm & Soil Details',
      'hi': 'खेत और मिट्टी का विवरण',
      'mr': 'जमीन आणि मातीचा तपशील',
    },
    'landSize': {
      'en': 'Total Land (in Acres)',
      'hi': 'कुल जमीन (एकड़ में)',
      'mr': 'एकूण जमीन (एकरमध्ये)',
    },
    'soilType': {
      'en': 'Soil Type',
      'hi': 'मिट्टी का प्रकार',
      'mr': 'मातीचा प्रकार',
    },
    'irrigation': {
      'en': 'Irrigation Source',
      'hi': 'सिंचाई का साधन',
      'mr': 'सिंचनाची सोय',
    },
    'crops': {
      'en': 'Crops You Grow',
      'hi': 'आपकी फसलें',
      'mr': 'तुम्ही पिकवणारी पिके',
    },
    'save': {
      'en': 'Save Information',
      'hi': 'जानकारी सहेजें',
      'mr': 'माहिती सेव्ह करा',
    },
    'editProfile': {
      'en': 'Edit Profile',
      'hi': 'प्रोफ़ाइल बदलें',
      'mr': 'प्रोफाइल बदला',
    },
    'switchAccount': {
      'en': 'Switch Account',
      'hi': 'खाता बदलें',
      'mr': 'खाते बदला',
    },
    'savedSuccess': {
      'en': 'Successfully saved your information!',
      'hi': 'आपकी जानकारी सफलतापूर्वक सहेज ली गई!',
      'mr': 'तुमची माहिती यशस्वीरीत्या सेव्ह केली गेली!',
    },
    'farmerSummary': {
      'en': 'Farmer Profile Summary',
      'hi': 'किसान प्रोफ़ाइल विवरण',
      'mr': 'शेतकरी प्रोफाइल सारांश',
    },
    'serverSetting': {
      'en': 'Backend Server Host (for Android Phone)',
      'hi': 'बैकएंड सर्वर होस्ट (मोबाइल फोन हेतु)',
      'mr': 'बॅकएंड सर्व्हर पत्ता (मोबाईल फोनसाठी)',
    },
  };

  String _t(String key) => _labels[key]?[widget.lang] ?? _labels[key]?['en'] ?? key;

  final List<String> _districts = [
    'Nashik',
    'Pune',
    'Ahmednagar',
    'Satara',
    'Kolhapur',
    'Solapur',
    'Sangli',
    'Aurangabad (Chh. Sambhajinagar)',
    'Jalgaon',
    'Amravati',
    'Nagpur',
    'Latur',
    'Nanded',
  ];

  final Map<String, Map<String, String>> _soilOptions = {
    'black': {'en': 'Black Soil (काळी माती)', 'hi': 'काली मिट्टी', 'mr': 'काळी कसदार माती'},
    'red': {'en': 'Red Soil (तांबडी माती)', 'hi': 'लाल मिट्टी', 'mr': 'तांबडी माती'},
    'loamy': {'en': 'Loamy Soil (गाळाची माती)', 'hi': 'दोमट मिट्टी', 'mr': 'गाळाची पोयटा माती'},
    'sandy': {'en': 'Sandy Soil (रेताड माती)', 'hi': 'बलुई मिट्टी', 'mr': 'रेताड हलकी माती'},
  };

  final Map<String, Map<String, String>> _irrigationOptions = {
    'drip': {'en': 'Drip Irrigation (ठिबक)', 'hi': 'ड्रिप सिंचाई', 'mr': 'ठिबक सिंचन'},
    'sprinkler': {'en': 'Sprinkler (तुषार)', 'hi': 'फव्वारा सिंचाई', 'mr': 'तुषार सिंचन'},
    'well': {'en': 'Well / Borewell (विहीर / बोअर)', 'hi': 'कुआं / बोरवेल', 'mr': 'विहीर / बोअरवेल'},
    'canal': {'en': 'Canal (कालवा)', 'hi': 'नहर', 'mr': 'कालवा / पाटबंधारे'},
    'rainfed': {'en': 'Rainfed (कोरडवाहू)', 'hi': 'वर्षा आधारित', 'mr': 'कोरडवाहू (पावसावर)'},
  };

  final Map<String, Map<String, String>> _cropOptions = {
    'tomato': {'en': 'Tomato 🍅', 'hi': 'टमाटर 🍅', 'mr': 'टोमॅटो 🍅'},
    'wheat': {'en': 'Wheat 🌾', 'hi': 'गेहूं 🌾', 'mr': 'गहू 🌾'},
    'ladyfinger': {'en': 'Ladyfinger 🥬', 'hi': 'भिंडी 🥬', 'mr': 'भेंडी 🥬'},
    'chili': {'en': 'Chili 🌶️', 'hi': 'मिर्च 🌶️', 'mr': 'मिरची 🌶️'},
    'broccoli': {'en': 'Broccoli 🥦', 'hi': 'ब्रोकोली 🥦', 'mr': 'ब्रोकोली 🥦'},
    'apple': {'en': 'Apple 🍎', 'hi': 'सेब 🍎', 'mr': 'सफरचंद 🍎'},
    'mango': {'en': 'Mango 🥭', 'hi': 'आम 🥭', 'mr': 'आंबा 🥭'},
    'onion': {'en': 'Onion 🧅', 'hi': 'प्याज 🧅', 'mr': 'कांदा 🧅'},
    'soybean': {'en': 'Soybean 🌱', 'hi': 'सोयाबीन 🌱', 'mr': 'सोयाबीन 🌱'},
    'cotton': {'en': 'Cotton ☁️', 'hi': 'कपास ☁️', 'mr': 'कापूस ☁️'},
    'sugarcane': {'en': 'Sugarcane 🎋', 'hi': 'गन्ना 🎋', 'mr': 'ऊस 🎋'},
  };

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('farmer_name') ?? '';
    final phone = prefs.getString('farmer_phone') ?? '';
    final village = prefs.getString('farmer_village') ?? '';
    final land = prefs.getString('farmer_land_size') ?? '';
    final host = prefs.getString('backend_base_url') ?? 'http://127.0.0.1:8000';

    final hasData = name.trim().isNotEmpty || phone.trim().isNotEmpty;

    setState(() {
      _nameController.text = name;
      _phoneController.text = phone;
      _villageController.text = village;
      _landSizeController.text = land;
      _serverHostController.text = host;
      _selectedState = prefs.getString('farmer_state') ?? 'Maharashtra';
      _selectedDistrict = prefs.getString('farmer_district') ?? 'Nashik';
      _selectedSoil = prefs.getString('farmer_soil') ?? 'black';
      _selectedIrrigation = prefs.getString('farmer_irrigation') ?? 'drip';

      final savedCrops = prefs.getStringList('farmer_crops');
      if (savedCrops != null && savedCrops.isNotEmpty) {
        _selectedCrops.clear();
        _selectedCrops.addAll(savedCrops);
      }
      _hasSavedProfile = hasData;
      _isEditing = !hasData;
      _isLoading = false;
    });
  }

  Future<void> _saveProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final village = _villageController.text.trim();
    final land = _landSizeController.text.trim();
    final host = _serverHostController.text.trim();

    await prefs.setString('farmer_name', name);
    await prefs.setString('farmer_phone', phone);
    await prefs.setString('farmer_village', village);
    await prefs.setString('farmer_land_size', land);
    await prefs.setString('farmer_state', _selectedState);
    await prefs.setString('farmer_district', _selectedDistrict);
    await prefs.setString('farmer_soil', _selectedSoil);
    await prefs.setString('farmer_irrigation', _selectedIrrigation);
    await prefs.setStringList('farmer_crops', _selectedCrops.toList());

    if (host.isNotEmpty) {
      await FarmerApiService.setBaseUrl(host);
    }

    setState(() {
      _hasSavedProfile = true;
      _isEditing = false;
    });

    if (!mounted) return;

    // Show prominent success dialog / snackbar
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Color(0xFF16A34A), size: 28),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                widget.lang == 'mr'
                    ? 'यशस्वी!'
                    : widget.lang == 'hi'
                        ? 'सफलता!'
                        : 'Success!',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Text(
          _t('savedSuccess'),
          style: const TextStyle(fontSize: 15),
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(ctx),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF16A34A),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(
              widget.lang == 'mr' ? 'ठीक आहे' : widget.lang == 'hi' ? 'ठीक है' : 'OK',
            ),
          ),
        ],
      ),
    );
  }

  void _switchAccount() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          widget.lang == 'mr'
              ? 'खाते बदलायचे आहे का?'
              : widget.lang == 'hi'
                  ? 'क्या आप खाता बदलना चाहते हैं?'
                  : 'Switch Account?',
        ),
        content: Text(
          widget.lang == 'mr'
              ? 'नवीन शेतकऱ्याची माहिती नोंदवण्यासाठी किंवा दुसऱ्या खात्यात जाण्यासाठी होय निवडा.'
              : widget.lang == 'hi'
                  ? 'नए किसान की जानकारी दर्ज करने या दूसरा खाता चुनने के लिए हाँ चुनें।'
                  : 'You can register another farmer profile or reset current credentials.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(widget.lang == 'mr' ? 'रद्द करा' : widget.lang == 'hi' ? 'रद्द करें' : 'Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFFDC2626)),
            child: Text(widget.lang == 'mr' ? 'होय, बदला' : widget.lang == 'hi' ? 'हाँ, बदलें' : 'Yes, Switch'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('farmer_name');
      await prefs.remove('farmer_phone');
      await prefs.remove('farmer_village');
      await prefs.remove('farmer_land_size');
      setState(() {
        _nameController.clear();
        _phoneController.clear();
        _villageController.clear();
        _landSizeController.clear();
        _hasSavedProfile = false;
        _isEditing = true;
      });
    }
  }

  String _generateFarmerSummary() {
    final name = _nameController.text.trim().isNotEmpty ? _nameController.text.trim() : 'Farmer';
    final land = _landSizeController.text.trim().isNotEmpty ? _landSizeController.text.trim() : '2';
    final district = _selectedDistrict;
    final village = _villageController.text.trim().isNotEmpty ? _villageController.text.trim() : district;
    final soil = _soilOptions[_selectedSoil]?[widget.lang] ?? _selectedSoil;
    final irrigation = _irrigationOptions[_selectedIrrigation]?[widget.lang] ?? _selectedIrrigation;
    final cropNames = _selectedCrops.map((c) => _cropOptions[c]?[widget.lang] ?? c).join(', ');

    if (widget.lang == 'mr') {
      return 'शेतकरी मित्र $name हे $village ($district) येथील प्रगतीशील शेतकरी आहेत. '
          'त्यांच्याकडे $land एकर शेतजमीन असून मुख्यत्वे $soil जमीन आहे. '
          '$irrigation च्या मदतीने ते $cropNames ही पिके घेतात. '
          'सेंद्रिय खते व संतुलित पोषण व्यवस्थापनाने ते उच्च कृषी उत्पादनासाठी प्रयत्नशील आहेत.';
    } else if (widget.lang == 'hi') {
      return 'किसान $name, $village ($district) के एक प्रगतिशील किसान हैं। '
          'उनके पास $land एकड़ खेत है जिसमें $soil और $irrigation की उत्तम व्यवस्था है। '
          'वे मुख्य रूप से $cropNames की सफल खेती करते हैं और आधुनिक तकनीकी मार्गदर्शन से उच्च पैदावार ले रहे हैं।';
    } else {
      return 'Progressive agricultural grower $name operating in $village ($district, $_selectedState). '
          'Cultivates $cropNames across $land acres of fertile $soil with $irrigation. '
          'Focused on climate-resilient practices, balanced NPK fertigation, and maximizing harvest yield.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final brand = Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF2E9E5B)
        : const Color(0xFF14532D);

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
          children: [
            // Top Header Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [brand, const Color(0xFF2EB86A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: alpha(brand, 0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(50),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person_rounded,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _t('title'),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _t('subtitle'),
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // If not editing and has saved profile: Show Profile Summary view
            if (_hasSavedProfile && !_isEditing) ...[
              _buildSavedSummaryView(cs, brand),
            ] else ...[
              _buildEditFormView(cs, brand),
            ],
          ],
        ),
      ),
    );
  }

  // --- SUMMARY / DESCRIPTION VIEW ---
  Widget _buildSavedSummaryView(ColorScheme cs, Color brand) {
    final name = _nameController.text.trim().isNotEmpty ? _nameController.text.trim() : 'Registered Farmer';
    final phone = _phoneController.text.trim().isNotEmpty ? _phoneController.text.trim() : 'Not provided';
    final village = _villageController.text.trim().isNotEmpty ? _villageController.text.trim() : 'Village';
    final district = _selectedDistrict;
    final land = _landSizeController.text.trim().isNotEmpty ? _landSizeController.text.trim() : 'N/A';
    final soil = _soilOptions[_selectedSoil]?[widget.lang] ?? _selectedSoil;
    final irrigation = _irrigationOptions[_selectedIrrigation]?[widget.lang] ?? _selectedIrrigation;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Verified Farmer Card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: alpha(cs.surface, 0.96),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: alpha(brand, 0.4)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(12),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: alpha(brand, 0.15),
                    child: Icon(Icons.verified_user_rounded, color: brand, size: 28),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: cs.onSurface,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Icon(Icons.phone_outlined, size: 14, color: brand),
                            const SizedBox(width: 4),
                            Text(
                              phone,
                              style: TextStyle(fontSize: 13, color: alpha(cs.onSurface, 0.7)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF16A34A).withAlpha(25),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFF16A34A)),
                    ),
                    child: Text(
                      widget.lang == 'mr' ? 'नोंदणीकृत' : widget.lang == 'hi' ? 'सत्यापित' : 'Active',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF16A34A),
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),

              // Details Grid
              _summaryRow(Icons.location_on_outlined, widget.lang == 'mr' ? 'स्थान' : 'Location', '$village, $district, $_selectedState', cs),
              _summaryRow(Icons.straighten_rounded, widget.lang == 'mr' ? 'एकूण जमीन' : 'Land Area', '$land Acres (एकर)', cs),
              _summaryRow(Icons.terrain_rounded, widget.lang == 'mr' ? 'मातीचा प्रकार' : 'Soil Type', soil, cs),
              _summaryRow(Icons.water_drop_outlined, widget.lang == 'mr' ? 'सिंचन पद्धत' : 'Irrigation', irrigation, cs),

              const SizedBox(height: 12),
              Text(
                widget.lang == 'mr' ? 'पिकवली जाणारी पिके:' : widget.lang == 'hi' ? 'उगाई जाने वाली फसलें:' : 'Cultivated Crops:',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: _selectedCrops.map((c) {
                  final label = _cropOptions[c]?[widget.lang] ?? c;
                  return Chip(
                    label: Text(label, style: const TextStyle(fontSize: 12)),
                    backgroundColor: alpha(brand, 0.1),
                    side: BorderSide(color: alpha(brand, 0.3)),
                  );
                }).toList(),
              ),

              const Divider(height: 24),

              // Short Summary Description
              Row(
                children: [
                  Icon(Icons.auto_awesome_rounded, color: brand, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    _t('farmerSummary'),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: brand,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: alpha(brand, 0.06),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: alpha(brand, 0.2)),
                ),
                child: Text(
                  _generateFarmerSummary(),
                  style: TextStyle(
                    fontSize: 13.5,
                    height: 1.5,
                    color: cs.onSurface,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Action Buttons: Edit Profile & Switch Account
        Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                icon: const Icon(Icons.edit_rounded, size: 18),
                label: Text(_t('editProfile')),
                onPressed: () => setState(() => _isEditing = true),
                style: FilledButton.styleFrom(
                  backgroundColor: brand,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.switch_account_rounded, size: 18),
                label: Text(_t('switchAccount')),
                onPressed: _switchAccount,
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFDC2626),
                  side: const BorderSide(color: Color(0xFFDC2626)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 24),

        // Server connection info for Android
        _card(
          cs,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.phonelink_setup_rounded, size: 18, color: Colors.blue),
                  const SizedBox(width: 8),
                  Text(
                    _t('serverSetting'),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Active API: ${_serverHostController.text.isNotEmpty ? _serverHostController.text : "http://127.0.0.1:8000"}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _summaryRow(IconData icon, String label, String value, ColorScheme cs) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: Colors.grey),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: cs.onSurface),
            ),
          ),
        ],
      ),
    );
  }

  // --- EDIT FORM VIEW ---
  Widget _buildEditFormView(ColorScheme cs, Color brand) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Section 1: Basic Info
          _sectionHeader(_t('basicInfo'), Icons.badge_outlined, brand, cs),
          const SizedBox(height: 10),
          _card(
            cs,
            child: Column(
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: _t('name'),
                    hintText: 'e.g. Ramesh Patil',
                    prefixIcon: const Icon(Icons.person_outline_rounded),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: _t('phone'),
                    hintText: 'e.g. 9876543210',
                    prefixIcon: const Icon(Icons.phone_outlined),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Section 2: Location
          _sectionHeader(_t('location'), Icons.location_on_outlined, brand, cs),
          const SizedBox(height: 10),
          _card(
            cs,
            child: Column(
              children: [
                DropdownButtonFormField<String>(
                  initialValue: _selectedDistrict,
                  decoration: InputDecoration(
                    labelText: _t('district'),
                    prefixIcon: const Icon(Icons.map_outlined),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  items: _districts.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedDistrict = val);
                  },
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _villageController,
                  decoration: InputDecoration(
                    labelText: _t('village'),
                    hintText: 'e.g. Niphad / Baramati',
                    prefixIcon: const Icon(Icons.home_work_outlined),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Section 3: Farm & Soil
          _sectionHeader(_t('farmDetails'), Icons.terrain_rounded, brand, cs),
          const SizedBox(height: 10),
          _card(
            cs,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _landSizeController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: _t('landSize'),
                    hintText: 'e.g. 3.5',
                    prefixIcon: const Icon(Icons.straighten_rounded),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
                const SizedBox(height: 16),
                Text(_t('soilType'), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: cs.onSurface)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _soilOptions.entries.map((entry) {
                    final isSelected = _selectedSoil == entry.key;
                    final label = entry.value[widget.lang] ?? entry.value['en']!;
                    return ChoiceChip(
                      label: Text(label),
                      selected: isSelected,
                      selectedColor: alpha(brand, 0.2),
                      onSelected: (selected) {
                        if (selected) setState(() => _selectedSoil = entry.key);
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                Text(_t('irrigation'), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: cs.onSurface)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _irrigationOptions.entries.map((entry) {
                    final isSelected = _selectedIrrigation == entry.key;
                    final label = entry.value[widget.lang] ?? entry.value['en']!;
                    return ChoiceChip(
                      label: Text(label),
                      selected: isSelected,
                      selectedColor: alpha(brand, 0.2),
                      onSelected: (selected) {
                        if (selected) setState(() => _selectedIrrigation = entry.key);
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Section 4: Crops
          _sectionHeader(_t('crops'), Icons.eco_rounded, brand, cs),
          const SizedBox(height: 10),
          _card(
            cs,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.lang == 'mr'
                      ? 'तुम्ही पिकवत असलेली सर्व पिके निवडा:'
                      : widget.lang == 'hi'
                          ? 'अपनी सभी फसलें चुनें:'
                          : 'Select all crops you grow:',
                  style: TextStyle(fontSize: 13, color: cs.onSurface.withAlpha(180)),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _cropOptions.entries.map((entry) {
                    final isSelected = _selectedCrops.contains(entry.key);
                    final label = entry.value[widget.lang] ?? entry.value['en']!;
                    return FilterChip(
                      label: Text(label),
                      selected: isSelected,
                      selectedColor: alpha(brand, 0.25),
                      checkmarkColor: brand,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedCrops.add(entry.key);
                          } else {
                            if (_selectedCrops.length > 1) {
                              _selectedCrops.remove(entry.key);
                            }
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Backend IP configuration (for Android phone / Edge connection)
          _card(
            cs,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.settings_ethernet_rounded, size: 18, color: Colors.blue),
                    const SizedBox(width: 8),
                    Text(
                      _t('serverSetting'),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  widget.lang == 'mr'
                      ? 'मोबाईलवरून चालवताना तुमच्या लॅपटॉपचा IP टाका (उदा. http://192.168.1.5:8000)'
                      : widget.lang == 'hi'
                          ? 'मोबाइल पर चलाने के लिए लैपटॉप का लोकल आईपी डालें (उदा. http://192.168.1.5:8000)'
                          : 'Enter your computer Wi-Fi IP when accessing from Android phone',
                  style: TextStyle(fontSize: 12, color: alpha(cs.onSurface, 0.65)),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _serverHostController,
                  decoration: InputDecoration(
                    hintText: 'http://127.0.0.1:8000',
                    prefixIcon: const Icon(Icons.link_rounded),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Save Button
          FilledButton.icon(
            onPressed: _saveProfile,
            icon: const Icon(Icons.save_rounded),
            label: Text(
              _t('save'),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            style: FilledButton.styleFrom(
              backgroundColor: brand,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
          if (_hasSavedProfile) ...[
            const SizedBox(height: 10),
            TextButton(
              onPressed: () => setState(() => _isEditing = false),
              child: Text(widget.lang == 'mr' ? 'रद्द करा' : widget.lang == 'hi' ? 'रद्द करें' : 'Cancel'),
            ),
          ],
        ],
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
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: cs.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _card(ColorScheme cs, {required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: alpha(cs.surface, 0.96),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: alpha(cs.outlineVariant, 0.6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(12),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}
