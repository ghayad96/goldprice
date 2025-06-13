import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../config/api_config.dart';

class ApiTestPage extends StatefulWidget {
  const ApiTestPage({super.key});

  @override
  State<ApiTestPage> createState() => _ApiTestPageState();
}

class _ApiTestPageState extends State<ApiTestPage> {
  String _testResult = 'Henüz test yapılmadı';
  bool _isLoading = false;

  Future<void> _testExchangeRateApi() async {
    setState(() {
      _isLoading = true;
      _testResult = 'API test ediliyor...';
    });

    try {
      // Test your Exchange Rate API
      final result = await ApiService.getExchangeRates(baseCurrency: 'USD');
      
      if (result != null) {
        final rates = result['conversion_rates'] as Map<String, dynamic>;
        final tryRate = rates['TRY'];
        final eurRate = rates['EUR'];
        
        setState(() {
          _testResult = '''✅ API başarıyla çalışıyor!
          
API Anahtarı: ${ApiConfig.exchangeRateApiKey}
Tarih: ${result['time_last_update_utc']}
Base: ${result['base_code']}

Örnek Kurlar:
• 1 USD = $tryRate TRY
• 1 USD = $eurRate EUR

Desteklenen para birimleri: ${rates.length}''';
        });
      } else {
        setState(() {
          _testResult = '❌ API çağrısı başarısız oldu';
        });
      }
    } catch (e) {
      setState(() {
        _testResult = '❌ Hata: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testMetalPrices() async {
    setState(() {
      _isLoading = true;
      _testResult = 'Metal fiyatları test ediliyor...';
    });

    try {
      final metalPrices = await ApiService.getMetalPrices();
      final goldInTry = await ApiService.getMetalPriceInCurrency(
        metal: 'XAU',
        currency: 'TRY',
      );

      if (metalPrices != null) {
        setState(() {
          _testResult = '''✅ Metal fiyatları başarıyla alındı!
          
Güncel Fiyatlar (USD/ons):
• Altın (XAU): \$${metalPrices['XAU']?.toStringAsFixed(2)}
• Gümüş (XAG): \$${metalPrices['XAG']?.toStringAsFixed(2)}
• Platin (XPT): \$${metalPrices['XPT']?.toStringAsFixed(2)}
• Paladyum (XPD): \$${metalPrices['XPD']?.toStringAsFixed(2)}

Altın TRY Fiyatı: ${goldInTry?.toStringAsFixed(2)} ₺/gram''';
        });
      } else {
        setState(() {
          _testResult = '❌ Metal fiyatları alınamadı';
        });
      }
    } catch (e) {
      setState(() {
        _testResult = '❌ Hata: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('API Test'),
        backgroundColor: Colors.amber,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'API Test Sonuçları',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Text(
                        _testResult,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _testExchangeRateApi,
              icon: _isLoading 
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.currency_exchange),
              label: const Text('Exchange Rate API Testini Çalıştır'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _testMetalPrices,
              icon: _isLoading 
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.monetization_on),
              label: const Text('Metal Fiyatları Testini Çalıştır'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 24),
            Card(
              color: Colors.blue[50],
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info, color: Colors.blue[700]),
                        const SizedBox(width: 8),
                        Text(
                          'API Bilgileri',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[700],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Exchange Rate API: Aylık 1500 ücretsiz çağrı\n'
                      'Metals API: Ücretsiz, sınırsız\n'
                      'API Anahtarı: ${ApiConfig.exchangeRateApiKey}',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
