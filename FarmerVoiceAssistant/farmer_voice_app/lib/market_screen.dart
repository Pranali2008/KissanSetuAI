import 'package:flutter/material.dart';
import 'app_theme.dart';

class MarketScreen extends StatefulWidget {
  final String lang; // 'en', 'hi', or 'mr'

  const MarketScreen({super.key, required this.lang});

  @override
  State<MarketScreen> createState() => _MarketScreenState();
}

class _MarketRecord {
  final String crop;
  final String emoji;
  final Map<String, String> cropName;
  final Map<String, String> marketName;
  final int minPrice;
  final int maxPrice;
  final int modalPrice;
  final int change;

  const _MarketRecord({
    required this.crop,
    required this.emoji,
    required this.cropName,
    required this.marketName,
    required this.minPrice,
    required this.maxPrice,
    required this.modalPrice,
    required this.change,
  });
}

class _MarketScreenState extends State<MarketScreen> {
  String _selectedCrop = 'all';
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';

  final List<_MarketRecord> _records = const [
    _MarketRecord(
      crop: 'onion',
      emoji: '🧅',
      cropName: {'en': 'Onion', 'hi': 'प्याज', 'mr': 'कांदा'},
      marketName: {
        'en': 'Lasalgaon APMC (Nashik)',
        'hi': 'लासलगांव एपीएमसी (नाशिक)',
        'mr': 'लासलगाव बाजार समिती (नाशिक)'
      },
      minPrice: 1650,
      maxPrice: 2800,
      modalPrice: 2350,
      change: 80,
    ),
    _MarketRecord(
      crop: 'tomato',
      emoji: '🍅',
      cropName: {'en': 'Tomato', 'hi': 'टमाटर', 'mr': 'टोमॅटो'},
      marketName: {
        'en': 'Nashik APMC (Nashik)',
        'hi': 'नाशिक मंडी (नाशिक)',
        'mr': 'नाशिक कृषी उत्पन्न बाजार समिती'
      },
      minPrice: 1200,
      maxPrice: 2400,
      modalPrice: 1950,
      change: -110,
    ),
    _MarketRecord(
      crop: 'wheat',
      emoji: '🌾',
      cropName: {'en': 'Wheat', 'hi': 'गेहूं', 'mr': 'गहू'},
      marketName: {
        'en': 'Pune Market Yard (Pune)',
        'hi': 'पुणे मार्केट यार्ड (पुणे)',
        'mr': 'पुणे मार्केट यार्ड'
      },
      minPrice: 2400,
      maxPrice: 3250,
      modalPrice: 2850,
      change: 30,
    ),
    _MarketRecord(
      crop: 'soybean',
      emoji: '🌱',
      cropName: {'en': 'Soybean', 'hi': 'सोयाबीन', 'mr': 'सोयाबीन'},
      marketName: {
        'en': 'Latur APMC (Latur)',
        'hi': 'लातूर मंडी (लातूर)',
        'mr': 'लातूर कृषी उत्पन्न बाजार समिती'
      },
      minPrice: 4200,
      maxPrice: 4850,
      modalPrice: 4600,
      change: 50,
    ),
    _MarketRecord(
      crop: 'cotton',
      emoji: '☁️',
      cropName: {'en': 'Cotton', 'hi': 'कपास', 'mr': 'कापूस'},
      marketName: {
        'en': 'Jalna APMC (Jalna)',
        'hi': 'जालना मंडी (जालना)',
        'mr': 'जालना कृषी उत्पन्न बाजार समिती'
      },
      minPrice: 6800,
      maxPrice: 7700,
      modalPrice: 7350,
      change: -75,
    ),
    _MarketRecord(
      crop: 'ladyfinger',
      emoji: '🥬',
      cropName: {'en': 'Ladyfinger (Okra)', 'hi': 'भिंडी', 'mr': 'भेंडी'},
      marketName: {
        'en': 'Navi Mumbai Vashi APMC',
        'hi': 'नवी मुंबई वाशी मंडी',
        'mr': 'नवी मुंबई वाशी बाजार'
      },
      minPrice: 2800,
      maxPrice: 4500,
      modalPrice: 3600,
      change: 120,
    ),
    _MarketRecord(
      crop: 'chili',
      emoji: '🌶️',
      cropName: {'en': 'Green Chili', 'hi': 'हरी मिर्च', 'mr': 'मिरची'},
      marketName: {
        'en': 'Nanded APMC (Nanded)',
        'hi': 'नांदेड मंडी (नांदेड)',
        'mr': 'नांदेड बाजार समिती'
      },
      minPrice: 4800,
      maxPrice: 8500,
      modalPrice: 6500,
      change: -150,
    ),
    _MarketRecord(
      crop: 'broccoli',
      emoji: '🥦',
      cropName: {'en': 'Broccoli', 'hi': 'ब्रोकोली', 'mr': 'ब्रोकोली'},
      marketName: {
        'en': 'Pune Gultekdi Market',
        'hi': 'पुणे गुलटेकड़ी मंडी',
        'mr': 'पुणे गुलटेकडी भाजीपाला बाजार'
      },
      minPrice: 3500,
      maxPrice: 7500,
      modalPrice: 5500,
      change: 250,
    ),
    _MarketRecord(
      crop: 'apple',
      emoji: '🍎',
      cropName: {'en': 'Apple', 'hi': 'सेब', 'mr': 'सफरचंद'},
      marketName: {
        'en': 'Vashi Fruit Market (Mumbai)',
        'hi': 'वाशी फल मंडी (मुंबई)',
        'mr': 'वाशी फळ बाजार (मुंबई)'
      },
      minPrice: 7500,
      maxPrice: 16000,
      modalPrice: 11500,
      change: 400,
    ),
    _MarketRecord(
      crop: 'mango',
      emoji: '🥭',
      cropName: {'en': 'Mango (Alphonso / Kesar)', 'hi': 'आम (हापुस / केसर)', 'mr': 'आंबा (हापूस / केशर)'},
      marketName: {
        'en': 'Ratnagiri APMC',
        'hi': 'रत्नागिरी मंडी',
        'mr': 'रत्नागिरी बाजार समिती'
      },
      minPrice: 6500,
      maxPrice: 19000,
      modalPrice: 12500,
      change: 1000,
    ),
    _MarketRecord(
      crop: 'pomegranate',
      emoji: '🔴',
      cropName: {'en': 'Pomegranate (Bhagwa)', 'hi': 'अनार (भगवा)', 'mr': 'डाळिंब (भगवा)'},
      marketName: {
        'en': 'Solapur APMC',
        'hi': 'सोलापूर मंडी',
        'mr': 'सोलापूर बाजार समिती'
      },
      minPrice: 4500,
      maxPrice: 9800,
      modalPrice: 7200,
      change: 320,
    ),
    _MarketRecord(
      crop: 'banana',
      emoji: '🍌',
      cropName: {'en': 'Banana', 'hi': 'केला', 'mr': 'केळी'},
      marketName: {
        'en': 'Jalgaon APMC (Jalgaon)',
        'hi': 'जलगांव मंडी (जलगांव)',
        'mr': 'जळगाव कृषी उत्पन्न बाजार समिती'
      },
      minPrice: 1300,
      maxPrice: 2400,
      modalPrice: 1850,
      change: -40,
    ),
    _MarketRecord(
      crop: 'grapes',
      emoji: '🍇',
      cropName: {'en': 'Grapes (Thompson)', 'hi': 'अंगूर', 'mr': 'द्राक्ष'},
      marketName: {
        'en': 'Pimpalgaon APMC (Nashik)',
        'hi': 'पिंपलगांव मंडी (नाशिक)',
        'mr': 'पिंपळगाव बसवंत बाजार समिती'
      },
      minPrice: 3800,
      maxPrice: 7500,
      modalPrice: 5600,
      change: 220,
    ),
    _MarketRecord(
      crop: 'potato',
      emoji: '🥔',
      cropName: {'en': 'Potato', 'hi': 'आलू', 'mr': 'बटाटा'},
      marketName: {
        'en': 'Pune APMC (Pune)',
        'hi': 'पुणे मंडी (पुणे)',
        'mr': 'पुणे कृषी उत्पन्न बाजार समिती'
      },
      minPrice: 1100,
      maxPrice: 1900,
      modalPrice: 1500,
      change: 25,
    ),
    _MarketRecord(
      crop: 'garlic',
      emoji: '🧄',
      cropName: {'en': 'Garlic', 'hi': 'लहसुन', 'mr': 'लसून'},
      marketName: {
        'en': 'Ahmednagar APMC',
        'hi': 'अहमदनगर मंडी',
        'mr': 'अहमदनगर बाजार समिती'
      },
      minPrice: 8500,
      maxPrice: 15000,
      modalPrice: 12000,
      change: 500,
    ),
    _MarketRecord(
      crop: 'ginger',
      emoji: '🫚',
      cropName: {'en': 'Ginger (Fresh)', 'hi': 'अदरक', 'mr': 'आले'},
      marketName: {
        'en': 'Satara APMC (Satara)',
        'hi': 'सातारा मंडी (सातारा)',
        'mr': 'सातारा कृषी उत्पन्न बाजार समिती'
      },
      minPrice: 5000,
      maxPrice: 9500,
      modalPrice: 7500,
      change: 300,
    ),
    _MarketRecord(
      crop: 'cauliflower',
      emoji: '🥦',
      cropName: {'en': 'Cauliflower', 'hi': 'फूलगोभी', 'mr': 'फुलकोबी'},
      marketName: {
        'en': 'Pune APMC',
        'hi': 'पुणे मंडी',
        'mr': 'पुणे बाजार समिती'
      },
      minPrice: 700,
      maxPrice: 1600,
      modalPrice: 1150,
      change: 50,
    ),
    _MarketRecord(
      crop: 'groundnut',
      emoji: '🥜',
      cropName: {'en': 'Groundnut', 'hi': 'मूंगफली', 'mr': 'भुईमूग'},
      marketName: {
        'en': 'Akola APMC (Akola)',
        'hi': 'अकोला मंडी (अकोला)',
        'mr': 'अकोला बाजार समिती'
      },
      minPrice: 5400,
      maxPrice: 6800,
      modalPrice: 6100,
      change: 110,
    ),
    _MarketRecord(
      crop: 'watermelon',
      emoji: '🍉',
      cropName: {'en': 'Watermelon', 'hi': 'तरबूज', 'mr': 'कलिंगड'},
      marketName: {
        'en': 'Solapur Fruit Market',
        'hi': 'सोलापूर फल मंडी',
        'mr': 'सोलापूर फळ बाजार'
      },
      minPrice: 800,
      maxPrice: 1600,
      modalPrice: 1200,
      change: -30,
    ),
    _MarketRecord(
      crop: 'marigold',
      emoji: '🌼',
      cropName: {'en': 'Marigold Flower', 'hi': 'गेंदा फूल', 'mr': 'झेंडू फुले'},
      marketName: {
        'en': 'Dadar Flower Market (Mumbai)',
        'hi': 'दादर फूल मंडी (मुंबई)',
        'mr': 'दादर फूल बाजार (मुंबई)'
      },
      minPrice: 4500,
      maxPrice: 9500,
      modalPrice: 7000,
      change: 350,
    ),
  ];

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  String _t(Map<String, String> m) => m[widget.lang] ?? m['en'] ?? '';

