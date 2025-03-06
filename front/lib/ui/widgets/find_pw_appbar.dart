import 'package:flutter/material.dart';

AppBar findPwAppBar(context) {
  return AppBar(
    title: Row(
      children: [
        Text(
          '비밀번호 찾기',
          style: TextStyle(fontSize: 20, color: Colors.black),
        ),
      ],
    ),
    backgroundColor: Colors.white,
    leading: IconButton(
      onPressed: () {
        Navigator.popUntil(context, (route) => route.isFirst);
      },
      icon: Icon(Icons.arrow_back),
    ),
  );
}
