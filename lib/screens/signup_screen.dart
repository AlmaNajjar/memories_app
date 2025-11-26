import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_widgets.dart';
import './home_screen.dart';

class SignUpScreen extends StatefulWidget {
  static const routeName = '/signup';
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final emailControl = FormControl<String>(
    validators: [Validators.required, Validators.email],
  );
  final usernameControl = FormControl<String>(
    validators: [Validators.required, Validators.minLength(3)],
  );
  final passwordControl = FormControl<String>(
    validators: [Validators.required, Validators.minLength(6)],
  );
  final confirmControl = FormControl<String>(validators: [Validators.required]);
  bool agreedToTerms = false;

  Future<void> _saveUserData(String email, String username) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('email', email);
    await prefs.setString('username', username);
    await prefs.setBool('isLoggedIn', true);
  }

  void _submit(BuildContext context) async {
    if (!emailControl.valid ||
        !usernameControl.valid ||
        !passwordControl.valid ||
        !confirmControl.valid) {
      emailControl.markAsTouched();
      usernameControl.markAsTouched();
      passwordControl.markAsTouched();
      confirmControl.markAsTouched();
      return;
    }

    if (passwordControl.value != confirmControl.value) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Passwords do not match.')));
      return;
    }

    if (!agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You must agree to the terms and privacy policy.'),
        ),
      );
      return;
    }

    final email = emailControl.value!;
    final username = usernameControl.value!;
    final password = passwordControl.value!;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.signUp(email, password, username);

    if (success) {
      await _saveUserData(email, username);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Sign Up Successful!')));
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sign Up Failed. Try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final isLoading = authProvider.isLoading;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 80),
              Image.asset(
                'assets/images/Logo 1 (1).png',
                height: 100,
                width: 250,
              ),
              const SizedBox(height: 60),

              ReactiveTextField(
                formControl: emailControl,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.email_outlined),
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
                  ValidationMessage.required: (_) => 'Email required',
                  ValidationMessage.email: (_) => 'Invalid email',
                },
              ),
              const SizedBox(height: 16),
              ReactiveTextField(
                formControl: usernameControl,
                decoration: InputDecoration(
                  prefixIcon: const Icon(
                    Icons.person,
                    color: Color(0xff000000),
                  ),
                  hintText: 'Enter your username',
                  filled: true,
                  fillColor: const Color(0xffFFF5F5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
                validationMessages: {
                  ValidationMessage.required: (_) => 'Username required',
                  ValidationMessage.minLength: (_) => 'Min 3 characters',
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
              ),
              const SizedBox(height: 16),
              ReactiveTextField(
                formControl: confirmControl,
                obscureText: true,
                decoration: InputDecoration(
                  prefixIcon: const Icon(
                    Icons.lock_outline,
                    color: Color(0xff000000),
                  ),
                  hintText: 'confirm password',
                  filled: true,
                  fillColor: const Color(0xffFFF5F5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),

              Padding(
                padding: EdgeInsets.only(
                  right: screenWidth * 0.1,
                  top: 10,
                  bottom: 20,
                ),
                child: Row(
                  children: [
                    Checkbox(
                      value: agreedToTerms,
                      onChanged:
                          (v) => setState(() => agreedToTerms = v ?? false),
                      activeColor: Colors.black87,
                    ),
                    const Expanded(
                      child: FittedBox(
                        child: Row(
                          children: [
                            Text(
                              'I accept ',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.black,
                              ),
                            ),
                            Text(
                              'Terms and Conditions ',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            Text(
                              'and ',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.black,
                              ),
                            ),
                            Text(
                              'Privacy policy',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              AuthPrimaryButton(
                text: 'Create Account',
                isLoading: isLoading,
                onPressed: () => _submit(context),
              ),
              TextButton(
                onPressed:
                    () => Navigator.of(context).pushReplacementNamed('/login'),
                child: const Text(
                  'Login',
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
