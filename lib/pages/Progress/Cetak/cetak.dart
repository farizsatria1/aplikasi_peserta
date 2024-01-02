import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../Widget/color.dart';
import '../../../Widget/url.dart';

class CetakProgress extends StatefulWidget {
  const CetakProgress({Key? key}) : super(key: key);

  @override
  _CetakProgressState createState() => _CetakProgressState();
}

class _CetakProgressState extends State<CetakProgress> {
  String selectedOption = 'All';
  int selectedMonthIndex = 0; // Default month index for January
  late Uri websiteUriAll;
  late Uri websiteUriBulanan;

  List<String> months = [
    '--Pilih Bulan--',
    'Januari', 'Februari', 'Maret', 'April',
    'Mei', 'Juni', 'Juli', 'Agustus',
    'September', 'Oktober', 'November', 'Desember'
  ];

  Future<void> updateUrl() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int idPeserta = prefs.getInt('id') ?? 0;

    setState(() {
      websiteUriAll = Uri.parse("${ApiConstants.cetak}$idPeserta");
      websiteUriBulanan = Uri.parse("${ApiConstants.cetak}bulanan/$idPeserta?bulan=$selectedMonthIndex");
    });
  }

  @override
  void initState() {
    updateUrl();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Cetak Progress",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: AppColor.biru1,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Text(
                  'Pilih Rentang Waktu:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey, width: 1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: DropdownButton<String>(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    borderRadius: BorderRadius.circular(20),
                    underline: const SizedBox(),
                    value: selectedOption,
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedOption = newValue!;
                      });

                      // Reset selectedMonthIndex when 'All' is selected
                      if (newValue == 'All') {
                        selectedMonthIndex = 0; // Reset to default month index for "Pilih Bulan"
                      }
                      updateUrl(); // Update the URL when the option is changed
                    },
                    items: [
                      const DropdownMenuItem<String>(
                        value: 'All',
                        child: Text('All'),
                      ),
                      const DropdownMenuItem<String>(
                        value: 'Bulanan',
                        child: Text('Bulanan'),
                      ),
                    ],
                  ),
                ),
                if (selectedOption == 'Bulanan') ...[
                  const SizedBox(height: 30),
                  const Text(
                    'Pilih Bulan:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey, width: 1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: DropdownButton<String>(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      borderRadius: BorderRadius.circular(20),
                      underline: const SizedBox(),
                      value: months[selectedMonthIndex],
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedMonthIndex = months.indexOf(newValue!);
                        });
                        updateUrl(); // Update the URL when the month is selected
                      },
                      items: months.map((String month) {
                        return DropdownMenuItem<String>(
                          value: month,
                          child: Text(month),
                        );
                      }).toList(),
                    ),
                  ),
                ],
                const SizedBox(height: 30),
                const Icon(Icons.print, color: Colors.black, size: 200),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () {
                    Uri selectedUri = selectedOption == 'Bulanan' ? websiteUriBulanan : websiteUriAll;
                    launchUrl(
                      selectedUri,
                      mode: LaunchMode.externalApplication,
                    );
                  },
                  child: const Text("Cetak"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
