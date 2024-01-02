import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

// const BASE_URL = "http://127.0.0.1:8000/api/";
// const BASE_URL = "http://192.168.247.146/api/";
const BASE_URL = "http://192.168.174.146/api/";

class Api {
  //Api Login peserta
  static Future<Map<String, dynamic>> getLogin(
      String username, String password) async {
    try {
      var response = await http.post(Uri.parse(BASE_URL + "login-peserta"),
          body: {
            'username': username,
            'password': password
          }).timeout(Duration(seconds: 15));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)['data'];
        final id = data['peserta']['id'];
        ;
        final name = data['peserta']['nama'];
        final asal = data['peserta']['asal'];
        final asal_sekolah = data['peserta']['asal_sekolah'];
        final no_hp = data['peserta']['no_hp'];
        final tgl_mulai = data['peserta']['tgl_mulai'];
        final pembimbing = data['peserta']['pembimbing']['nama'];

        return {
          'id': id,
          'name': name,
          'asal': asal,
          'asal_sekolah': asal_sekolah,
          'no_hp': no_hp,
          'tgl_mulai': tgl_mulai,
          'pembimbing': pembimbing
        };
      } else {
        print("Failed to fetch data: ${response.statusCode}");
        throw Exception("Failed to fetch data");
      }
    } on TimeoutException catch (e) {
      throw e;
    } on Exception catch (e) {
      throw e;
    }
  }

  static Future<List<Map<String, dynamic>>> getPeserta() async {
    var response = await http.get(Uri.parse(BASE_URL + 'peserta'));
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(json.decode(response.body));
    } else {
      throw Exception('Failed to load data from API');
    }
  }

  static Future<List<Map<String, dynamic>>> getListPembimbing() async {
    var response = await http.get(Uri.parse(BASE_URL + 'pembimbing'));
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(json.decode(response.body)['data']);
    } else {
      throw Exception('Failed to load data from API');
    }
  }

  //API list pembimbing
  static Future<List<Map<String, dynamic>>> getPembimbing() async {
    try {
      var response = await http.get(Uri.parse(BASE_URL + "pembimbing"));
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body)['data'];
        List<Map<String, dynamic>> pembimbings = [];
        if (data != null) {
          for (var item in data) {
            pembimbings.add({
              'id': item['id'].toString(),
              'nama': item['nama'],
            });
          }
          return pembimbings;
        }
      } else {
        print("Failed to fetch data: ${response.statusCode}");
      }
    } catch (e) {
      throw (e);
    }
    return [];
  }

  //API Absen Masuk
  static Future<http.Response> absensiMasuk(
      int idPeserta,
      String password,
      String formattedTime,
      String formattedDate,
      String coordinat,
      String alamat) async {
    try {
      var response =
          await http.post(Uri.parse(BASE_URL + 'presensi-masuk'), body: {
        'id_peserta': idPeserta.toString(),
        'password': password,
        'jam_masuk': formattedTime,
        'tgl_masuk': formattedDate,
        'coordinat': coordinat,
        'alamat': alamat,
      });
      return response;
    } catch (e) {
      rethrow;
    }
  }

  //API keterangan absen masuk
  static Future<List<dynamic>> getMasuk(int id) async {
    var response = await http.get(Uri.parse(BASE_URL + 'masuk?id_peserta=$id'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load data from API');
    }
  }

  //API Absen Pulang
  static Future<http.Response> absensiPulang(int idPeserta, String password,
      String formattedTime, String formattedDate, String coordinat,
      String alamat) async {
    try {
      var response =
          await http.post(Uri.parse(BASE_URL + 'presensi-pulang'), body: {
        'id_peserta': idPeserta.toString(),
        'password': password,
        'jam_pulang': formattedTime,
        'tgl_pulang': formattedDate,
        'coordinat': coordinat,
        'alamat': alamat,
      });
      return response;
    } catch (e) {
      rethrow;
    }
  }

  //API keterangan absen pulang
  static Future<List<dynamic>> getPulang(int id) async {
    var response =
        await http.get(Uri.parse(BASE_URL + 'pulang?id_peserta=$id'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load data from API');
    }
  }

  //API Pekerjaan
  static Future<http.Response> judulProgress(
      int idPeserta, String judul) async {
    try {
      var response =
          await http.post(Uri.parse(BASE_URL + 'tambah-judul'), body: {
        'id_peserta': idPeserta.toString(),
        'judul': judul,
      });
      return response;
    } catch (e) {
      rethrow;
    }
  }

  //API listJudul
  static Future<List<Map<String, dynamic>>> getJudul() async {
    try {
      final response = await http.get(Uri.parse(BASE_URL + 'judul'));
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        if (data is List) {
          return data.cast<Map<String, dynamic>>();
        } else {
          throw Exception("Response is not a List");
        }
      } else {
        throw Exception(
            "Failed to load data, status code: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Failed to load data: $e");
    }
  }

  //API tambah Progress
  static Future<http.Response> tambahProgress(
      String idPekerjaan,
      String catatan,
      String trainer_pembimbing,
      String trainer_peserta,
      XFile? image,
      ) async {
    var url = Uri.parse(BASE_URL + 'tambah-progress');
    var request = http.MultipartRequest('POST', url);
    request.fields['id_pekerjaan'] = idPekerjaan;
    request.fields['catatan'] = catatan;
    request.fields['trainer_pembimbing'] = trainer_pembimbing;
    request.fields['trainer_peserta'] = trainer_peserta;

    if (image != null) {
      var imageFile = await http.MultipartFile.fromPath('foto_dokumentasi', image.path);
      request.files.add(imageFile);
    }

    try {
      var response = await request.send();
      var responseData = await response.stream.toBytes();
      var responseString = String.fromCharCodes(responseData);
      return http.Response(responseString, response.statusCode);
    } catch (error) {
      print('Error in tambahProgress: $error');
      throw error;
    }
  }

  //API List Progress
  static Future<List<dynamic>> getDataProgress() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int idPeserta = prefs.getInt('id') ?? 0;
    try {
      var response = await http
          .get(
            Uri.parse(BASE_URL + 'progress/$idPeserta'),
          )
          .timeout(Duration(seconds: 15));

      if (response.statusCode == 200) {
        List<dynamic> jsonResponse = json.decode(response.body);
        List<dynamic> filteredList = [];
        if (jsonResponse != null) {
          filteredList = jsonResponse
              .where((progress) =>
                  progress['pekerjaan'] != null &&
                  progress['pekerjaan']['id_peserta'] == idPeserta)
              .toList();
        }
        return filteredList;
      } else {
        return [];
      }
    } on TimeoutException catch (e) {
      throw e;
    } on Exception catch (e) {
      throw e;
    }
  }

  //API List Progress
  static Future<List<dynamic>> getProgress(int idPeserta) async {
    try {
      var response = await http
          .get(
        Uri.parse(BASE_URL + 'progress/$idPeserta'),
      )
          .timeout(Duration(seconds: 15));

      if (response.statusCode == 200) {
        List<dynamic> jsonResponse = json.decode(response.body);
        List<dynamic> filteredList = [];
        if (jsonResponse != null) {
          filteredList = jsonResponse
              .where((progress) =>
          progress['pekerjaan'] != null &&
              progress['pekerjaan']['id_peserta'] == idPeserta)
              .toList();
        }
        return filteredList;
      } else {
        return [];
      }
    } on TimeoutException catch (e) {
      throw e;
    } on Exception catch (e) {
      throw e;
    }
  }

  //API all progress peserta
  static Future<List<dynamic>> getAllProgress() async {
    try {
      final response = await http.get(Uri.parse(BASE_URL + "progress"));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      throw Exception('Failed to load progress');
    } catch (e) {
      print(e);
      throw Exception('Failed to load progress');
    }
  }

  //API update Approve progress
  static Future<void> updateStatus(int id, String peserta_approve) async {
    var url = Uri.parse(BASE_URL + 'progress/$id/update-approve');
    var headers = {
      "Content-type": "application/json",
    };
    var body = json.encode({'peserta_approve': peserta_approve});

    try {
      var response = await http.put(url, headers: headers, body: body);
      // Handle the response if needed
    } catch (e) {
      print('Terjadi kesalahan: $e');
      // Handle the error if needed
    }
  }
  
  //API piket peserta
  static Future<Map<String, dynamic>> getPiket() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int idPeserta = prefs.getInt('id') ?? 0;

    try {
      final response = await http.get(Uri.parse(BASE_URL + "piket/$idPeserta")).timeout(Duration(seconds: 15));
      if (response.statusCode == 200) {
        // Decode the JSON response and return it
        return jsonDecode(response.body);
      } else {
        // If the status code is not 200, you might want to handle this case
        print("Failed to fetch data. Status code: ${response.statusCode}");
        return {}; // or throw an exception, depending on your use case
      }
    } catch (e) {
      // Handle any exceptions that occurred during the request
      print("Error: $e");
      return {}; // or throw an exception, depending on your use case
    }
  }

  //API Piket
  static Future<dynamic> getAllPiket() async {
    var response = await http.get(
        Uri.parse(BASE_URL + 'piket'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);

    } else {
      throw Exception('Failed to load data');
    }
  }

  //API Keterangan
  static Future<void> addKeterangan(
      int idPeserta, String keterangan, String catatan) async {
    try {
      var response = await http.post(
        Uri.parse(BASE_URL + "keterangan"),
        body: {
          'id_peserta': idPeserta.toString(),
          'keterangan': keterangan,
          'catatan': catatan,
        },
      ).timeout(Duration(seconds: 15));

      if (response.statusCode == 201) {
        print('Data berhasil ditambahkan');
        print(response.body);
      } else {
        throw Exception(
            'Gagal menambahkan data. Status code: ${response.statusCode}');
      }
    } on TimeoutException catch (e) {
      throw e;
    } on Exception catch (e) {
      throw e;
    }
  }

  static Future<void> updateProgress(String progressId, String catatan, File? imageFile) async {
    try {
      var uri = Uri.parse('http://192.168.174.146/api/progress/$progressId/update-progress');

      var request = http.MultipartRequest('POST', uri);
      request.fields['catatan'] = catatan;

      if (imageFile != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'foto_dokumentasi',
          imageFile.path,
        ));
      }

      var response = await request.send();

      if (response.statusCode == 200) {
        print('Progress updated successfully');
      } else {
        print('Failed to update progress. Status code: ${response.statusCode}');
        print('Response body: ${await response.stream.bytesToString()}');
      }
    } catch (e) {
      print('Exception during progress update: $e');
    }
  }
}

