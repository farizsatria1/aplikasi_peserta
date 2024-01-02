import 'package:absensi_magang/navbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api/api.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<void> login() async {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(color: Colors.black),
        );
      },
    );
    try {
      var data = await Api.getLogin(usernameController.text, passwordController.text);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('id', data['id']);
      await prefs.setString('name', data['name']);
      await prefs.setString('asal', data['asal']);
      await prefs.setString('asal_sekolah', data['asal_sekolah']);
      await prefs.setString('tgl_mulai', data['tgl_mulai']);
      await prefs.setString('pembimbing', data['pembimbing']);

      //Dalam perintah ini, maka halaman Login akan dihapus pda Back stap, sehingga
      //ketika berhasil Login, saat tombol Back ditekan maka tidak akan kembali lagi
      Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => NavBar(selectedIndex: 0),),
    (Route<dynamic> route) => false );
    } catch (e) {
      Navigator.pop(context);
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.grey.shade300,
            title: const Text('Login Gagal',style: TextStyle(fontWeight: FontWeight.bold)),
            content: const Text('Username atau Password salah. Silakan coba lagi.'),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Tutup'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
      throw (e);
    }
  }

  Future<void> checkIfLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (
        prefs.containsKey('id') &&
        prefs.containsKey('name') &&
        prefs.containsKey('asal') &&
        prefs.containsKey('asal_sekolah') &&
        prefs.containsKey('tgl_mulai') &&
        prefs.containsKey('pembimbing')
    ) {
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => NavBar(selectedIndex: 0),));
    } else {

    }
  }

  @override
  void initState() {
    checkIfLoggedIn();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                const SizedBox(height: 50),
                Image.asset(
                  "images/lauwba.png",
                  width: 150,
                  height: 150,
                ),
                const SizedBox(height: 50),
                const Text(
                  "Selamat Datang Kembali Peserta Magang \n "
                      "PT.Lauwba Techno Indonesia",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 25),
                MyTextField(
                  theController: usernameController,
                  obscureText: false,
                  hintText: "Username",
                ),
                const SizedBox(height: 25),
                MyTextField(
                  theController: passwordController,
                  obscureText: true,
                  hintText: "Password",
                ),
                const SizedBox(height: 40),
                Container(
                  height: 60,
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 25),
                  decoration: const BoxDecoration(),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(20),
                      backgroundColor: Colors.blueAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      "Log In",
                      style:
                      TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    onPressed: () {
                      login();
                    },
                  ),
                ),
                const SizedBox(height: 40)
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MyTextField extends StatelessWidget {
  final TextEditingController theController;
  final String hintText;
  final bool obscureText;

  const MyTextField({
    Key? key,
    required this.theController,
    required this.hintText,
    required this.obscureText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: TextField(
        obscureText: obscureText,
        controller: theController,
        decoration: InputDecoration(
            enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey.shade400),
            ),
            filled: true,
            fillColor: Colors.grey.shade200,
            hintText: hintText,
            hintStyle: TextStyle(color: Colors.grey.shade500)),
      ),
    );
  }
}
