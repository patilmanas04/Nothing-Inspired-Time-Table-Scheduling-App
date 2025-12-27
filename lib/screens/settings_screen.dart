import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/theme_service.dart';

import '../theme/nothing_theme.dart';
import 'privacy_policy_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionHeader(context, 'Appearance'),
          const SizedBox(height: 8),
          _buildSettingsCard(
            context,
            child: _buildSettingsItem(
              context,
              title: 'Theme',
              subtitle: _getThemeName(context),
              onTap: () => _showThemeDialog(context),
            ),
          ),
          const SizedBox(height: 24),
          _buildSectionHeader(context, 'About'),
          const SizedBox(height: 8),
          _buildSettingsCard(
            context,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(24),
              bottom: Radius.circular(4),
            ),
            child: _buildSettingsItem(
              context,
              title: 'Version',
              subtitle: '1.0.0',
            ),
          ),
          const SizedBox(height: 4), // Very small space between options

          _buildSettingsCard(
            context,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(4),
              bottom: Radius.circular(24),
            ),
            child: _buildSettingsItem(
              context,
              title: 'Privacy policy',
              showArrow: true,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PrivacyPolicyScreen()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 4),
      child: Text(
        title,
        style: GoogleFonts.jetBrainsMono(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }

  Widget _buildSettingsCard(BuildContext context, {required Widget child, BorderRadius? borderRadius}) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.light
            ? NothingTheme.offWhite
            : const Color(0xFF1A1A1A),
        borderRadius: borderRadius ?? BorderRadius.circular(24),
      ),
      child: child,
    );
  }

  Widget _buildSettingsItem(
    BuildContext context, {
    required String title,
    String? subtitle,
    bool showArrow = false,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 16,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 12,
                        color: NothingTheme.grey,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (showArrow || onTap != null)
              Icon(
                Icons.chevron_right,
                color: NothingTheme.grey,
              ),
          ],
        ),
      ),
    );
  }

  String _getThemeName(BuildContext context) {
    final mode = Provider.of<ThemeService>(context).themeMode;
    switch (mode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System Default';
    }
  }

  void _showThemeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
          contentPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          title: Text(
            'Choose Theme',
            style: GoogleFonts.jetBrainsMono(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildThemeOption(context, 'Light', ThemeMode.light),
              const SizedBox(height: 12), // Reduced space
              _buildThemeOption(context, 'Dark', ThemeMode.dark),
              const SizedBox(height: 12), // Reduced space
              _buildThemeOption(context, 'System Default', ThemeMode.system),
            ],
          ),
        );
      },
    );
  }

  Widget _buildThemeOption(BuildContext context, String title, ThemeMode mode) {
    final themeService = Provider.of<ThemeService>(context, listen: false);
    final currentMode = themeService.themeMode;
    final isSelected = currentMode == mode;
    
    return InkWell(
      onTap: () {
        themeService.setThemeMode(mode);
        Navigator.pop(context);
      },
      borderRadius: BorderRadius.circular(8),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? NothingTheme.red : Theme.of(context).colorScheme.onSurface,
                width: 2,
              ),
            ),
            padding: const EdgeInsets.all(3),
            child: isSelected
                ? Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: NothingTheme.red,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 16), // Space between radio and text
          Text(
            title,
            style: GoogleFonts.jetBrainsMono(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
