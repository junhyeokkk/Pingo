import 'package:flutter/material.dart';

AppBar findIdAppBar(context) {
  return AppBar(
    title: Row(
      children: [
        Text(
          '아이디 찾기',
          style: TextStyle(fontSize: 20, color: Colors.black),
        ),
      ],
    ),
    backgroundColor: Colors.white,
    leading: IconButton(
      onPressed: () {
        Navigator.pop(context);
      },
      icon: Icon(Icons.arrow_back),
    ),
  );
}
