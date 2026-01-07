import 'package:flutter/material.dart';
import 'package:flutterapp/UI/screens/home/home_screen.dart';
import 'package:flutterapp/UI/widgets/main_bottom_nav.dart';
import 'package:flutterapp/core/theme/app_theme.dart'; // Import your merged theme

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: AppTheme.themeMode,
      builder: (context, currentMode, _) {
        final isDark = currentMode == ThemeMode.dark || 
                      (currentMode == ThemeMode.system && 
                       Theme.of(context).brightness == Brightness.dark);

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                automaticallyImplyLeading: false,
                expandedHeight: 65.0,
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                elevation: 0,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  titlePadding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                  title: Text(
                    "Settings",
                    style: TextStyle(
                      // Uses Navy in light mode, Cyan in dark mode
                      color: Theme.of(context).colorScheme.primary, 
                      fontWeight: FontWeight.bold, 
                      fontSize: 20,
                    ),
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
                      value: isDark,
                      activeColor: Theme.of(context).colorScheme.primary,
                      // 2. Call your merged toggle function here
                      onChanged: (val) => AppTheme.toggleTheme(val),
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
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(25, 25, 25, 25),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          // Secondary text color from your theme
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSettingCard({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      decoration: BoxDecoration(
        // Card color (Surface) automatically switches from White to Dark Gray
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: Theme.of(context).colorScheme.primary),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(fontSize: 12),
        ),
        trailing: trailing ?? const Icon(Icons.chevron_right),
      ),
    );
  }
}