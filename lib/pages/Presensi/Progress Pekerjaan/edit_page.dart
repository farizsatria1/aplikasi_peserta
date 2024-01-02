import 'dart:io';
import 'package:absensi_magang/navbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import '../../../Api/api.dart';
import '../../../Widget/color.dart';

class EditProgress extends StatefulWidget {
  const EditProgress({super.key, required this.id, required this.image, required this.catatan});
  final String id;
  final String image;
  final String catatan;

  @override
  State<EditProgress> createState() => _EditProgressState();
}

class _EditProgressState extends State<EditProgress> {
  late TextEditingController catatan;
  final ImagePicker _picker = ImagePicker();
  XFile? _imageFile;

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      try {
        var result = await FlutterImageCompress.compressAndGetFile(
          pickedFile.path,
          pickedFile.path + "_compressed.jpg",
          quality: 80,
        );

        setState(() {
          _imageFile = result;
        });
      } catch (error) {
        print("Error compressing image: $error");
      }
    }
  }

  Future<void> updateProgress(String progressId) async {
    try {
      await Api.updateProgress(progressId, catatan.text, _imageFile != null ? File(_imageFile!.path) : null);

    } catch (e) {
      Navigator.of(context);
      print('Exception during progress update: $e');
    }
  }


  @override
  void initState() {
    super.initState();
    catatan = TextEditingController(text: widget.catatan);
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Edit Progress",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: AppColor.biru1,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 20),
              const Text(
                "Catatan",
                // Menggunakan nilai nama dari widget
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 10),
              Container(
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
                    hintStyle: TextStyle(
                      color: Colors.grey.shade500,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              const Text(
                "Dokumentasi",
                // Menggunakan nilai nama dari widget
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () {
                  _pickImage(); // Panggil metode untuk memilih gambar
                },
                child: Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.grey.shade300,
                    image: _imageFile != null
                        ? DecorationImage(
                      image: FileImage(File(_imageFile!.path)),
                      fit: BoxFit.cover,
                    )
                        : DecorationImage(
                      image: NetworkImage(widget.image),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 25),
              Center(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.3,
                  height: MediaQuery.of(context).size.height * 0.06,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(15),
                      backgroundColor: AppColor.biru1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)
                      ),
                    ),
                    onPressed: () async {
                      await updateProgress(widget.id);
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => NavBar(selectedIndex: 1),));
                    },
                    child: const Text('Simpan'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
