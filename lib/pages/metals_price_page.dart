// 📁 pages/metals_price_page.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../widgets/base_page.dart';
import '../services/api_service.dart';

class MetalsPricePage extends StatefulWidget {
  const MetalsPricePage({super.key});
  
  @override
  State<MetalsPricePage> createState() => _MetalsPricePageState();
}

class _MetalsPricePageState extends State<MetalsPricePage> {
  Map<String, dynamic> metalPrices = {};
  bool isLoading = true;
  String? errorMessage;
  DateTime? lastUpdate;
  
  // Conversion rates (per troy ounce to gram)
  static const double ounceToGram = 31.1035;
  
  // Metal configurations
  final Map<String, MetalConfig> metalConfigs = {
    'XAU': MetalConfig(
      name: 'Altın',
      icon: Icons.monetization_on,
      color: Colors.amber,
      turkishWeights: {
        'Gram Altın': 1.0,
        'Çeyrek Altın': 1.75,
        'Yarım Altın': 3.5,
        'Tam Altın': 7.0,
        'Reşat Altın': 7.05,
        'Cumhuriyet Altını': 7.2,
      },
    ),
    'XAG': MetalConfig(
      name: 'Gümüş',
      icon: Icons.circle_outlined,
      color: Colors.grey,
      turkishWeights: {
        'Gram Gümüş': 1.0,
        'Ons Gümüş': 31.1035,
      },
    ),
    'XPT': MetalConfig(
      name: 'Platin',
      icon: Icons.diamond,
      color: Colors.blueGrey,
      turkishWeights: {
        'Gram Platin': 1.0,
        'Ons Platin': 31.1035,
      },
    ),
    'XPD': MetalConfig(
      name: 'Paladyum',
      icon: Icons.stars,
      color: Colors.indigo,
      turkishWeights: {
        'Gram Paladyum': 1.0,
        'Ons Paladyum': 31.1035,
      },
    ),
  };

  @override
  void initState() {
    super.initState();
    fetchMetalPrices();
  }
  Future<void> fetchMetalPrices() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      print('Metals page: Starting to fetch metal prices...');
      
      // Get metal prices in USD first
      final metalPricesUSD = await ApiService.getMetalPrices();
      if (metalPricesUSD == null) {
        throw Exception('Metal fiyatları alınamadı');
      }
      
      print('Metals page: Metal prices in USD: $metalPricesUSD');
      
      // Get exchange rate for TRY
      final exchangeRates = await ApiService.getMultiCurrencyRates(
        baseCurrency: 'USD',
        targetCurrencies: ['TRY'],
      );
      
      if (exchangeRates == null || !exchangeRates.containsKey('TRY')) {
        throw Exception('TRY döviz kuru alınamadı');
      }
      
      final tryRate = exchangeRates['TRY']!;
      print('Metals page: USD/TRY rate: $tryRate');
      
      // Calculate metal prices in TRY per gram
      setState(() {
        metalPrices = {};
        for (String metal in metalConfigs.keys) {
          if (metalPricesUSD.containsKey(metal)) {
            final priceInUSD = (metalPricesUSD[metal] as num).toDouble();
            final priceInTRY = priceInUSD * tryRate;
            metalPrices[metal] = priceInTRY / ounceToGram; // Convert to per gram
            print('Metals page: $metal price per gram in TRY: ${metalPrices[metal]}');
          }
        }
        lastUpdate = DateTime.now();
        isLoading = false;
      });
      
    } catch (e) {
      print('Metals page error: $e');
      setState(() {
        isLoading = false;
        errorMessage = 'Veri alınamadı: ${e.toString()}';
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  String formatPrice(double price) {
    final formatter = NumberFormat.currency(
      locale: 'tr_TR', 
      symbol: '₺',
      decimalDigits: 2,
    );
    return formatter.format(price);
  }

  String formatLastUpdate() {
    if (lastUpdate == null) return '';
    final formatter = DateFormat('dd.MM.yyyy HH:mm');
    return 'Son güncelleme: ${formatter.format(lastUpdate!)}';
  }

  @override
  Widget build(BuildContext context) {
    return BasePage(
      title: 'Metal Fiyatları',
      content: Column(
        children: [
          // Header with last update info
          if (lastUpdate != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).primaryColor.withOpacity(0.3),
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.access_time,
                    color: Theme.of(context).primaryColor,
                    size: 20,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formatLastUpdate(),
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          
          // Content
          Expanded(
            child: isLoading
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Metal fiyatları yükleniyor...'),
                      ],
                    ),
                  )
                : errorMessage != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 64,
                              color: Colors.red[300],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              errorMessage!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: fetchMetalPrices,
                              icon: const Icon(Icons.refresh),
                              label: const Text('Tekrar Dene'),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: fetchMetalPrices,
                        child: ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.all(8),
                          children: [
                            ...metalConfigs.entries.map((entry) {
                              final metalSymbol = entry.key;
                              final config = entry.value;
                              final pricePerGram = metalPrices[metalSymbol];
                              
                              if (pricePerGram == null) return const SizedBox.shrink();
                              
                              return MetalSection(
                                config: config,
                                pricePerGram: pricePerGram,
                                formatPrice: formatPrice,
                              );
                            }).toList(),
                          ],
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}

class MetalConfig {
  final String name;
  final IconData icon;
  final Color color;
  final Map<String, double> turkishWeights;

  MetalConfig({
    required this.name,
    required this.icon,
    required this.color,
    required this.turkishWeights,
  });
}

class MetalSection extends StatelessWidget {
  final MetalConfig config;
  final double pricePerGram;
  final String Function(double) formatPrice;

  const MetalSection({
    super.key,
    required this.config,
    required this.pricePerGram,
    required this.formatPrice,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          // Metal header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: config.color.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  config.icon,
                  color: config.color,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Text(
                  config.name,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: config.color,
                  ),
                ),
              ],
            ),
          ),
          
          // Price items
          ...config.turkishWeights.entries.map((weightEntry) {
            final weightName = weightEntry.key;
            final weightMultiplier = weightEntry.value;
            final price = pricePerGram * weightMultiplier;
            
            return Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Colors.grey[200]!,
                    width: 0.5,
                  ),
                ),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: config.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.scale,
                    color: config.color,
                    size: 20,
                  ),
                ),
                title: Text(
                  weightName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                subtitle: Text(
                  '${weightMultiplier}g',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: config.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    formatPrice(price),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: config.color,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
          
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
