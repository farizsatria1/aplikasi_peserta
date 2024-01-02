import 'package:absensi_magang/Widget/alert.dart';
import 'package:absensi_magang/Widget/color.dart';
import 'package:absensi_magang/pages/Presensi/Progress%20Pekerjaan/judul_progress.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../api/api.dart';
import '../absen_pulang.dart';
import 'dart:io';

class ProgressPekerjaan extends StatefulWidget {
  const ProgressPekerjaan({
    Key? key,
  }) : super(key: key);

  @override
  State<ProgressPekerjaan> createState() => _ProgressPekerjaanState();
}

class _ProgressPekerjaanState extends State<ProgressPekerjaan> {
  TextEditingController judul = TextEditingController();
  TextEditingController catatan = TextEditingController();
  TextEditingController password = TextEditingController();
  late Map<String, dynamic> pulangData = {};
  late Map<String, dynamic> judulProgress = {};
  bool isAbsenHariIni = false;
  String selectedJudul = ""; // Penyimpanan pembimbing terpilih
  String selectedTrainer = ""; // Penyimpanan trainer terpilih
  List<Map<String, dynamic>> judulList = [];
  List<Map<String, dynamic>> pesertaList = [];
  List<Map<String, dynamic>> pembimbingList = [];
  final ImagePicker _picker = ImagePicker();
  XFile? _imageFile;
  String strLatLong = '';
  String strAlamat = '';
  bool isPembimbingSelected = false;
  bool isPesertaSelected = false;
  int selectedTrainerId = 0;
  int? currentParticipantId;

  Future<void> selectImage() async {
    XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      var result = await FlutterImageCompress.compressAndGetFile(
        // path dari gambar asli
        image.path,

        // path di mana gambar yang dikompresi harus disimpan
        image.path + "_compressed.jpg",

        // kualitas dari gambar yang dikompresi
        quality: 80,
      );
      setState(() {
        _imageFile = XFile(result!.path);
      });
    }
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
            barrierDismissible: false,
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
        var response = await Api.absensiPulang(idPeserta, password.text,
            formattedTime, formattedDate, strLatLong, strAlamat);

