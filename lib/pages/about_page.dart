// 📁 pages/about_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/base_page.dart';
import '../config/api_config.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Panoya kopyalandı'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BasePage(
      title: 'Hakkında',
      content: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // App Info Section
            _buildSection(
              context,
              'Metal Takip Uygulaması',
              Icons.monetization_on,
              Colors.amber,
              [
                'Bu uygulama güncel altın, gümüş, platin ve paladyum fiyatlarını gerçek zamanlı olarak takip etmenizi sağlar.',
                'Türkiye\'de yaygın kullanılan altın türleri (gram, çeyrek, yarım, tam, reşat, cumhuriyet altını) için anlık fiyat bilgisi sunar.',
                'Veriler güvenilir API servisleri üzerinden alınarak Türk Lirası cinsinden gösterilir.',
              ],
            ),

            const SizedBox(height: 24),

            // Features Section
            _buildSection(
              context,
              'Özellikler',
              Icons.star,
              Colors.blue,
              [
                '📊 Gerçek zamanlı metal fiyatları (Altın, Gümüş, Platin, Paladyum)',
                '🇹🇷 Türkiye\'de yaygın altın türleri ve ağırlıkları',
                '💱 Çoklu para birimi karşılaştırması (USD, EUR, TRY, GBP)',
                '🔄 Otomatik fiyat güncellemeleri',
                '📱 Modern ve kullanıcı dostu arayüz',
                '⚡ Hızlı ve güvenilir veri kaynakları',
                '🎯 Gram bazında hassas hesaplamalar',
              ],
            ),

            const SizedBox(height: 24),

            // Data Sources Section
            _buildSection(
              context,
              'Veri Kaynakları',
              Icons.source,
              Colors.green,
              [
                'Exchange Rate API: Döviz kurları ve para birimi dönüşümleri',
                'Metals.live API: Spot metal fiyatları',
                'API Key: ${ApiConfig.exchangeRateApiKey}',
                'Veriler 5-15 dakika arayla güncellenir',
                'Tüm fiyatlar Troy Ons bazından gram bazına dönüştürülür',
              ],
            ),

            const SizedBox(height: 24),

            // FAQ Section
            _buildFAQSection(context),

            const SizedBox(height: 24),

            // Technical Info Section
            _buildSection(
              context,
              'Teknik Bilgiler',
              Icons.code,
              Colors.purple,
              [
                'Platform: Flutter (iOS, Android, Web)',
                'Programlama Dili: Dart',
                'API Servisleri: REST API',
                'Güncelleme: Haziran 2025',
                'Sürüm: 1.0.0',
              ],
            ),

            const SizedBox(height: 24),

            // Disclaimer Section
            _buildSection(
              context,
              'Önemli Uyarılar',
              Icons.warning,
              Colors.orange,
              [
                '⚠️ Bu uygulama sadece bilgilendirme amaçlıdır',
                '💰 Yatırım kararlarınızı profesyonel danışmanlık almadan vermeyin',
                '📊 Fiyatlar piyasa koşullarına göre sürekli değişir',
                '🔄 Internet bağlantısı gereklidir',
                '📱 En güncel fiyatlar için uygulamayı düzenli güncelleyin',
              ],
            ),

            const SizedBox(height: 24),

            // Contact Section
            _buildContactSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    List<String> content,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...content.map((text) => Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    text,
                    style: const TextStyle(fontSize: 15, height: 1.4),
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQSection(BuildContext context) {
    final faqs = [
      {
        'question': 'Fiyatlar ne sıklıkla güncellenir?',
        'answer': 'Fiyatlar gerçek zamanlı olarak güncellenir. Sayfa yenilendiğinde veya aşağı çekme hareketiyle en güncel veriler alınır.'
      },
      {
        'question': 'Hangi metal türleri destekleniyor?',
        'answer': 'Altın (XAU), Gümüş (XAG), Platin (XPT) ve Paladyum (XPD) fiyatları takip edilmektedir.'
      },
      {
        'question': 'Altın çeşitleri nelerdir?',
        'answer': 'Gram, Çeyrek (1.75g), Yarım (3.5g), Tam (7g), Reşat (7.05g), Cumhuriyet (7.2g) ve Ata (7.2g) altını desteklenmektedir.'
      },
      {
        'question': 'Fiyatlar doğru mu?',
        'answer': 'Fiyatlar güvenilir API servislerinden alınır ancak gerçek alım-satım fiyatları değişiklik gösterebilir. Yatırım öncesi mutlaka güncel piyasa fiyatlarını kontrol edin.'
      },
      {
        'question': 'İnternet bağlantısı olmadan çalışır mı?',
        'answer': 'Hayır, güncel fiyat bilgileri için internet bağlantısı gereklidir. Offline mod planlanmamıştır.'
      },
      {
        'question': 'Hangi para birimleri destekleniyor?',
        'answer': 'Ana sayfalarda Türk Lirası (TRY), karşılaştırma sayfasında USD, EUR, TRY ve GBP para birimleri desteklenmektedir.'
      },
      {
        'question': 'Uygulama ücretsiz mi?',
        'answer': 'Evet, uygulama tamamen ücretsizdir. API limitlerini aşmamak için makul kullanım önerilir.'
      },
    ];

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.help, color: Colors.indigo, size: 24),
                const SizedBox(width: 8),
                Text(
                  'Sık Sorulan Sorular (FAQ)',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.indigo,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...faqs.map((faq) => ExpansionTile(
                  title: Text(
                    faq['question']!,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        faq['answer']!,
                        style: const TextStyle(fontSize: 15, height: 1.4),
                      ),
                    ),
                  ],
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildContactSection(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.contact_support, color: Colors.teal, size: 24),
                const SizedBox(width: 8),
                Text(
                  'İletişim & Destek',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.teal,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Bu uygulama Flutter ile geliştirilmiştir.',
              style: TextStyle(fontSize: 15, height: 1.4),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.api, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                const Text('API Key: '),
                Expanded(
                  child: Text(
                    ApiConfig.exchangeRateApiKey,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => _copyToClipboard(context, ApiConfig.exchangeRateApiKey),
                  icon: const Icon(Icons.copy, size: 16),
                  tooltip: 'API Key\'i kopyala',
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Center(
              child: Text(
                '© 2025 Metal Fiyatları Takip Uygulaması\nTüm hakları saklıdır.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
