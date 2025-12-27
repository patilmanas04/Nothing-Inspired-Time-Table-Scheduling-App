import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/nothing_theme.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(context, '1. Introduction', 
              'Welcome to our Time Table application. We respect your privacy and are committed to protecting your personal data. This privacy policy will inform you as to how we look after your personal data when you visit our application and tell you about your privacy rights and how the law protects you.'),
            const SizedBox(height: 24),
            _buildSection(context, '2. Data We Collect', 
              'We may collect, use, store and transfer different kinds of personal data about you which we have grouped together follows:\n\n• Identity Data: includes first name, last name, username or similar identifier.\n• Contact Data: includes email address and telephone numbers.\n• Usage Data: includes information about how you use our website, products and services.'),
            const SizedBox(height: 24),
            _buildSection(context, '3. How We Use Your Data', 
              'We will only use your personal data when the law allows us to. Most commonly, we will use your personal data in the following circumstances:\n\n• Where we need to perform the contract we are about to enter into or have entered into with you.\n• Where it is necessary for our legitimate interests (or those of a third party) and your interests and fundamental rights do not override those interests.'),
            const SizedBox(height: 24),
            _buildSection(context, '4. Data Security', 
              'We have put in place appropriate security measures to prevent your personal data from being accidentally lost, used or accessed in an unauthorized way, altered or disclosed.'),
            const SizedBox(height: 24),
            _buildSection(context, '5. Contact Us', 
              'If you have any questions about this privacy policy or our privacy practices, please contact us at: support@timetableapp.com'),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.jetBrainsMono(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          content,
          style: GoogleFonts.jetBrainsMono(
            fontSize: 14,
            height: 1.5,
            color: NothingTheme.grey,
          ),
        ),
      ],
    );
  }
}
