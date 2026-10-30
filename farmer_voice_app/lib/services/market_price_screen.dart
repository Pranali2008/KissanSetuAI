// ignore_for_file: deprecated_member_use

import 'dart:math';
import 'package:flutter/material.dart';
import '../app_theme.dart';

class MarketPriceScreen extends StatefulWidget {
  final String lang;
  const MarketPriceScreen({super.key, required this.lang});

  @override
  State<MarketPriceScreen> createState() => _MarketPriceScreenState();
}

class _MarketPriceScreenState extends State<MarketPriceScreen> {
  String _search = '';
  String _selectedMarket = 'All';
  List<Map<String, dynamic>> _prices = [];

  // --- Multilingual labels ---
  static const Map<String, Map<String, String>> _labels = {
    'title': {
      'en': 'Mandi Prices',
      'hi': 'मंडी भाव',
      'mr': 'मंडी भाव',
    },
    'lastUpdated': {
      'en': 'Last Updated',
      'hi': 'अंतिम अपडेट',
      'mr': 'शेवटचे अपडेट',
    },
    'search': {
      'en': 'Search crop...',
      'hi': 'फसल खोजें...',
      'mr': 'पीक शोधा...',
    },
    'unit': {
      'en': '₹/quintal',
      'hi': '₹/क्विंटल',
      'mr': '₹/क्विंटल',
    },
    'note': {
      'en':
          '⚠️ Prices are indicative. Please verify at your local mandi.',
      'hi':
          '⚠️ कीमतें संकेतात्मक हैं। कृपया अपनी स्थानीय मंडी में सत्यापित करें।',
      'mr':
          '⚠️ किंमती सूचक आहेत. कृपया तुमच्या स्थानिक मंडीत पडताळा.',
    },
    'allMarkets': {
      'en': 'All Markets',
      'hi': 'सभी मंडियां',
      'mr': 'सर्व मंड्या',
    },
    'noResults': {
      'en': 'No crops found matching your search.',
      'hi': 'आपकी खोज से मेल खाने वाली कोई फसल नहीं मिली।',
      'mr': 'तुमच्या शोधाशी जुळणारे कोणतेही पीक आढळले नाही.',
    },
    'today': {
      'en': 'Today',
      'hi': 'आज',
      'mr': 'आज',
    },
  };

  String _l(String key) => _labels[key]?[widget.lang] ?? _labels[key]?['en'] ?? key;

  @override
  void initState() {
    super.initState();
    _initPrices();
  }

