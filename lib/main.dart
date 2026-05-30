import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:secure_vault/data/vault_repository.dart';
import 'package:secure_vault/model/password_item.dart';
import 'package:secure_vault/view/screens/add_password_screen.dart';
import 'package:secure_vault/view/screens/dashboard_screen.dart';
import 'package:secure_vault/view/screens/login_screen.dart';
import 'package:secure_vault/view/screens/password_generator_screen.dart';
import 'package:secure_vault/view/screens/password_list_screen.dart';
import 'package:secure_vault/view/screens/search_filter_screen.dart';
import 'package:secure_vault/view/screens/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(PasswordItemAdapter());
  await VaultRepository.instance.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Secure Vault',
      theme: ThemeData(
        useMaterial3: true,
        textTheme: GoogleFonts.robotoSlabTextTheme(),
      ),
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
      routes: {
        '/login': (_) => const LoginScreen(),
        '/dashboard': (_) => DashboardScreen(),
        '/add-password': (_) => const AddPasswordScreen(),
        '/password-list': (_) => PasswordListScreen(),
        '/search-filter': (_) => const SearchFilterScreen(),
        '/password-generator': (_) => const PasswordGeneratorScreen(),
      },
    );
  }
}
