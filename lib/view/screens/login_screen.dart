import 'package:flutter/material.dart';
import 'package:secure_vault/controller/login_controller.dart';
import 'package:secure_vault/view/theme/app_colors.dart';
import 'package:secure_vault/view/widgets/primary_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final LoginController _controller = LoginController();
  bool _obscure = true;
  bool _isFirstTime = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _isFirstTime = !_controller.hasMasterPassword;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 50),
              _buildLogo(),
              const SizedBox(height: 20),
              const Text(
                'Welcome Back',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: AppColors.dark,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _isFirstTime
                    ? 'Create a master password to secure your vault'
                    : 'Enter your master password to unlock',
                style: const TextStyle(color: AppColors.muted),
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _controller.passwordController,
                obscureText: _obscure,
                decoration: InputDecoration(
                  labelText:
                      _isFirstTime ? 'Create Master Password' : 'Master Password',
                  filled: true,
                  fillColor: AppColors.card,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  errorText: _errorText,
                  suffixIcon: IconButton(
                    icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              PrimaryButton(
                label: _isFirstTime ? 'Set Master Password' : 'Unlock Vault',
                onPressed: _handleLogin,
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {},
                child: const Text('Use biometrics instead'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return SizedBox(
      width: 160,
      height: 160,
      child: Image.asset('assets/logo.png', width: 200, height: 200),
    );
  }

  void _handleLogin() async {
    setState(() => _errorText = null);
    final password = _controller.passwordController.text.trim();
    if (password.isEmpty) {
      setState(() => _errorText = 'Please enter a password');
      return;
    }

    if (_isFirstTime) {
      await _controller.setMasterPassword(password);
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed('/dashboard');
      return;
    }

    final isValid = _controller.verifyPassword(password);
    if (!isValid) {
      setState(() => _errorText = 'Invalid master password');
      return;
    }

    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed('/dashboard');
  }
}
