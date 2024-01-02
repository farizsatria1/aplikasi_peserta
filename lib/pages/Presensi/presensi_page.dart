import 'dart:async';
import 'package:absensi_magang/Widget/color.dart';
import 'package:alarm/alarm.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../Widget/alert.dart';
import '../../Widget/piket.dart';
import '../../Widget/url.dart';
import '../../api/api.dart';
import 'Progress Pekerjaan/progress_pekerjaan.dart';
import 'absen_masuk.dart';
import 'package:intl/date_symbol_data_local.dart';

class PresensiPage extends StatefulWidget {
  const PresensiPage({Key? key}) : super(key: key);

  @override
  State<PresensiPage> createState() => _PresensiPageState();
}

class _PresensiPageState extends State<PresensiPage> {
  late String name;
  DateTime tanggal_mulai = DateTime.now();
  bool isLoading = false;
  late Map<String, dynamic> masukData = {};
  late Map<String, dynamic> pulangData = {};
  bool isAbsenHariIni = false;
  TextEditingController password = TextEditingController();
  TextEditingController catatan = TextEditingController();
  String? _selectedKeterangan;
  String strLatLong = '';
  String strAlamat = '';
  Map<String, dynamic> jadwalPiket = {};
  late Uri websiteUri;

  String generateAlertContent() {
    if (masukData['jam_masuk'] == "__ : __") {
      return "Anda belum mengambil absen masuk";
    } else {
      return "Anda sudah mengambil absen pulang";
    }
  }