        if (response.statusCode == 200) {
          print('Data berhasil terkirim');
          Navigator.pop(context);
          showDialog(
            context: context,
            builder: (context) {
              return AlertAction(
                title: "Berhasil",
                content: "Anda sudah absen hari ini",
                button: () {
                  password.clear();
                  Navigator.pop(context);
                },
              );
            },
          );
          setState(() {
            isAbsenHariIni =
                true; // Set isAbsenHariIni menjadi true setelah mengisi absen
          });
        } else {
          print('Gagal mengirim data. Status code: ${response.statusCode}');
          print('Response: ${response.body}');
          Navigator.pop(context);
          showDialog(
            context: context,
            builder: (context) {
              return AlertAction(
                title: "Gagal",
                content: "Periksa kembali password anda",
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

  Future<void> submitJudul() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int? idPeserta = prefs.getInt('id');
      if (idPeserta != null) {
        showDialog(
          barrierDismissible: false,
          context: context,
          builder: (context) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          },
        );
        await Api.judulProgress(idPeserta, judul.text);
        await getJudul();
        Navigator.pop(context); // Tutup dialog loading
        showDialog(
          context: context,
          builder: (context) {
            return AlertAction(
              title: "Berhasil",
              content: "Judul berhasil ditambahkan",
              button: () {
                judul.clear();
                Navigator.pop(context);
              },
            );
          },
        );
      } else {
        print('ID Peserta tidak ditemukan');
      }
    } catch (e) {
      print('Error: $e');
      // Tampilkan pesan kesalahan jika ada
      showDialog(
        context: context,
        builder: (context) {
          return AlertAction(
            title: "Gagal",
            content: "Terjadi kesalahan saat menambahkan Judul",
            button: () {
              Navigator.pop(context);
            },
          );
        },
      );
    }
  }

  Future<void> getJudul() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int? idPeserta = prefs.getInt('id');
      if (idPeserta != null) {
        List<Map<String, dynamic>> data = await Api.getJudul();
        List<Map<String, dynamic>> filteredData = data
            .where((element) => element['id_peserta'] == idPeserta)
            .toList();
        setState(() {
          judulList = filteredData;
        });
      } else {
        print('ID Peserta tidak ditemukan');
      }
    } catch (e) {
      throw (e);
    }
  }

  Future<void> getProgress() async {
    if (catatan.text.isEmpty || selectedJudul.isEmpty || _imageFile == null) {
      // Tampilkan dialog jika ada kolom yang kosong
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertAction(
            title: "Gagal",
            content: "Mohon isi semua kolom",
            button: () {
              Navigator.pop(context);
            },
          );
        },
      );
      return;
    } else {
      try {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        int? idPeserta = prefs.getInt('id');
        if (idPeserta != null) {
          showDialog(
            barrierDismissible: false,
            context: context,
            builder: (context) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.white),
              );
            },
          );
          String idPekerjaan = judulList
              .firstWhere((element) => element['judul'] == selectedJudul)['id']
              .toString();

          var response;

          if (isPembimbingSelected) {
            response = await Api.tambahProgress(
              idPekerjaan,
              catatan.text,
              selectedTrainerId.toString(), // Pembimbing ID
              '', // Peserta ID (null because Pembimbing is selected)
              _imageFile,
            );
          } else {
            response = await Api.tambahProgress(
              idPekerjaan,
              catatan.text,
              '', // Pembimbing ID (null because Peserta is selected)
              selectedTrainerId.toString(), // Peserta ID
              _imageFile,
            );
          }

          Navigator.pop(context); // Tutup dialog loading

          if (response.statusCode == 201) {
            // Tindakan setelah berhasil memanggil API
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) {
                return AlertAction(
                  title: "Berhasil",
                  content: "Progress berhasil ditambahkan",
                  button: () {
                    selectedJudul = "";
                    catatan.clear();
                    selectedTrainerId = 0;
                    setState(() {
                      _imageFile =
                          null; // Reset _imageFile setelah berhasil mengirim
                    });
                    Navigator.pop(context);
                  },
                );
              },
            );
          } else {
            // Tindakan jika gagal memanggil API
            print('Gagal mengirim data. Status code: ${response.statusCode}');
            print('Response: ${response.body}');
            showDialog(
              context: context,
              builder: (context) {
                return AlertAction(
                  title: "Gagal",
                  content: "Gagal mengirim data",
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
      } catch (e) {
        print('Error: $e');
        // Tampilkan pesan kesalahan jika ada
        showDialog(
          context: context,
          builder: (context) {
            return AlertAction(
              title: "Gagal",
              content: "Terjadi kesalahan saat mengirim progress",
              button: () {
                Navigator.pop(context);
              },
            );
          },
        );
      }
    }
  }

  Future<void> getPesertaList() async {
    try {
      final data = await Api.getPeserta();

      SharedPreferences prefs = await SharedPreferences.getInstance();
      currentParticipantId = prefs.getInt('id'); // Get the ID of the currently logged-in participant

      setState(() {
        pesertaList = List<Map<String, dynamic>>.from(data)
            .where((participant) => participant['id'] != currentParticipantId)
            .toList();
      });
    } catch (e) {
      print('Error mengambil daftar trainer: $e');
    }
  }

  Future<void> getPembimbingList() async {
    try {
      final data = await Api.getListPembimbing();

      setState(() {
        pembimbingList = List<Map<String, dynamic>>.from(data);
      });
    } catch (e) {
      print('Error mengambil daftar pembimbing: $e');
    }
  }

  Future _getGeoLocationPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return const AlertDialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          content: Column(
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
          ),
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

  @override
  void initState() {
    getJudul();
    getPesertaList();
    getPembimbingList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColor.biru1,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        title: const Text(
          "Progress Pekerjaan",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Container(
                        color: Colors.grey.shade200,
                        child: DropdownButton<String>(
                          padding: const EdgeInsets.only(left: 10),
                          value: selectedJudul.isNotEmpty &&
                                  judulList.any((element) =>
                                      element['judul'] == selectedJudul)
                              ? selectedJudul
                              : null,
                          hint: Text('Pilih Judul',
                              style: TextStyle(color: Colors.grey.shade500)),
                          underline: const SizedBox(),
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedJudul = newValue!;
                            });
                          },
                          isExpanded: true,
                          items: judulList.map<DropdownMenuItem<String>>(
                              (Map<String, dynamic> value) {
                            return DropdownMenuItem<String>(
                              value: value['judul'],
                              child: Text(value['judul']),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: AppColor.biru1,
                    ),
                    child: IconButton(
                      padding: const EdgeInsets.all(0),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return PopUpJudul(
                              controller: judul,
                              tombol: () {
                                submitJudul();
                                Navigator.pop(context);
                              },
                            );
                          },
                        );
                      },
                      icon: const Icon(Icons.add, color: Colors.white),
                    ),
                  )
                ],
              ),
            ),

            Row(
              children: [
                const SizedBox(width: 5),
                Row(
                  children: [
                    // Checkbox untuk "Pembimbing"
                    SizedBox(
                      width: 50,
                      child: Checkbox(
                        value: isPembimbingSelected,
                        onChanged: (value) {
                          setState(() {
                            isPembimbingSelected = value!;
                            isPesertaSelected = !value; // Unselect Peserta if Pembimbing is selected
                            selectedTrainer = ""; // Reset selected trainer
                          });
                        },
                      ),
                    ),
                    const Text("Pembimbing"),
                  ],
                ),

                // Checkbox for "Peserta"
                Row(
                  children: [
                    SizedBox(
                      width: 50,
                      child: Checkbox(
                        value: isPesertaSelected,
                        onChanged: (value) {
                          setState(() {
                            isPesertaSelected = value!;
                            isPembimbingSelected = !value; // Unselect Pembimbing if Peserta is selected
                            selectedTrainer = ""; // Reset selected trainer
                          });
                        },
                      ),
                    ),
                    const Text("Peserta"),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Trainer Dropdown
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                color: Colors.grey.shade200,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            color: Colors.grey.shade200,
                            child: DropdownButton<int>(
                              padding: const EdgeInsets.only(left: 10),
                              value: selectedTrainerId != 0
                                  ? selectedTrainerId
                                  : null,
                              hint: Text(
                                isPembimbingSelected
                                    ? 'Pilih Trainer Pembimbing'
                                    : 'Pilih Trainer Peserta',
                                style: TextStyle(color: Colors.grey.shade500),
                              ),
                              underline: const SizedBox(),
                              onChanged: (int? newValue) {
                                setState(() {
                                  selectedTrainerId = newValue!;
                                });
                              },
                              isExpanded: true,
                              items: isPembimbingSelected
                                  ? pembimbingList.map<DropdownMenuItem<int>>(
                                      (Map<String, dynamic> value) {
                                    return DropdownMenuItem<int>(
                                      value: value['id'],
                                      child: Text(value['nama']),
                                    );
                                  }).toList()
                                  : pesertaList.map<DropdownMenuItem<int>>(
                                      (Map<String, dynamic> value) {
                                    return DropdownMenuItem<int>(
                                      value: value['id'],
                                      child: Text(value['nama']),
                                    );
                                  }).toList(),
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Card(
                color: Colors.white,
                child: Container(
                  height: 150,
                  color: Colors.grey.shade200,
                  child: TextField(
                    maxLines: null,
                    controller: catatan,
                    decoration: InputDecoration(
                        border: InputBorder.none,
                        filled: true,
                        fillColor: Colors.grey.shade200,
                        hintText: "Catatan",
                        hintStyle: TextStyle(color: Colors.grey.shade500)),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 25),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const Text(
                      "Dokumentasi",
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(width: 5),
                    GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              backgroundColor: Colors.grey.shade300,
                              title: const Text("Pemberitahuan",
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              content: const Text(
                                  "Pastikan Gambar dokumentasi tidak lebih dari 2048px"),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              actions: <Widget>[
                                TextButton(
                                  child: const Text('Ok'),
                                  onPressed: () => Navigator.pop(context),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      child: const Icon(
                        CupertinoIcons.exclamationmark_circle,
                        color: Colors.grey,
                      ),
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(height: 15),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  onTap: () {
                    selectImage();
                  },
                  child: Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.grey.shade300,
                        image: const DecorationImage(
                          image: AssetImage("images/icon-image.png"),
                        )),
                    // Display the selected image here
                    child: _imageFile != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.file(
                              File(_imageFile!.path),
                              fit: BoxFit.cover,
                            ),
                          )
                        : Container(), // Show empty container if no image is selected
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.biru1,
                    padding: const EdgeInsets.symmetric(
                      vertical: 20,
                      horizontal: 25,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onPressed: () {
                    getProgress();
                  },
                  child: const Text(
                    "Simpan",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 17,
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: pulangData.containsKey('jam_pulang') &&
                            pulangData['jam_pulang'] != "__ : __"
                        ? Colors.grey
                        : Colors.red,
                    padding: const EdgeInsets.symmetric(
                      vertical: 20,
                      horizontal: 25,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onPressed: (isAbsenHariIni == true)
                      ? null // nonaktifkan tombol jika sudah absen
                      : (pulangData.containsKey('jam_pulang') &&
                              pulangData['jam_pulang'] != "__ : __")
                          ? () {}
                          : () {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    icon: const Icon(Icons.warning_amber, size: 40),
                                    backgroundColor: Colors.grey.shade300,
                                    title: const Text("Peringatan",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.red)),
                                    content: const Text(
                                        "Anda tidak dapat mengisi Absen lagi jika dilanjutkan,"
                                        "apakah Anda yakin ?",
                                        style: TextStyle(
                                            fontWeight: FontWeight.w500)),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    actions: <Widget>[
                                      TextButton(
                                        child: const Text('Batal'),
                                        onPressed: () => Navigator.pop(context),
                                      ),
                                      TextButton(
                                        child: const Text('Yakin'),
                                        onPressed: () {
                                          Navigator.pop(context);
                                          showDialog(
                                            barrierDismissible: false,
                                            context: context,
                                            builder: (context) {
                                              return PopUpAbsensiPulang(
                                                password_pulang: password,
                                                button_pulang: () async {
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
                                                  Navigator.pop(context);
                                                },
                                              );
                                            },
                                          );
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                  child: const Text(
                    "Pulang",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 17,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30)
          ],
        ),
      ),
    );
  }
}
