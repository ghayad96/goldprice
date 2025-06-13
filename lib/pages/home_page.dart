// 📁 pages/home_page.dart
import 'package:flutter/material.dart';
import '../widgets/base_page.dart';
import '../services/auth_service.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BasePage(
      title: 'Metal Fiyatları',
      content: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Welcome header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.amber[400]!, Colors.orange[400]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.amber.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.trending_up,
                    color: Colors.white,
                    size: 24,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Metal Fiyatları Uygulaması',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Güncel altın, gümüş, platin ve paladyum fiyatlarını takip edin',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.9),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Authentication Status Card
            _buildAuthStatusCard(context),
            
            const SizedBox(height: 24),
            
            // Navigation cards
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildNavigationCard(
                    context,
                    'Altın Fiyatları',
                    'Türk altın çeşitleri ve güncel fiyatlar',
                    Icons.monetization_on,
                    Colors.amber,
                    '/gold',
                  ),
                  _buildNavigationCard(
                    context,
                    'Tüm Metaller',
                    'Altın, gümüş, platin ve paladyum',
                    Icons.diamond,
                    Colors.blueGrey,
                    '/metals',
                  ),
                  _buildNavigationCard(
                    context,
                    'Piyasa Analizi',
                    'Yakında...',
                    Icons.analytics,
                    Colors.green,
                    null,
                  ),
                  _buildNavigationCard(
                    context,
                    'Favori Metaller',
                    'Yakında...',
                    Icons.favorite,
                    Colors.red,
                    null,
                  ),
                ],
              ),
            ),
            
            // Features section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    'Özellikler',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildFeatureItem(
                          Icons.refresh,
                          'Canlı Fiyatlar',
                          'Gerçek zamanlı güncelleme',
                        ),
                      ),
                      Expanded(
                        child: _buildFeatureItem(
                          Icons.language,
                          'Türkçe Arayüz',
                          'Kullanıcı dostu tasarım',
                        ),
                      ),
                      Expanded(
                        child: _buildFeatureItem(
                          Icons.security,
                          'Güvenilir',
                          'Resmi API kaynakları',
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
    );
  }

  Widget _buildNavigationCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
    String? route,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: route != null ? () => Navigator.pushNamed(context, route) : null,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: route != null 
                ? [color.withOpacity(0.1), color.withOpacity(0.05)]
                : [Colors.grey.withOpacity(0.1), Colors.grey.withOpacity(0.05)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 30,
                color: route != null ? color : Colors.grey,
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: route != null ? Colors.black87 : Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: route != null ? Colors.grey[600] : Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String subtitle) {
    return Column(
      children: [
        Icon(icon, color: Colors.amber, size: 24),
        const SizedBox(height: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildAuthStatusCard(BuildContext context) {
    bool isLoggedIn = AuthService.isLoggedIn;
    String? userEmail = AuthService.userEmail;
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: isLoggedIn 
                ? [Colors.green[50]!, Colors.green[100]!]
                : [Colors.blue[50]!, Colors.blue[100]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isLoggedIn ? Icons.verified_user : Icons.person_outline,
              color: isLoggedIn ? Colors.green[700] : Colors.blue[700],
              size: 32,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isLoggedIn ? 'Hoş geldiniz!' : 'Misafir olarak geziniyorsunuz',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isLoggedIn ? Colors.green[800] : Colors.blue[800],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isLoggedIn 
                        ? userEmail ?? 'Kullanıcı'
                        : 'Tüm özelliklere erişmek için giriş yapın',
                    style: TextStyle(
                      fontSize: 12,
                      color: isLoggedIn ? Colors.green[700] : Colors.blue[700],
                    ),
                  ),
                ],
              ),
            ),
            if (!isLoggedIn)
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/login');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[600],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Giriş Yap',
                  style: TextStyle(fontSize: 12),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
