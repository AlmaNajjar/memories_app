import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './providers/auth_provider.dart';
import './providers/memories_provider.dart';
import './screens/login_screen.dart';
import './screens/signup_screen.dart';
import './screens/home_screen.dart';
import './screens/create_memory_screen.dart';
import './screens/view_memory_screen.dart';
import './screens/delete_account_screen.dart';
import './screens/forgot_password_screen.dart';
import './screens/forgot_password_success_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  final prefs = await SharedPreferences.getInstance();
  final savedEmail = prefs.getString('logged_in_user');

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthProvider()),
        ChangeNotifierProvider(create: (context) => MemoriesProvider()),
      ],
      child: MyApp(savedEmail: savedEmail),
    ),
  );
}

class MyApp extends StatelessWidget {
  final String? savedEmail;
  const MyApp({super.key, required this.savedEmail}); 

  @override
  Widget build(BuildContext context) {
    final memoriesProvider = Provider.of<MemoriesProvider>(
      context,
      listen: false,
    );

    if (savedEmail != null) {
      Future.microtask(() async {
        await memoriesProvider.loadUserMemories(savedEmail!);
      });
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Memo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Inter',
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      home: savedEmail != null ? const HomeScreen() : const LoginScreen(),
      routes: {
        LoginScreen.routeName: (context) => const LoginScreen(),
        SignUpScreen.routeName: (context) => const SignUpScreen(),
        HomeScreen.routeName: (context) => const HomeScreen(),
        CreateMemoryScreen.routeName: (context) => const CreateMemoryScreen(),
        DeleteAccountScreen.routeName: (context) => const DeleteAccountScreen(),
        ViewMemoryScreen.routeName: (context) => const ViewMemoryScreen(),
        ForgotPasswordScreen.routeName:
            (context) => const ForgotPasswordScreen(),
        ForgotPasswordSuccessScreen.routeName:
            (context) => const ForgotPasswordSuccessScreen(),
      },
    );
  }
}
