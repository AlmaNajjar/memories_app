import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_widgets.dart';
import './signup_screen.dart';
import './home_screen.dart';
import '../providers/memories_provider.dart';

class LoginScreen extends StatefulWidget {
  static const routeName = '/login';
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailControl = FormControl<String>(
    validators: [Validators.required, Validators.email],
  );
  final passwordControl = FormControl<String>(
    validators: [Validators.required, Validators.minLength(6)],
  );

  void _submit(BuildContext context) async {
    if (!emailControl.valid || !passwordControl.valid) {
      emailControl.markAsTouched();
      passwordControl.markAsTouched();
      return;
    }

    final email = emailControl.value!;
    final password = passwordControl.value!;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.signIn(email, password);

    if (success) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('email', email);
      await prefs.setString('username', email.split('@')[0]);
      await prefs.setBool('isLoggedIn', true);
      await prefs.setString('logged_in_user', email); // ✅ إضافة جديدة

      final memoriesProvider = Provider.of<MemoriesProvider>(
        context,
        listen: false,
      );
      await memoriesProvider.loadUserMemories(email);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Sign In Successful!')));
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sign In Failed. Check credentials.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final isLoading = authProvider.isLoading;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 80),
              Image.asset('assets/images/Logo 1 (1).png'),
              const SizedBox(height: 60),

              ReactiveTextField(
                formControl: emailControl,
                decoration: InputDecoration(
                  prefixIcon: const Icon(
                    Icons.email_outlined,
                    color: Color(0xff000000),
                  ),
                  hintText: 'Enter your email',
                  filled: true,
                  fillColor: const Color(0xffFFF5F5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
                validationMessages: {
                  ValidationMessage.required: (_) => 'Email is required',
                  ValidationMessage.email: (_) => 'Enter a valid email',
                },
              ),
              const SizedBox(height: 16),
              ReactiveTextField(
                formControl: passwordControl,
                obscureText: true,
                decoration: InputDecoration(
                  prefixIcon: const Icon(
                    Icons.lock_outline,
                    color: Color(0xff000000),
                  ),
                  hintText: 'Enter your password',
                  filled: true,
                  fillColor: const Color(0xffFFF5F5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
                validationMessages: {
                  ValidationMessage.required: (_) => 'Password required',
                  ValidationMessage.minLength: (_) => 'Min 6 characters',
                },
              ),
              const SizedBox(height: 10),

              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed:
                      () => Navigator.of(
                        context,
                      ).pushReplacementNamed('/forgot-password'),
                  child: const Text(
                    'Forgot Password?',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              AuthPrimaryButton(
                text: 'Sign in',
                isLoading: isLoading,
                onPressed: () => _submit(context),
              ),
              TextButton(
                onPressed:
                    () =>
                        Navigator.of(context).pushNamed(SignUpScreen.routeName),
                child: const Text(
                  'Create Account',
                  style: TextStyle(
                    color: Color(0xFF1272CA),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }
}
