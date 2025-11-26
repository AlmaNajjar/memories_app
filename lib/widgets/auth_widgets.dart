import 'package:flutter/material.dart';

class AuthInputField extends StatelessWidget {
  final IconData icon;
  final String hintText;
  final bool isPassword;
  final void Function(String)? onChanged;
  final String? Function(String?)? validator;

  const AuthInputField({
    super.key,
    required this.icon,
    required this.hintText,
    this.isPassword = false,
    this.onChanged,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        width: screenWidth * 0.85,
        decoration: BoxDecoration(
          color: const Color(0xffFFF5F5),
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: TextFormField(
          keyboardType:
              hintText.toLowerCase().contains('email')
                  ? TextInputType.emailAddress
                  : TextInputType.text,
          onChanged: onChanged,
          validator: validator,
          obscureText: isPassword,
          style: const TextStyle(color: Colors.black),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(color: Colors.black, fontSize: 14),
            prefixIcon: Icon(icon, color: Colors.black),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 16.0,
              horizontal: 10.0,
            ),
          ),
        ),
      ),
    );
  }
}

class AuthPrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;

  const AuthPrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: SizedBox(
        width: screenWidth * 0.85,
        height: 54,
        child: ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black87,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(7.72),
            ),
            padding: const EdgeInsets.all(0),
            elevation: 5,
          ),
          child:
              isLoading
                  ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                  : Text(
                    text,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17.37,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
        ),
      ),
    );
  }
}