  List<_MarketRecord> get _filtered {
    List<_MarketRecord> list = _selectedCrop == 'all'
        ? _records
        : _records.where((r) => r.crop == _selectedCrop).toList();

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list.where((r) {
        final nameEn = (r.cropName['en'] ?? '').toLowerCase();
        final nameHi = (r.cropName['hi'] ?? '').toLowerCase();
        final nameMr = (r.cropName['mr'] ?? '').toLowerCase();
        final mName = _t(r.marketName).toLowerCase();
        return nameEn.contains(q) ||
            nameHi.contains(q) ||
            nameMr.contains(q) ||
            r.crop.contains(q) ||
            mName.contains(q);
      }).toList();
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final brand = brandOf(context);

    final filteredList = _filtered;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
          children: [
            // Header
            Row(
              children: [
                Icon(Icons.storefront_rounded, color: brand, size: 28),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    widget.lang == 'mr'
                        ? 'कृषी उत्पन्न बाजारभाव (मंडी भाव)'
                        : widget.lang == 'hi'
                            ? 'दैनिक मंडी भाव व बाजार दर'
                            : 'Mandi Rates & Market Prices',
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
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.amber.withAlpha(40),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.amber),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.offline_pin_outlined, size: 13, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(
                        widget.lang == 'mr'
                            ? 'थेट व ऑफलाइन दर'
                            : widget.lang == 'hi'
                                ? 'लाइव व ऑफ़लाइन दर'
                                : 'Live & Offline Rates',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  '₹ / Quintal (क्विंटल = 100 kg)',
                  style: TextStyle(fontSize: 12, color: cs.onSurface.withAlpha(160)),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Search Bar for any fruit/vegetable/crop
            TextField(
              controller: _searchCtrl,
              onChanged: (val) => setState(() => _searchQuery = val.trim()),
              decoration: InputDecoration(
                hintText: widget.lang == 'mr'
                    ? 'फळ, भाजी किंवा पिकाचे नाव शोधा (उदा. सफरचंद, भेंडी, मिरची...)'
                    : widget.lang == 'hi'
                        ? 'फल, सब्जी या फसल का भाव खोजें (उदा. सेब, भिंडी, मिर्च...)'
                        : 'Search any fruit, vegetable, or crop rate...',
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
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                filled: true,
                fillColor: cs.surface,
                contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              ),
            ),
            const SizedBox(height: 14),

            // Quick Filter Chips with full multilingual labels
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _filterChip('all', widget.lang == 'mr' ? 'सर्व पिके' : widget.lang == 'hi' ? 'सभी फसलें' : 'All', brand),
                  _filterChip('onion', widget.lang == 'mr' ? 'कांदा 🧅' : widget.lang == 'hi' ? 'प्याज 🧅' : 'Onion 🧅', brand),
                  _filterChip('tomato', widget.lang == 'mr' ? 'टोमॅटो 🍅' : widget.lang == 'hi' ? 'टमाटर 🍅' : 'Tomato 🍅', brand),
                  _filterChip('wheat', widget.lang == 'mr' ? 'गहू 🌾' : widget.lang == 'hi' ? 'गेहूं 🌾' : 'Wheat 🌾', brand),
                  _filterChip('soybean', widget.lang == 'mr' ? 'सोयाबीन 🌱' : widget.lang == 'hi' ? 'सोयाबीन 🌱' : 'Soybean 🌱', brand),
                  _filterChip('ladyfinger', widget.lang == 'mr' ? 'भेंडी 🥬' : widget.lang == 'hi' ? 'भिंडी 🥬' : 'Ladyfinger 🥬', brand),
                  _filterChip('chili', widget.lang == 'mr' ? 'मिरची 🌶️' : widget.lang == 'hi' ? 'मिर्च 🌶️' : 'Chili 🌶️', brand),
                  _filterChip('apple', widget.lang == 'mr' ? 'सफरचंद 🍎' : widget.lang == 'hi' ? 'सेब 🍎' : 'Apple 🍎', brand),
                  _filterChip('mango', widget.lang == 'mr' ? 'आंबा 🥭' : widget.lang == 'hi' ? 'आम 🥭' : 'Mango 🥭', brand),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // If searched query is not in static records, show dynamic estimate card
            if (filteredList.isEmpty && _searchQuery.isNotEmpty)
              _dynamicSearchRateCard(_searchQuery, cs, brand),

            // Records List
            ...filteredList.map((record) => _rateCard(record, cs)),
          ],
        ),
      ),
    );
  }

  Widget _filterChip(String key, String label, Color brand) {
    final isSelected = _selectedCrop == key;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        selectedColor: alpha(brand, 0.22),
        onSelected: (selected) {
          if (selected) setState(() => _selectedCrop = key);
        },
      ),
    );
  }

  Widget _dynamicSearchRateCard(String query, ColorScheme cs, Color brand) {
    final title = query.toUpperCase();
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: alpha(cs.surface, 0.96),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: alpha(brand, 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('📦', style: TextStyle(fontSize: 28)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        color: cs.onSurface,
                      ),
                    ),
                    Text(
                      widget.lang == 'mr'
                          ? 'अंदाजे एपीएमसी सरासरी दर'
                          : widget.lang == 'hi'
                              ? 'अनुमानित एपीएमसी मंडी दर'
                              : 'Estimated Mandi Average Benchmark',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withAlpha(25),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '₹ 2,200 – 4,500',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green[800]),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            widget.lang == 'mr'
                ? 'या पिकाचे दर बाजारातील आवक आणि प्रतवारीनुसार बदलतात. सविस्तर माहितीसाठी होम स्क्रीनवर आवाजाने विचारा.'
                : widget.lang == 'hi'
                    ? 'इस फसल का भाव दैनिक आवक और गुणवत्ता के अनुसार निर्धारित होता है। विस्तृत जानकारी के लिए वॉइस असिस्टेंट से पूछें।'
                    : 'Prices fluctuate based on daily arrivals and quality grades. Ask KissanSetu voice assistant for live specifics.',
            style: TextStyle(fontSize: 12.5, color: cs.onSurface.withAlpha(180)),
          ),
        ],
      ),
    );
  }

  Widget _rateCard(_MarketRecord r, ColorScheme cs) {
    final isPos = r.change >= 0;
    final changeColor = isPos ? const Color(0xFF16A34A) : const Color(0xFFDC2626);
    final changeText = '${isPos ? '+' : ''}₹${r.change}';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: alpha(cs.surface, 0.96),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: alpha(cs.outlineVariant, 0.6)),
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
              Text(r.emoji, style: const TextStyle(fontSize: 28)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _t(r.cropName),
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        color: cs.onSurface,
                      ),
                    ),
                    Text(
                      _t(r.marketName),
                      style: TextStyle(fontSize: 12, color: alpha(cs.onSurface, 0.65)),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: alpha(changeColor, 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isPos ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                      size: 14,
                      color: changeColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      changeText,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: changeColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: alpha(cs.surfaceContainerHighest, 0.4),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _priceCol(widget.lang == 'mr' ? 'किमान दर' : widget.lang == 'hi' ? 'न्यूनतम' : 'Min', '₹${r.minPrice}', cs),
                Container(height: 24, width: 1, color: alpha(cs.outline, 0.3)),
                _priceCol(widget.lang == 'mr' ? 'सरासरी दर' : widget.lang == 'hi' ? 'मॉडल दर' : 'Modal', '₹${r.modalPrice}', cs, isModal: true),
                Container(height: 24, width: 1, color: alpha(cs.outline, 0.3)),
                _priceCol(widget.lang == 'mr' ? 'कमाल दर' : widget.lang == 'hi' ? 'अधिकतम' : 'Max', '₹${r.maxPrice}', cs),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _priceCol(String label, String value, ColorScheme cs, {bool isModal = false}) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: alpha(cs.onSurface, 0.6),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: isModal ? 15 : 13.5,
            fontWeight: isModal ? FontWeight.w900 : FontWeight.w700,
            color: isModal ? const Color(0xFF16A34A) : cs.onSurface,
          ),
        ),
      ],
    );
  }
}
