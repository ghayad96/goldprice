// 📁 widgets/base_page.dart
import 'package:flutter/material.dart';
import 'drawer_menu.dart';
import 'custom_app_bar.dart';

class BasePage extends StatelessWidget {
  final String title;
  final Widget content;
  const BasePage({super.key, required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      endDrawer: const DrawerMenu(),
      appBar: CustomAppBar(title: title, showDrawer: true),
      body: content,
    );
  }
}