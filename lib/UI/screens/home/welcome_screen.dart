import 'package:flutter/material.dart';
import 'package:flutterapp/core/constants/app_colors.dart'; 
import 'package:flutterapp/UI/screens/home/home_screen.dart';

class Welcomescreen extends StatelessWidget {
  const Welcomescreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter, 
            end: Alignment.bottomCenter,
            colors: [
              AppColors.primaryNavy, // Deep Royal Blue from constants
              AppColors.navyDark,   // Dark Navy from constants
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              children: [
                const Spacer(flex: 3),
                
                // Icon/Logo Section
                const Icon(
                  Icons.auto_awesome_motion_rounded,
                  color: AppColors.textPrimary, // White
                  size: 70,
                ),
                
                const SizedBox(height: 20),
                
                // Title
                const Text(
                  "Study Flow",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary, // White
                    letterSpacing: -1,
                  ),
                ),
                
                const SizedBox(height: 10),
                
                const Text(
                  "Level Up Your Learning\nThrough Play",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    color: AppColors.textSecondary, // Light grey/white70
                    fontWeight: FontWeight.w300,
                    height: 1.4,
                  ),
                ),
                
                const Spacer(flex: 5),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const HomeScreen()),
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    decoration: BoxDecoration(
                      color: AppColors.textPrimary, // White button
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Text(
                      "Get Started",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        color:AppColors.navyDark, // Dark Navy text
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}