  void loadData() async {
    setState(() {
      isLoading = true;
    });

    await Future.delayed(const Duration(seconds: 1));

    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      name = prefs.getString('name') ?? "Nama Peserta";
      isLoading = false;
    });
  }

  Future<void> submitData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? idPeserta = prefs.getInt('id');

    if (idPeserta != null) {
      try {
        var now = DateTime.now();
        var formattedTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);
        var formattedDate = DateFormat('yyyy-MM-dd').format(now);

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
              child: CircularProgressIndicator(color: Colors.white),
            );
          },
        );
        var response = await Api.absensiMasuk(idPeserta, password.text,
            formattedTime, formattedDate, strLatLong, strAlamat);

        if (response.statusCode == 200) {
          print('Data berhasil terkirim');
          Navigator.pop(context);
          showDialog(
            context: context,
            builder: (context) {
              return AlertAction(
                title: "Berhasil",
                content: "Absen berhasil diambil",
                button: () {
                  password.clear();
                  Navigator.pop(context);
                },
              );
            },
          );
          setState(() {
            isAbsenHariIni =
                true; // Set isAbsenHariIni to true after successful attendance
          });
          await getListMasuk(); // Refresh the data after successful attendance
          await getListPulang();
          setState(() {}); // Update the UI after data refresh

          // Initialize the Alarm service
          await Alarm.init();

          DateTime alarmTime = DateTime(now.year, now.month, now.day, 16, 0);
          // Define your alarm settings
          final alarmSettings = AlarmSettings(
              id: 42,
              dateTime: alarmTime,
              assetAudioPath: 'assets/alarm.mp3',
              loopAudio: true,
              vibrate: true,
              fadeDuration: 3.0,
              enableNotificationOnKill: true,
              notificationTitle: "Absen Pulang",
              notificationBody: "Waktunya mengambil Absen Pulang",
              stopOnNotificationOpen: true,
              androidFullScreenIntent: true);

          await Alarm.setNotificationOnAppKillContent(
              "Absen Pulang", "Waktunya mengambil Absen Pulang");
          // Set the alarm
          await Alarm.set(alarmSettings: alarmSettings);
        } else {
          print('Gagal mengirim data. Status code: ${response.statusCode}');
          print('Response: ${response.body}');
          Navigator.pop(context);
          showDialog(
            context: context,
            builder: (context) {
              return AlertAction(
                title: "Gagal",
                content: "Periksa kembali password Anda",
                button: () {
                  Navigator.pop(context);
                },
              );
            },
          );
        }
      } catch (e) {
        print('Error: $e');
      }
    } else {
      print('ID Peserta tidak ditemukan');
    }
  }

  Future<void> getListMasuk() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int idPengguna = prefs.getInt('id') ??
          0; // Ganti dengan kunci yang sesuai untuk ID pengguna
      List<dynamic> data = await Api.getMasuk(idPengguna);

      if (data.isNotEmpty) {
        setState(() {
          masukData = data
              .last; // Perbarui 'masukData' dengan data terakhir jika tersedia
        });

        DateTime now = DateTime.now();
        if (masukData.containsKey('jam_masuk') &&
            masukData['jam_masuk'] != "__ : __") {
          DateTime lastCheckIn = DateTime.parse(masukData['jam_masuk']);
          if (now.day != lastCheckIn.day) {
            setState(() {
              masukData['jam_masuk'] = "__ : __";
              isAbsenHariIni = false; // Reset variabel isAbsenHariIni
            });
          } else {
            setState(() {
              isAbsenHariIni =
                  true; // Set variabel isAbsenHariIni menjadi true jika sudah melakukan absensi
            });
          }
        } else {
          setState(() {
            isAbsenHariIni =
                false; // Set variabel isAbsenHariIni menjadi false jika belum melakukan absensi
          });
        }
      }
    } catch (e) {
      print('Error saat mengambil data: $e');
    }
  }

  Future<void> getListPulang() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int idPengguna = prefs.getInt('id') ?? 0;
      List<dynamic> data = await Api.getPulang(idPengguna);

      if (data.isNotEmpty) {
        setState(() {
          pulangData = data.last;
        });

        DateTime now = DateTime.now();
        if (pulangData.containsKey('jam_pulang') &&
            pulangData['jam_pulang'] != "__ : __") {
          DateTime lastCheckOut = DateTime.parse(pulangData['jam_pulang']);
          if (now.day != lastCheckOut.day) {
            setState(() {
              pulangData['jam_pulang'] = "__ : __";
              isAbsenHariIni = false;
            });
          } else {
            setState(() {
              isAbsenHariIni = true;
            });
          }
        } else {
          // Reset isAbsenHariIni jika tidak ada data pulang
          setState(() {
            isAbsenHariIni = false;
          });
        }
      } else {
        // Reset isAbsenHariIni jika tidak ada data pulang
        setState(() {
          pulangData = {};
          isAbsenHariIni = false;
        });
      }
    } catch (e) {
      print('Error saat mengambil data absen pulang: $e');
    }
  }

  Future<void> addKeterangan() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? idPeserta = prefs.getInt('id');
    if (idPeserta != null) {
      try {
        if (_selectedKeterangan == null || _selectedKeterangan!.isEmpty) {
          showDialog(
            context: context,
            builder: (context) {
              return AlertAction(
                title: "Gagal",
                content: "Keterangan tidak boleh kosong",
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
              child: CircularProgressIndicator(color: Colors.white),
            );
          },
        );
        await Api.addKeterangan(idPeserta, _selectedKeterangan!, catatan.text);
        Navigator.pop(context); // Tutup dialog sebelumnya
        // Menampilkan dialog sukses atau penanganan sesuai kebutuhan
        showDialog(
          context: context,
          builder: (context) {
            return AlertAction(
              title: "Berhasil",
              content: "Izin berhasil dicatat",
              button: () {
                catatan.clear();
                _selectedKeterangan =
                    null; // Reset nilai _selectedKeterangan menjadi null
                Navigator.pop(context);
              },
            );
          },
        );
      } catch (e) {
        print('Error: $e');
        // Penanganan kasus error sesuai kebutuhan
        Navigator.pop(context);
        showDialog(
          context: context,
          builder: (context) {
            return AlertAction(
              title: "Gagal",
              content: "Anda sudah mengambil Izin",
              button: () {
                Navigator.pop(context);
              },
            );
          },
        );
      }
    } else {
      print('ID Peserta tidak ditemukan');
    }
  }

  Future _getGeoLocationPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              color: Colors.white, // Tetapkan warna menjadi putih
            ),
            SizedBox(height: 16),
            Text(
              'Mendapatkan lokasi...',
              style: TextStyle(color: Colors.white),
            ),
          ],
        );
      },
    );

    serviceEnabled = await Geolocator.isLocationServiceEnabled();

    // Layanan lokasi tidak aktif, hentikan proses
    if (!serviceEnabled) {
      Navigator.pop(context);
      await Geolocator.openLocationSettings();
      return Future.error('Layanan lokasi tidak aktif');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        Navigator.pop(context);
        return Future.error('Izin lokasi ditolak');
      }
    }

    // Izin ditolak selamanya
    if (permission == LocationPermission.deniedForever) {
      Navigator.pop(context);
      return Future.error(
        'Izin lokasi ditolak selamanya, kami tidak dapat mengakses',
      );
    }
    // Lanjutkan mengakses posisi perangkat
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    // Tutup dialog setelah mendapatkan lokasi
    Navigator.pop(context);

    // Handle posisi yang didapat sesuai kebutuhan
    await getAddressFromLongLat(position);
    return position;
  }

  // //getAddress
  Future getAddressFromLongLat(Position position) async {
    List placemarks =
        await placemarkFromCoordinates(position.latitude, position.longitude);
    print(placemarks);

    Placemark place = placemarks[0];
    setState(() {
      strAlamat = '${place.street}, ${place.subLocality}, ${place.locality}, '
          '${place.postalCode}, ${place.country}';
    });
  }

  Future<void> _refreshData() async {
    try {
      print("Refreshing data...");
      await getListMasuk();
      await getListPulang();
      setState(() {
        print("Data refreshed successfully");
      });
    } catch (e) {
      print('Error in _refreshData: $e');
    }
  }

  Future<void> getPiket() async {
    final data = await Api.getPiket();
    setState(() {
      jadwalPiket = data as Map<String, dynamic>;
    });
  }

  Future<void> url() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int idPeserta = prefs.getInt('id') ?? 0;
    setState(() {
      websiteUri = Uri.parse("${ApiConstants.cetakAbsen}$idPeserta");
    });
  }

  @override
  void initState() {
    super.initState();
    url();
    loadData();
    getListMasuk();
    getListPulang();
    getPiket();
  }

  @override
  Widget build(BuildContext context) {
    initializeDateFormatting('id_ID', null);
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Presensi Peserta",
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.w900, fontSize: 20),
        ),
        backgroundColor: AppColor.biru1,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () {
              launchUrl(
                websiteUri,
                mode: LaunchMode.externalApplication,
              );
            },
            icon: const Icon(Icons.print,color: Colors.white),
          )
        ],
      ),
      body: RefreshIndicator(
        color: Colors.black,
        onRefresh: _refreshData,
        child: isLoading
            ? Center(
                child: CircularProgressIndicator(
                  color: AppColor.biru1,
                ),
              )
            : SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Card(
                        color: AppColor.biru1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        elevation: 5,
                        child: Padding(
                          padding: const EdgeInsets.all(15),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Center(
                                child: Text(
                                  name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 23,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Center(
                                child: Text(
                                  "${DateFormat('dd MMMM yyyy', 'id_ID').format(tanggal_mulai)}",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              const Divider(
                                color: Colors.white,
                                thickness: 5,
                              ),
                              const SizedBox(height: 20),
                              TimeAbsensi(
                                status: "Jam Masuk : ",
                                absensi: masukData.containsKey('jam_masuk')
                                    ? masukData['jam_masuk']
                                    : "__ : __",
                              ),
                              const SizedBox(height: 20),
                              TimeAbsensi(
                                status: "Jam Pulang : ",
                                absensi: pulangData.containsKey('jam_pulang')
                                    ? pulangData['jam_pulang']
                                    : "__ : __",
                              ),
                              const SizedBox(height: 30),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  AbsenButton(
                                    text: "Absen Masuk",
                                    color: masukData.containsKey('jam_masuk') &&
                                            masukData['jam_masuk'] != "__ : __"
                                        ? Colors.grey.shade400
                                        : AppColor.biru3,
                                    onPressed: masukData
                                                .containsKey('jam_masuk') &&
                                            masukData['jam_masuk'] != "__ : __"
                                        ? () {
                                            showDialog(
                                              context: context,
                                              builder: (context) {
                                                return AlertAction(
                                                  title: "Pemberitahuan",
                                                  content:
                                                      "Anda sudah mengisi Absen Masuk",
                                                  button: () {
                                                    Navigator.pop(context);
                                                  },
                                                );
                                              },
                                            );
                                          }
                                        : () {
                                            showDialog(
                                              context: context,
                                              builder: (context) {
                                                return PopUpAbsensiMasuk(
                                                  password: password,
                                                  button: () async {
                                                    Position position =
                                                        await _getGeoLocationPosition();
                                                    setState(() {
                                                      strLatLong =
                                                          '${position.latitude}, ${position.longitude}';
                                                      Navigator.pop(context);
                                                    });
                                                    await getAddressFromLongLat(
                                                        position);
                                                    await submitData();
                                                  },
                                                );
                                              },
                                            );
                                          },
                                  ),
                                  const SizedBox(width: 5),
                                  AbsenButton(
                                    text: "Absen Pulang",
                                    color:
                                        (masukData['jam_masuk'] == "__ : __" ||
                                                isAbsenHariIni ||
                                                (pulangData.containsKey(
                                                        'jam_pulang') &&
                                                    pulangData['jam_pulang'] !=
                                                        "__ : __"))
                                            ? Colors.grey.shade400
                                            : AppColor.biru3,
                                    onPressed:
                                        (masukData['jam_masuk'] == "__ : __" ||
                                                isAbsenHariIni ||
                                                (pulangData.containsKey(
                                                        'jam_pulang') &&
                                                    pulangData['jam_pulang'] !=
                                                        "__ : __"))
                                            ? () {
                                                showDialog(
                                                  context: context,
                                                  builder: (context) {
                                                    return AlertAction(
                                                      title: "Pemberitahuan",
                                                      content:
                                                          generateAlertContent(),
                                                      button: () {
                                                        Navigator.pop(context);
                                                      },
                                                    );
                                                  },
                                                );
                                              }
                                            : () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        const ProgressPekerjaan(),
                                                  ),
                                                ).then(
                                                  (value) {
                                                    _refreshData(); // Perbarui data setelah absen pulang berhasil
                                                  },
                                                );
                                              },
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              Center(
                                child: Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 10),
                                  width: double.infinity,
                                  child: OutlinedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColor.biru3,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 25,
                                        horizontal: 20,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                    ),
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) {
                                          return StatefulBuilder(
                                            builder: (BuildContext context,
                                                StateSetter setState) {
                                              return AlertDialog(
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            15)),
                                                backgroundColor:
                                                    Colors.grey.shade200,
                                                actionsPadding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 20,
                                                        vertical: 20),
                                                title: const Align(
                                                  alignment: Alignment.center,
                                                  child: Text(
                                                    "Izin",
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                                content: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Container(
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                              horizontal: 10),
                                                      decoration: BoxDecoration(
                                                        color: Colors.grey
                                                            .shade300, // Tambahkan dekorasi di sini
                                                      ),
                                                      child: DropdownButton<
                                                          String>(
                                                        value:
                                                            _selectedKeterangan,
                                                        underline: const SizedBox(),
                                                        isExpanded: true,
                                                        onChanged:
                                                            (String? newValue) {
                                                          setState(() {
                                                            _selectedKeterangan =
                                                                newValue;
                                                          });
                                                        },
                                                        hint: Text(
                                                          'Pilih Keterangan',
                                                          style: TextStyle(
                                                              color: Colors.grey
                                                                  .shade500),
                                                        ),
                                                        items: <String>[
                                                          'Izin',
                                                          'Sakit'
                                                        ].map((String value) {
                                                          return DropdownMenuItem<
                                                              String>(
                                                            value: value,
                                                            child: Text(value),
                                                          );
                                                        }).toList(),
                                                      ),
                                                    ),
                                                    const SizedBox(height: 10),
                                                    Container(
                                                      height: 150,
                                                      decoration: BoxDecoration(
                                                        color: Colors.grey
                                                            .shade300, // Tambahkan dekorasi di sini
                                                      ),
                                                      child: TextField(
                                                        maxLines: null,
                                                        controller: catatan,
                                                        decoration:
                                                            InputDecoration(
                                                          border:
                                                              InputBorder.none,
                                                          filled: true,
                                                          fillColor: Colors
                                                              .grey.shade300,
                                                          hintText:
                                                              "Catatan (Optional)",
                                                          hintStyle: TextStyle(
                                                              color: Colors.grey
                                                                  .shade500),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                    child: const Text("Batal"),
                                                  ),
                                                  TextButton(
                                                    onPressed: () {
                                                      addKeterangan();
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                    child: const Text("OK"),
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                        },
                                      );
                                    },
                                    child: Text(
                                      "Izin",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: AppColor.biru1,
                                        fontSize: 17,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      Card(
                        color: AppColor.biru1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        elevation: 5,
                        child: Container(
                          margin: const EdgeInsets.all(15),
                          width: double.infinity,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              RichText(
                                text: TextSpan(
                                  text: "Anda piket pada hari : ",
                                  style: const TextStyle(
                                    fontSize: 18,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: jadwalPiket['hari'],
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 10),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const ListPiket(),
                                    ),
                                  );
                                },
                                child: const Text(
                                  "Lihat Selengkapnya",
                                  style: TextStyle(
                                    color: Colors.white,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}

class AbsenButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color color;

  const AbsenButton({
    Key? key,
    required this.text,
    required this.onPressed,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(
          vertical: 25,
          horizontal: 15,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      onPressed: onPressed,
      child: Text(
        text, // Menggunakan variabel 'text' untuk menghindari hardcoded value
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: AppColor.biru1,
          fontSize: 17,
        ),
      ),
    );
  }
}

class TimeAbsensi extends StatelessWidget {
  final String status;
  final String absensi;

  const TimeAbsensi({
    Key? key,
    required this.status,
    required this.absensi,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String formattedAbsensi = "__ : __";
    if (absensi != "__ : __" && absensi.isNotEmpty) {
      try {
        DateTime parsedDate = DateTime.parse(absensi);
        formattedAbsensi = DateFormat('HH:mm').format(parsedDate);
      } catch (e) {
        print("Error formatting date: $e");
      }
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Text(
          status,
          style: const TextStyle(
            fontSize: 22,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          formattedAbsensi,
          style: const TextStyle(
            fontSize: 22,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
