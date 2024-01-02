import 'dart:convert';
import 'package:absensi_magang/Widget/alert.dart';
import 'package:absensi_magang/Widget/url.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../login_page.dart';

class GantiPassword extends StatefulWidget {
  const GantiPassword({Key? key}) : super(key: key);

  @override
  State<GantiPassword> createState() => _GantiPasswordState();
}

class _GantiPasswordState extends State<GantiPassword> {
  TextEditingController password = TextEditingController();

  Future<void> updatePassword() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int pesertaId = prefs.getInt('id') ?? 0;

    if (password.text.isEmpty) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertAction(
            title: "Peringatan",
            content: "Password tidak boleh kosong",
            button: () {
              Navigator.pop(context);
            },
          );
        },
      );
      return;
    }

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(color: Colors.black),
        );
      },
    );

    final String newPassword = password.text;
    try {
      final response = await http.put(
        Uri.parse('${ApiConstants.gantiPassword}$pesertaId/update-password'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'password': newPassword}),
      );

      if (response.statusCode == 200) {
        Navigator.pop(context);
        showDialog(
          barrierDismissible: false,
          context: context,
          builder: (context) {
            return AlertAction(
              title: "Berhasil",
              content: "Password berhasil diubah",
              button: () {
                logout();
                Navigator.pop(context);
              },
            );
          },
        );
        print('Password updated successfully');
      } else {
        // Handle other status codes or errors
        print('Failed to update password: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      // Handle exceptions
      print('Exception during password update: $e');
    }
  }

  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey.shade300,
          title: Text('Log Out', style: TextStyle(fontWeight: FontWeight.bold)),
          content: Text('Anda Sudah Log Out, Silahkan Masuk kembali'),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          actions: [
            TextButton(
              onPressed: () async {
                await prefs.remove('id');
                await prefs.remove('name');
                await prefs.remove('asal');
                await prefs.remove('asal_sekolah');
                await prefs.remove('no_hp');
                await prefs.remove('tgl_mulai');
                await prefs.remove('pembimbing');
                Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => LoginScreen()),(Route<dynamic> route) => false);
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.black),
        title: Text(
          "Ganti Password",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(0, 50, 0, 50),
              child: Icon(
                Icons.lock,
                color: Colors.black,
                size: 200,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: TextField(
                obscureText: true,
                controller: password,
                decoration: InputDecoration(
                    enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey.shade400),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade200,
                    hintText: "New Password",
                    hintStyle: TextStyle(color: Colors.grey.shade500)),
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(20),
                backgroundColor: Colors.blueAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () async {
                await updatePassword();
              },
              child: Text(
                'Simpan',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
