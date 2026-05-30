import 'package:flutter/material.dart';
import 'package:secure_vault/controller/password_form_controller.dart';
import 'package:secure_vault/data/vault_repository.dart';
import 'package:secure_vault/model/password_item.dart';
import 'package:secure_vault/view/theme/app_colors.dart';
import 'package:secure_vault/view/widgets/glassmorphism_card.dart';
import 'package:secure_vault/view/widgets/primary_button.dart';

class AddPasswordScreen extends StatefulWidget {
  const AddPasswordScreen({super.key});

  @override
  State<AddPasswordScreen> createState() => _AddPasswordScreenState();
}

class _AddPasswordScreenState extends State<AddPasswordScreen> {
  final PasswordFormController _controller = PasswordFormController();
  final VaultRepository _repository = VaultRepository.instance;
  bool _obscure = true;
  double _strength = 0.0;
  String _strengthLabel = 'Very Weak';
  bool _initialized = false;
  PasswordItem? _editingItem;

  void _onPasswordChanged() {
    _updateStrength(_controller.passwordController.text);
  }

  @override
  void dispose() {
    _controller.passwordController.removeListener(_onPasswordChanged);
    _controller.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is PasswordItem) {
      _editingItem = args;
      _controller.appNameController.text = args.appName;
      _controller.usernameController.text = args.username;
      _controller.passwordController.text = args.password;
      _controller.urlController.text = args.url;
      _controller.notesController.text = args.notes;
      _controller.selectedCategory = args.category;
    }
    // compute initial strength for prefilled password
    _updateStrength(_controller.passwordController.text);
    _initialized = true;
  }

  @override
  void initState() {
    super.initState();
    _controller.passwordController.addListener(_onPasswordChanged);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = _editingItem != null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          isEditing ? 'Edit Password' : 'Add Password',
          style: const TextStyle(
            color: AppColors.dark,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.dark),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          children: [
            _buildTextField(
              'Website / App Name',
              _controller.appNameController,
            ),
            const SizedBox(height: 14),
            _buildTextField('Username / Email', _controller.usernameController),
            const SizedBox(height: 14),
            _buildPasswordField(),
            const SizedBox(height: 10),
            _buildStrengthMeter(),
            const SizedBox(height: 14),
            _buildTextField('URL', _controller.urlController),
            const SizedBox(height: 14),
            _buildNotesField(),
            const SizedBox(height: 14),
            _buildCategoryField(),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final result = await Navigator.of(
                        context,
                      ).pushNamed('/password-generator');
                      if (result is String && result.isNotEmpty) {
                        setState(
                          () => _controller.passwordController.text = result,
                        );
                      }
                    },
                    icon: const Icon(Icons.auto_awesome),
                    label: const Text('Generate Password'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 52),
                      side: const BorderSide(
                        color: AppColors.primary,
                        width: 2,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      foregroundColor: AppColors.dark,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            PrimaryButton(
              label: isEditing ? 'Update Password' : 'Save Password',
              onPressed: _savePassword,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: AppColors.card,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppColors.border.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
    );
  }

  Widget _buildPasswordField() {
    return TextField(
      controller: _controller.passwordController,
      obscureText: _obscure,
      decoration: InputDecoration(
        labelText: 'Password',
        filled: true,
        fillColor: AppColors.card,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppColors.border.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        suffixIcon: IconButton(
          icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
          onPressed: () => setState(() => _obscure = !_obscure),
        ),
      ),
    );
  }

  Widget _buildStrengthMeter() {
    return GlassmorphismCard(
      icon: Icons.security,
      title: 'Password Strength',
      description: _strengthLabel,
      child: LinearProgressIndicator(
        value: _strength.clamp(0.0, 1.0),
        color:
            _strength >= 0.8
                ? Colors.green
                : _strength >= 0.6
                ? Colors.lightGreen
                : _strength >= 0.4
                ? Colors.orange
                : Colors.red,
        backgroundColor: AppColors.border,
        minHeight: 8,
      ),
      padding: const EdgeInsets.all(14),
      borderRadius: 14,
      iconGradient: const LinearGradient(
        colors: [
          Color(0xFF0088FF),
          Color(0xFF4DB8FF),
        ],
      ),
    );
  }

  void _updateStrength(String password) {
    final pwd = password;
    if (pwd.isEmpty) {
      if (!mounted) return;
      setState(() {
        _strength = 0.0;
        _strengthLabel = 'Very Weak';
      });
      return;
    }

    double score = 0;
    final lengthScore = (pwd.length / 20).clamp(0.0, 1.0) * 0.4;
    score += lengthScore;

    final hasLower = pwd.contains(RegExp(r'[a-z]'));
    final hasUpper = pwd.contains(RegExp(r'[A-Z]'));
    final hasDigit = pwd.contains(RegExp(r'\d'));
    final hasSpecial = pwd.contains(RegExp(r'[^A-Za-z0-9]'));
    final varietyCount =
        [hasLower, hasUpper, hasDigit, hasSpecial].where((e) => e).length;
    score += (varietyCount / 4) * 0.5;

    final lowers = pwd.toLowerCase();
    if (lowers.contains('1234') ||
        lowers.contains('password') ||
        lowers.contains('qwerty')) {
      score -= 0.2;
    }

    score = score.clamp(0.0, 1.0);

    String label;
    if (score >= 0.8) {
      label = 'Strong';
    } else if (score >= 0.6) {
      label = 'Good';
    } else if (score >= 0.4) {
      label = 'Fair';
    } else if (score >= 0.2) {
      label = 'Weak';
    } else {
      label = 'Very Weak';
    }

    if (!mounted) return;
    setState(() {
      _strength = score;
      _strengthLabel = label;
    });
  }

  Widget _buildNotesField() {
    return TextField(
      controller: _controller.notesController,
      maxLines: 3,
      decoration: InputDecoration(
        labelText: 'Notes',
        filled: true,
        fillColor: AppColors.card,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppColors.border.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
    );
  }

  Widget _buildCategoryField() {
    return DropdownButtonFormField<String>(
      value: _controller.selectedCategory,
      items: const [
        DropdownMenuItem(value: 'Social', child: Text('Social')),
        DropdownMenuItem(value: 'Finance', child: Text('Finance')),
        DropdownMenuItem(value: 'Work', child: Text('Work')),
        DropdownMenuItem(value: 'Shopping', child: Text('Shopping')),
      ],
      onChanged: (value) {
        if (value != null) {
          setState(() => _controller.selectedCategory = value);
        }
      },
      decoration: InputDecoration(
        labelText: 'Category',
        filled: true,
        fillColor: AppColors.card,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppColors.border.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
    );
  }

  Future<void> _savePassword() async {
    final appName = _controller.appNameController.text.trim();
    final username = _controller.usernameController.text.trim();
    final password = _controller.passwordController.text.trim();
    final url = _controller.urlController.text.trim();
    final notes = _controller.notesController.text.trim();
    final category = _controller.selectedCategory;

    if (appName.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('App name and password are required')),
      );
      return;
    }

    final now = DateTime.now();
    final item =
        _editingItem == null
            ? PasswordItem(
              id: now.microsecondsSinceEpoch.toString(),
              appName: appName,
              username: username,
              password: password,
              category: category,
              url: url,
              notes: notes,
              createdAt: now,
              updatedAt: now,
            )
            : _editingItem!.copyWith(
              appName: appName,
              username: username,
              password: password,
              category: category,
              url: url,
              notes: notes,
              updatedAt: now,
            );

    await _repository.savePassword(item);
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed('/password-list');
  }
}
