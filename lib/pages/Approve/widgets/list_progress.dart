import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../Api/api.dart';
import '../../../Widget/color.dart';
import '../../../Widget/fullscreen_photo.dart';
import '../../../Widget/url.dart';

class ListProgress extends StatefulWidget {
  final List listProgress;
  final Function refresh;

  const ListProgress(
      {super.key, required this.listProgress, required this.refresh});

  @override
  State<ListProgress> createState() => _ListProgressState();
}

class _ListProgressState extends State<ListProgress> {
  late SharedPreferences prefs;

  Future<void> initializeSharedPreferences() async {
    prefs = await SharedPreferences.getInstance();
  }

  void updateStatus(int id, String peserta_approve) async {
    try {
      await Api.updateStatus(id, peserta_approve);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          duration: Duration(seconds: 2),
          content: Text(
            "Data berhasil di Approve",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print('Terjadi kesalahan: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          duration: Duration(seconds: 2),
          content: Text(
            "Data berhasil di Approve",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('id_ID', null);
    initializeSharedPreferences();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: widget.refresh(),
      builder: (context, snapshoot) {
        if (snapshoot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(color: AppColor.biru1),
          );
        } else {
          if (widget.listProgress.isEmpty) {
            return const Center(
              child: Text(
                "Tidak ada progress",
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
            );
          } else {
            var dataProgress = widget.listProgress.where((element) {
              return element['status'] == '1' &&
                  element['peserta_approve'] == '0';
            }).toList();

            if (dataProgress.isEmpty) {
              return const Center(child: Text('Tidak ada data'));
            } else {
              return ListView.builder(
                padding: const EdgeInsets.only(top: 10),
                itemCount: dataProgress.length,
                itemBuilder: (context, index) {
                  return Card(
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: Colors.grey, width: 0.5)),
                      child: ListTile(
                        onTap: () {
                          showModalBottomSheet(
                            shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(20))),
                            useSafeArea: true,
                            isScrollControlled: true,
                            backgroundColor: Colors.white,
                            context: context,
                            builder: (context) {
                              return Container(
                                constraints: BoxConstraints(
                                    maxHeight:
                                        MediaQuery.of(context).size.height *
                                            0.75),
                                padding: const EdgeInsets.all(15),
                                child: ListView(
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  GambarProgress(
                                                    gambar: ApiConstants
                                                                .BASE_URL +
                                                            dataProgress[index][
                                                                "foto_dokumentasi"]
                                                  ),
                                          ),
                                        );
                                      },
                                      child: Image.network(
                                        ApiConstants.BASE_URL +
                                                dataProgress[index]
                                                    ["foto_dokumentasi"],
                                        height: 250,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return const Center(
                                            child: Icon(
                                              CupertinoIcons.photo_fill,
                                              size: 100,
                                              color: Colors.grey,
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    Text(
                                      dataProgress[index]["pekerjaan"]["judul"],
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    dataProgress[index]["pembimbing"] == null
                                        ? Text(
                                            "Trainer : " +
                                                (dataProgress[index]["peserta"]
                                                    ["nama"]),
                                            style: const TextStyle(
                                              color: Colors.grey,
                                              fontSize: 14,
                                            ),
                                          )
                                        : Text(
                                            "Trainer : " +
                                                (dataProgress[index]
                                                    ["pembimbing"]["nama"]),
                                            style: const TextStyle(
                                              color: Colors.grey,
                                              fontSize: 14,
                                            ),
                                          ),
                                    Text(
                                      DateFormat('dd MMMM yyyy', 'id_ID')
                                          .format(DateTime.parse(
                                              dataProgress[index]
                                                  ["created_at"])),
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    Text(
                                      dataProgress[index]["catatan"],
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 15,
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              dataProgress[index]["pekerjaan"]["judul"],
                              style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              DateFormat('dd MMMM yyyy', 'id_ID').format(
                                  DateTime.parse(
                                      dataProgress[index]["created_at"])),
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 10),
                          ],
                        ),
                        subtitle: Text(
                          dataProgress[index]["catatan"],
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 15,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              height: 60,
                              width: 60,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(5),
                                child: Image.network(
                                  ApiConstants.BASE_URL +
                                          dataProgress[index]
                                              ["foto_dokumentasi"],
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Icon(
                                      CupertinoIcons.photo_fill,
                                      size: 30,
                                      color: Colors.grey,
                                    );
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(width: 5),
                            IconButton(
                              icon: const Icon(
                                Icons.check_circle_rounded,
                                color: Colors.green,
                                size: 35,
                              ),
                              onPressed: () {
                                setState(() {
                                  dataProgress[index]["peserta_approve"] =
                                      dataProgress[index]["peserta_approve"] ==
                                              "1"
                                          ? "0"
                                          : "1";
                                });
                                updateStatus(dataProgress[index]["id"],
                                    dataProgress[index]["peserta_approve"]);
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            }
          }
        }
      },
    );
  }
}
