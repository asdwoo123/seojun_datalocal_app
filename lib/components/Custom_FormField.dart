import 'package:flutter/material.dart';

Widget CustomFormField({ password = false, double? circular, String hintText = '', number = false,
  double padding = 14.0, required TextEditingController controller, required onChange, required onPressed}) {
  return SizedBox(
    child: TextFormField(
      obscureText: password,
    keyboardType: (number) ? TextInputType.number : TextInputType.text,
    decoration: InputDecoration(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(circular ?? 24.0),
        borderSide: BorderSide(
          width: 0,
          style: BorderStyle.none
        )
      ),
      hintText: hintText,
      filled: true,
      fillColor: Colors.white,
      contentPadding: EdgeInsets.all(padding),
      suffixIcon: controller.text.isEmpty ? null : IconButton(
        onPressed: () {
          controller.clear();
          onPressed();
        }, icon: Icon(Icons.clear),
      ),
    ),
    controller: controller,
    onChanged: onChange,
  ),);
}
