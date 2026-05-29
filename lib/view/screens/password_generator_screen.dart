import 'package:flutter/material.dart';
import 'package:secure_vault/controller/password_generator_controller.dart';
import 'package:flutter/services.dart';
import 'package:secure_vault/view/theme/app_colors.dart';
import 'package:secure_vault/view/widgets/primary_button.dart';

class PasswordGeneratorScreen extends StatefulWidget {
  const PasswordGeneratorScreen({super.key});

  @override
  State<PasswordGeneratorScreen> createState() =>
      _PasswordGeneratorScreenState();
}

class _PasswordGeneratorScreenState extends State<PasswordGeneratorScreen> {
  final PasswordGeneratorController _controller = PasswordGeneratorController();

  @override
  Widget build(BuildContext context) {
    final options = _controller.options;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Password Generator',
          style: TextStyle(color: AppColors.dark, fontWeight: FontWeight.w700),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.dark),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _controller.samplePassword,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () async {
                    await Clipboard.setData(
                      ClipboardData(text: _controller.samplePassword),
                    );
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Copied to clipboard')),
                    );
                  },
                  icon: const Icon(Icons.copy, color: AppColors.primary),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text('Length', style: TextStyle(fontWeight: FontWeight.w600)),
          Slider(
            value: options.length,
            min: 8,
            max: 32,
            divisions: 24,
            label: options.length.toInt().toString(),
            onChanged: (value) => setState(() => options.length = value),
          ),
          const SizedBox(height: 8),
          _buildToggle('Include Symbols', options.includeSymbols, (value) {
            setState(() => options.includeSymbols = value);
          }),
          _buildToggle('Include Numbers', options.includeNumbers, (value) {
            setState(() => options.includeNumbers = value);
          }),
          _buildToggle('Include Uppercase', options.includeUppercase, (value) {
            setState(() => options.includeUppercase = value);
          }),
          _buildToggle('Include Lowercase', options.includeLowercase, (value) {
            setState(() => options.includeLowercase = value);
          }),
          const SizedBox(height: 20),
          PrimaryButton(
            label: 'Generate Password',
            onPressed: () {
              final generated = _controller.generate();
              setState(() {});
              Navigator.of(context).pop(generated);
            },
            icon: Icons.auto_awesome,
          ),
        ],
      ),
    );
  }

  Widget _buildToggle(String label, bool value, ValueChanged<bool> onChanged) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label),
      value: value,
      onChanged: onChanged,
      activeColor: AppColors.primary,
    );
  }
}