  void _initPrices() {
    final rng = Random(42);
    final today = DateTime.now();
    final dateStr =
        '${today.day.toString().padLeft(2, '0')}/${today.month.toString().padLeft(2, '0')}/${today.year}';
    final markets = ['Nashik', 'Pune', 'Nagpur', 'Aurangabad'];

    final rawData = [
      {
        'cropKey': 'tomato',
        'emoji': '🍅',
        'name': {'en': 'Tomato', 'hi': 'टमाटर', 'mr': 'टोमॅटो'},
        'price': 1200,
        'market': markets[0],
        'unit': '₹/quintal',
      },
      {
        'cropKey': 'onion',
        'emoji': '🧅',
        'name': {'en': 'Onion', 'hi': 'प्याज', 'mr': 'कांदा'},
        'price': 2500,
        'market': markets[1],
        'unit': '₹/quintal',
      },
      {
        'cropKey': 'wheat',
        'emoji': '🌾',
        'name': {'en': 'Wheat', 'hi': 'गेहूं', 'mr': 'गहू'},
        'price': 2100,
        'market': markets[2],
        'unit': '₹/quintal',
      },
      {
        'cropKey': 'rice',
        'emoji': '🍚',
        'name': {'en': 'Rice', 'hi': 'धान', 'mr': 'भात'},
        'price': 2800,
        'market': markets[3],
        'unit': '₹/quintal',
      },
      {
        'cropKey': 'cotton',
        'emoji': '🌿',
        'name': {'en': 'Cotton', 'hi': 'कपास', 'mr': 'कापूस'},
        'price': 6500,
        'market': markets[0],
        'unit': '₹/quintal',
      },
      {
        'cropKey': 'soybean',
        'emoji': '🟢',
        'name': {'en': 'Soybean', 'hi': 'सोयाबीन', 'mr': 'सोयाबीन'},
        'price': 4200,
        'market': markets[1],
        'unit': '₹/quintal',
      },
      {
        'cropKey': 'marigold',
        'emoji': '🌼',
        'name': {'en': 'Marigold', 'hi': 'गेंदे का फूल', 'mr': 'झेंडू'},
        'price': 3500,
        'market': markets[2],
        'unit': '₹/quintal',
      },
      {
        'cropKey': 'sugarcane',
        'emoji': '🎋',
        'name': {'en': 'Sugarcane', 'hi': 'गन्ना', 'mr': 'ऊस'},
        'price': 350,
        'market': markets[3],
        'unit': '₹/quintal',
      },
      {
        'cropKey': 'pomegranate',
        'emoji': '🍎',
        'name': {'en': 'Pomegranate', 'hi': 'अनार', 'mr': 'डाळिंब'},
        'price': 8000,
        'market': markets[0],
        'unit': '₹/quintal',
      },
      {
        'cropKey': 'grapes',
        'emoji': '🍇',
        'name': {'en': 'Grapes', 'hi': 'अंगूर', 'mr': 'द्राक्षे'},
        'price': 4500,
        'market': markets[1],
        'unit': '₹/quintal',
      },
      {
        'cropKey': 'banana',
        'emoji': '🍌',
        'name': {'en': 'Banana', 'hi': 'केला', 'mr': 'केळी'},
        'price': 2200,
        'market': markets[2],
        'unit': '₹/quintal',
      },
      {
        'cropKey': 'chilli',
        'emoji': '🌶️',
        'name': {'en': 'Chilli', 'hi': 'मिर्च', 'mr': 'मिरची'},
        'price': 8500,
        'market': markets[3],
        'unit': '₹/quintal',
      },
    ];

    _prices = rawData.map((d) {
      final price = d['price'] as int;
      final change = (rng.nextDouble() * 300 - 150);
      final changePercent =
          double.parse((change / price * 100).toStringAsFixed(1));
      return {
        ...d,
        'change': change,
        'changePercent': changePercent,
        'lastUpdated': dateStr,
      };
    }).toList();
  }

  List<Map<String, dynamic>> get _filteredPrices {
    return _prices.where((item) {
      final name = item['name'] as Map<String, dynamic>;
      final displayName =
          (name[widget.lang] ?? name['en'] ?? '').toString().toLowerCase();
      final matchesSearch =
          _search.isEmpty || displayName.contains(_search.toLowerCase());
      final matchesMarket =
          _selectedMarket == 'All' || item['market'] == _selectedMarket;
      return matchesSearch && matchesMarket;
    }).toList();
  }

