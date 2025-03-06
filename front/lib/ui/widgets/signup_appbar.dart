import 'package:flutter/material.dart';

AppBar signupAppBar(context, currentStep, _prevStep) {
  return AppBar(
    title: Row(
      children: [
        Text(
          '회원 가입',
          style: TextStyle(fontSize: 20, color: Colors.black),
        ),
      ],
    ),
    backgroundColor: Colors.white,
    leading: IconButton(
      onPressed: () {
        if (currentStep == 0 || currentStep > 6) {
          Navigator.pop(context);
        } else {
          _prevStep();
        }
      },
      icon: Icon(Icons.arrow_back),
    ),
  );
}
