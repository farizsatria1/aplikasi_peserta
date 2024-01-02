import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../Widget/color.dart';
import '../../../Widget/fullscreen_photo.dart';
import '../../../Widget/url.dart';

class ListApprove extends StatefulWidget {
  final List listProgress;
  final Function refresh;

  const ListApprove(
      {super.key, required this.listProgress, required this.refresh});

  @override
  State<ListApprove> createState() => _ListApproveState();
}

class _ListApproveState extends State<ListApprove> {
  late SharedPreferences prefs;

  Future<void> initializeSharedPreferences() async {
    prefs = await SharedPreferences.getInstance();
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
          var dataProgress = widget.listProgress.where((element) {
            int idPeserta = prefs.getInt('id') ?? 0;
            return element['status'] == '1' &&
                element['trainer_peserta'] == idPeserta &&
                element['peserta_approve'] == '1';
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
                                                              "foto_dokumentasi"],
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
                                              (dataProgress[index]["pembimbing"]
                                                  ["nama"]),
                                          style: const TextStyle(
                                            color: Colors.grey,
                                            fontSize: 14,
                                          ),
                                        ),
                                  Text(
                                    DateFormat('dd MMMM yyyy', 'id_ID').format(
                                        DateTime.parse(
                                            dataProgress[index]["created_at"])),
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
                                    dataProgress[index]["foto_dokumentasi"],
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
