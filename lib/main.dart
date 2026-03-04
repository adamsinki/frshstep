import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/sales_screen.dart';
import 'screens/login_screen.dart';
import 'screens/admin_screen.dart';
import 'firebase_options.dart'; // Uncomment this after running flutterfire configure

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint("Firebase initialization failed: $e");
  }

  runApp(const PosApp());
}

class PosApp extends StatelessWidget {
  const PosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StepWise POS',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blueGrey,
          brightness: Brightness.light,
        ),
        textTheme: const TextTheme(
          displaySmall: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
          headlineMedium: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ),
      // Set SalesScreen as the initial home
      initialRoute: '/',
      routes: {
        '/': (context) => const SalesScreen(),
        '/login': (context) => const LoginScreen(),
        '/admin': (context) => const AdminScreen(),
      },
    );
  }
}
