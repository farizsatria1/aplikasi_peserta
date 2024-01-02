import 'package:flutter/material.dart';

class PopUpAbsensiPulang extends StatelessWidget {
  final TextEditingController password_pulang;
  final VoidCallback button_pulang;

  const PopUpAbsensiPulang({Key? key, required this.password_pulang, required this.button_pulang}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      actionsAlignment: MainAxisAlignment.center,
      actionsPadding: const EdgeInsets.symmetric(horizontal: 20,vertical: 20),
      backgroundColor: Colors.grey.shade300,
      title: const Row(
        children: [
          Icon(
            Icons.lock,
            color: Colors.black,
          ),
          SizedBox(height: 5),
          Text(
            'Password',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
      content: TextField(
        obscureText: true,
        controller: password_pulang,
        decoration: InputDecoration(
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey.shade400),
          ),
          filled: true,
          fillColor: Colors.grey.shade200,
          hintText: "Password Anda",
          hintStyle: TextStyle(
            color: Colors.grey.shade500,
          ),
        ),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      actions: <Widget>[
        ElevatedButton(
          style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20)),
          onPressed: button_pulang,
          child: const Text(
            "Submit",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        )
      ],
    );
  }
}
