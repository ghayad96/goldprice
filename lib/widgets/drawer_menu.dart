// 📁 widgets/drawer_menu.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';

class DrawerMenu extends StatefulWidget {
  const DrawerMenu({super.key});

  @override
  State<DrawerMenu> createState() => _DrawerMenuState();
}

class _DrawerMenuState extends State<DrawerMenu> {
  bool _isLoggedIn = false;
  String? _userEmail;

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  void _checkAuthStatus() {
    setState(() {
      _isLoggedIn = AuthService.isLoggedIn;
      _userEmail = AuthService.userEmail;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.amber, Colors.orange],
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.trending_up,
                    color: Colors.white,
                    size: 40,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Metal Fiyatları',
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    _isLoggedIn ? _userEmail ?? 'Kullanıcı' : 'Canlı Takip',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ),
          ),
          _buildDrawerItem(context, Icons.home, 'Ana Sayfa', '/'),
          _buildDrawerItem(context, Icons.monetization_on, 'Altın Fiyatları', '/gold'),
          _buildDrawerItem(context, Icons.diamond, 'Tüm Metaller', '/metals'),
          _buildDrawerItem(context, Icons.compare_arrows, 'Fiyat Karşılaştırma', '/comparison'),
          const Divider(),
          
          // Authentication Section
          if (_isLoggedIn) ...[
            _buildDrawerItem(context, Icons.person, 'Profil', '/profile'),
            _buildDrawerItem(context, Icons.logout, 'Çıkış Yap', null, onTap: _logout),
          ] else ...[
            _buildDrawerItem(context, Icons.login, 'Giriş Yap', '/login'),
            _buildDrawerItem(context, Icons.person_add, 'Üye Ol', '/register'),
          ],
          
          const Divider(),
          _buildDrawerItem(context, Icons.bug_report, 'API Test', '/api-test'),
          _buildDrawerItem(context, Icons.security, 'Auth Test', '/auth-test'),
          _buildDrawerItem(context, Icons.info_outline, 'Hakkında', '/about'),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, 
    IconData icon, 
    String title, 
    String? route, {
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.black),
      title: Text(title, style: GoogleFonts.poppins(fontSize: 16)),
      onTap: onTap ?? () {
        Navigator.pop(context);
        if (route != null && ModalRoute.of(context)?.settings.name != route) {
          Navigator.pushNamed(context, route);
        }
      },
    );
  }

  Future<void> _logout() async {
    Navigator.pop(context); // Close drawer first
    
    final result = await AuthService.logout();
    if (result.success) {
      setState(() {
        _isLoggedIn = false;
        _userEmail = null;
      });
      
      // Navigate to home and show success message
      Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message ?? 'Başarıyla çıkış yapıldı'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message ?? 'Çıkış yapılamadı'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
