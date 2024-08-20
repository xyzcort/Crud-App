import 'package:app_assets/pages/user/login_page.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // Tema aplikasi
        colorScheme: const ColorScheme.light(
          secondary: Colors.amber, // Warna sekunder tema
          primary: Colors.blue, // Warna primer tema
        ),
        scaffoldBackgroundColor: Colors.blue[50], //Latar belakang scaffold
        elevatedButtonTheme: ElevatedButtonThemeData(
          // Gaya tombol di aplikasi
          style: ButtonStyle(
            padding: const MaterialStatePropertyAll(
              EdgeInsets.symmetric(
                vertical: 16,
                horizontal: 30,
              ),
            ),
            shape: MaterialStatePropertyAll(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            backgroundColor: const MaterialStatePropertyAll(Colors.blue),
          ),
        ),
      ),
      home: LoginPage(), // Main page
    );
  }
}
