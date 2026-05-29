import 'package:flutter/material.dart';

class PasswordFormController {
  final TextEditingController appNameController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController urlController = TextEditingController();
  final TextEditingController notesController = TextEditingController();

  String selectedCategory = 'Social';

  void dispose() {
    appNameController.dispose();
    usernameController.dispose();
    passwordController.dispose();
    urlController.dispose();
    notesController.dispose();
  }
}
