import 'package:absensi_magang/pages/Approve/peserta.dart';
import 'package:absensi_magang/pages/Profile/profile_page.dart';
import 'package:absensi_magang/pages/Presensi/presensi_page.dart';
import 'package:absensi_magang/pages/Progress/progress_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'Widget/color.dart';

class NavBar extends StatefulWidget {
  final int selectedIndex;
  NavBar({required this.selectedIndex});

  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  int selected = 0;

  final List<Widget> pages = [
    const PresensiPage(),
    const ProgressPage(),
    const ListPeserta(),
    const ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    selected = widget.selectedIndex; // Gunakan selectedIndex dari widget
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: pages[selected], // Tampilkan halaman yang sesuai berdasarkan indeks terpilih
        bottomNavigationBar: BottomNavigationBar(
          items: [
            const BottomNavigationBarItem(icon: Icon(Icons.timer),label: "Presensi"),
            const BottomNavigationBarItem(icon: Icon(CupertinoIcons.book_solid),label: "Progress"),
            const BottomNavigationBarItem(icon: Icon(CupertinoIcons.check_mark_circled_solid),label: "Approve"),
            const BottomNavigationBarItem(icon: Icon(Icons.person),label: "Profile"),
          ],
          type: BottomNavigationBarType.fixed,
          currentIndex: selected,
          backgroundColor: AppColor.biru1,
          selectedItemColor: Colors.white,
          unselectedItemColor: AppColor.biru4,
          showUnselectedLabels: true,
          showSelectedLabels: true,
          onTap: (value) {
            setState(() {
              selected = value;
            });
          },
        )
    );
  }
}