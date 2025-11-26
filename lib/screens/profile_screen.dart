import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'delete_account_screen.dart';
import 'dart:async';

class ProfileScreen extends StatefulWidget {
  static const routeName = '/profile';
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _username = 'Loading...';
  String _email = 'loading@email.com';

  static const String _usernameKey = 'username';
  static const String _emailKey = 'email';
  static const String _loggedInKey = 'isLoggedIn';

  String? _statusMessage;
  Timer? _statusTimer;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _statusTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _username = prefs.getString(_usernameKey) ?? 'Default Username';
        _email = prefs.getString(_emailKey) ?? 'default.user@app.com';
      });
    }
  }

  Future<void> _updateUsername(String newUsername) async {
    if (newUsername.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_usernameKey, newUsername);

    if (mounted) {
      setState(() {
        _username = newUsername;
        _showStatusMessage('Username updated successfully!');
      });
    }
  }

  Future<void> _updateEmail(String newEmail) async {
    if (newEmail.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_emailKey, newEmail);

    if (mounted) {
      setState(() {
        _email = newEmail;
        _showStatusMessage('Email updated successfully!');
      });
    }
  }

  Future<void> _updatePassword() async {
    _showStatusMessage('Password updated successfully! (Dummy)');
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(_usernameKey);
    await prefs.remove(_emailKey);
    await prefs.remove(_loggedInKey);
    await prefs.remove('logged_in_user');

    if (mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
    }
  }

  void _showStatusMessage(String message) {
    if (_statusTimer != null && _statusTimer!.isActive) {
      _statusTimer!.cancel();
    }
    setState(() {
      _statusMessage = message;
    });
    _statusTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _statusMessage = null;
        });
      }
    });
  }

  void _showUpdateDialog(
    BuildContext context,
    String title,
    String hintText,
    int numberOfFields,
  ) {
    final isPasswordUpdate = numberOfFields > 1;

    final TextEditingController inputController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          contentPadding: const EdgeInsets.only(
            left: 24,
            top: 12,
            right: 12,
            bottom: 12,
          ),
          backgroundColor: Colors.white,

          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.05),

              if (!isPasswordUpdate)
                _buildInputField(hintText, controller: inputController),

              if (isPasswordUpdate) ...[
                _buildInputField('Input old Password'),
                const SizedBox(height: 12),
                _buildInputField('Input New Password'),
                const SizedBox(height: 12),
                _buildInputField('Match New Password'),
              ],

              SizedBox(height: MediaQuery.of(context).size.height * 0.05),

              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  TextButton(
                    onPressed: () {
                      if (isPasswordUpdate) {
                        _updatePassword();
                      } else if (title.contains('Username')) {
                        _updateUsername(inputController.text);
                      } else if (title.contains('Email')) {
                        _updateEmail(inputController.text);
                      }
                      Navigator.of(context).pop();
                    },
                    child: const Text(
                      'Save',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    ).then((_) {
      inputController.dispose();
    });
  }

  Widget _buildInputField(String hint, {TextEditingController? controller}) {
    return Container(
      width: 332,
      height: 46,
      padding: EdgeInsets.zero,
      decoration: BoxDecoration(
        color: const Color(0xffFFF5F5),
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xff000000),
            fontSize: 12,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 0,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Center(
            child: Column(
              children: <Widget>[
                SizedBox(height: MediaQuery.of(context).size.height * 0.01),

                Image.asset('assets/images/Group 4.png', height: 100),
                SizedBox(height: MediaQuery.of(context).size.height * 0.02),

                Text(
                  _username.isNotEmpty ? _username : 'No username saved',
                  style: const TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),

                Text(
                  _email.isNotEmpty ? _email : 'No email saved',
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.black54,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                SizedBox(height: MediaQuery.of(context).size.height * 0.03),

                if (_statusMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20.0),
                    child: Text(
                      _statusMessage!,
                      style: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                _ProfileButton(
                  text: 'Update Username',
                  onPressed:
                      () => _showUpdateDialog(
                        context,
                        'Update Username',
                        'Enter new Username',
                        1,
                      ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.01),

                _ProfileButton(
                  text: 'Update Email',
                  onPressed:
                      () => _showUpdateDialog(
                        context,
                        'Update Email',
                        'Enter new Email',
                        1,
                      ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.01),

                _ProfileButton(
                  text: 'Update Password',
                  onPressed:
                      () => _showUpdateDialog(
                        context,
                        'Update password',
                        'Input old Password',
                        3,
                      ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.01),

                _ProfileButton(
                  text: 'Delete Account',
                  onPressed: () {
                    Navigator.of(
                      context,
                    ).pushNamed(DeleteAccountScreen.routeName);
                  },
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.01),

                _ProfileButton(text: 'Logout', onPressed: _logout),
                const SizedBox(height: 40),

                const Text(
                  'Read',
                  style: TextStyle(fontSize: 12, color: Colors.black),
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () {},
                      child: const Text(
                        'Terms and Condition',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Text(
                      'and',
                      style: TextStyle(color: Colors.black, fontSize: 12),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: const Text(
                        softWrap: true,
                        'Privacy Policy',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const _ProfileButton({required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.6,
      height: 39,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF333333),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          elevation: 5,
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class DummyScreen extends StatelessWidget {
  final String title;
  const DummyScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Text(
          'This is the $title screen (implementation pending).',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
