// 📁 pages/price_comparison_page.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../widgets/base_page.dart';
import '../services/api_service.dart';

class PriceComparisonPage extends StatefulWidget {
  const PriceComparisonPage({super.key});
  
  @override
  State<PriceComparisonPage> createState() => _PriceComparisonPageState();
}

class _PriceComparisonPageState extends State<PriceComparisonPage> {
  Map<String, Map<String, dynamic>> metalData = {};
  bool isLoading = true;
  String? errorMessage;
  DateTime? lastUpdate;
  
  final List<String> currencies = ['USD', 'EUR', 'TRY', 'GBP'];
  String selectedCurrency = 'TRY';
  
  final Map<String, MetalInfo> metals = {
    'XAU': MetalInfo('Altın', Icons.monetization_on, Colors.amber),
    'XAG': MetalInfo('Gümüş', Icons.circle_outlined, Colors.grey),
    'XPT': MetalInfo('Platin', Icons.diamond, Colors.blueGrey),
    'XPD': MetalInfo('Paladyum', Icons.stars, Colors.indigo),
  };

  @override
  void initState() {
    super.initState();
    fetchAllPrices();
  }
  Future<void> fetchAllPrices() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      // Fetch metal prices in USD first
      final metalPrices = await ApiService.getMetalPrices();
      if (metalPrices == null) {
        throw Exception('Metal fiyatları alınamadı');
      }

      // Fetch exchange rates for all currencies
      final exchangeRates = await ApiService.getMultiCurrencyRates(
        baseCurrency: 'USD',
        targetCurrencies: currencies,
      );
      
      if (exchangeRates == null) {
        throw Exception('Döviz kurları alınamadı');
      }

      // Calculate prices for each currency
      for (String currency in currencies) {
        final rate = currency == 'USD' ? 1.0 : (exchangeRates[currency] ?? 1.0);
        
        metalData[currency] = {
          'XAU': (metalPrices['XAU'] * rate) / 31.1035, // per gram
          'XAG': (metalPrices['XAG'] * rate) / 31.1035,
          'XPT': (metalPrices['XPT'] * rate) / 31.1035,
          'XPD': (metalPrices['XPD'] * rate) / 31.1035,
        };
      }
      
      setState(() {
        lastUpdate = DateTime.now();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Veriler yüklenirken hata oluştu: $e';
      });
    }
  }

  String formatPrice(double price, String currency) {
    String symbol = _getCurrencySymbol(currency);
    final formatter = NumberFormat.currency(
      locale: _getLocale(currency),
      symbol: symbol,
      decimalDigits: 2,
    );
    return formatter.format(price);
  }

  String _getCurrencySymbol(String currency) {
    switch (currency) {
      case 'USD': return '\$';
      case 'EUR': return '€';
      case 'TRY': return '₺';
      case 'GBP': return '£';
      default: return currency;
    }
  }

  String _getLocale(String currency) {
    switch (currency) {
      case 'TRY': return 'tr_TR';
      case 'EUR': return 'de_DE';
      case 'GBP': return 'en_GB';
      default: return 'en_US';
    }
  }

  @override
  Widget build(BuildContext context) {
    return BasePage(
      title: 'Fiyat Karşılaştırması',
      content: Column(
        children: [
          // Currency selector
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Text(
                  'Para Birimi: ',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
                Expanded(
                  child: DropdownButton<String>(
                    value: selectedCurrency,
                    isExpanded: true,
                    underline: const SizedBox(),
                    items: currencies.map((String currency) {
                      return DropdownMenuItem<String>(
                        value: currency,
                        child: Text(
                          '${_getCurrencySymbol(currency)} $currency',
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          selectedCurrency = newValue;
                        });
                      }
                    },
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
                        Text('Fiyatlar yükleniyor...'),
                      ],
                    ),
                  )
                : errorMessage != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error, size: 64, color: Colors.red[300]),
                            const SizedBox(height: 16),
                            Text(errorMessage!, textAlign: TextAlign.center),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: fetchAllPrices,
                              child: const Text('Tekrar Dene'),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: fetchAllPrices,
                        child: ListView(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          children: [
                            if (lastUpdate != null)
                              Container(
                                padding: const EdgeInsets.all(12),
                                margin: const EdgeInsets.only(bottom: 16),
                                decoration: BoxDecoration(
                                  color: Colors.blue[50],
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.blue[200]!),
                                ),
                                child: Text(
                                  'Son güncelleme: ${DateFormat('dd.MM.yyyy HH:mm').format(lastUpdate!)}',
                                  style: TextStyle(color: Colors.blue[700]),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            
                            ...metals.entries.map((entry) {
                              final metalSymbol = entry.key;
                              final metalInfo = entry.value;
                              final currentPrice = metalData[selectedCurrency]?[metalSymbol];
                              
                              if (currentPrice == null) return const SizedBox.shrink();
                              
                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                elevation: 3,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  children: [
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: metalInfo.color.withOpacity(0.1),
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(12),
                                          topRight: Radius.circular(12),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            metalInfo.icon,
                                            color: metalInfo.color,
                                            size: 24,
                                          ),
                                          const SizedBox(width: 12),
                                          Text(
                                            metalInfo.name,
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: metalInfo.color,
                                            ),
                                          ),
                                          const Spacer(),
                                          Text(
                                            formatPrice(currentPrice, selectedCurrency),
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: metalInfo.color,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Row(
                                        children: currencies.map((currency) {
                                          final price = metalData[currency]?[metalSymbol];
                                          if (price == null) return const SizedBox.shrink();
                                          
                                          return Expanded(
                                            child: Column(
                                              children: [
                                                Text(
                                                  currency,
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey[600],
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  formatPrice(price, currency),
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w600,
                                                    color: currency == selectedCurrency 
                                                        ? metalInfo.color 
                                                        : Colors.grey[700],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                  ],
                                ),
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

class MetalInfo {
  final String name;
  final IconData icon;
  final Color color;

  MetalInfo(this.name, this.icon, this.color);
}
