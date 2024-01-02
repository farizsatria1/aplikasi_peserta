import 'package:absensi_magang/pages/Approve/widgets/list_approve.dart';
import 'package:absensi_magang/pages/Approve/widgets/list_progress.dart';
import 'package:flutter/material.dart';
import '../../Api/api.dart';
import '../../Widget/color.dart';

class Approve extends StatefulWidget {
  final int id;
  final String nama;

  const Approve({Key? key, required this.id, required this.nama}) : super(key: key);

  @override
  State<Approve> createState() => _ApproveState();
}

class _ApproveState extends State<Approve> {
  List<dynamic> listProgressAll = [];

  Future<void> getAllProgress() async {
    try {
      final response = await Api.getProgress(widget.id);
      setState(() {
        listProgressAll = response;
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    getAllProgress();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: AppColor.biru1,
        title: Text(widget.nama,
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        elevation: 0,
      ),
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            const TabBar(
              indicatorColor: Colors.black,
              labelColor: Colors.black,
              unselectedLabelColor: Colors.grey,
              tabs: [
                Tab(text: "Progress"),
                Tab(text: "Approve"),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  ListProgress(
                    listProgress: listProgressAll,
                    refresh: () async {
                      await Future.delayed(const Duration(seconds: 1));
                    },
                  ),
                  ListApprove(
                    listProgress: listProgressAll,
                    refresh: () async {
                      await Future.delayed(const Duration(seconds: 1));
                    },
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
