import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'services/storage_service.dart';
import 'services/theme_service.dart';
import 'theme/nothing_theme.dart';
import 'screens/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  


  final storageService = StorageService();
  await storageService.init();

  final themeService = ThemeService();
  await themeService.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: storageService),
        ChangeNotifierProvider.value(value: themeService),
      ],
      child: const NothingTimetableApp(),
    ),
  );
}

class NothingTimetableApp extends StatelessWidget {
  const NothingTimetableApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeService = Provider.of<ThemeService>(context);
    return MaterialApp(
      title: 'When.',
      debugShowCheckedModeBanner: false,
      theme: NothingTheme.theme,
      darkTheme: NothingTheme.darkTheme,
      themeMode: themeService.themeMode,
      home: const MainScreen(),
    );
  }
}
