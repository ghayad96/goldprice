// 📁 pages/gold_price_page.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../widgets/base_page.dart';
import '../services/api_service.dart';

class GoldItem {
  final String name;
  final double weight;
  final IconData icon;
  final Color color;

  GoldItem(this.name, this.weight, this.icon, this.color);
}

class GoldPricePage extends StatefulWidget {
  const GoldPricePage({super.key});
  @override
  State<GoldPricePage> createState() => _GoldPricePageState();
}

class _GoldPricePageState extends State<GoldPricePage> {
  double? gramAltin;
  bool isLoading = true;
  String? errorMessage;
  DateTime? lastUpdate;
  static const double ounceToGram = 31.1035;

  // Enhanced gold items with icons and colors
  final Map<String, GoldItem> goldItems = {
    'gram': GoldItem('Gram Altın', 1.0, Icons.monetization_on, Colors.amber),
    'ceyrek': GoldItem('Çeyrek Altın', 1.75, Icons.star, Colors.amber[600]!),
    'yarim': GoldItem('Yarım Altın', 3.5, Icons.star_half, Colors.amber[700]!),
    'tam': GoldItem('Tam Altın', 7.0, Icons.stars, Colors.amber[800]!),
    'resat': GoldItem('Reşat Altın', 7.05, Icons.account_balance, Colors.amber[900]!),
    'cumhuriyet': GoldItem('Cumhuriyet Altını', 7.2, Icons.flag, Colors.orange[800]!),
    'ata': GoldItem('Ata Altın', 7.2, Icons.person, Colors.orange[900]!),
  };

  @override
  void initState() {
    super.initState();
    fetchGoldPrice();
  }

  Future<void> fetchGoldPrice() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      print('Gold price page: Starting to fetch gold price...');
      
      // Get gold price in TRY using the new API service
      final goldPriceInTRY = await ApiService.getMetalPriceInCurrency(
        metal: 'XAU',
        currency: 'TRY',
      );
      
      print('Gold price page: Received gold price: $goldPriceInTRY');
      
      if (goldPriceInTRY != null) {
        setState(() {
          gramAltin = goldPriceInTRY / ounceToGram; // Convert from ounce to gram
          lastUpdate = DateTime.now();
          isLoading = false;
          errorMessage = null;
        });
        print('Gold price page: Gram gold price set to: $gramAltin');
      } else {
        throw Exception('Altın fiyatı alınamadı - API yanıtı null');
      }
    } catch (e) {
      print('Gold price page error: $e');
      setState(() {
        isLoading = false;
        errorMessage = 'Bağlantı hatası: ${e.toString()}';
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
      title: 'Altın Fiyatları',
      content: Column(
        children: [
          // Header with current gram gold price and last update
          if (gramAltin != null)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.amber[400]!, Colors.amber[600]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.amber.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.trending_up,
                        color: Colors.white,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Canlı Altın Fiyatı',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    formatPrice(gramAltin!),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Gram Altın',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 16,
                    ),
                  ),
                  if (lastUpdate != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      formatLastUpdate(),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          
          // Gold items list
          Expanded(
            child: isLoading
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.amber),
                        ),
                        SizedBox(height: 16),
                        Text('Altın fiyatları yükleniyor...'),
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
                              onPressed: fetchGoldPrice,
                              icon: const Icon(Icons.refresh),
                              label: const Text('Tekrar Dene'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.amber,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      )
                    : gramAltin == null
                        ? const Center(child: Text('Veri alınamadı'))
                        : RefreshIndicator(
                            onRefresh: fetchGoldPrice,
                            color: Colors.amber,
                            child: ListView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              children: goldItems.entries.map((entry) {
                                final item = entry.value;
                                final price = gramAltin! * item.weight;
                                
                                return goldTile(item, price);
                              }).toList(),
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  Widget goldTile(GoldItem item, double price) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [
              item.color.withOpacity(0.1),
              item.color.withOpacity(0.05),
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: item.color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              item.icon,
              color: item.color,
              size: 24,
            ),
          ),
          title: Text(
            item.name,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          subtitle: Text(
            '${item.weight}g',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 13,
            ),
          ),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: item.color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              formatPrice(price),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: item.color,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
