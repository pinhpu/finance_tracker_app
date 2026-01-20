import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/constants/app_colors.dart';
import 'features/auth/view/auth_screen.dart';
import 'features/home/view/home_screen.dart';
import 'features/settings/view/settings_screen.dart';
import 'features/statistic/view/statistic_screen.dart';
import 'features/transaction/view/add_transaction_screen.dart';

import 'features/auth/controller/auth_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  String initialRoute = '/home';

  try {
    final authController = AuthController();
    final hasPin = await authController.hasPin();
    if (hasPin) {
      initialRoute = '/auth';
    }
  } catch (e) {
    debugPrint("Error checking PIN: $e");
  }

  runApp(MyApp(initialRoute: initialRoute));
}

class MyApp extends StatelessWidget {
  final String initialRoute;
  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Finance Tracker',
      theme: ThemeData(
        textTheme: GoogleFonts.interTextTheme(),
        primaryColor: AppColors.primary,
        useMaterial3: true,
      ),
      initialRoute: initialRoute,
      routes: {
        '/home': (context) => const MainScaffold(),
        '/auth': (context) => const AuthScreen(),
        '/add_transaction': (context) => const AddTransactionScreen(),
      },
    );
  }
}

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});
  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _index = 0;

  final GlobalKey<StatisticsScreenState> _statsKey =
      GlobalKey<StatisticsScreenState>();

  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      const HomeScreen(),
      StatisticsScreen(key: _statsKey),
      const SizedBox(),
      const Center(child: Text("No Content")),
      const SettingsScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_index],
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.pushNamed(context, '/add_transaction');
        },
        backgroundColor: AppColors.primary,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: Icon(
                Icons.home,
                size: 36,
                color: _index == 0 ? AppColors.primary : Colors.grey,
              ),
              onPressed: () => setState(() => _index = 0),
            ),
            IconButton(
              icon: Icon(
                Icons.bar_chart,
                size: 36,
                color: _index == 1 ? AppColors.primary : Colors.grey,
              ),
              onPressed: () {
                setState(() => _index = 1);
                _statsKey.currentState?.refreshData();
              },
            ),
            const SizedBox(width: 48),
            IconButton(
              icon: Icon(
                Icons.settings,
                size: 36,
                color: _index == 3 ? AppColors.primary : Colors.grey,
              ),
              onPressed: () => setState(() => _index = 3),
            ),
            IconButton(
              icon: Icon(
                Icons.person,
                size: 36,
                color: _index == 4 ? AppColors.primary : Colors.grey,
              ),
              onPressed: () => setState(() => _index = 4),
            ),
          ],
        ),
      ),
    );
  }
}
