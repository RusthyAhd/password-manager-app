import 'package:flutter/material.dart';
import 'package:secure_vault/controller/password_form_controller.dart';
import 'package:secure_vault/data/vault_repository.dart';
import 'package:secure_vault/model/password_item.dart';
import 'package:secure_vault/view/theme/app_colors.dart';
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
  final double _strength = 0.7;
  bool _initialized = false;
  PasswordItem? _editingItem;

  @override
  void dispose() {
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
    _initialized = true;
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
                      final result = await Navigator.of(context).pushNamed('/password-generator');
                      if (result is String && result.isNotEmpty) {
                        setState(() => _controller.passwordController.text = result);
                      }
                    },
                    icon: const Icon(Icons.auto_awesome),
                    label: const Text('Generate Password'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 52),
                      side: const BorderSide(color: AppColors.primary),
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
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        suffixIcon: IconButton(
          icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
          onPressed: () => setState(() => _obscure = !_obscure),
        ),
      ),
    );
  }

  Widget _buildStrengthMeter() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Text('Strength', style: TextStyle(color: AppColors.muted)),
          const SizedBox(width: 12),
          Expanded(
            child: LinearProgressIndicator(
              value: _strength,
              color: AppColors.primary,
              backgroundColor: AppColors.border,
              minHeight: 8,
            ),
          ),
          const SizedBox(width: 8),
          const Text('Strong', style: TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildNotesField() {
    return TextField(
      controller: _controller.notesController,
      maxLines: 3,
      decoration: InputDecoration(
        labelText: 'Notes',
        filled: true,
        fillColor: AppColors.card,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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
    final item = _editingItem == null
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
