import 'package:absensi_magang/Widget/fullscreen_photo.dart';
import 'package:absensi_magang/Widget/url.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../Api/api.dart';
import 'color.dart';

class HariIni extends StatelessWidget {
  const HariIni({super.key, required this.listProgressHariIni});

  final List listProgressHariIni;

  @override
  Widget build(BuildContext context) {
    initializeDateFormatting('id_ID', null);
    return FutureBuilder(
      future: Api.getDataProgress(),
      builder: (context, snapshoot) {
        if (snapshoot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(color: AppColor.biru1),
          );
        } else {
          if (listProgressHariIni.isEmpty) {
            return const Center(
              child: Text(
                "Hari ini tidak ada progress",
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
            );
          } else {
            return ListView.builder(
              padding: const EdgeInsets.only(top: 10),
              itemCount: listProgressHariIni.length,
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
                                                  gambar: ApiConstants.BASE_URL +
                                                          listProgressHariIni[
                                                                  index][
                                                              "foto_dokumentasi"] ??
                                                      "",
                                                )),
                                      );
                                    },
                                    child: Image.network(
                                      ApiConstants.BASE_URL +
                                              listProgressHariIni[index]
                                                  ["foto_dokumentasi"] ??
                                          "",
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
                                    listProgressHariIni[index]["pekerjaan"]
                                        ["judul"],
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  listProgressHariIni[index]["pembimbing"] ==
                                          null
                                      ? Text(
                                          "Trainer : " +
                                              (listProgressHariIni[index]
                                                  ["peserta"]["nama"]),
                                          style: const TextStyle(
                                            color: Colors.grey,
                                            fontSize: 14,
                                          ),
                                        )
                                      : Text(
                                          "Trainer : " +
                                              (listProgressHariIni[index]
                                                  ["pembimbing"]["nama"]),
                                          style: const TextStyle(
                                            color: Colors.grey,
                                            fontSize: 14,
                                          ),
                                        ),
                                  Text(
                                    DateFormat('dd MMMM yyyy', 'id_ID').format(
                                        DateTime.parse(
                                            listProgressHariIni[index]
                                                ["created_at"])),
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  Text(
                                    listProgressHariIni[index]["catatan"],
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
                            listProgressHariIni[index]["pekerjaan"]["judul"],
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
                                    listProgressHariIni[index]["created_at"])),
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 10),
                        ],
                      ),
                      subtitle: Text(
                        listProgressHariIni[index]["catatan"],
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: Container(
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
                                    listProgressHariIni[index]
                                        ["foto_dokumentasi"] ??
                                "",
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
                    ),
                  ),
                );
              },
            );
          }
        }
      },
    );
  }
}
