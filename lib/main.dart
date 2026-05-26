import 'package:flutter/material.dart';
import 'package:deepfake_ai/core/theme/app_theme.dart';
import 'package:deepfake_ai/core/utils/size_config.dart';
import 'package:deepfake_ai/shared/widgets/bottom_nav_bar.dart';
import 'package:deepfake_ai/features/splash_onboarding/presentation/splash_screen.dart';
import 'package:deepfake_ai/features/dashboard/presentation/home_dashboard_screen.dart';
import 'package:deepfake_ai/features/history/presentation/history_screen.dart';
import 'package:deepfake_ai/features/notifications/presentation/notifications_screen.dart';
import 'package:deepfake_ai/features/profile/presentation/profile_screen.dart';

// Global ValueNotifier to listen and switch themes (Dark/Light) dynamically in the preview app
final ValueNotifier<ThemeMode> themeModeNotifier = ValueNotifier<ThemeMode>(ThemeMode.dark);

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const DeepFakeAIApp());
}

class DeepFakeAIApp extends StatelessWidget {
  const DeepFakeAIApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeModeNotifier,
      builder: (context, currentThemeMode, _) {
        return MaterialApp(
          title: 'DeepFake AI',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.getLightTheme(),
          darkTheme: AppTheme.getDarkTheme(),
          themeMode: currentThemeMode,
          // Start the application from the high-fidelity Splash Screen
          home: const AppInitializationWrapper(),
        );
      },
    );
  }
}

// Wrapper to initialize responsiveness SizeConfig
class AppInitializationWrapper extends StatelessWidget {
  const AppInitializationWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return const SplashScreen();
  }
}

// Main Scaffold container holding the interactive pages and overlapping bottom nav bar
class MainAppContainer extends StatefulWidget {
  const MainAppContainer({Key? key}) : super(key: key);

  @override
  State<MainAppContainer> createState() => _MainAppContainerState();
}

class _MainAppContainerState extends State<MainAppContainer> {
  int _currentIndex = 0;

  // The 4 main nav views
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      const HomeDashboardScreen(),
      const HistoryScreen(),
      // Middle tab (2) is a custom trigger action, we map its view as Home too
      const HomeDashboardScreen(),
      const NotificationsScreen(),
      const ProfileScreen(),
    ];
  }

  void _onTabTapped(int index) {
    setState(() {
      if (index == 2) {
        // Central Quick Upload Scan Action: focuses Home tab (0) and triggers upload
        _currentIndex = 0;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Quick Scan triggered! Tap 'Upload & Analyze' to start scanning."),
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        _currentIndex = index;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBody: true, // Allows pages to scroll and display transparently under the floating bottom bar
      body: Stack(
        children: [
          // Background layout gradient
          Container(
            decoration: BoxDecoration(
              gradient: isDark 
                  ? const LinearGradient(
                      colors: [Color(0xFF0A0915), Color(0xFF121124)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    )
                  : const LinearGradient(
                      colors: [Color(0xFFF5F5FA), Color(0xFFFFFFFF)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
            ),
          ),
          
          SafeArea(
            bottom: false, // Allows full view undernav coverage
            child: IndexedStack(
              index: _currentIndex,
              children: _pages,
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}
