import 'package:flutter/material.dart';
import 'package:secure_vault/controller/login_controller.dart';
import 'package:secure_vault/view/theme/app_colors.dart';
import 'package:secure_vault/view/widgets/glassmorphism_card.dart';
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
  bool _canUseBiometrics = false;
  bool _isBiometricAuthenticating = false;

  @override
  void initState() {
    super.initState();
    _isFirstTime = !_controller.hasMasterPassword;
    _checkBiometricAvailability();
  }

  Future<void> _checkBiometricAvailability() async {
    if (_isFirstTime) return;
    final canUse = await _controller.canUseBiometrics();
    if (mounted) {
      setState(() => _canUseBiometrics = canUse);
    }
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
                    ? 'Create a password to secure your vault'
                    : 'Enter your password to unlock',
                style: const TextStyle(color: AppColors.dark),
              ),
              const SizedBox(height: 32),
              GlassmorphismCard(
                icon: Icons.lock_outline,
                title: 'Vault Access',
                description:
                    _isFirstTime
                        ? 'Create a password to secure your vault'
                        : 'Enter your password to unlock',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _controller.passwordController,
                      obscureText: _obscure,
                      decoration: InputDecoration(
                        labelText:
                            _isFirstTime
                                ? 'Create Password'
                                : 'Password',
                        filled: true,
                        labelStyle: const TextStyle(color: AppColors.dark),
                        fillColor: AppColors.card,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        errorText: _errorText,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscure ? Icons.visibility_off : Icons.visibility,
                          ),
                          onPressed: () => setState(() => _obscure = !_obscure),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    PrimaryButton(
                      label:
                          _isFirstTime ? 'Set Password' : 'Unlock Vault',
                      onPressed: _handleLogin,
                    ),
                    if (!_isFirstTime && _canUseBiometrics) ...[
                      const SizedBox(height: 10),
                      Center(
                        child: TextButton.icon(
                          onPressed:
                              _isBiometricAuthenticating
                                  ? null
                                  : _handleBiometricLogin,
                          icon: _isBiometricAuthenticating
                              ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    AppColors.primary.withValues(alpha: 0.7),
                                  ),
                                  strokeWidth: 2,
                                ),
                              )
                              : const Icon(Icons.fingerprint, color: AppColors.dark),
                          label: Text(
                            _isBiometricAuthenticating
                                ? 'Authenticating...'
                                : 'Use Biometrics',
                          style: TextStyle(color: AppColors.dark),),
                        ),
                      ),
                    ],
                  ],
                ),
                iconGradient: const LinearGradient(
                  colors: [
                    Color(0xFF0088FF),
                    Color(0xFF4DB8FF),
                  ],
                ),
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
      setState(() => _errorText = 'Invalid password');
      return;
    }

    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed('/dashboard');
  }

  Future<void> _handleBiometricLogin() async {
    setState(() {
      _isBiometricAuthenticating = true;
      _errorText = null;
    });

    try {
      final isAuthenticated =
          await _controller.authenticateWithBiometrics();
      if (!mounted) return;

      if (isAuthenticated) {
        Navigator.of(context).pushReplacementNamed('/dashboard');
      } else {
        _showBiometricFailedDialog();
      }
    } catch (e) {
      if (mounted) {
        _showBiometricFailedDialog();
      }
    } finally {
      if (mounted) {
        setState(() => _isBiometricAuthenticating = false);
      }
    }
  }

  void _showBiometricFailedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Biometric Authentication'),
        content: const Text(
          'Biometric authentication is not available or was cancelled. Please use your password instead.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Use Password'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _handleBiometricLogin();
            },
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }
}
