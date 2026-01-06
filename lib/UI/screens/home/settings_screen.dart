import 'package:flutter/material.dart';
import 'package:flutterapp/UI/screens/home/home_screen.dart';
import 'package:flutterapp/core/constants/app_colors.dart';
import 'package:flutterapp/UI/widgets/main_bottom_nav.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _darkMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            automaticallyImplyLeading: false, // Removes the back button
            expandedHeight: 65.0,
            backgroundColor: AppColors.scaffoldBg,
            elevation: 0,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
              title: const Text(
                "Settings",
                style: TextStyle(color: AppColors.primaryNavy, fontWeight: FontWeight.bold, fontSize: 20),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              _buildSectionTitle("Appearance"),
              _buildSettingCard(
                icon: Icons.dark_mode_outlined,
                title: "Dark Mode",
                subtitle: "Reduce eye strain at night",
                trailing: Switch(
                  value: _darkMode,
                  activeColor: AppColors.primaryNavy,
                  onChanged: (val) => setState(() => _darkMode = val),
                ),
              ),
            ]),
          ),
        ],
      ),
      bottomNavigationBar: MainBottomNav(
        currentIndex: 1, 
        onTabSelected: (index) {
          if (index == 0) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
              (route) => false,
            );
          }
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(25, 25, 25, 25),
      child: Text(title.toUpperCase(), style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildSettingCard({required IconData icon, required String title, required String subtitle, Widget? trailing, VoidCallback? onTap}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      decoration: BoxDecoration(color: AppColors.textPrimary, borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: AppColors.navyLight, borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: AppColors.primaryNavy),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        trailing: trailing ?? const Icon(Icons.chevron_right),
      ),
    );
  }
}