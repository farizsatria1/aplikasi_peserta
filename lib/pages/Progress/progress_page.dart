import 'dart:async';
import 'package:absensi_magang/Widget/color.dart';
import 'package:absensi_magang/Widget/ditolak.dart';
import 'package:absensi_magang/pages/Progress/Cetak/cetak.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../Widget/kemarin.dart';
import '../../Widget/recap.dart';
import '../../api/api.dart';
import '../../Widget/hari_ini.dart';

class ProgressPage extends StatefulWidget {
  const ProgressPage({Key? key}) : super(key: key);

  @override
  State<ProgressPage> createState() => _ProgressPageState();
}

class _ProgressPageState extends State<ProgressPage> {
  List<dynamic> listProgressHariIni = [];
  List<dynamic> listProgressKemarin = [];
  List<dynamic> listProgressAll = [];

  Future<void> getProgress() async {
    List<dynamic> filteredList = await Api.getDataProgress();
    if (filteredList.isNotEmpty) {
      String targetDate =
          filteredList.last["created_at"].toString().split('T')[0];
      filteredList = filteredList
          .where((element) =>
              element["created_at"].toString().split('T')[0] == targetDate)
          .toList();
    }
    setState(() {
      listProgressHariIni = filteredList;
    });
  }

  Future<void> getProgressKemarin() async {
    List<dynamic> filteredList = await Api.getDataProgress();
    if (filteredList.isNotEmpty) {
      DateTime now = DateTime.now();
      DateTime yesterday =
          DateTime(now.year, now.month, now.day).subtract(const Duration(days: 1));
      String yesterdayDate = yesterday.toIso8601String().split('T')[0];
      filteredList = filteredList
          .where((element) =>
              element["created_at"].toString().split('T')[0] == yesterdayDate)
          .toList();
    }
    setState(() {
      listProgressKemarin = filteredList;
    });
  }

  Future<void> getAllProgress() async {
    try {
      final response = await Api.getDataProgress();
      setState(() {
        listProgressAll = response;
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();
    getProgress();
    getProgressKemarin();
    getAllProgress();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Pogress Peserta",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: AppColor.biru1,
        elevation: 0,
        actions: [
          TextButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CetakProgress(),
                ),
              );
            },
            icon: const Icon(Icons.print, color: Colors.white),
            label: const Text("Cetak", style: TextStyle(color: Colors.white)),
          )
        ],
      ),
      body: SafeArea(
        child: DefaultTabController(
          length: 4, // Jumlah tab
          child: Column(
            children: [
              const TabBar(
                indicatorColor: Colors.black,
                labelColor: Colors.black,
                unselectedLabelColor: Colors.grey,
                tabs: [
                  Tab(text: 'Hari Ini'),
                  Tab(text: 'Kemarin'),
                  Tab(text: 'Recap'),
                  Tab(text: 'Ditolak'),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    // Tampilan konten untuk tab 'Hari Ini'
                    HariIni(listProgressHariIni: listProgressHariIni),
                    // Tampilan konten untuk tab 'Kemarin'
                    Kemarin(listProgressKemarin: listProgressKemarin),
                    // Tampilan konten untuk tab 'Recap'
                    AllProgress(listProgressAll: listProgressAll),
                    // Tampilan konten untuk tab 'Ditolak'
                    Ditolak(ditolak: listProgressAll),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
