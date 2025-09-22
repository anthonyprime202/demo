import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'pages/analysis_page.dart';
import 'pages/chat_page.dart';
import 'pages/settings_page.dart';
import 'widgets/profile_selector.dart';

void main() {
  runApp(const FloatChatApp());
}

class FloatChatApp extends StatefulWidget {
  const FloatChatApp({super.key});

  @override
  State<FloatChatApp> createState() => _FloatChatAppState();
}

class _FloatChatAppState extends State<FloatChatApp> {
  int _currentIndex = 1; // Chat is the initial page
  ThemeMode _themeMode = ThemeMode.light;
  final ValueNotifier<ProfileMode> _profileNotifier =
      ValueNotifier<ProfileMode>(ProfileMode.general);

  @override
  void dispose() {
    _profileNotifier.dispose();
    super.dispose();
  }

  void _onThemeChanged(bool isDark) {
    setState(() {
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ProfileMode>(
      valueListenable: _profileNotifier,
      builder: (context, profileMode, _) {
        return MaterialApp(
          title: 'FloatChat',
          debugShowCheckedModeBanner: false,
          themeMode: _themeMode,
          theme: ThemeData(
            colorSchemeSeed: const Color(0xFF0A8BD9),
            brightness: Brightness.light,
            textTheme: GoogleFonts.interTextTheme(),
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            colorSchemeSeed: const Color(0xFF0A8BD9),
            brightness: Brightness.dark,
            textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
            useMaterial3: true,
          ),
          home: Scaffold(
            appBar: FloatChatAppBar(
              profileMode: profileMode,
              onTap: () => showProfileSelector(context, _profileNotifier),
            ),
            body: IndexedStack(
              index: _currentIndex,
              children: [
                AnalysisPage(profileNotifier: _profileNotifier),
                ChatPage(profileNotifier: _profileNotifier),
                SettingsPage(
                  onThemeChanged: _onThemeChanged,
                  isDarkMode: _themeMode == ThemeMode.dark,
                ),
              ],
            ),
            bottomNavigationBar: NavigationBar(
              selectedIndex: _currentIndex,
              onDestinationSelected: (index) {
                setState(() => _currentIndex = index);
              },
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.public),
                  label: 'Analysis',
                ),
                NavigationDestination(
                  icon: Icon(Icons.chat_bubble_outline),
                  label: 'Chat',
                ),
                NavigationDestination(
                  icon: Icon(Icons.settings_outlined),
                  label: 'Settings',
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class FloatChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  const FloatChatAppBar({
    super.key,
    required this.profileMode,
    required this.onTap,
  });

  final ProfileMode profileMode;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      titleSpacing: 0,
      title: Row(
        children: [
          const SizedBox(width: 16),
          CircleAvatar(
            radius: 18,
            backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
            child: const Text('🐬', style: TextStyle(fontSize: 20)),
          ),
          const SizedBox(width: 12),
          Text(
            'FloatChat',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: ProfileSelectorChip(
            profileMode: profileMode,
            onPressed: onTap,
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
