import 'dart:convert';

import 'package:app_assets/configure/app_constant.dart';
import 'package:app_assets/pages/asset/home_page.dart';
import 'package:d_info/d_info.dart';
import 'package:d_method/d_method.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class LoginPage extends StatelessWidget {
  LoginPage({Key? key}) : super(key: key);

  // Controller untuk input username
  final edtUsername = TextEditingController();

  // Controller untuk input password
  final edtPassword = TextEditingController();

  // GlobalKey untuk mengelola form
  final formkey = GlobalKey<FormState>();

  // Fungsi untuk melakukan login
  login(BuildContext context) {
    // Validasi input form
    bool isValid = formkey.currentState!.validate();
    if (isValid) {
      // URL endpoint untuk login
      Uri url = Uri.parse(
        '${AppConstant.baseURL}/user/login.php',
      );

      // Mengirim permintaan POST untuk login
      http.post(url, body: {
        'username': edtUsername.text,
        'password': edtPassword.text,
      }).then((response) {
        DMethod.printResponse(response);

        // Mengurai respons JSON
        Map resBody = jsonDecode(response.body);

        // Mengecek apakah login berhasil
        bool success = resBody['success'] ?? false;
        if (success) {
          DInfo.toastSuccess('Login success');
          // Pindah ke halaman HomePage jika login berhasil
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const HomePage(),
            ),
          );
        } else {
          DInfo.toastError('Login failed');
        }
      }).catchError((onError) {
        DInfo.toastError('Error');
        DMethod.printBasic(onError.toString());
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(30),
            child: Form(
              key: formkey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Teks judul aplikasi
                  Text(
                    AppConstant.appName.toUpperCase(),
                    style: TextStyle(
                      color: Colors.blue[800],
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Input field untuk username
                  TextFormField(
                    controller: edtUsername,
                    validator: (value) =>
                        value == '' ? "Username required" : null,
                    decoration: InputDecoration(
                      fillColor: Colors.white,
                      filled: true,
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      isDense: true,
                      hintText: 'Username',
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Input field untuk password
                  TextFormField(
                    controller: edtPassword,
                    obscureText: true,
                    validator: (value) =>
                        value == '' ? "Password required" : null,
                    decoration: InputDecoration(
                      fillColor: Colors.white,
                      filled: true,
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      isDense: true,
                      hintText: 'Password',
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Tombol untuk melakukan login
                  ElevatedButton(
                    onPressed: () {
                      login(
                          context); // Memanggil fungsi login saat tombol ditekan
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[800],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Login'),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