  String _timeString() {
    final now = DateTime.now();
    final h = now.hour.toString().padLeft(2, '0');
    final m = now.minute.toString().padLeft(2, '0');
    return '${_l('today')}, $h:$m';
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
            colors: [brand.withOpacity(0.07), Colors.white],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildTopBar(context, brand),
              Expanded(
                child: Column(
                  children: [
                    _buildSubHeader(brand),
                    _buildMarketFilter(brand),
                    _buildSearchBar(brand),
                    Expanded(child: _buildPriceList(brand)),
                    _buildNoteBar(),
                  ],
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
          IconButton(
            icon: Icon(Icons.refresh_rounded, color: brand),
            onPressed: () => setState(() => _initPrices()),
          ),
        ],
      ),
    );
  }

  Widget _buildSubHeader(Color brand) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Icon(Icons.access_time_rounded, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 6),
          Text(
            '${_l('lastUpdated')}: ${_timeString()}',
            style: TextStyle(fontSize: 13, color: Colors.grey[600]),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFF28A745).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(Icons.circle, size: 8, color: Color(0xFF28A745)),
                const SizedBox(width: 4),
                Text(
                  'Live',
                  style: TextStyle(
                    fontSize: 12,
                    color: const Color(0xFF28A745),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMarketFilter(Color brand) {
    final markets = ['All', 'Nashik', 'Pune', 'Nagpur', 'Aurangabad'];
    return SizedBox(
      height: 44,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: markets.length,
        itemBuilder: (ctx, i) {
          final m = markets[i];
          final selected = _selectedMarket == m;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(m == 'All' ? _l('allMarkets') : m),
              selected: selected,
              onSelected: (_) => setState(() => _selectedMarket = m),
              selectedColor: brand.withOpacity(0.2),
              checkmarkColor: brand,
              labelStyle: TextStyle(
                color: selected ? brand : Colors.grey[700],
                fontWeight:
                    selected ? FontWeight.bold : FontWeight.normal,
              ),
              side: BorderSide(
                color: selected ? brand : Colors.grey[300]!,
              ),
              backgroundColor: Colors.white,
              showCheckmark: false,
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchBar(Color brand) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: TextField(
        onChanged: (v) => setState(() => _search = v),
        decoration: InputDecoration(
          hintText: _l('search'),
          prefixIcon: const Icon(Icons.search_rounded),
          prefixIconColor: Colors.grey,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: brand, width: 1.5),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildPriceList(Color brand) {
    final filtered = _filteredPrices;
    if (filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🔍', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 12),
            Text(
              _l('noResults'),
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      itemCount: filtered.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (ctx, i) {
        return _PriceTile(
          item: filtered[i],
          lang: widget.lang,
          brand: brand,
          unitLabel: _l('unit'),
        );
      },
    );
  }

  Widget _buildNoteBar() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      color: const Color(0xFFFFF3CD),
      child: Text(
        _l('note'),
        style: const TextStyle(
          fontSize: 12,
          color: Color(0xFF664D03),
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

// --- Price Tile Widget ---

class _PriceTile extends StatelessWidget {
  final Map<String, dynamic> item;
  final String lang;
  final Color brand;
  final String unitLabel;

  const _PriceTile({
    required this.item,
    required this.lang,
    required this.brand,
    required this.unitLabel,
  });

  @override
  Widget build(BuildContext context) {
    final name = item['name'] as Map<String, dynamic>;
    final displayName = (name[lang] ?? name['en'] ?? '').toString();
    final emoji = item['emoji'] as String;
    final price = item['price'] as int;
    final change = (item['change'] as double);
    final changePercent = item['changePercent'] as double;
    final market = item['market'] as String;

    final bool isUp = change > 0;
    final bool isDown = change < 0;
    final trendColor = isUp
        ? const Color(0xFF28A745)
        : isDown
            ? const Color(0xFFDC3545)
            : Colors.grey;
    final trendArrow = isUp ? '↑' : isDown ? '↓' : '→';
    final trendIcon = isUp
        ? Icons.trending_up_rounded
        : isDown
            ? Icons.trending_down_rounded
            : Icons.trending_flat_rounded;

    final formattedPrice = _formatPrice(price);
    final changeStr = isUp
        ? '+₹${change.abs().toStringAsFixed(0)}'
        : isDown
            ? '-₹${change.abs().toStringAsFixed(0)}'
            : '₹0';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border(
          left: BorderSide(color: trendColor, width: 4),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            // Left: emoji + name + market
            Expanded(
              child: Row(
                children: [
                  Text(emoji, style: const TextStyle(fontSize: 28)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          displayName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Icon(
                              Icons.store_rounded,
                              size: 12,
                              color: Colors.grey[500],
                            ),
                            const SizedBox(width: 3),
                            Text(
                              market,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Right: price + trend
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '₹$formattedPrice',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  unitLabel,
                  style: TextStyle(fontSize: 10, color: Colors.grey[500]),
                ),
                const SizedBox(height: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: trendColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(trendIcon, size: 14, color: trendColor),
                      const SizedBox(width: 3),
                      Text(
                        '$trendArrow$changeStr (${changePercent.abs()}%)',
                        style: TextStyle(
                          fontSize: 11,
                          color: trendColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatPrice(int price) {
    if (price >= 1000) {
      final s = price.toString();
      if (s.length > 3) {
        return '${s.substring(0, s.length - 3)},${s.substring(s.length - 3)}';
      }
    }
    return price.toString();
  }
}
