import 'package:absensi_magang/pages/Profile/ganti_password.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Widget/color.dart';
import '../login_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? name;
  String? asal;
  String? asal_sekolah;
  String? tgl_mulai;
  String? nama_pembimbing;
  bool isLoading = false;

  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey.shade300,
          title: const Text('Konfirmasi Log Out',
              style: TextStyle(fontWeight: FontWeight.bold)),
          content: const Text('Apakah Anda yakin ingin Log Out?'),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () async {
                await prefs.remove('id');
                await prefs.remove('name');
                await prefs.remove('asal');
                await prefs.remove('asal_sekolah');
                await prefs.remove('tgl_mulai');
                await prefs.remove('pembimbing');
                Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => LoginScreen()),(route) => false);

              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void loadData() async {
    setState(() {
      isLoading = true; // show loading indicator
    });

    // Simulate a delay of 2 seconds using Future.delayed
    await Future.delayed(const Duration(seconds: 1));

    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      name = prefs.getString('name') ?? "Nama Peserta";
      asal = prefs.getString('asal') ?? "Asal";
      asal_sekolah = prefs.getString('asal_sekolah') ?? "Belum diatur";
      tgl_mulai = prefs.getString('tgl_mulai') ?? "Belum diatur";
      nama_pembimbing = prefs.getString('pembimbing') ?? "Belum diatur";
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    // Load data from shared preferences
    loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: const Text(
          "Profile Peserta",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColor.biru1,
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
              color: Colors.black,
            ))
          : SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 30),
                    child: Center(
                      child: Stack(
                        children: [
                          Container(
                            child: const Column(
                              children: [
                                SizedBox(
                                  width: 100,
                                  height: 100,
                                  child: CircleAvatar(
                                    backgroundColor: Colors.white,
                                    radius: 50,
                                    backgroundImage: AssetImage(
                                      "images/img-default.jpg",
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    name!,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    asal!,
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 30),
                  Container(
                    height: 40,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amberAccent,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                          padding: const EdgeInsets.symmetric(horizontal: 60)),
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const GantiPassword(),
                            ));
                      },
                      child: const Text(
                        "Ganti Password",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  ProfileField(
                    title: "Tanggal Mulai",
                    icon: const Icon(Icons.date_range, color: Colors.white),
                    subtitle: tgl_mulai!,
                  ),
                  ProfileField(
                    title: "Pembimbing",
                    icon: const Icon(Icons.person_add, color: Colors.white),
                    subtitle: nama_pembimbing!,
                  ),
                  ProfileField(
                    title: "Asal Sekolah",
                    icon: const Icon(Icons.date_range, color: Colors.white),
                    subtitle: asal_sekolah!,
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: InkWell(
                      onTap: () {
                        logout();
                      },
                      child: const ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.red,
                          child: Icon(Icons.logout, color: Colors.white),
                        ),
                        title: Text(
                          "LOG OUT",
                          style: TextStyle(
                              color: Colors.red, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class ProfileField extends StatelessWidget {
  final Icon icon;
  final String title;
  final String subtitle;

  const ProfileField({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.black,
            child: icon,
          ),
          title: Text(title),
          subtitle: Text(subtitle, style: const TextStyle(fontSize: 13)),
       ),
    );
  }
}
