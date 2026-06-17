import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:deepfake_ai/core/theme/app_theme.dart';
import 'package:deepfake_ai/core/utils/size_config.dart';
import 'package:deepfake_ai/shared/widgets/bottom_nav_bar.dart';
import 'package:deepfake_ai/features/splash_onboarding/presentation/splash_screen.dart';
import 'package:deepfake_ai/features/dashboard/presentation/home_dashboard_screen.dart';
import 'package:deepfake_ai/features/history/presentation/history_screen.dart';
import 'package:deepfake_ai/features/notifications/presentation/notifications_screen.dart';
import 'package:deepfake_ai/features/profile/presentation/profile_screen.dart';
import 'package:deepfake_ai/services/supabase_service.dart';
import 'package:deepfake_ai/providers/auth_provider.dart';

// Global ValueNotifier to listen and switch themes (Dark/Light) dynamically in the preview app
final ValueNotifier<ThemeMode> themeModeNotifier = ValueNotifier<ThemeMode>(ThemeMode.dark);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase before running the app
  await SupabaseService.initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(create: (_) => AuthProvider()),
      ],
      child: const DeepFakeAIApp(),
    ),
  );
}

class DeepFakeAIApp extends StatelessWidget {
  const DeepFakeAIApp({super.key});

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
  const AppInitializationWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return const SplashScreen();
  }
}

// Main Scaffold container holding the interactive pages and overlapping bottom nav bar
class MainAppContainer extends StatefulWidget {
  const MainAppContainer({super.key});

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
      const NotificationsScreen(),
      const ProfileScreen(),
    ];
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
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
